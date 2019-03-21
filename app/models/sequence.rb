class Sequence < ApplicationRecord
  belongs_to :target, polymorphic: true

  def increment!
    # LOCK ROW
    with_lock do
      self.number = self.number + 1
      self.save!
    end

    self.number
  end

  class << self
    def next(target, scope = "")
      seq = find_by_target(target, scope) || create_new(target, scope)

      seq.increment!
    end

    def create_new(target, scope)
      Sequence.transaction(requires_new: true) do
        Sequence.create!(
          target_type: target.class.name,
          target_id: target.id,
          scope: scope,
          number: 0
        )
      end
    rescue ActiveRecord::RecordNotUnique
      find_by_target(target, scope)
    end

    def find_by_target(target, scope = "")
      Sequence.find_by(target_type: target.class.name, target_id: target.id, scope: scope)
    end
  end
end