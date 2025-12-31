# frozen_string_literal: true

module Tui; end

require 'date'
require 'io/console'


require_relative 'tui/assets'
require_relative 'tui/block'
require_relative 'tui/format'
require_relative 'tui/layout'
require_relative 'tui/settings'

##
# Root module / singleton. See {Tui#run} - the main entrypoint.
module Tui
  # Delay correction step to maintain FPS
  DELAY_STEP_MS = 100

  # Frames counter to calculate average FPS
  @frames_count = 0

  class << self

    # Current delay between redraws
    attr_reader :delay_ms
    # Average redraws count / sec
    attr_reader :current_avg_fps

    ##
    # The main entrypoint of the TUI
    # @param layout {Tui::Layout} - UI's layout to render and draw
    # @param settings {Tui::Settings} - UI's settings that affects UI's behavior
    # @return {Thread}
    def run layout, settings = Settings::new
      raise "expected Layout, found #{layout.class}" unless layout.is_a? Layout

      @settings = settings
      @started_at = DateTime.now.strftime('%Q').to_i
      @delay_ms = 1000 / @settings.target_fps

      @thread = Thread.new {
        loop {
          clear
          refresh
          print @settings.draw_main_window ?
            layout.render
                .align!(**effective_window_size)
                .fit!(**effective_window_size, fill: true)
                .box!
            : layout.render

          sleep @delay_ms / 1000.0
        }
      }

      @thread
    end

    private

    def clear
      print "\e[2J\e[f"
    end

    # Refresh terminal size and adjust delay
    def refresh
      ms_spent = 1 + DateTime.now.strftime('%Q').to_i - @started_at

      @current_avg_fps = @frames_count * 1000.0 / ms_spent

      # TODO: use progression
      if @settings.target_fps > @current_avg_fps && @delay_ms > DELAY_STEP_MS
        @delay_ms -= DELAY_STEP_MS
      end

      if @settings.target_fps < @current_avg_fps && @delay_ms < 1000
        @delay_ms += DELAY_STEP_MS
      end

      @frames_count += 1;
    end

    # Calculate actual content size from settings and available terminal's shape
    def effective_window_size
      {
        height: (IO.console&.winsize&.first.nil? || @settings.window_size[:height] < IO.console.winsize.first ? @settings.window_size[:height] : IO.console.winsize.first) - 4,
        width: (IO.console&.winsize&.last.nil? || @settings.window_size[:width] < IO.console.winsize.last ? @settings.window_size[:width] : IO.console.winsize.last) - 2
      }
    end

  end
end
