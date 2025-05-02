# frozen_string_literal: true

class ControlUnit::SessionsController < Devise::SessionsController
  layout "authentication", only: [ :new, :create ]
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  # If you have after sign in path, uncomment the following method
  def after_sign_in_path_for(resource)
    # super(resource)
    control_unit_index_path
  end
end
