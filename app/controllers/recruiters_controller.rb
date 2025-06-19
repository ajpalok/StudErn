class RecruitersController < ApplicationController
  layout 'recruiter'
  before_action :authenticate_recruiter!
  before_action :complete_profile, except: [:account_complete, :account_complete_post, :account_complete_company_create, :account_complete_company_join, :account_complete_company_join_post]
  before_action :set_company, only: [:account_complete_company_join, :account_complete_company_join_post]
  skip_before_action :verify_authenticity_token, only: [:account_complete_post]

  def index
  end

  def profile
    @user = current_recruiter
  end

  def recruitment_publish
    # here will be shown all the companies the recruiter is associated with to publish jobs and internships
    # @companies will contain current_recruiter.companies which companies are approved in recruiter_permissions_on_companies table
    @companies = RecruiterPermissionsOnCompany
                  .where(recruiter_id: current_recruiter.id, recruiter_status: "approved", can_manage_jobs: true)
                  .includes(:company)
                  .map(&:company)

    if params[:company].present?
      if !params[:company].match?(/\A\d+\z/)
        redirect_to recruiter_index_path, alert: "Invalid Company ID format." and return
      end
      if params[:company].to_i <= 0
        redirect_to recruiter_index_path, alert: "Invalid Company ID." and return
      end
      # @company will be the data from @companies where the id matches the params[:company]
      @company = @companies.find { |c| c.id == params[:company].to_i }
      if @company.nil?
        redirect_to recruiter_recruitment_publish_path, alert: "Invalid request." and return
      end
    end

    # if @companies is only one company, redirect to the recruitment publish page of that company
    if @companies.length == 1 && params[:company].nil?
      redirect_to recruiter_recruitment_publish_path(company: @companies.first.id) and return
    end
  end

  def recruitment_publish_create
    
  end

  def account_complete
    @new_company = Company.new

    @recruiter_details = current_recruiter

    # if the recruiter is already associated with a company, redirect to the index page
    recruiter_permission = RecruiterPermissionsOnCompany.find_by(recruiter_id: @recruiter_details.id)
    if recruiter_permission.present?
      redirect_to recruiter_index_path and return
    end

    # if the recruiter is not associated with any company, show the account complete page
    @companies = RecruiterPermissionsOnCompany
                  .where(recruiter_id: @recruiter_details.id)
                  .includes(:company)
                  .map(&:company)
                  .select { |c| c.account_status == "complete" }
    if @companies.empty?
      flash.now[:alert] = "You are not associated with any company. Please search for a company to join or create a new one."
    else
      flash.now[:notice] = "You are associated with the following companies. You can join any of them."
    end
    @companies = @companies.map do |company|
      {
        id: company.id,
        name: company.name,
        tagline: company.tagline,
        description: company.description,
        email: company.email
      }
    end
  end

  def account_complete_post
    allowed_origin = request.base_url

    if request.origin.present? && request.origin != allowed_origin
      return head :forbidden
    end

    case params[:type]
    when "account_completing_company_search"
      company_name = "%#{params[:company_name].to_s.downcase.strip}%"
      @companies =  Company
                    .where("LOWER(name) LIKE ?", company_name)
                    .where.not(
                      id: RecruiterPermissionsOnCompany
                            .where(recruiter_id: current_recruiter.id)
                            .select(:company_id)
                    ).limit(10).pluck(:id, :name)
      render json: {
        message: "success",
        companies: @companies.map do |id, name|
          {
            id: id,
            name: name
          }
        end
      }, status: :ok

    else
      render json: { error: "Invalid request" }, status: :bad_request
    end
  end

  def account_complete_company_create
    @new_company = Company.new(company_params)
    if @new_company.save
      @recruiter_permission = RecruiterPermissionsOnCompany.create!(
        recruiter: current_recruiter,
        company: @new_company,
        recruiter_position: "Recruiter",
        recruiter_status: 1, # Default to approved if not set
        can_manage_jobs: true,
        can_manage_applicants: true,
        can_manage_interviews: true,
        can_manage_offers: true,
        can_manage_company_profile: true,
        can_manage_recruiter_profile: true,
        can_manage_company_settings: true,
        can_manage_recruiter_settings: true,
        can_manage_company_users: true,
        can_manage_subscriptions_of_studern: true
      )
      if @recruiter_permission.persisted?
        current_recruiter.update(account_status: "complete")
        redirect_to recruiter_index_path, notice: "Company created successfully and you are now the owner."
      else
        redirect_to recruiter_account_complete_path, alert: "Failed to create company. Please try again."
      end
    else
      flash[:alert] = "Failed to create company. Please check the errors in the form."
      render :account_complete, status: :unprocessable_entity
    end
  end

  def account_complete_company_join
    @recruiter = current_recruiter
    @RecruiterPermissionsOnCompany = RecruiterPermissionsOnCompany.find_by(company_id: @company.id, recruiter_id: @recruiter.id)
    @latitude = @company.latitude || 23.79930876698311 # Default latitude if not set
    @longitude = @company.longitude || 90.44951877721275 # Default longitude if not set

    if @RecruiterPermissionsOnCompany.nil?
      @new_recruiter_permission = RecruiterPermissionsOnCompany.new()
    end

    if @RecruiterPermissionsOnCompany.present?
      case @RecruiterPermissionsOnCompany.recruiter_status
      when "approved"
        redirect_to recruiter_index_path, notice: "You are already a member of this company."
      when "rejected"
        flash.now[:alert] = "Your request to join this company has been rejected."
      when "blocked"
        flash.now[:alert] = "Your request to join this company has been blocked."
      else
        flash.now[:alert] = "Your request to join this company is pending approval."
      end
    end
  end

  def account_complete_company_join_post
    @recruiter = current_recruiter
    @RecruiterPermissionsOnCompany = RecruiterPermissionsOnCompany.find_by(company_id: @company.id, recruiter_id: @recruiter.id)
    if @RecruiterPermissionsOnCompany.nil?
      @new_recruiter_permission = RecruiterPermissionsOnCompany.new(
        recruiter: @recruiter,
        company: @company,
        recruiter_position: "Recruiter",
        recruiter_status: 0, # Default to pending if not set
      )
      if @new_recruiter_permission.save
        current_recruiter.update(account_status: "complete")
        # send mail to the company owner or admin to approve the join request
        CompanyMailer.with(company: @company, recruiter: @recruiter).join_request_email.deliver_now
        redirect_to recruiter_account_complete_path, notice: "Your request to join the company has been sent. Please wait for approval."
      else
        redirect_to recruiter_account_complete_path, alert: "Failed to send join request. Please try again."
      end
    end
  end

  private

  def complete_profile
    account_status = current_recruiter.account_status
    recruiter_permission = RecruiterPermissionsOnCompany.find_by(recruiter_id: current_recruiter.id)

    if account_status == "suspended" || account_status == "closed"
      redirect_to root_path, alert: "Your account is suspended or closed. Please contact support." and return
    end

    if account_status == "incomplete" || recruiter_permission.nil?
      redirect_to recruiter_account_complete_path, alert: "Please complete your profile before proceeding." and return
    end

    if account_status == "complete" && recruiter_permission.nil?
      redirect_to recruiter_account_complete_path, alert: "Please complete your account setup by selecting a company." and return
    end

    if action_name == 'account_complete'
      redirect_to recruiter_index_path, alert: "You are not allowed to access this page directly. Please complete your profile first." and return
    end
  end

  def company_params
    params.require(:company).permit(:name, :tagline, :description, :email, :phone, :website, :latitude, :longitude )
  end

  def set_company
    id = params[:company_id]
    if id.nil? || id.empty?
      redirect_to recruiter_account_complete_path, alert: "Company ID is missing." and return
    end
    if !id.match?(/\A\d+\z/)
      redirect_to recruiter_account_complete_path, alert: "Invalid Company ID format." and return
    end
    id = id.to_i
    if id <= 0
      redirect_to recruiter_account_complete_path, alert: "Invalid Company ID." and return
    end

    @company = Company.find_by(id: params[:company_id])
    if @company.nil?
      redirect_to recruiter_account_complete_path, alert: "Company not found." and return
    end
  end
end
