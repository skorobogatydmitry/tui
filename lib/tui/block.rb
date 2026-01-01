# frozen_string_literal: true

require 'unicode/display_width'

require_relative 'format'
require_relative 'tools'

module Tui
  # Basic TUI building block.
  #
  # In a nutshell, all blocks are columns ({Block#column}) with {::String}s in it printed vertically one by one (see {#to_s}).
  # So a row is a way to compose multiple columns to a single "column" (see {Block#row}), which is an {::Array} of lines anyway.
  class Block

    attr_reader :width, :array

    # Mix-in formatting methods.
    # The {Blocks} class has only methods to make nested blocks
    include Format

    # Make a column with several rows in it. Rows could be other {Block}s or just {::String}s.
    #
    # The method actually transform array or "rows" to a single column right away.
    # @example
    #   Block.column "some", "other"                   # "some" and "other will be centered in the column by default
    #   Block.column "some", "other", align: :left     # "some" and "other" will be aligned to the left
    #   Block.column
    #     Block.row("one", "two"),
    #     "three"
    #   ]}                                             # "one" and "two" will be printed in the first row, "three" will be below them centered
    #   Block.column("some", "other") { |el| el.box! } # box both string then place boxes to a column
    #
    # @param rows array of rows ({Block}s / {::String}s)
    # @param align how to align blocks between each other: :center (default), :right, :left
    # @param block individual row processor, the block is supplied with {Block}s
    def self.column *rows, align: :center, &block
      # row could be a String, make an array of horizontal lines from it
      rows.collect! { |col| col.is_a?(Block) ? col : Block.new(col) }
      rows.collect!(&block) if block_given? # pre-process "rows"
      max_row_width = rows.collect(&:width).max
      Block.new rows.collect! { |blk|
        extra_columns = max_row_width - blk.width
        case align
        when :left then blk.collect! { |line| line + ' ' * extra_columns }
        when :right then blk.collect! { |line| ' ' * extra_columns + line }
        else
          blk.h_pad!(extra_columns / 2)
          extra_columns.odd? ? blk.collect! { |line| line + ' ' } : blk
        end
        blk.array # get the array to join using builtin flatten
      }.flatten!
    end

    # Compose a row of other {Block}s or {::String}s.
    #
    # The method actually squashes a row of columns (blocks) to a single block (column)
    # @example
    #   Block.row "some", "other"                         # => "someother"
    #   Block.row "some", ["other", "foo"], aligh: bottom # "some" will be shifted down by 1 line
    #   Block.row("some", "other") { |blk| blk.box! }     # both columns will be enclosed in a box
    #
    # @param cols array of columns ({Block}s / {::String}s) to squash
    # @param align how to align blocks in the row: :center, :top, :bottom
    # @param block individual column processor
    def self.row *cols, align: :center, &block
      cols.collect! { |col| col.is_a?(Block) ? col : Block.new(col) }
      cols.collect!(&block) if block_given? # pre-process columns
      max_col_height = cols.collect(&:height).max
      Block.new cols.collect! { |col|
        extra_lines = max_col_height - col.height
        case align
        when :top then col << Array.new(extra_lines, '')
        when :bottom then col >> Array.new(extra_lines, '')
        else
          col.v_pad!(extra_lines / 2)
          col << '' if extra_lines.odd?
        end
        col.v_align! # is needed due to transpose call below
        col.array # get the array to process using builtin methods
      }.transpose.collect(&:join)
    end

    # "Render" the Block to print to the console.
    # As each block and operation just transforms a list of Strings,
    # the whole "rendering" is as simple as ...
    def to_s
      @array.join "\n"
    end

    # Add extra lines from the supplied array to the block;
    # no auto-alignment is performed, see {#v_align!} to make width even
    # @param other either {::Array} or {::String} to push back
    def << other
      other.is_a?(Array) ? @array += other : @array << other
      @width = Tools.calc_width @array
      self
    end

    # Add extra lines to the "start" of the block
    # @param other either {::Array} or {::String} to push_forward
    # @example
    #   Block.column '1'
    #   block << %w[2 3] # now block has %w[2 3 1]
    def >> other
      case other
      when Array
        @width = [@width, Tools.calc_width(other)].max
        other.reverse_each { |i|
          @array.unshift i
        }
      when String
        @width = [@width, Tools.calc_width(other)].max
        @array.unshift other
      end
      self
    end

    # Get {Block}'s height in symbols
    # Block is a column => column's height is {Block}'s array size
    def height
      @array.size
    end

    # Modify each "row" of the {Block} inline
    def collect! &block
      @array.collect!(&block)
      @width = Tools.calc_width @array
    end

    private

    # Constructor is private.
    #
    # {#column} and {#row} are to make blocks;
    def initialize arg
      @array = case arg
               when Array then arg
               when String then [arg]
               else [arg.to_s]
               end
      @width = Tools.calc_width @array
    end
  end
end
