# frozen_string_literal: true

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
    end
  end
end