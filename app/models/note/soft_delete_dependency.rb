# frozen_string_literal: true

class Note
  include SoftDelete

  # PRO-begin
  set_callback :restore, :before do
    restore_dependents(:comments)
  end
  # PRO-end
end
