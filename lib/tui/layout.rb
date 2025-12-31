require_relative 'block'

# Main window layout.
#
# It represents the main window of the application's TUI
class Tui::Layout
  # Internal content is expected to be rendered each time => should be callable
  # @example
  #   Tui::Layout.new { Block.column "foo", "bar" }
  def initialize &block
    @root = block || -> { Tui::Block::column "Hello TUI!" }
  end

  # Render content to produce a frame, which could be print -ed.
  def render
    box = @root.call
    raise "main window is not a block but #{box.class}" unless box.is_a? Tui::Block

    box
  end
end
