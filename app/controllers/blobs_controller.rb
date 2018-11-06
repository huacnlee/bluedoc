class BlobsController < ApplicationController
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    expires_in 3.days
    send_file_by_disk_key @blob, content_type: @blob.content_type
  rescue ActionController::MissingFile
    head :not_found
  end

  private

    def send_file_by_disk_key(blob, content_type: )
      if BookLab::Blob.disk_service?
        send_file BookLab::Blob.path_for(blob.key), type: content_type, disposition: :inline
      else
        redirect_to blob.service_url(expires_in: 1.weeks)
      end
    end

    def set_blob
      @blob = Rails.cache.fetch("blobs:{params:id}") { ActiveStorage::Blob.find_by(key: params[:id]) }
      head :not_found if @blob.blank?
    end
end
