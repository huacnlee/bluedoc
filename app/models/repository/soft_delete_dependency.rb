# frozen_string_literal: true

class Repository
  include SoftDelete

  # PRO-begin
  set_callback :restore, :before do
    self.restore_dependents(:docs)
  end
  # PRO-end
end
