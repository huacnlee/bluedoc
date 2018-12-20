# frozen_string_literal: true

module ApplicationHelper
  def markdown(body, opts = {})
    opts[:format] = "markdown"
    raw BookLab::HTML.render(body, opts)
  end

  def sanitize_html(html)
    raw Sanitize.fragment(html, BookLab::Sanitize::DEFAULT)
  end

  def close_button
    raw %(<button type="button" class="flash-close js-flash-close"><i class="fas fa-times"></i></button>)
  end

  def icon_tag(name, opts = {})
    icon_html = content_tag(:i, "", class: "octicon fas fa-#{name} #{opts[:class]}")
    return icon_html if opts[:label].blank?
    raw [icon_html, "<span>#{opts[:label]}</span>"].join(" ")
  end

  def notice_message
    flash_messages = []

    flash.each do |type, message|
      type = :success if type.to_sym == :notice
      type = :error  if type.to_sym == :alert
      text = content_tag(:div, class: "flash flash-block flash-#{type}") do
        content_tag(:div, class: "container") do
          close_button + message
        end
      end
      flash_messages << text if message
    end

    content_tag(:div, flash_messages.join("\n").html_safe, class: "flash-full")
  end

  def timeago(t)
    if t < 2.weeks.ago
      return content_tag(:span, class: "time", title: t.iso8601) { l t, format: :short }
    end

    content_tag(:span, class: "timeago", datetime: t.iso8601, title: t.iso8601) { l t, format: :short }
  end

  def title_tag(*texts)
    text = texts.join(" - ")
    content_for :title, h("#{text} - BookLab")
  end

  def action_button_tag(target, action_type, opts = {})
    return "" if target.blank?

    label      = opts[:label]
    undo_label = opts[:undo_label]
    icon       = opts[:icon]
    undo       = opts[:undo]
    with_count = opts[:with_count]

    label ||= action_type.to_s.titleize
    undo_label ||= "un#{action_type.to_s}".titleize
    icon ||= label.downcase

    action_type_pluralize = action_type.to_s.pluralize
    action_count = "#{action_type_pluralize}_count"

    url = target.to_path("/action?#{{ action_type: action_type }.to_query}")

    data = { method: :post, label: label, undo_label: undo_label, remote: true, disable: true }
    class_names = opts[:class] || "btn btn-sm"
    if with_count
      class_names += " btn-with-count"
    end
    btn_label = label.dup

    if undo.nil?
      undo = current_user && User.find_action(action_type, target: target, user: current_user)
    end

    if undo
      data[:method] = :delete
      btn_label = undo_label.dup
    end

    out = []

    out << link_to(icon_tag(icon, label: btn_label), url, data: data, class: class_names)
    if with_count && target.respond_to?(action_count)
      out << %(<button class="social-count" href="#url">#{target.send(action_count)}</button>)
    end
    content_tag(:span, raw(out.join("")), class: "#{target.class.name.underscore.singularize}-#{target.id}-#{action_type}-button")
  end
end
