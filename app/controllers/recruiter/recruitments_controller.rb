class Recruiter::RecruitmentsController < ApplicationController
  before_action :authenticate_recruiter!
  before_action :set_recruitment, only: [:show, :edit, :update, :destroy, :applications]
  before_action :ensure_access, only: [:show, :edit, :update, :destroy, :applications]

  def index
    @recruitments = Recruitment.where(recruiter: current_recruiter)
                              .includes(:recruitment_applies, :company)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(20)
    
    # Set @company to the first company if there are recruitments, otherwise nil
    @company = @recruitments.first&.company
  end

  def show
    @recent_applications = @recruitment.recruitment_applies.includes(:user)
                                      .order(created_at: :desc)
                                      .limit(5)
    @applications_count = @recruitment.recruitment_applies.count
  end

  def new
    @recruitment = Recruitment.new
    @companies = Company.joins(:recruiter_permissions_on_companies)
                       .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                       .order(:name)
  end

  def create
    @recruitment = Recruitment.new(recruitment_params)
    @recruitment.recruiter = current_recruiter
    @recruitment.company = Company.joins(:recruiter_permissions_on_companies)
                                 .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                                 .find(params[:recruitment][:company_id])
    
    if @recruitment.save
      redirect_to recruiter_recruitment_path(@recruitment), notice: "Recruitment created successfully."
    else
      @companies = Company.joins(:recruiter_permissions_on_companies)
                         .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                         .order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @companies = Company.joins(:recruiter_permissions_on_companies)
                       .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                       .order(:name)
  end

  def update
    if @recruitment.update(recruitment_params)
      redirect_to recruiter_recruitment_path(@recruitment), notice: "Recruitment updated successfully."
    else
      @companies = Company.joins(:recruiter_permissions_on_companies)
                         .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                         .order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @recruitment.destroy
      redirect_to recruiter_recruitments_path, notice: "Recruitment deleted successfully."
    else
      redirect_to recruiter_recruitment_path(@recruitment), alert: "Failed to delete recruitment."
    end
  end

  def applications
    @applications = @recruitment.recruitment_applies.includes(:user)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(20)
  end

  private

  def set_recruitment
    @recruitment = Recruitment.where(recruiter: current_recruiter).find(params[:id])
  end

  def ensure_access
    unless @recruitment
      redirect_to recruiter_recruitments_path, alert: "You don't have access to this recruitment."
    end
  end

  def recruitment_params
    params.require(:recruitment).permit(
      :title, :description, :recruitment_type, :work_type, :work_place,
      :experience_level, :number_of_vacancies, :salary_type, :salary_range,
      :application_collection_status, :application_collection_end_date,
      :company_id
    )
  end
end 