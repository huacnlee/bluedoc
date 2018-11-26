# frozen_string_literal: true

class BlobsController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    expires_in 10.minutes
    send_file_by_disk_key @blob, content_type: @blob.content_type
  rescue ActionController::MissingFile
    head :not_found
  end

  private

    def send_file_by_disk_key(blob, content_type:)
      case BookLab::Blob.service_name
      when "Disk"
        send_file BookLab::Blob.path_for(blob.key), type: content_type, disposition: :inline
      when "Aliyun"
        if params[:s]
          redirect_to blob.service_url(expires_in: 1.weeks, params: { "x-oss-process" => BookLab::Blob.process_for_aliyun(params[:s]) })
        else
          redirect_to blob.service_url(expires_in: 1.weeks)
        end
      else
        redirect_to blob.service_url(expires_in: 1.weeks)
      end
    end

    def set_blob
      @blob = Rails.cache.fetch("blobs:#{params[:id]}") { ActiveStorage::Blob.find_by(key: params[:id]) }
      head :not_found if @blob.blank?
    end
end
