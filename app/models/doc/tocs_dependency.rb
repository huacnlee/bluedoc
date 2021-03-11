# frozen_string_literal: true

# Sync update TOC after doc update
class Doc
  has_one :toc

  after_update :sync_update_toc_after_update
  after_create :sync_create_toc_after_create

  delegate :depth, :parent, to: :toc

  # Move doc to target_doc
  # position allow :left, :right, :child
  def move_to(target_doc, position)
    toc.move_to(target_doc.toc, position)
  end

  def ensure_toc!
    if !toc
      send(:sync_create_toc_after_create)
    end
  end

  private

  def sync_create_toc_after_create
    create_toc!(title: title, url: slug, repository_id: repository_id, doc_id: id)
  end

  def sync_update_toc_after_update
    # Only update on slug or title has changed
    if saved_change_to_slug? || saved_change_to_title?
      toc&.update(title: title, url: slug)
    end
  end
end
