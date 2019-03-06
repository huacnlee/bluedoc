# frozen_string_literal: true

class BlobsController < ActiveStorage::BaseController
  before_action :set_blob

  # GET /uploads/:id
  # GET /uploads/:id?s=large
  def show
    send_file_by_disk_key @blob, content_type: @blob.content_type
  rescue ActionController::MissingFile, ActiveStorage::FileNotFoundError
    head :not_found
  rescue ActiveStorage::IntegrityError
    head :unprocessable_entity
  end

  private

    def disk?
      BlueDoc::Blob.service_name == "Disk"
    end

    def send_file_by_disk_key(blob, content_type:)
      if disk?
        expires_in 100.days

        blob_key = blob.key

        # Process image thumb when params[:s] given, to get a blob_key like: "variants/0uavxgum7j4r63pwcc3q443vqhfu/10d4e6731e902108be27818bfbb7b760bac6df85d9578ddb35096d2102c0bd89"
        if params[:s]
          blob_key = @blob.representation(BlueDoc::Blob.variation(params[:s])).processed.key
        end

        send_file BlueDoc::Blob.path_for(blob_key), type: content_type, disposition: blob_disposition, filename: @blob.filename.to_s
      else
        expires_in 10.hours
        redirect_to service_url(@blob, params[:s]), allow_other_host: true
      end
    end

    def service_url(blob, style = nil)
      Rails.cache.fetch("blobs/show#{blob.cache_key}#{style}/v4", expires_in: 11.hours) do
        scope = blob

        # Resize image
        if style
          scope = scope.variant(BlueDoc::Blob.variation(style)).processed
        end

        expires_in = 7.days
        case BlueDoc::Blob.service_name
        when "Aliyun"
          # Aliyun OSS limit that url max age: 64800s
          # ref: https://help.aliyun.com/document_detail/31952.html
          expires_in = 12.hours
        end

        scope.service_url(disposition: blob_disposition, expires_in: expires_in)
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
