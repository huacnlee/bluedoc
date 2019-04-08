# frozen_string_literal: true

class Repository
  has_many :tocs, class_name: "RepositoryToc"

  def has_toc?
    return true
  end

  def toc_html(prefix: nil)
    BlueDoc::Toc.parse(self.toc_text).to_html(prefix: prefix)
  end

  def toc_text
    tocs.to_text
  end

  def toc_json
    BlueDoc::Toc.parse(self.toc_text).to_json
  end

  # sort docs as Toc order
  def toc_ordered_docs
    @toc_ordered_docs ||= self.tocs.nested_tree.includes(:doc).collect(&:doc)
  end
end
