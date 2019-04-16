# frozen_string_literal: true

class Repository
  has_many :tocs

  def has_toc?
    return true if self.preferences[:has_toc].nil?
    ActiveModel::Type::Boolean.new.cast(self.preferences[:has_toc])
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
    @toc_ordered_docs ||= self.tocs.nested_tree.includes(:doc).collect(&:doc).compact
  end
end
