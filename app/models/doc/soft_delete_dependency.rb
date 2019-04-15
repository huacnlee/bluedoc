# frozen_string_literal: true

class Doc
  include SoftDelete

  # PRO-begin
  set_callback :restore, :before do
    self.restore_dependents(:comments)
    self.ensure_toc!
  end
  # PRO-end
end
