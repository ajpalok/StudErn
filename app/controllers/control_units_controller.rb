class ControlUnitsController < ApplicationController
  layout 'control_unit'
  before_action :authenticate_control_unit!, only: [ :index ]

  def index
  end
end
