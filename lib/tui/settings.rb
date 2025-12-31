# Settings for the TUI.
#
# - target_fps - how frequently you want the content to refresh. It's useful to control CPU, console I/O and data fetching usage
# - window_size - size of the main window, e.g. `{ height: 70, width: 200 }`
# - draw_main_window - whether to fit content in a box and center it by default within window
Tui::Settings = Data.define(:target_fps, :window_size, :draw_main_window) do
  def initialize(
    target_fps: 30,
    window_size: { height: 70, width: 200 }.freeze,
    draw_main_window:  true)
      super(target_fps:, window_size:, draw_main_window:)
  end
end
