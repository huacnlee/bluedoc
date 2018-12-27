# frozen_string_literal: true

require "test_helper"

class BookLab::Import::ArchiveTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
    @user = create(:user)
  end

  test "perform" do
    importer = BookLab::Import::Archive.new(repository: @repo, user: @user, url: "foo")
    importer.stub(:valid_url?, false) do
      assert_raise("Invalid git url") { importer.perform }
    end
  end
end
