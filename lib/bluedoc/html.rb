# frozen_string_literal: true

require "html/pipeline"

module BlueDoc
  class HTML
    depends_on :mention_fragments

    def self.constantizePilelines(*pipelines)
      pipeline_classes = pipelines.map { |name| "BlueDoc::Pipeline::#{name.to_s.camelize}Filter".constantize }
      ::HTML::Pipeline.new(pipeline_classes)
    end

    MarkdownPileline = constantizePilelines(:normalize_mention, :markdown, :mention, :plantuml, :mathjax, :pdf_preview, :auto_correct)
    SmlPileline = constantizePilelines(:sml, :normalize_mention, :mention, :plantuml, :pdf_preview, :auto_correct)
    PublicAttachmentPipeline = constantizePilelines(:public_attachments)

    class << self
      # render html with BlueDoc HTML pilepine
      # opts:
      # - format: [html, markdown, sml]
      # - public: generate attachment for public
      def render(body, opts = {})
        return "" if body.blank?

        cache_version = opts[:format].to_s == "sml" ? "#{BlueDoc::SML::VERSION}/v1.2" : "v1.3"

        Rails.cache.fetch(["bluedoc/html", cache_version, Digest::MD5.hexdigest(body), opts]) do
          render_without_cache(body, opts)
        end
      end

      def render_without_cache(body, opts = {})
        opts[:format] ||= "html"

        result = case opts[:format].to_s
        when "sml"
          SmlPileline.call(body)[:output].inner_html
        when "markdown"
          MarkdownPileline.call(body)[:output].inner_html
        else
          body
        end

        result = public_attachment(result) if opts[:public]
        ::Sanitize.fragment(result, BlueDoc::Sanitize::DEFAULT)
      end

      private

      def public_attachment(body)
        PublicAttachmentPipeline.call(body)[:output].inner_html
      end
    end
  end
end
