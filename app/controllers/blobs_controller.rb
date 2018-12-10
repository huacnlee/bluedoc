# frozen_string_literal: true

class BlobsController < ApplicationController
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    expires_in 7.days
    send_file_by_disk_key @blob, content_type: @blob.content_type
  rescue ActionController::MissingFile
    head :not_found
  end

  private

    def send_file_by_disk_key(blob, content_type:)
      case BookLab::Blob.service_name
      when "Disk"
        send_file BookLab::Blob.path_for(blob.key), type: content_type, disposition: blob_disposition, filename: @blob.filename
      else
        redirect_to service_url(@blob, params[:s])
      end
    end

    def service_url(blob, style = nil)
      Rails.cache.fetch("blobs/show#{blob.cache_key}#{style}", expires_in: 7.days) do
        case BookLab::Blob.service_name
        when "Aliyun"
          if style
            blob.service_url(disposition: blob_disposition, expires_in: 10.days, params: { "x-oss-process" => BookLab::Blob.process_for_aliyun(style) })
          else
            blob.service_url(disposition: blob_disposition, expires_in: 10.days)
          end
        else
          blob.service_url(expires_in: 7.days)
        end
      end
    end

    def set_blob
      @blob = Rails.cache.fetch("blobs:#{params[:id]}") { ActiveStorage::Blob.find_by(key: params[:id]) }
      head :not_found if @blob.blank?
    end

    def blob_disposition
      ActiveStorage.variable_content_types.include?(@blob.content_type) ? :inline : :attachment
    end
end
