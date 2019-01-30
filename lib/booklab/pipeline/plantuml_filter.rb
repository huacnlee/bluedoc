# frozen_string_literal: true

require "uri"

module BookLab
  class Pipeline
    class PlantumlFilter < ::HTML::Pipeline::Filter
      def call
        doc.search("pre").each do |node|
          text = node.css("code").first&.inner_text || ""
          if text.start_with?("@startuml")
            svg_code = BookLab::Plantuml.encode(text.strip)
            node.replace(%(<img src="#{Setting.plantuml_service_host}/svg/#{svg_code}" class="plantuml-image" />))
          end
        end
        doc
      end
    end
  end
end
