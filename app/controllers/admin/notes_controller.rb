# frozen_string_literal: true

class Admin::NotesController < Admin::ApplicationController
  before_action :set_note, only: %i[destroy restore]

  def index
    @notes = Note.unscoped.where(privacy: "public").includes(:user).order("id desc")
    if params[:user_id]
      @notes = @notes.where(user_id: params[:user_id])
    end
    if params[:q]
      q = "%#{params[:q]}%"
      @notes = @notes.where("title ilike ? or slug ilike ? or description ilike ?", q, q, q)
    end
    @notes = @notes.page(params[:page])
  end

  def destroy
    @note.destroy
    redirect_to admin_notes_path(user_id: @note.user_id, q: @note.slug), notice: t(".Note was successfully deleted")
  end

  # PRO-begin
  def restore
    check_feature! :soft_delete

    @note.restore
    redirect_to admin_notes_path(user_id: @note.user_id, q: @note.slug), notice: t(".Note was successfully restored")
  end
  # PRO-end

  private
    def set_note
      @note = Note.unscoped.find(params[:id])
    end

    def note_params
      params.require(:note).permit!
    end
end
