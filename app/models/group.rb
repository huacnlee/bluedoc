# frozen_string_literal: true

class Group < User
  include Memberable

  # Disable Devise user features
  def password_required?; false; end
  def email_required?; false; end
  def group?; true; end
  def user?; false; end
end
