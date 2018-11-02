class BlobsController < ApplicationController
  before_action :require_disk_service!
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    expires_in 1.week
    if params[:s]
      variation_key = BookLab::Blob.variation(params[:s])
      send_file_by_disk_key @blob.representation(variation_key).processed.key, content_type: @blob.content_type
    else
      send_file_by_disk_key @blob.key, content_type: @blob.content_type
    end
  end

  private

    def send_file_by_disk_key(key, content_type: )
      send_file BookLab::Blob.path_for(key), type: content_type, disposition: :inline
    end

    def set_blob
      @blob = ActiveStorage::Blob.find_by(key: params[:id])
      head :not_found if @blob.blank?
    end

    def require_disk_service!
      head :not_found unless BookLab::Blob.disk_service?
    end
end
