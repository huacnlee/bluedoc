# frozen_string_literal: true

FactoryBot.define do
  factory :blob, class: "ActiveStorage::Blob" do
    key { SecureRandom.uuid }
    filename { "test.png" }
    content_type { "image/png" }
    byte_size { 100 }
    checksum { SecureRandom.base64 }
  end
end
