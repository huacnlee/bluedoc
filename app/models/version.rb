class Version < ApplicationRecord
  include Markdownable
  include Activityable

  belongs_to :subject, required: false, polymorphic: true
  belongs_to :user, required: false

  # use for view render show offset
  attr_accessor :idx

  has_rich_text :body
end
