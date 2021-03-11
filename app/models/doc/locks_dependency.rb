# frozen_string_literal: true

class Doc
  def lock!(user)
    Rails.cache.write(write_lock_key, user.id, expires_in: 30.seconds)
  end

  def unlock!
    Rails.cache.delete(write_lock_key)
  end

  def locked_user
    user_id = Rails.cache.read(write_lock_key)
    return nil if user_id.blank?
    begin
      User.find(user_id)
    rescue
      nil
    end
  end

  def locked?
    !locked_user.blank?
  end

  private

  def write_lock_key
    @write_lock_key ||= [cache_key, "write-lock"].join("/")
  end
end
