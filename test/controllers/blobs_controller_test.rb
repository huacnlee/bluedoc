require 'test_helper'

class BlobsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @blob = create(:blob)
    @filename = BookLab::Blob.path_for(@blob.key)
    FileUtils.mkdir_p File.dirname(@filename)
    FileUtils.copy_file Rails.root.join("test/factories/blank.png"), @filename
  end

  teardown do
    FileUtils.rm_f @filename
  end

  test "GET /blobs/:id" do
    assert_equal false, @blob.new_record?

    get upload_path(@blob.key)
    assert_equal 200, response.status
    assert_equal @blob.content_type, response.content_type
  end

  test "GET /blobs/:id?s=small" do
    get upload_path(@blob.key, s: :small)

    variation_key = BookLab::Blob.variation(:small)
    assert_equal 200, response.status
    assert_equal @blob.content_type, response.content_type

    BookLab::Blob.stub(:disk_service?, false) do
      get upload_path(@blob.key, s: :small)
      assert_redirected_to @blob.representation(variation_key).processed.service_url
    end
  end
end
