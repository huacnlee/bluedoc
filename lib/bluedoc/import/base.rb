# frozen_string_literal: true

module BlueDoc
  module Import
    class Base
      include BlueDoc::Concerns::Shellable

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

      def repo_dir
        @repo_dir ||= File.join(tmp_path, Digest::MD5.hexdigest(self.url))
      end
    end
  end
end
