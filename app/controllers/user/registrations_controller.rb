# frozen_string_literal: true

class User::RegistrationsController < Devise::RegistrationsController
  layout 'authentication', only: [:new, :create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :first_name, :last_name, :dob, :latitude, :longitude, :phone, :role, :status, :gender, :career_objective ])

    # sanitize gender
    if params[:user][:gender].present?
      gender_value = params[:user][:gender].to_s
      # Only allow integer digits
      if gender_value.match?(/^\d+$/)
        params[:user][:gender] = gender_value.to_i
      else
        params[:user][:gender] = nil # prevent error by invalid string
      end
    end
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # Redirect to confirmation page after registration
    new_user_confirmation_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
