# frozen_string_literal: true

class User
  include SoftDelete

  # PRO-begin
  set_callback :restore, :before do
    self.restore_dependents(:owned_repositories)
  end
  # PRO-end
end
