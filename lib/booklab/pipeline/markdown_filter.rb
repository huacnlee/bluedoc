# frozen_string_literal: true

require "redcarpet"
require "rouge/plugins/redcarpet"
require "nokogiri"

module BookLab
  class Pipeline
    class MarkdownFilter < ::HTML::Pipeline::TextFilter
      DEFAULT_OPTIONS = {
        no_styles: true,
        hard_wrap: true,
        autolink: false,
        fenced_code_blocks: true,
        strikethrough: true,
        underline: true,
        superscript: true,
        footnotes: true,
        highlight: false,
        tables: true,
        lax_spacing: true,
        space_after_headers: true,
        disable_indented_code_blocks: true,
        no_intra_emphasis: true
      }

      def call
        html = Render.renderer.render(@text)
        html.strip!
        html
      end

      class Render < Redcarpet::Render::HTML
        include Rouge::Plugins::Redcarpet

        def header(text, header_level)
          raw_text = Nokogiri::HTML(text).xpath("//text()").to_s

          title_length = raw_text.length
          min_length = title_length * 0.3
          words_length = /[a-z0-9]/i.match(raw_text)&.length || 0

          header_id = raw_text.gsub(/[^a-z0-9]+/i, "-").downcase
          if title_length - header_id.length > min_length
            header_id = Digest::MD5.hexdigest(raw_text)[0..8]
          end

          %(<h#{header_level} id="#{header_id}"><a href="##{header_id}" class="heading-anchor">#</a>#{raw_text}</h#{header_level}>)
        end

        def link(link, title, content)
          link ||= ""
          if link.include?("/uploads/")
            %(<a class="attachment-file" href="#{link}" title="#{title}" target="_blank">#{content}</a>)
          else
            %(<a href="#{link}">#{content}</a>)
          end
        end

        class << self
          def renderer
            @renderer ||= Redcarpet::Markdown.new(self.new, DEFAULT_OPTIONS)
          end
        end
      end
    end
  end
end
