# frozen_string_literal: true

class ReactionsController < ApplicationController
  before_action :authenticate_anonymous!
  before_action :authenticate_user!
  before_action :set_subject

  # POST /reactions?subject_type=?&subject_id
  def create
    authorize! :read, @subject

    contents = reaction_params[:content]&.split(" ") || []
    name = contents.first.strip
    option = contents.last.strip

    @reaction = Reaction.where(subject: @subject, name: name, user: current_user).first
    if @reaction && option == "unset"
      @reaction.destroy
    else
      @reaction = Reaction.create_reaction(name, @subject, user: current_user)
    end
  end

  private

    def set_subject
      klass = reaction_params[:subject_type].constantize
      @subject = klass.find(reaction_params[:subject_id])
    end

    def reaction_params
      params.require(:reaction).permit(:subject_type, :subject_id, :content)
    end
end