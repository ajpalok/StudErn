# frozen_string_literal: true

class Recruiter::RegistrationsController < Devise::RegistrationsController
  layout :layout_by_action
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
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :gender])
    
    # sanitize gender
    if params[:recruiter][:gender].present?
      gender_value = params[:recruiter][:gender].to_s
      # Only allow integer digits
      if gender_value.match?(/^\d+$/)
        params[:recruiter][:gender] = gender_value.to_i
      else
        params[:recruiter][:gender] = nil # prevent error by invalid string
      end
    end
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone, :gender])
    
    # sanitize gender
    if params[:recruiter][:gender].present?
      gender_value = params[:recruiter][:gender].to_s
      # Only allow integer digits
      if gender_value.match?(/^\d+$/)
        params[:recruiter][:gender] = gender_value.to_i
      else
        params[:recruiter][:gender] = nil # prevent error by invalid string
      end
    end
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    # super(resource)
    recruiter_index_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  def layout_by_action
    if (%w[new create].include? action_name)
      return "authentication"
    end
    return "recruiter"
  end
end
