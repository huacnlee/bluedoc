# frozen_string_literal: true

# Sync update TOC after doc update
class Doc

  after_update :sync_update_toc_after_update

  private
    def sync_update_toc_after_update
      toc_url = self.slug
      toc_url = self.slug_before_last_save if self.saved_change_to_slug?

      # Only update on slug or title has changed
      if self.saved_change_to_slug? || self.saved_change_to_title?
        self.repository&.update_toc_by_url(toc_url, title: self.title, url: self.slug)
      end
    end
end