# frozen_string_literal: true

module Tui
  # Collection of low-level {Block} formatting methods.
  #
  # Most methods
  # - mutate the object they are called for => no need to re-assign
  # - `return self` => are intended to be chained (`block.box!.v_pad!(2)`)
  #
  # The module is not to be used directly
  # and exists just to de-couple formatting methods from the rest.
  module Format

    # Add horizontal (to the sides) padding to the block.
    # @param size number of spaces to add
    def h_pad! size = 1
      collect! { |line|
        "#{' ' * size}#{line}#{' ' * size}"
      }
      @width += size * 2
      self
    end

    # Add vertical padding (before-after) to the block
    # @param size number of spaces to add
    def v_pad! size = 1
      filler = ' ' * @width
      size.times {
        self >> filler
        self << filler
      }
      self
    end

    # Adds spaces around the block
    # @param size number of spaces to add
    def pad! size = 1
      # order matters!
      v_pad! size
      h_pad! size
    end

    # Aligns block elements vertically (by width) by adding spaces.
    #
    # Lines (rows) within the block can be of uneven width.
    # This method changes all lines to have the same # of chars
    # @param type {Symbol} :left, :center, :right
    # @param width {Integer} target block width, is ignored if less than @width (look at {fit!})
    def v_align! type = :left, width: @width
      line_transformer = case type
                         when :center
                           ->(line, num_spaces) { ' ' * (num_spaces / 2) + line.to_s + (' ' * (num_spaces / 2)) + (num_spaces.odd? ? ' ' : '') }
                         when :right
                           ->(line, num_spaces) { (' ' * num_spaces) + line.to_s }
                         else # :left
                           ->(line, num_spaces) { line.to_s + (' ' * num_spaces) }
                         end

      return self if width.nil? || @width > width # == case makes all lines width even

      @width = width
      @array.collect! { |line| line_transformer.call line, @width - Tools.calc_width(line) }
      self
    end

    # Aligns block elements horisontally (by height) by adding spaces.
    #
    # New lines get added to the block to have the specified # of lines in total.
    # @param type {Symbol} :top, :center, :bottom
    # @param height {Integer} target block height, is ignored if less than @width (look at {fit!})
    def h_align! type = :top, height: @height
      return self if height.nil? || @array.size > height

      extra_lines_count = height - @array.size
      case type
      when :center
        (extra_lines_count/2).times { @array.prepend ' ' * @width }
        (extra_lines_count/2 + (extra_lines_count.odd? ? 1 : 0)).times { @array.append ' ' * @width }
      when :top
        (extra_lines_count).times { @array.append ' ' * @width }
      else # :bottom
        (extra_lines_count).times { @array.prepend ' ' * @width }
      end

      self
    end

    # Align content to the center of the specified width and height.
    #
    # @param height {Number} target height
    # @param width {Number} target width
    def align! height: nil, width: nil
      v_align! :center, width: width
      h_align! :center, height: height
    end

    # Add a square box around the block.
    #
    # It auto-aligns the block, so use {v_align!} beforehand!
    # if you want custom alignment for the block
    def box! corners: :round
      corners = Assets::CORNERS[corners]
      lines = Assets::LINES[:single]
      v_align!
      @array.collect! { |line| "#{lines[0]}#{line}#{lines[0]}" }
      @array.unshift "#{corners[0]}#{lines[1] * width}#{corners[1]}"
      @array << "#{corners[2]}#{lines[1] * width}#{corners[3]}"
      @width += 2
      self
    end

    # Fit the current block to a rectangle by
    # cropping the block and adding a special markers to its content.
    #
    # Actual content width and height will be 1 char less to store cropping symbols too.
    #
    # Filling does not align content, {v_align!} does.
    #
    # @param width width to fit, nil => don't touch width
    # @param height height to fit, nil =>  don't touch height
    # @param fill whether to fill {Block} to be of the size of the box
    def fit! width: nil, height: nil, fill: false
      # pre-calc width to use below
      @width = width unless width.nil? || (@width < width && !fill)

      unless height.nil?
        if @array.size > height
          @array.slice!((height - 1)..)
          @array << ('░' * @width)
        elsif fill && @array.size < height
          @array += Array.new(height - @array.size, ' ' * @width)
        end
      end
      unless width.nil?
        collect! { |line|
          if line.size > width
            "#{line[...(width - 1)]}░"
          elsif fill && line.size < width
            extra = (width - line.size)
            "#{' ' * (extra/2)}#{line}#{' ' * (extra/2 + (extra.odd? ? 1 : 0))}"
          else
            line
          end
        }
      end
      self
    end

  end
end
