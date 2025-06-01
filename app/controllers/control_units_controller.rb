class ControlUnitsController < ApplicationController
  layout 'control_unit'
  before_action :authenticate_control_unit!

  def index
  end

  def profile
  end
end
