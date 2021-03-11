# frozen_string_literal: true

module Sequenceable
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    def has_sequence(target_name, scope: "", column: :iid)
      before_validation :sequence_generate_id, on: :create

      define_method(:sequence_generate_id) do
        target = send(target_name)
        send("#{column}=", Sequence.next(target, scope))
      end
    end
  end
end
