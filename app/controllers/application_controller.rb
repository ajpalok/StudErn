class ApplicationController < ActionController::Base
  # Lang parameter is used to switch the locale.
  around_action :switch_locale

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # before_action :complete_auth_registration
  allow_browser versions: :modern

  def switch_locale(&action)
    locale = params[:lang] || session[:lang] || I18n.default_locale
    session[:lang] = locale
    I18n.with_locale(locale, &action)
  end
end
