# frozen_string_literal: true

module BootstrapHelper
  def render_list(opts = {})
    list = []
    yield(list)
    list_items = render_list_items(list)
    content_tag("ul", list_items, opts)
  end

  def render_list_items(opts = {}, list = [])
    opts[:type] ||= :li
    opts[:class] ||= "nav-link"
    opts[:active_class] ||= "selected"
    opts[:check_parameters] = false if opts[:check_parameters].nil?

    yield(list) if block_given?
    items = []
    list.each do |link|
      urls = link.match(/href=(["'])(.*?)(\1)/) || []
      url = urls.length > 2 ? urls[2] : nil
      if url && current_page?(url, check_parameters: opts[:check_parameters])
        link = link.gsub(opts[:class], "#{opts[:class]} #{opts[:active_class]}")
      end

      item = link
      if opts[:type] == :li
        item = content_tag("li", raw(item), class: "nav-item")
      end

      items << item
    end
    raw items.join("")
  end
end
