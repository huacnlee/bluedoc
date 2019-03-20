# frozen_string_literal: true

class User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :lockable,
         :rememberable, :validatable, :confirmable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github gitlab ldap]

  attr_accessor :omniauth_provider, :omniauth_uid

  has_many :authorizations

  before_validation on: :create do
    self.name = slug if name.blank?
  end

  # Validate email suffix
  validate do |user|
    if user.user?
      self.errors.add(:email, t(".is invalid email suffix")) unless Setting.valid_user_email?(self.email)
    end
  end

  after_create :bind_omniauth_on_create

  # Override Devise to send mails with async
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  def bind_omniauth_on_create
    if self.omniauth_provider
      Authorization.find_or_create_by!(provider: self.omniauth_provider, uid: self.omniauth_uid, user_id: self.id)
    end
  end

  # Update user password
  def update_password(params)
    %i[current_password password password_confirmation].each do |key|
      self.errors.add(key, :blank) if params[key].blank?
    end

    return false if self.errors.size > 0

    self.update_with_password(params)
  end

  def confirmation_required?
    Setting.confirmable_enable?
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = conditions.delete(:email)
    where(conditions.to_h).where(["(slug ilike :value OR email ilike :value)", { value: email }]).first
  end

  # Allow empty password, when use LDAP or encrypted_password was empty
  def password_required?
    return false if allow_feature?(:ldap_auth) && self.omniauth_provider == "ldap"

    !persisted? || !password.nil? || !password_confirmation.nil?
  end

  # Use Omniauth callback info to create and bind user
  def self.find_or_create_by_omniauth(omniauth_auth)
    user = Authorization.find_user_by_provider(omniauth_auth["provider"], omniauth_auth["uid"])
    return user if user

    if allow_feature?(:ldap_auth) && omniauth_auth["provider"] == "ldap"
      user = self.create(
        omniauth_provider: omniauth_auth["provider"],
        omniauth_uid: omniauth_auth["uid"],
        name: omniauth_auth.dig("info", "name"),
        slug: omniauth_auth.dig("info", "login"),
        email: omniauth_auth.dig("info", "email"),
        # Directly to confirm user
        confirmed_at: Time.now
      )
    end

    user
  end
end
