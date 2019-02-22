# frozen_string_literal: true

module DocsHelper
  def doc_title_tag(doc)
    return "" if doc.blank?
    return "" if doc.repository.blank?
    return "" if doc.repository.user.blank?

    link_to truncate(doc.title, length: 100), doc.to_path, class: "doc-link", title: doc.title
  end
end
