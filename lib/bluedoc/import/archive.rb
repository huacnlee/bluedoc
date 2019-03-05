# frozen_string_literal: true

module BlueDoc
  module Import
    class Archive < GitBook
      def valid_url?
        self.url&.start_with?("http")
      end

      def download
        script = <<~SCRIPT
        mkdir -p #{self.repo_dir} && \
        wget -O #{self.repo_dir}/archive.zip '#{self.url}' && \
        unzip #{self.repo_dir}/archive.zip -d #{self.repo_dir}
        SCRIPT

        logger.info script
        self.execute(script)
      end
    end
  end
end
