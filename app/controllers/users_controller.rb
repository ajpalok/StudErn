class UsersController < ApplicationController
  # layout 'control_unit'
  before_action :authenticate_user!, only: [ :index ]

  def index
  end
end
