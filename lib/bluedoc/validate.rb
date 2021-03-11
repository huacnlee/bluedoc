# frozen_string_literal: true

module BlueDoc
  class Validate
    class << self
      def url?(src)
        /^https?:\/\//.match?(src)
      end
    end
  end
end
