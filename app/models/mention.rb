class Mention < ApplicationRecord
  belongs_to :mentionable, polymorphic: true
end
