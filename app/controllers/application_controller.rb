class ApplicationController < ActionController::Base
  # Lang parameter is used to switch the locale.
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # before_action :complete_auth_registration
  allow_browser versions: :modern

  # Redirect incomplete users to onboarding
  before_action :redirect_incomplete_users, if: :user_signed_in?

  def switch_locale(&action)
    locale = params[:lang] || session[:lang] || I18n.default_locale
    session[:lang] = locale
    I18n.with_locale(locale, &action)
  end

  private

  def redirect_incomplete_users
    return unless current_user.account_status == "incomplete"
    return unless current_user.confirmed_at.present? # Only redirect if user is confirmed
    return if controller_name == "users" && action_name.in?(["onboarding", "onboarding_update", "onboarding_back"])
    return if controller_name == "sessions" && action_name.in?(["destroy"])
    
    # Preserve the step parameter if it exists
    step_param = params[:step] ? "?step=#{params[:step]}" : ""
    redirect_to "#{user_onboarding_path}#{step_param}", alert: "Please complete your profile to continue."
  end
end
