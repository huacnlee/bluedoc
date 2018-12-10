# frozen_string_literal: true

require "test_helper"

class ActiveStorage::BlobTest < ActiveSupport::TestCase
  test "service_url with :disk" do
    blob = create(:blob)
    assert_equal "#{Setting.host}/uploads/#{blob.key}", blob.service_url
  end
end