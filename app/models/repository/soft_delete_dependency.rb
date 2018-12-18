# frozen_string_literal: true

class Repository
  include SoftDelete

  set_callback :restore, :before do
    self.restore_dependents(:docs)
  end
end
