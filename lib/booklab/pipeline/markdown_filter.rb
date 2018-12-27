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
        include ActionView::Helpers::NumberHelper

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
          content ||= ""
          if link.include?("/uploads/") || content.include?("download:")
            content = content.gsub("download:", "").strip

            size = ""
            if title && title =~ /size:(\d+)/
              size = number_to_human_size(Regexp.last_match(1) || 0)
            end

            %(<a class="attachment-file" title="#{content}" target="_blank" href="#{link}">
                <span class="icon-box"><i class="fas fa-file"></i></span>
                <span class="filename">#{content}</span>
                <span class="filesize">#{size}</span>
            </a>)
          else
            %(<a href="#{link}">#{content}</a>)
          end
        end

        # Extend to support img width
        # ![](foo.jpg | width=300)
        # ![](foo.jpg | height=300)
        # ![](foo.jpg =300x200)
        # Example: https://gist.github.com/uupaa/f77d2bcf4dc7a294d109
        def image(link, title, alt_text)
          link ||= ""
          links = link.split(" ")
          link = links[0]
          if links.count > 1
            # Original markdown title part need "": ![](foo.jpg "Title")
            # ![](foo.jpg =300x)
            title = links.last
          end

          if title =~ /width=(\d+)/
            %(<img src="#{link}" width="#{Regexp.last_match(1)}" alt="#{alt_text}">)
          elsif title =~ /height=(\d+)/
            %(<img src="#{link}" height="#{Regexp.last_match(1)}" alt="#{alt_text}">)
          elsif title =~ /=(\d+)x(\d+)/
            %(<img src="#{link}" width="#{Regexp.last_match(1)}" height="#{Regexp.last_match(2)}" alt="#{alt_text}">)
          else
            %(<img src="#{link}" alt="#{alt_text}">)
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
