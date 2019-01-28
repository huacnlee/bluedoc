# frozen_string_literal: true

class Doc
  include Editorable

  belongs_to :last_editor, class_name: "User", required: false
  belongs_to :creator, class_name: "User", required: false

  attr_accessor :current_editor_id

  before_create :set_current_creator_id_on_create
  before_save :set_current_last_editor_id_on_save
  after_save :set_repository_editors_after_save

  private
    def set_current_creator_id_on_create
      self.creator_id = Current.user.id if Current.user
      self.last_editor_id = self.creator_id
      self.add_editor(self.last_editor_id)
    end

    def set_current_last_editor_id_on_save
      if current_editor_id && self.publishing?
        self.last_editor_id = current_editor_id
        self.add_editor(self.last_editor_id)
      end
    end

    def set_repository_editors_after_save
      self.repository.add_editor(self.editor_ids)
      self.repository.save!
    end
end
