# RailsSettings Model
class Setting < RailsSettings::Base
  source Rails.root.join("config/app.yml")

  SEPARATOR_REGEXP = /[\s,]/

  # When config/app.yml has changed, you need change this prefix to v2, v3 ... to expires caches
  # cache_prefix { "v1" }

  class << self
    def field(key, default: nil, type: :string, separator: nil)
      self.class.define_method(key) do
        val = self[key]
        default = default.call if default.is_a?(Proc)
        return default if val.nil?
        val
      end

      if type == :boolean
        self.class.define_method("#{key}?") do
          val = self.send(key.to_sym)
          val == "true" || val == "1"
        end
      elsif type == :array
        self.class.define_method("#{key.to_s.singularize}_list") do
          val = self.send(key.to_sym) || ""
          separator = SEPARATOR_REGEXP if separator.nil?
          val.split(separator).reject { |str| str.empty? }
        end
      end
    end
  end

  field :admin_emails, default: "admin@booklab.io", type: :array

  class << self
    def has_admin?(email)
      return false if self.admin_email_list.blank?
      self.admin_email_list.include?(email)
    end
  end
end
