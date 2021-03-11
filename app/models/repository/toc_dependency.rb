# frozen_string_literal: true

class Repository
  has_many :tocs

  def has_toc?
    return true if preferences[:has_toc].nil?
    ActiveModel::Type::Boolean.new.cast(preferences[:has_toc])
  end

  def toc_html(prefix: nil)
    BlueDoc::Toc.parse(toc_text).to_html(prefix: prefix)
  end

  def toc_text
    tocs.to_text
  end

  def toc_json
    BlueDoc::Toc.parse(toc_text).to_json
  end

  # sort docs as Toc order
  def toc_ordered_docs
    @toc_ordered_docs ||= tocs.nested_tree.includes(:doc).collect(&:doc).compact
  end
end
