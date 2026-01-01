# frozen_string_literal: true

# Various functions
module Tui::Tools
  # Calculate width of a line / array of lines on console.
  #
  # Code mainains width by +/- operations in the most cases,
  # but sometimes it needs re-calculating it from scratch
  def self.calc_width value
    case value
    when Array then val.collect { |row| Unicode::DisplayWidth.of(row) }.max
    when String then Unicode::DisplayWidth.of(val)
    end
  end
end
