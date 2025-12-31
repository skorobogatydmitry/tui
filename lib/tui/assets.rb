# frozen_string_literal: true

# Static assets to draw boxes.
# Are used mainly in {Format#box!}
module Tui::Assets
  CORNERS = {
    sharp: '┏┓┗┛',
    round: '╭╮╰╯'
  }.freeze
  LINES = {
    single: '│─'
  }.freeze
end
