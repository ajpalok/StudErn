class Recruiter::CompaniesController < ApplicationController
  before_action :authenticate_recruiter!
  before_action :set_company, only: [:show, :edit, :update, :recruitments]
  before_action :ensure_access, only: [:show, :edit, :update, :recruitments]

  def index
    @companies = Company.joins(:recruiter_permissions_on_companies)
                       .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                       .includes(:recruitments)
                       .page(params[:page])
                       .per(12)
    
    # Calculate statistics
    @total_active_recruitments = Recruitment.where(recruiter: current_recruiter)
                                           .where(application_collection_status: "open")
                                           .count
    
    @total_applications = RecruitmentApply.joins(:recruitment)
                                         .where(recruitments: { recruiter: current_recruiter })
                                         .count
  end

  def show
    @recruitments = @company.recruitments.where(recruiter: current_recruiter)
                           .includes(:recruitment_applies)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(10)
    
    @recent_applications = RecruitmentApply.joins(:recruitment)
                                          .where(recruitments: { company: @company, recruiter: current_recruiter })
                                          .includes(:user, :recruitment)
                                          .order(created_at: :desc)
                                          .limit(5)
  end

  def edit
    # Only allow editing if user is admin of the company
    unless current_recruiter.has_admin_access?(@company)
      redirect_to recruiter_company_path(@company), alert: "You don't have permission to edit this company."
    end
  end

  def update
    if @company.update(company_params)
      redirect_to recruiter_company_path(@company), notice: "Company updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def recruitments
    @recruitments = @company.recruitments.includes(:recruitment_applies)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
  end

  private

  def set_company
    @company = Company.find(params[:id])
  end

  def ensure_access
    unless current_recruiter.has_access_to?(@company)
      redirect_to recruiter_companies_path, alert: "You don't have access to this company."
    end
  end

  def company_params
    params.require(:company).permit(:name, :tagline, :email, :phone, :website, :address, :description)
  end
end 