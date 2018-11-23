# frozen_string_literal: true

require 'open3'

module BookLab
  module Import
    class Base
      delegate :logger, to: Rails

      attr_accessor :repository, :user, :url

      def initialize(repository:, user:, url:)
        @user = user
        @repository = repository
        @url = url.gsub(/[\s\'\"]+/, "")
      end

      def valid_url?
        true
      end

      def execute(script)
        stdout, stderr, status = Open3.capture3(script)

        if !status.success?
          raise RuntimeError.new("execute error: #{stderr}")
        end

        stdout
      end
    end
  end
end