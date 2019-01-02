# frozen_string_literal: true

module BookLab
  module Export
    class Base
      include BookLab::Concerns::Shellable

      delegate :logger, to: Rails

      attr_accessor :repository

      def initialize(repository:)
        @repository = repository
      end

      def repo_dir
        return @repo_dir if defined? @repo_dir
        @repo_dir = File.join(tmp_path, SecureRandom.uuid)
        FileUtils.mkdir_p(@repo_dir)
        @repo_dir
      end

      def write_file!(fname, content)
        filename = File.join(repo_dir, fname)
        file_path = File.dirname(filename)
        FileUtils.mkdir_p(file_path)

        File.open(filename, "w") { |f| f.write(content) }
      end
    end
  end
end
