# frozen_string_literal: true

require "html/pipeline"

module BookLab
  class Markdown
    pipelines = %i{normalize_mention markdown mention}

    pipelineClasses = pipelines.map { |name| "BookLab::Pipeline::#{name.to_s.classify}Filter".constantize }
    MainPileline = HTML::Pipeline.new(pipelineClasses)

    class << self
      def render(body)
        result = MainPileline.call(body)[:output].inner_html
        result.strip!
        result.gsub!(/>[\s]+</, "><")
        result
      end
    end
  end
end
