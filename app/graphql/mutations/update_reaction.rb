# frozen_string_literal: true

class Mutations::UpdateReaction < Mutations::BaseMutation
  argument :subject_type, String, required: true, description: "Subject type class name"
  argument :subject_id, ID, required: true, description: "Subject primary id"
  argument :name, String, required: true, description: "Reaction emoji name"
  argument :option, String, required: false, description: "Give unset if want unset, [set, unset]"

  type [Types::ReactionType]

  def resolve(subject_type:, subject_id:, name:, option: nil)
    @subject = Reaction.class_with_subject_type(subject_type).find(subject_id)
    authorize! :read, @subject

    name = name.strip
    option = option&.strip

    @reaction = Reaction.where(subject: @subject, name: name, user: current_user).first
    if @reaction && option == "unset"
      @reaction.destroy
    else
      @reaction = Reaction.create_reaction(name, @subject, user: current_user)
    end

    @subject.reactions.grouped
  end
end
