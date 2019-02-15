# frozen_string_literal: true

module BlueDoc
  class Pipeline
    class PublicAttachmentsFilter < ::HTML::Pipeline::Filter
      def call
        file_host = Setting.host
        doc.search("img").each do |node|
          next if node["src"].blank?
          url = find_blob_url(node["src"])
          next if url.blank?

          node["src"] = url
        end

        doc.search("a.attachment-file").each do |node|
          next if node["href"].blank?
          next unless node["href"].start_with?("/uploads/")
          node["href"] = "#{file_host}#{node["href"]}"
        end
        doc
      end

      def find_blob_url(upload_path)
        m = /^\/uploads\/([\w\-_]+)/.match(upload_path)
        return nil if m.blank?
        blob_key = m[1].strip
        return nil if blob_key.blank?
        blob = ActiveStorage::Blob.find_by(key: blob_key)
        return nil if blob.blank?
        blob.service_url(expires_in: 10.years)
      end
    end
  end
end
