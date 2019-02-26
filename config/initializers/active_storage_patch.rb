# frozen_string_literal: true

# Override ActiveStorage DiskService service_url method to generate custom controller path
module ActiveStorageDiskServiceURL
  def url(key, expires_in:, filename:, disposition:, content_type:)
    "#{Setting.host}/uploads/#{key}"
  end
end

# Override S3 service for public-read ACL upload and url generate
module ActiveStorageS3ServiceURL
  # def url(key, expires_in:, filename:, disposition:, content_type:)
  #   object_for(key).public_url
  # end

  def upload(key, io, checksum: nil, **)
    instrument :upload, key: key, checksum: checksum do
      begin
        object_for(key).put(upload_options.merge(body: io, content_md5: checksum, cache_control: "max-age=#{300.days}"))
      rescue Aws::S3::Errors::BadDigest
        raise ActiveStorage::IntegrityError
      end
    end
  end

  def url_for_direct_upload(key, expires_in:, content_type:, content_length:, checksum:)
    instrument :url, key: key do |payload|
      generated_url = object_for(key).presigned_url :put, expires_in: expires_in.to_i,
        content_type: content_type, content_length: content_length, content_md5: checksum, cache_control: "max-age=#{300.days}"

      payload[:url] = generated_url

      generated_url
    end
  end
end

require "active_storage/service/disk_service"
require "active_storage/service/s3_service"

ActiveStorage::Service::DiskService.send(:prepend, ActiveStorageDiskServiceURL)
ActiveStorage::Service::S3Service.send(:prepend, ActiveStorageS3ServiceURL)
