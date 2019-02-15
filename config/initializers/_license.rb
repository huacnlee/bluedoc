# frozen_string_literal: true

begin
  public_key_file = File.read(Rails.root.join(".license-key.pub"))
  public_key = OpenSSL::PKey::RSA.new(public_key_file)
  BlueDoc::License.encryption_key = public_key
rescue
  warn "WARNING: No valid license encryption key provided."
end
