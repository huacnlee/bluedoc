module UsersHelper
  include LetterAvatar::AvatarHelper

  def user_name_tag(user)
    return "" if user.blank?

    link_to user.slug, user.to_path, class: "user-name"
  end

  def group_name_tag(group)
    return "" if group.blank?

    link_to group.name, group.to_path, class: "group-name"
  end

  def user_avatar_tag(user, opts = {})
    opts[:style] ||= "small"
    opts[:class] = "avatar avatar-#{opts[:style]}"
    opts[:link] = true if opts[:link].nil?

    return "" if user.blank?

    if user.avatar.attached?
      image_html = image_tag(user.avatar_url(style: opts[:style]), class: opts[:class])
    else
      image_html = letter_avatar_tag(user.slug, 400, class: opts[:class])
    end



    return image_html if opts[:link] == false

    link_to user.to_path, class: "user-avatar" do
      image_html
    end
  end
end
