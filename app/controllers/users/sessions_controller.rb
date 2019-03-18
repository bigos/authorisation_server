# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end
  def create
    login = params['user']['login']
    password  = params['user']['password']

    authenticated = Ldap.new.authenticate_ldap(login, password).to_s.downcase

    @user = User.where(email: authenticated).first
    unless @user
      # TODO
      # we need to create admin users from the console, because all other users
      # passwords are are set to the same string, random hash would be better
      @user = User.new(email: authenticated, password: 'not-applicable')
      @user.save
    end
    sign_in @user
    session[:user_id] = @user.id

    redirect_to root_path
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
