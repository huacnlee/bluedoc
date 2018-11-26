# frozen_string_literal: true

class User
  AVATAR_STYLES = %i[tiny small medium large]

  has_one_attached :avatar, dependent: false
  validates :avatar, file_size: { less_than_or_equal_to: 5.megabytes },
                     file_content_type: { allow: %w[image/jpeg image/png] },
                     if: -> { avatar.attached? }

  def letter_avatar_url
    path = LetterAvatar.generate(self.slug, 240).sub("public/", "/")

    "#{Setting.host}#{path}"
  end

  def avatar_url
    return self.letter_avatar_url unless self.avatar.attached?
    "#{Setting.host}/uploads/#{self.avatar.blob.key}?s=large"
  rescue
    self.letter_avatar_url
  end
end
