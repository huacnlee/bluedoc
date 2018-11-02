# frozen_string_literal: true

module ApplicationHelper
  include OcticonsHelper

  def markdown(body)
    return nil if body.blank?
    Rails.cache.fetch(["markdown", "v1", Digest::MD5.hexdigest(body)]) do
      sanitize_html(BookLab::Markdown.render(body))
    end
  end

  def sanitize_html(html)
    raw Sanitize.fragment(html, BookLab::Sanitize::DEFAULT)
  end

  def close_button
    raw %(<button type="button" class="flash-close js-flash-close">#{octicon "x"}</button>)
  end

  def icon_tag(name, label: nil)
    return octicon(name) if label.blank?
    raw [octicon(name), "<span>#{label}</span>"].join(" ")
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
    content_tag(:span, class: "timeago", title: t.iso8601) { t.iso8601 }
  end

  def title_tag(*texts)
    text = texts.join(" - ")
    content_for :title, h("#{text} - BookLab")
  end
end
