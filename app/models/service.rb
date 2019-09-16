# frozen_string_literal: true

class Service < ApplicationRecord
  belongs_to :repository, required: false
  serialize :properties, Hash
  scope :templates, -> { where(template: :true) }
  scope :actives, -> { where(active: :true) }

  def self.actived_template
    self.templates.actives.find_by(repository_id: nil)
  end

  def self.accessible_attrs
    [:repository_id, :active]
  end

  private
    def need_validate?
      active? || template?
    end
end
