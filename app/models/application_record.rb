# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include BookLab::RichText::Attribute

  self.abstract_class = true
end
