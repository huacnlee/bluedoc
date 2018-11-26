# frozen_string_literal: true

module UsersHelper
  include LetterAvatar::AvatarHelper

  def user_name_tag(user)
    return "" if user.blank?

    link_to user.slug, user.to_path, class: "user-name", title: user.fullname
  end

  def user_display_name_tag(user)
    return "" if user.blank?

    link_to user.name, user.to_path, class: "user-display-name", title: user.fullname
  end

  def group_name_tag(group)
    return "" if group.blank?

    link_to group.name, group.to_path, class: "group-name", title: group.fullname
  end

  def user_avatar_tag(user, opts = {})
    opts[:style] ||= "small"
    opts[:class] = "avatar avatar-#{opts[:style]}"
    opts[:link] = true if opts[:link].nil?

    return "" if user.blank?

    if user.avatar.attached?
      image_html = image_tag(user.avatar_url(style: opts[:style]), class: opts[:class], title: user.fullname)
    else
      image_html = letter_avatar_tag(user.slug, 400, class: opts[:class], title: user.fullname)
    end

    return image_html if opts[:link] == false

    data = { name: user.name, slug: user.slug }
    link_to user.to_path, class: "user-avatar", data: data do
      image_html
    end
  end

  def follow_user_tag(user, opts = {})
    return "" if current_user.blank?
    return "" if user.blank?
    return "" if current_user.id == user.id
    followed = current_user.follow_user_ids.include?(user.id)
    opts[:class] ||= "btn btn-block"

    class_names = "btn-follow-user #{opts[:class]}"
    slug        = user.slug

    if followed
      link_to raw("<span>Unfollow</span>"), "#", data: { id: slug }, class: "#{class_names} active"
    else
      link_to raw("<span>Follow</span>"), "#", data: { id: slug }, class: class_names
    end
  end
end
