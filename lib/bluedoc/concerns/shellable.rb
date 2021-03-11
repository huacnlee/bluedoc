# frozen_string_literal: true

require "open3"

module BlueDoc
  module Concerns
    module Shellable
      extend ActiveSupport::Concern

      def tmp_path
        return @tmp_path if defined? @tmp_path
        @tmp_path = Rails.root.join("tmp", self.class.name)
        FileUtils.mkdir_p(@tmp_path)
        @tmp_path
      end

      def execute(script)
        stdout, stderr, status = Open3.capture3(script)

        if !status.success?
          raise "execute error: #{stderr}"
        end

        stdout
      end
    end
  end
end
