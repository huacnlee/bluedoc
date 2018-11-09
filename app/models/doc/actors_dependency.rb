# frozen_string_literal: true

class Doc
  belongs_to :last_editor, class_name: "User", required: false
  belongs_to :creator, class_name: "User", required: false

  before_create :set_current_creator_id
  before_save :set_current_last_editor_id

  private
    def set_current_creator_id
      self.creator_id = Current.user.id if Current.user
    end

    def set_current_last_editor_id
      self.last_editor_id = Current.user.id if Current.user
    end
end
