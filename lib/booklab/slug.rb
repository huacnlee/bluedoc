module BookLab
  class Slug
    FORMAT = 'A-Za-z0-9\-\_\.'
    REGEXP = /\A[#{Slug::FORMAT}]+\z/

    def self.valid?(slug)
      REGEXP.match? slug
    end
  end
end
