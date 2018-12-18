# frozen_string_literal: true

class User
  include SoftDelete

  set_callback :restore, :before do
    self.restore_dependents(:owned_repositories)
  end
end
