# frozen_string_literal: true

class Doc
  include SoftDelete

  set_callback :restore, :before do
    self.restore_dependents(:comments)
  end
end
