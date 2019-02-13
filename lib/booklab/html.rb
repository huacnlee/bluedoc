# frozen_string_literal: true

require "html/pipeline"

module BookLab
  class HTML
    depends_on :mention_fragments

    def self.constantizePilelines(*pipelines)
      pipelineClasses = pipelines.map { |name| "BookLab::Pipeline::#{name.to_s.camelize}Filter".constantize }
      ::HTML::Pipeline.new(pipelineClasses)
    end

    MarkdownPileline = constantizePilelines(:normalize_mention, :markdown, :mention, :plantuml, :mathjax)
    SmlPileline = constantizePilelines(:sml, :plantuml)
    PublicAttachmentPipeline = constantizePilelines(:public_attachments)

    class << self
      # render html with BookLab HTML pilepine
      # opts:
      # - format: [html, markdown, sml]
      # - public: generate attachment for public
      def render(body, opts = {})
        return "" if body.blank?

        Rails.cache.fetch(["booklab/html", "v1", Digest::MD5.hexdigest(body), opts]) do
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
        ::Sanitize.fragment(result, BookLab::Sanitize::DEFAULT)
      end

      private
        def public_attachment(body)
          PublicAttachmentPipeline.call(body)[:output].inner_html
        end
    end
  end
end
