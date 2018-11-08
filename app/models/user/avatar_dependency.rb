class User
  AVATAR_STYLES = %i[tiny small medium large]

  has_one_attached :avatar, dependent: false
  validates :avatar, file_size: { less_than_or_equal_to: 5.megabytes },
                     file_content_type: { allow: %w[image/jpeg image/png] },
                     if: -> { avatar.attached? }

 class << self
   include ActionView::Helpers::AssetUrlHelper
   include Webpacker::Helper

   def default_user_avatar
     @default_user_avatar ||= asset_pack_path("images/default-user.png")
   end

   def default_group_avatar
     @default_group_avatar ||= asset_pack_path("images/default-group.png")
   end
 end

  def avatar_url(style: :small)
    return self.default_avatar unless self.avatar.attached?

    style = :small unless AVATAR_STYLES.include?(style)

    "/uploads/#{self.avatar.blob.key}?s=#{style}"
  rescue
    self.default_avatar
  end

  def avatar_or_default
    self.avatar.attached? ? self.avatar : self.default_avatar
  end

  def default_avatar
    self.type == "Group" ? self.class.default_group_avatar : self.class.default_user_avatar
  end

end
