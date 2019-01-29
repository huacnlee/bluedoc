# frozen_string_literal: true

class User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :lockable,
         :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2 github gitlab]

  attr_accessor :omniauth_provider, :omniauth_uid

  has_many :authorizations

  before_validation on: :create do
    self.name = slug if name.blank?
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

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    email = conditions.delete(:email)
    where(conditions.to_h).where(["(slug ilike :value OR email ilike :value)", { value: email }]).first
  end
end
