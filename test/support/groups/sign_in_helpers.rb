# frozen_string_literal: true

module Groups::SignInHelpers
  def sign_in_user
    user = create(:user)
    sign_in user
    user
  end

  def sign_in_role(role, group: nil, repository: nil)
    user = create(:user)
    if group
      group.add_member(user, role)
    elsif repository
      repository.add_member(user, role)
    else
      raise "required keyword: group or repository"
    end
    sign_in user
    user
  end

  def sign_in_admin(user)
    sign_in user
    Setting.admin_emails = user.email
  end
end
