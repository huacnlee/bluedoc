# frozen_string_literal: true

require "commonmarker"
require "nokogiri"
require "rouge"

module BlueDoc
  class Pipeline
    class MarkdownFilter < ::HTML::Pipeline::TextFilter
      def call
        doc = CommonMarker.render_doc(@text, [:DEFAULT, :UNSAFE, :FOOTNOTES], [:tagfilter, :autolink, :table, :strikethrough])
        html = Render.new(options: [:DEFAULT, :UNSAFE]).render(doc)
        html.strip!
        html
      end

      class Render < CommonMarker::HtmlRenderer
        include ActionView::Helpers::NumberHelper

        class << self
          def renderer
            @renderer ||= new
          end
        end

        def header(node)
          raw_text = node.to_plaintext

          title_length = raw_text.length
          min_length = title_length * 0.3

          header_id = raw_text.gsub(/[^a-z0-9]+/i, "-").downcase.gsub(/^-|-$/, "")
          if title_length - header_id.length > min_length
            header_id = Digest::MD5.hexdigest(raw_text.strip)[0..8]
          end

          block do
            out(
              %(<h#{node.header_level} id="#{header_id}">),
              %(<a href="##{header_id}" class="heading-anchor">#</a>),
              :children,
              %(</h#{node.header_level}>)
            )
          end
        end

        def link(node)
          link = node.url || ""
          content = node.to_plaintext || ""
          title = node.title || ""

          if link.include?("/uploads/") || content.include?("download:")
            content = content.gsub("download:", "").strip

            size = ""
            if title && title =~ /size:(\d+)/
              size = number_to_human_size(Regexp.last_match(1) || 0)
            end

            out(%(<a class="attachment-file" title="#{escape_html(content)}" target="_blank" href="#{escape_href(link)}">
                <span class="icon-box"><i class="fas fa-file"></i></span>
                <span class="filename">#{escape_html(content)}</span>
                <span class="filesize">#{escape_html(size)}</span>
            </a>))
          else
            out(%(<a href="#{escape_href(link)}">), :children, "</a>")
          end
        end

        def code_block(node)
          lexer = Rouge::Lexer.find_fancy(node.fence_info) || Rouge::Lexers::PlainText.new
          source = node.string_content
          formatter = Rouge::Formatters::HTML.new

          block do
            out(%(<div class="highlight">))
            out(%(<pre class="highlight #{escape_html(lexer.tag)}"><code>))
            out(formatter.format(lexer.lex(source)))
            out("</code></pre></div>")
          end
        end
      end
    end
  end
end
