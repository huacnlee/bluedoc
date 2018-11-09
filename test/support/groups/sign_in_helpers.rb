# frozen_string_literal: true

module Groups::SignInHelpers
  def sign_in_user
    user = create(:user)
    sign_in user
    user
  end

  def sign_in_role(role, group:)
    user = create(:user)
    group.add_member(user, role)
    sign_in user
    user
  end

  def sign_in_admin(user)
    sign_in user
    Setting.admin_emails = user.email
  end
end
