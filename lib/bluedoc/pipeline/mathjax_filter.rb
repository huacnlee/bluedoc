# frozen_string_literal: true

require "uri"

module BlueDoc
  class Pipeline
    class MathjaxFilter < ::HTML::Pipeline::Filter
      def call
        doc.xpath(".//text()").each do |node|
          content = node.to_html
          next unless content.include?("$")
          # skip in code
          next if has_ancestor?(node, %w[pre code])
          content.gsub!(/\$(.+?)\$/) do
            code = Regexp.last_match(1)
            svg_code = CGI.escape(code)
            image_url = "#{Setting.mathjax_service_host}/svg?tex=#{svg_code}"

            %(<img class="tex-image" src="#{image_url}" />)
          end

          node.replace(content)
        end
        doc
      end
    end
  end
end
