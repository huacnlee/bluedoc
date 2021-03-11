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

  def as_rc_json(options = {})
    json = as_json(options)
    errors = {}
    self.errors.attribute_names.each do |key|
      errors[key.to_s] = self.errors.full_messages_for(key)&.first
    end
    json["errors"] = errors
    json
  end
end
