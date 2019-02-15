# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  include BlueDoc::RichText::Attribute

  self.abstract_class = true

  def self.t(*args)
    title = args.shift
    title = "activerecord.errors.messages.#{title}" if title.start_with?(".")
    I18n.t(title, *args)
  end

  def t(*args)
    self.class.t(*args)
  end
end
