# frozen_string_literal: true

require "test_helper"

class SlugableTest < ActiveSupport::TestCase
  setup do
    @doc = create(:doc)
  end

  test "find_by_slug / find_by_slug!" do
    assert_equal @doc, Doc.where(repository_id: @doc.repository_id).find_by_slug(@doc.slug)
    assert_nil Doc.where(repository_id: @doc.repository_id).find_by_slug("not-exist")

    assert_equal @doc, Doc.where(repository_id: @doc.repository_id).find_by_slug!(@doc.slug)
    assert_raise(ActiveRecord::RecordNotFound) do
      Doc.where(repository_id: @doc.repository_id).find_by_slug!("not-exist")
    end
  end

  test "to_url" do
    assert_equal "#{Setting.host}#{@doc.to_path}", @doc.to_url
    assert_equal "#{Setting.host}#{@doc.to_path}#comment-123", @doc.to_url(anchor: "comment-123")
  end
end
