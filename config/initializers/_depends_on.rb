# frozen_string_literal: true

class Module
  # Allow to split a big class into multiple files
  #
  #   # app/models/user.rb
  #   class User
  #     depends_on :authorization, :two_factor
  #   end
  #
  #   # app/models/user/authorization_dependency.rb
  #   class User
  #     has_many :authorizations
  #   end
  #
  #   # app/models/user/two_factor_dependency.rb
  #   class User
  #     has_many :two_factors
  #
  #     def two_factors_activited?
  #     end
  #   end
  def depends_on(*files)
    files.each { |f| require_dependency "#{name.underscore}/#{f}_dependency" }
  end
end
