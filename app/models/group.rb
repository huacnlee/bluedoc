# frozen_string_literal: true

class Group < User
  include Memberable
  include Activityable

  depends_on :user_actives, :search

  # Disable Devise user features
  def password_required?; false; end
  def email_required?; false; end
  def group?; true; end
  def user?; false; end

  # Group public owned repositories and user membered in this Group
  def owned_repositories_with_user(user)
    repos = self.owned_repositories.publics
    repos = repos.or(user.membered_repositories.where(user_id: self.id)) if user
    repos
  end
end
