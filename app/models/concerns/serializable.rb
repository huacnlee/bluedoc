module Serializable
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    include ActiveModel::Serialization
  end

  def persisted?; true end
  def id; 1 end
end