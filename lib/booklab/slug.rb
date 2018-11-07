module BookLab
  class Slug
    FORMAT = 'A-Za-z0-9\-\_\.'
    REGEXP = /\A[#{Slug::FORMAT}]+\z/

    def self.valid?(slug)
      REGEXP.match? slug
    end

    def self.slugize(slug)
      return "" if slug.blank?
      slug.underscore.gsub(/[^#{FORMAT}]+/, "-")
    end

    # generate range of 1000 .. seed random number to 36 radix as slug
    def self.random(seed: 9999999999)
      num = SecureRandom.random_number(seed) + 100000
      num.to_s(36)
    end
  end
end
