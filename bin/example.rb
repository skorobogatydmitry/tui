#!/usr/bin/env ruby

# load the gem, it should be just `require 'tui'` in your program
require_relative "../lib/tui"

# That's how you can override settings for the TUI,
# see {Tui::Settings} for all available settings
settings = Tui::Settings::new(
  target_fps: 2,
  window_size: { height: 50, width: 70 }
)

# Define page's layout. This example shows a main box window 50x70 with content.
# The top box has just a static greeting message, the other one has 2 columns: with FPS and delay between redraws.
layout = Tui::Layout::new { # it's important that the content is a block, so it gets re-rendered on every redraw
  Tui::Block.column( # The main window has 1 column with 2 rows
    "Greetings, {username}!", # 1st row - just a greeting message
    Tui::Block::row( # 2nd row
      "FPS: #{Tui.current_avg_fps}", # 2nd row, 2st column - FPS info
      Tui::Block::column("Refresh delay (ms)", Tui.delay_ms) # 2nd row, 2nd column - own column with message and a number
    ) { |col| col # Transformations for each inner Block of the parent one. In this case - columns of the 2nd row
      .fit!(width: 20, fill: true) # FPS number length varies, let's fit it to a block so interface doesn't "jump" (try to move this line below `box!`)
      .pad!(1) # add 1 symbol around the content of the column
      .box! # outline padded content with a box
      .h_pad!(1) # add 1 more space to the left and right sides
    }) { |row| row.h_pad!(1).box! } # horizontal padding for the greeting and the rest
}

# Now start the UI
# This example doesn't have anything to do on its own,
# so we're waiting on UI thread
Tui::run(layout, settings).join
