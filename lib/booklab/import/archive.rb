# frozen_string_literal: true

module BookLab
  module Import
    class Archive < GitBook
      def valid_url?
        self.url&.start_with?("http")
      end

      def download
        script = <<~SCRIPT
        mkdir -p #{self.repo_dir} && \
        curl -sSL '#{self.url}' -o #{self.repo_dir}/archive.zip && \
        unzip #{self.repo_dir}/archive.zip -d #{self.repo_dir}
        SCRIPT

        logger.info script
        self.execute(script)
      end
    end
  end
end
