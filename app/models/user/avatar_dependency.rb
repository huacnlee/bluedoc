# frozen_string_literal: true

class User
  AVATAR_STYLES = %i[tiny small medium large]

  has_one_attached :avatar, dependent: false
  validates :avatar, file_size: {less_than_or_equal_to: 5.megabytes},
                     file_content_type: {allow: %w[image/jpeg image/png]},
                     if: -> { avatar.attached? }

  def avatar_url
    Rails.cache.fetch([cache_key_with_version, "avatar_url"]) do
      avatar_url_without_cache
    end
  end

  def avatar_attached?
    Rails.cache.fetch([cache_key_with_version, "avatar_attached"]) do
      avatar.attached?
    end
  end

  def avatar_url_without_cache
    return nil unless avatar_attached?
    "#{Setting.host}/uploads/#{avatar.blob.key}?s=large"
  end
end
