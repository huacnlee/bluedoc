# frozen_string_literal: true

require "uri"

module BlueDoc
  class Pipeline
    class PDFPreviewFilter < ::HTML::Pipeline::Filter
      def call
        doc.css(".attachment-file").each do |node|
          filename = node.css(".filename")&.text || ""
          ext = File.extname(filename.downcase)
          next if ext != ".pdf"

          href = node.attr("href")
          content = %(<embed src="#{href}" class="attachment-pdf-preview"></embed>)
          node.after(content)
        end
        doc
      end
    end
  end
end
