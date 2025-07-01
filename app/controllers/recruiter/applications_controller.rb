class Recruiter::ApplicationsController < ApplicationController
  before_action :authenticate_recruiter!
  before_action :set_application, only: [:update_status]

  def index
    @applications = RecruitmentApply.joins(recruitment: :company)
                                   .where(companies: { id: current_recruiter.companies.pluck(:id) })
                                   .includes(:user, recruitment: :company)
                                   .order(created_at: :desc)
                                   .page(params[:page])
                                   .per(20)

    # Apply filters
    if params[:status].present?
      @applications = @applications.where(status: params[:status])
    end

    if params[:company_id].present?
      @applications = @applications.where(companies: { id: params[:company_id] })
    end

    if params[:recruitment_type].present?
      @applications = @applications.where(recruitments: { recruitment_type: params[:recruitment_type] })
    end

    # Get companies for filter dropdown
    @companies = current_recruiter.companies.order(:name)
  end

  def update_status
    if @application.update(status: params[:status])
      # Send notification to user
      # You can implement email notifications here
      
      redirect_back(fallback_location: recruiter_applications_path, 
                   notice: "Application status updated to #{params[:status].titleize}")
    else
      redirect_back(fallback_location: recruiter_applications_path, 
                   alert: "Failed to update application status")
    end
  end

  private

  def set_application
    @application = RecruitmentApply.joins(recruitment: :company)
                                  .where(companies: { id: current_recruiter.companies.pluck(:id) })
                                  .find(params[:id])
  end
end 