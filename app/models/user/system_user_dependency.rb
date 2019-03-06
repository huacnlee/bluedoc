# frozen_string_literal: true

class User
  SYSTEM_USER_SLUGS = %w[admin system]

  scope :without_system, -> { where.not(slug: SYSTEM_USER_SLUGS) }

  def system?
    @system ||= SYSTEM_USER_SLUGS.include?(self.slug)
  end

  class << self
    def system
      return @system_user if defined? @system_user

      @system_user = User.find_by_slug("system")
      if @system_user.blank?
        @system_user = User.new(id: -1, slug: "system", name: "System")
        @system_user.save!(validate: false)
      end

      @system_user
    end
  end
end
