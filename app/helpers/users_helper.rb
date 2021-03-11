# frozen_string_literal: true

module UsersHelper
  def user_slug_tag(user)
    return "" if user.blank?
    link_to user.slug, user.to_path, class: "user-slug", title: user.fullname, data: {type: user.type.downcase}
  end

  def user_name_tag(user, opts = {})
    return "" if user.blank?

    if opts[:with_icon]
      link_to icon_tag(user.type.downcase, label: user.name), user.to_path, class: "user-name icon-middle-wrap", title: user.fullname, data: {type: user.type.downcase}
    else
      link_to user.name, user.to_path, class: "user-name", title: user.fullname, data: {type: user.type.downcase}
    end
  end

  def group_name_tag(group)
    return "" if group.blank?

    link_to group.name, group.to_path, class: "group-name", title: group.fullname, data: {type: group.type.downcase}
  end

  def user_avatar_tag(user, opts = {})
    opts[:style] ||= "small"
    opts[:class] = "avatar avatar-#{opts[:style]}"
    opts[:link] = true if opts[:link].nil?

    return "" if user.blank?

    image_html = if user.avatar_attached?
      image_tag(user.avatar_url, class: opts[:class], title: user.fullname)
    else
      default_avatar_tag(user, class: opts[:class])
    end

    return image_html if opts[:link] == false

    data = {name: user.name, slug: user.slug, type: user.type.downcase, toggle: "tooltip"}
    link_to user.to_path, class: "user-avatar", title: user.name, data: data do
      image_html
    end
  end

  def default_avatar_tag(user, opts = {})
    opts[:class] ||= ""

    first_char = user.slug[0].upcase
    idx = first_char.bytes.first % 10
    class_name = "default-avatar #{opts[:class]} default-avatar-#{idx}"
    content_tag(:span, first_char, class: class_name)
  end

  def follow_user_tag(user, opts = {})
    return "" if current_user.blank?
    return "" if user.blank?
    return "" if current_user.id == user.id
    followed = current_user.follow_user_ids.include?(user.id)
    opts[:class] ||= "btn btn-block"

    class_names = "btn-follow-user #{opts[:class]}"
    slug = user.slug

    label = t("shared.follow_button.follow")
    undo_label = t("shared.follow_button.unfollow")
    btn_label = followed ? undo_label : label

    data = {id: slug, label: label, undo_label: undo_label}
    class_names += " active" if followed

    content_tag :button, btn_label, data: data, class: class_names
  end
end
