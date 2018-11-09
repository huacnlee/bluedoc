# frozen_string_literal: true

class Version < ApplicationRecord
  include Markdownable
  include Smlable
  include Activityable

  belongs_to :subject, required: false, polymorphic: true
  belongs_to :user, required: false

  # use for view render show offset
  attr_accessor :idx
end
