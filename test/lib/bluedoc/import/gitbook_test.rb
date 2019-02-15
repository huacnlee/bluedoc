# frozen_string_literal: true

require "test_helper"

class BlueDoc::Import::GitBookTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
    @user = create(:user)
  end

  test "valid_url?" do
    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "foo")
    assert_equal false, importer.valid_url?

    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "git@github.com:foo.git")
    assert_equal true, importer.valid_url?

    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "https://github.com/foo.git")
    assert_equal true, importer.valid_url?
  end

  test "perform" do
    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "foo")
    importer.stub(:valid_url?, false) do
      assert_raise("Invalid git url") { importer.perform }
    end
  end

  test "parse_title" do
    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "foo")

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

  test "upload_images" do
    local_path = Rails.root.join("test/factories/blank.png")
    importer = BlueDoc::Import::GitBook.new(repository: @repo, user: @user, url: "foo")

    body = "# hello [world](http://github.com)\n <img src='/aaa/bbb.jpg' /> this is bad file: ![](/foo/notfound) this is body ![](https://www.apple.com/ac/flags/1/images/cn/32.png)\n![](#{local_path})"
    importer.stub(:repo_dir, Rails.root.join("test").to_s) do
      BlueDoc::Blob.stub(:upload, "/uploads/foooo") do
        body = importer.upload_images(local_path, body)
        assert_match %([world](http://github.com)), body
        assert_match /\(\/uploads\/foooo\)/, body
        assert_match /<img src='\/uploads\/foooo' \/>/, body
      end
    end
  end
end
