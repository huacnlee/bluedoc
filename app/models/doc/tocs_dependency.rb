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
    self.toc.move_to(target_doc.toc, position)
  end

  def ensure_toc!
    if !self.toc
      self.send(:sync_create_toc_after_create)
    end
  end

  private
    def sync_create_toc_after_create
      self.create_toc!(title: self.title, url: self.slug, repository_id: self.repository_id, doc_id: self.id)
    end

    def sync_update_toc_after_update
      toc_url = self.slug
      toc_url = self.slug_before_last_save if self.saved_change_to_slug?

      # Only update on slug or title has changed
      if self.saved_change_to_slug? || self.saved_change_to_title?
        self.toc&.update(title: self.title, url: self.slug)
      end
    end
end
