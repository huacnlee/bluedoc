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
end
