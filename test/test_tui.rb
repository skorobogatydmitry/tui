# frozen_string_literal: true

require "test_helper"

class TestTui < Minitest::Test
  # check that Tui demands payload to be set
  def test_it_fails_without_payload
    assert_raises "expected Layout, found NilClass" do
      Tui::run nil
    end
  end

  # simply check a dummy application runs
  def test_basic_app_runs
    the_greeting = "greetings, traveler"
    Tui::run(
      Tui::Layout::new { Tui::Block::column the_greeting },
      Tui::Settings::new(window_size: { height: 1, width: the_greeting.size }, draw_main_window: false)
    ).kill
  end
end
