# frozen_string_literal: true

class License
  PRO_FEATURES = %i[
    soft_delete
  ]

  class << self
    delegate :expired?, :will_expire?, :expires_at,
             :licensee,
             :restrictions, :restricted?, :starts_at, to: :license

    def features
      PRO_FEATURES
    end

    def allow_feature?(name)
      return false unless license?
      return false if trial? && expired?

      features.include?(name)
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
          BookLab::License.import(Setting.license)
        rescue
          nil
        end
    end

    def update(license_body)
      Setting.license = license_body
      @license = nil
    end
  end
end
