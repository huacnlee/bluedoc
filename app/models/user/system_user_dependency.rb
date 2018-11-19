class User
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