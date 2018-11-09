# frozen_string_literal: true

module RepositoriesHelper
  def repository_name_tag(repo)
    return "" if repo.blank?
    return "" if repo.user.blank?
    link_to repo.name, repo.to_path, class: "repository-name"
  end

  def repository_path_tag(repo)
    return "" if repo.blank?
    return "" if repo.user.blank?

    text = [repo.user.name, repo.name].join(" / ")

    link_to text, repo.to_path, class: "repository-path"
  end

  def action_button_tag(repo, action_type, label: nil, undo_label: nil, icon: nil, undo: nil, with_count: false)
    return "" if repo.blank?
    return "" if repo.user.blank?

    label ||= action_type.to_s.titleize
    undo_label ||= "un#{action_type.to_s}".titleize
    icon ||= label.downcase

    action_type_pluralize = action_type.to_s.pluralize
    action_count = "#{action_type_pluralize}_count"

    url = repo.to_path("/action?#{{ action_type: action_type }.to_query}")

    data = { method: :post, label: label, undo_label: undo_label, remote: true }
    class_names = "btn btn-sm"
    if with_count
      class_names += " btn-with-count"
    end
    btn_label = label.dup

    if undo.nil?
      undo = current_user && User.find_action(action_type, target: repo, user: current_user)
    end

    if undo
      data[:method] = :delete
      btn_label = undo_label.dup
    end

    out = []

    out << link_to(icon_tag(icon, label: btn_label), url, data: data, class: class_names)
    if with_count
      out << %(<button class="social-count" href="#url">#{repo.send(action_count)}</button>)
    end
    content_tag(:div, raw(out.join("")), class: "repository-#{repo.id}-#{action_type}-button")
  end
end
