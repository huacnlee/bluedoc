class Users::LdapsController < ::ApplicationController
  def new
    render "devise/sessions/ldap"
  end
end