# frozen_string_literal: true

require "test_helper"

class BlueDoc::Export::ArchiveTest < ActiveSupport::TestCase
  setup do
    @repo = create(:repository)
  end

  test "downlod_images" do
    file0 = load_file("blank.png")

    file_url0 = BlueDoc::Blob.upload(file0.path)
    file_url1 = BlueDoc::Blob.upload(file0.path)
    file_key1 = file_url1.match(/uploads\/([\w]+)/)[1]

    body = <<~MD
    #{file_url0}

    ![](/uploads/)

    ![](#{file_url0})

    ![](#{file_url1})

    ![](https://www.google.com.hk/test.png)
    MD

    body_html = BlueDoc::HTML.render(body, format: :markdown)

    exporter = BlueDoc::Export::Archive.new(repository: @repo)

    expected = <<~MD
    ./images/blank.png

    ![](/uploads/)

    ![](./images/blank.png)

    ![](./images/#{file_key1}.png)

    ![](https://www.google.com.hk/test.png)
    MD
    assert_equal expected, exporter.send(:downlod_images, body, body_html)

    images_dir = File.join(exporter.repo_dir, "images")
    assert_equal true, File.exist?(File.join(images_dir, "blank.png"))
    assert_equal file0.size, File.size(File.join(images_dir, "blank.png"))

    assert_equal true, File.exist?(File.join(images_dir, "#{file_key1}.png"))
    assert_equal file0.size, File.size(File.join(images_dir, "#{file_key1}.png"))
  end
end
