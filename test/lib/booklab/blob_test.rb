# frozen_string_literal: true

require "test_helper"

class BookLab::BlobTest < ActiveSupport::TestCase
  test "service_name" do
    assert_equal "Disk", BookLab::Blob.service_name
  end

  test "combine_options" do
    assert_equal({ thumbnail: "36x36^", gravity: "center", extent: "36x36" }, BookLab::Blob.combine_options(:tiny))
    assert_equal({ thumbnail: "64x64^", gravity: "center", extent: "64x64" }, BookLab::Blob.combine_options(nil))
    assert_equal({ thumbnail: "64x64^", gravity: "center", extent: "64x64" }, BookLab::Blob.combine_options(:small))
    assert_equal({ thumbnail: "96x96^", gravity: "center", extent: "96x96" }, BookLab::Blob.combine_options(:medium))
    assert_equal({ thumbnail: "440x440^", gravity: "center", extent: "440x440" }, BookLab::Blob.combine_options(:large))
    assert_equal({ resize: "1600>" }, BookLab::Blob.combine_options(:xlarge))
    # support string argument
    assert_equal({ resize: "1600>" }, BookLab::Blob.combine_options("xlarge"))

    # default use :small
    assert_equal({ thumbnail: "64x64^", gravity: "center", extent: "64x64" }, BookLab::Blob.combine_options("foo"))
  end

  test "process_for_aliyun" do
    assert_equal "image/resize,m_fill,w_64,h_64", BookLab::Blob.process_for_aliyun(nil)
    assert_equal "image/resize,m_fill,w_36,h_36", BookLab::Blob.process_for_aliyun(:tiny)
    assert_equal "image/resize,m_fill,w_64,h_64", BookLab::Blob.process_for_aliyun(:small)
    assert_equal "image/resize,m_fill,w_96,h_96", BookLab::Blob.process_for_aliyun(:medium)
    assert_equal "image/resize,m_fill,w_440,h_440", BookLab::Blob.process_for_aliyun(:large)
    assert_equal "image/resize,w_1600", BookLab::Blob.process_for_aliyun(:xlarge)
    assert_equal BookLab::Blob.process_for_aliyun(:xlarge), BookLab::Blob.process_for_aliyun("xlarge")
  end

  test "variation" do
    assert_not_nil BookLab::Blob.variation(:small)
  end

  test "path_for" do
    blob = create(:blob)
    assert_equal ActiveStorage::Blob.service.send(:path_for, blob.key), BookLab::Blob.path_for(blob.key)
  end
end
