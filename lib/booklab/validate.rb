module BookLab
  class Validate
    class << self
      def url?(src)
        /^http[s]?:\/\//.match?(src)
      end
    end
  end
end