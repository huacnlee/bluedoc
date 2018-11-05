class BlobsController < ApplicationController
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    expires_in 3.days
    if params[:s]
      variation_key = BookLab::Blob.variation(params[:s])
      send_file_by_disk_key @blob.representation(variation_key).processed, content_type: @blob.content_type
    else
      send_file_by_disk_key @blob, content_type: @blob.content_type
    end
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
      @blob = ActiveStorage::Blob.find_by(key: params[:id])
      head :not_found if @blob.blank?
    end
end
