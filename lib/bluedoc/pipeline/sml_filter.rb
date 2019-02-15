# frozen_string_literal: true

module BlueDoc
  class Pipeline
    class SmlFilter < ::HTML::Pipeline::TextFilter
      def call
        renderer = BlueDoc::SML.parse(@text,
          plantuml_service_host: Setting.plantuml_service_host,
          mathjax_service_host: Setting.mathjax_service_host)
        renderer.to_html
      end
    end
  end
end
