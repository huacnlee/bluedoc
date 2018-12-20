# frozen_string_literal: true

module BookLab
  class Pipeline
    class SmlFilter < ::HTML::Pipeline::TextFilter
      def call
        html = BookLab::SML.parse(@text)
        html.strip!
        html
      end
    end
  end
end
