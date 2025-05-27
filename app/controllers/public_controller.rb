class PublicController < ApplicationController
  before_action :redirect_if_user_signed_in, only: [:home]

  def home
  end

  def about
  end

  def contact
  end

  private
  def redirect_if_user_signed_in
    if user_signed_in?
      redirect_to user_index_path, notice: "You are already signed in."
    end
  end
end
