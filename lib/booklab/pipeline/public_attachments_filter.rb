# frozen_string_literal: true

module BookLab
  class Pipeline
    class PublicAttachmentsFilter < HTML::Pipeline::Filter
      def call
        doc.search("img").each do |node|
          next if node['src'].blank?
          key = find_blob_key(node["src"])
          next if key.blank?

          blob = ActiveStorage::Blob.find_by(key: key)
          next if blob.blank?
          url = blob.service_url(expires_in: 10.years)
          node["src"] = url
        end
        doc
      end

      def find_blob_key(url)
        m = /^\/uploads\/([\w\-_]+)/.match(url)
        return nil if m.blank?
        m[1].strip
      end
    end
  end
end