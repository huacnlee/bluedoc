# frozen_string_literal: true

module BookLab
  class Slug
    FORMAT = 'A-Za-z0-9\-\_\.'
    REGEXP = /\A[#{Slug::FORMAT}]+\z/

    USER_KEYWORDS = YAML.load(File.open(Rails.root.join("config/keywords.yml")).read)["user"]
    REPOSITORY_KEYWORDS = YAML.load(File.open(Rails.root.join("config/keywords.yml")).read)["repository"]

    def self.valid?(slug)
      REGEXP.match? slug
    end

    def self.valid_user?(slug)
      return false if !self.valid?(slug)
      return false if USER_KEYWORDS.include?(slug.downcase)
      true
    end

    def self.valid_repo?(slug)
      return false if !self.valid?(slug)
      return false if REPOSITORY_KEYWORDS.include?(slug.downcase)
      true
    end

    def self.slugize(slug)
      return "" if slug.blank?
      new_slug = slug.strip.gsub(/[^#{FORMAT}]+/, "-")
      # trim -
      new_slug.gsub(/^\-|\-$/, "")
    end

    # generate range of 1000 .. seed random number to 36 radix as slug
    def self.random(seed: 9999999999)
      num = SecureRandom.random_number(seed) + 100000
      num.to_s(36)
    end
  end
end
