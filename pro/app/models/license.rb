# frozen_string_literal: true

class License
  PRO_FEATURES = %w[
    soft_delete
    reader_list
    export_pdf
    export_archive
    limit_user_emails
    ldap_auth
  ]

  class << self
    delegate :expired?, :will_expire?, :expires_at,
             :licensee, :restrictions, :restricted?, :starts_at, to: :license

    def features
      PRO_FEATURES
    end

    def allow_feature?(name)
      return false unless license?
      return false if trial? && expired?

      features.include?(name.to_s) && license.allow_feature?(name)
    end

    def check_users_limit!
      return false unless license?
      return false if users_limit == 0
      if current_active_users_count >= users_limit
        message = <<~MSG
        There is not enough user quota for the current license or free version.

        Current quota: #{users_limit}
        Actived users: #{current_active_users_count}
        MSG
        raise BlueDoc::UsersLimitError.new(message)
      end

      false
    end

    def trial?
      restricted_attr(:trial).present?
    end

    def remaining_days
      return 0 if expired?

      (expires_at - Date.today).to_i
    end

    def license?
      license && license.valid?
    end

    def restricted_attr(attr, default: nil)
      return default unless license? && restricted?(attr)

      restrictions[attr]
    end

    def license
      return nil if Setting.license.blank?

      @license ||=
        begin
          BlueDoc::License.import(Setting.license)
        rescue
          nil
        end
    end

    def update(license_body)
      Setting.license = license_body
      @license = nil
    end

    def users_limit
      restricted_attr(:users_limit, default: 0)
    end

    def current_active_users_count
      # Reduce 2 users (admin, system)
      User.where(type: "User").count - 2
    end
  end
end
