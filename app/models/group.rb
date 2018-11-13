# frozen_string_literal: true

class Group < User
  include Memberable
  include Activityable
  include Searchable
  include Elasticsearch::Model

  index_name { "#{Rails.env}-groups" }
  document_type name.underscore

  depends_on :user_active

  # Disable Devise user features
  def password_required?; false; end
  def email_required?; false; end
  def group?; true; end
  def user?; false; end
end
