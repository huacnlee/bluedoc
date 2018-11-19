# frozen_string_literal: true

require "test_helper"

class BookLab::Import::GitBookTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
    @user = create(:user)
  end


  test "valid_url?" do
    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "foo")
    assert_equal false, importer.valid_url?

    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "git@github.com:foo.git")
    assert_equal true, importer.valid_url?

    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "https://github.com/foo.git")
    assert_equal true, importer.valid_url?
  end

  test "base" do
    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "foo bar")
    assert_equal "foobar", importer.git_url
    assert_equal "foobar", importer.url
    assert_equal @repo, importer.repository
    assert_equal @user, importer.user

    assert_equal Rails.logger, importer.logger

    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "'rm -rf /'")
    assert_equal "rm-rf/", importer.url
    assert_equal "rm-rf/", importer.git_url
  end

  test "perform" do
    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "foo")
    importer.stub(:valid_url?, false) do
      assert_raise("Invalid git url") { importer.perform }
    end
  end

  test "parse_title" do
    importer = BookLab::Import::GitBook.new(repository: @repo, user: @user, url: "foo")

    body = "# hello world\nthis is body"
    res = importer.parse_title(body)
    assert_equal "hello world", res[:title]
    assert_equal "this is body", res[:body]

    body = <<~BODY
    Hello world
    -----------
    This is body
    BODY
    res = importer.parse_title(body)
    assert_equal "Hello world", res[:title]
    assert_equal body, res[:body]
  end
end