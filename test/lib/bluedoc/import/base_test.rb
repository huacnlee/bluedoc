# frozen_string_literal: true

require "test_helper"

class BlueDoc::Import::BaseTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
    @user = create(:user)
  end

  test "Base" do
    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "foo bar")
    assert_equal "foobar", importer.url
    assert_equal Rails.root.join("tmp", "BlueDoc::Import::GitBook"), importer.tmp_path
    assert_equal true, Dir.exists?(importer.tmp_path)
    assert_equal File.join(importer.tmp_path, Digest::MD5.hexdigest(importer.url)), importer.repo_dir
    assert_equal @repo, importer.repository
    assert_equal @user, importer.user

    assert_equal Rails.logger, importer.logger

    importer = BlueDoc::Import::Archive.new(repository: @repo, user: @user, url: "foo bar")
    assert_equal Rails.root.join("tmp", "BlueDoc::Import::Archive"), importer.tmp_path

    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "'rm -rf /'")
    assert_equal "rm-rf/", importer.url
  end

  test "execute" do
    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "foo")
    assert_raise(Errno::ENOENT) do
      importer.execute("not-exist-command")
    end

    assert_raise(RuntimeError) do
      importer.execute("echo 'stderr' >&2 && exit 1")
    end

    assert_equal "Hello", importer.execute("echo 'Hello'").strip
  end
end
