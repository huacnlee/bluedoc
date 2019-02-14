class License
  PRO_FEATURES = %i[
    soft_delete
  ]

  class << self
    def features
      PRO_FEATURES
    end

    def allow_feature?(name)
      return false if trial? && expired?

      features.include?(name)
    end

    def trial?
      return true
    end

    def expired?
      return false
    end

    def exists?
      Setting.license.present?
    end

    def restricted_attr(attr, default: nil)
      return default unless exists?
    end

    def restrictions
    end

    def decrypt_license(raw)
      len   = ActiveSupport::MessageEncryptor.key_len
      salt  = SecureRandom.random_bytes(len)
      key   = ActiveSupport::KeyGenerator.new('password').generate_key(salt, len)
      crypt = ActiveSupport::MessageEncryptor.new(key)
      encrypted_data = crypt.encrypt_and_sign('my secret data')
      crypt.decrypt_and_verify(encrypted_data)
    end
  end
end