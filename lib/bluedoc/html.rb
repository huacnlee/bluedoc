# frozen_string_literal: true

require "html/pipeline"

module BlueDoc
  class HTML
    depends_on :mention_fragments

    def self.constantizePilelines(*pipelines)
      pipelineClasses = pipelines.map { |name| "BlueDoc::Pipeline::#{name.to_s.camelize}Filter".constantize }
      ::HTML::Pipeline.new(pipelineClasses)
    end

    MarkdownPileline = constantizePilelines(:normalize_mention, :markdown, :mention, :plantuml, :mathjax, :auto_correct)
    SmlPileline = constantizePilelines(:sml, :normalize_mention, :mention, :plantuml, :auto_correct)
    PublicAttachmentPipeline = constantizePilelines(:public_attachments)

    class << self
      # render html with BlueDoc HTML pilepine
      # opts:
      # - format: [html, markdown, sml]
      # - public: generate attachment for public
      def render(body, opts = {})
        return "" if body.blank?

        cache_version = opts[:format].to_s == "sml" ? "#{BlueDoc::SML::VERSION}/v1.1" : "v1.1"

        Rails.cache.fetch(["bluedoc/html", cache_version, Digest::MD5.hexdigest(body), opts]) do
          render_without_cache(body, opts)
        end
      end

      def render_without_cache(body, opts = {})
        opts[:format] ||= "html"

        case opts[:format].to_s
        when "sml"
          result = SmlPileline.call(body)[:output].inner_html
        when "markdown"
          result = MarkdownPileline.call(body)[:output].inner_html
        else
          result = body
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
