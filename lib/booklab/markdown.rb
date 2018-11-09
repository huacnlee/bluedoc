# frozen_string_literal: true

require "html/pipeline"

module BookLab
  class Markdown
    MainPileline = HTML::Pipeline.new([
      BookLab::Pipeline::MarkdownFilter,
    ])

    class << self
      def render(body)
        result = MainPileline.call(body)[:output]
        result.strip
      end
    end
  end
end
