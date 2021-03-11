# frozen_string_literal: true

class Doc
  include SoftDelete

  # PRO-begin
  set_callback :restore, :before do
    restore_dependents(:comments)
    ensure_toc!
  end
  # PRO-end
end
