# frozen_string_literal: true

require "html/pipeline"

module BookLab
  class Markdown
    pipelines = %i{normalize_mention markdown mention plantuml}
    public_pipelines = pipelines + [:public_attachments]

    pipelineClasses = pipelines.map { |name| "BookLab::Pipeline::#{name.to_s.camelize}Filter".constantize }
    MainPileline = HTML::Pipeline.new(pipelineClasses)

    publicPipelineClasses = public_pipelines.map { |name| "BookLab::Pipeline::#{name.to_s.camelize}Filter".constantize }
    PublicPileline = HTML::Pipeline.new(publicPipelineClasses)

    class << self
      def render(body, opts = {})
        if opts[:public]
          result = PublicPileline.call(body)[:output].inner_html
        else
          result = MainPileline.call(body)[:output].inner_html
        end
        result.strip!
        result
      end
    end
  end
end
