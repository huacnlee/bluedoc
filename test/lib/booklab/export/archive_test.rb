# frozen_string_literal: true

require "test_helper"

class BookLab::Export::ArchiveTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
  end

  test "public_attachment" do
    body = "/uploads/foo ![](/uploads/foo) ![](/aaa/bbb)"
    exporter = BookLab::Export::Archive.new(repository: @repo)
    assert_equal "/uploads/foo ![](#{Setting.host}/uploads/foo) ![](/aaa/bbb)", exporter.send(:public_attachment, body)
  end
end