# frozen_string_literal: true

class BlobsController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    send_file_by_disk_key @blob, content_type: @blob.content_type
  rescue ActionController::MissingFile
    head :not_found
  end

  private

    def send_file_by_disk_key(blob, content_type:)
      case BookLab::Blob.service_name
      when "Disk"
        expires_in 2.weeks
        send_file BookLab::Blob.path_for(blob.key), type: content_type, disposition: blob_disposition, filename: @blob.filename
      when "Aliyun"
        expires_in 10.minutes
        if params[:s]
          redirect_to blob.service_url(disposition: blob_disposition, expires_in: 1.days, params: { "x-oss-process" => BookLab::Blob.process_for_aliyun(params[:s]) })
        else
          redirect_to blob.service_url(disposition: blob_disposition, expires_in: 1.days)
        end
      else
        expires_in 10.minutes
        redirect_to blob.service_url(expires_in: 1.days)
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
