# frozen_string_literal: true

module BlueDoc
  module Import
    class Archive < GitBook
      def valid_url?
        url&.start_with?("http")
      end

      def download
        script = <<~SCRIPT
          mkdir -p #{repo_dir} && \
          wget -O #{repo_dir}/archive.zip '#{url}' && \
          unzip #{repo_dir}/archive.zip -d #{repo_dir}
        SCRIPT

        logger.info script
        execute(script)
      end
    end
  end
end
