# frozen_string_literal: true

module BookLab
  class Pipeline
    class SmlFilter < ::HTML::Pipeline::TextFilter
      def call
        html = BookLab::SML.parse(@text,
          plantuml_service_host: Setting.plantuml_service_host,
          mathjax_service_host: Setting.mathjax_service_host)
        html.strip!
        html
      end
    end
  end
end
