# frozen_string_literal: true

class Share < ApplicationRecord
  belongs_to :shareable, polymorphic: true
  belongs_to :user, required: false
  belongs_to :repository

  before_validation :save_repository_id_on_create
  before_validation :generate_unique_slug

  class << self
    def find_by_slug!(slug)
      find_by!(slug: slug)
    end

    def create_share(shareable, user: nil)
      share = where(shareable: shareable).take
      return share if share

      create(shareable: shareable, user: user)
    end
  end

  def to_path
    "/shares/#{slug}"
  end

  def to_url
    "#{Setting.host}#{to_path}"
  end

  private

  def generate_unique_slug
    self.slug ||= SecureRandom.base58
  end

  def save_repository_id_on_create
    case shareable_type
    when "Doc"
      self.repository_id = shareable&.repository_id
    end
  end
end
