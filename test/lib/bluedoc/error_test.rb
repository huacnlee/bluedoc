# frozen_string_literal: true

require "test_helper"

class BlueDoc::ErrorTest < ActiveSupport::TestCase
  test "track" do
    e = Exception.new("Hello world")

    assert_changes -> { ExceptionTrack::Log.count }, 1 do
      BlueDoc::Error.track(e, title: "This is title")
    end

    log = ExceptionTrack::Log.last
    assert_equal "This is title", log.title
    assert_match %(Hello world), log.body

    assert_changes -> { ExceptionTrack::Log.count }, 1 do
      BlueDoc::Error.track(e)
    end
    log = ExceptionTrack::Log.last
    assert_equal "Hello world", log.title
  end
end
