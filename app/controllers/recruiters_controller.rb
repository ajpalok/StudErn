require "uri"
require "net/http"

class RecruitersController < ApplicationController
  layout "recruiter"
  before_action :authenticate_recruiter!
  before_action :complete_profile, except: [ :account_complete, :account_complete_post, :account_complete_company_create, :account_complete_company_join, :account_complete_company_join_post ]
  before_action :set_company, only: [ :account_complete_company_join, :account_complete_company_join_post ]

  def index
    # all the companies the recruiter is associated with
    @companies = Company.joins(:recruiter_permissions_on_companies)
                       .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id, recruiter_status: "approved" })
                       .select("*")
    # @companies = RecruiterPermissionsOnCompany
    #               .where(recruiter_id: current_recruiter.id, recruiter_status: "approved")
    #               .includes(:company)
    #               .map(&:company)
  end

  def profile
    @user = current_recruiter
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
        @recruiter.update(account_status: "complete")
        # send mail to the company owner or admin to approve the join request
        CompanyMailer.with(company: @company, recruiter: @recruiter).join_request_email.deliver_now
        redirect_to recruiter_account_complete_path, notice: "Your request to join the company has been sent. Please wait for approval."
      else
        redirect_to recruiter_account_complete_path, alert: "Failed to send join request. Please try again."
      end
    end
  end

  def recruitment_publish
    # here will be shown all the companies the recruiter is associated with to publish jobs and internships
    # @companies will contain current_recruiter.companies which companies are approved in recruiter_permissions_on_companies table
    @companies = RecruiterPermissionsOnCompany
                  .where(recruiter_id: current_recruiter.id, recruiter_status: "approved", can_manage_jobs: true)
                  .includes(:company)
                  .map(&:company)

    unless params[:company].present?
      # if @companies is only one company, redirect to the recruitment publish page of that company
      if @companies.length == 1 && params[:company].nil?
        redirect_to recruiter_recruitment_publish_path(company: @companies.first.id) and return
      end
      return
    end

    company_params = params[:company]

    if !company_params.match?(/\A\d+\z/)
      redirect_to recruiter_index_path, alert: "Invalid Company ID format." and return
    end

    if company_params.to_i <= 0
      redirect_to recruiter_index_path, alert: "Invalid Company ID." and return
    end

    # @company will be the data from @companies where the id matches the company_params
    @company = @companies.find { |c| c.id == company_params.to_i }
    if @company.nil?
      redirect_to recruiter_recruitment_publish_path, alert: "Invalid request." and return
    end

    @recruitment = Recruitment.new()
  end

  def recruitment_publish_create
    unless params[:company].present?
      redirect_to recruiter_recruitment_publish_path, alert: "Company ID is missing." and return
    end

    if !params[:company].match?(/\A\d+\z/)
      redirect_to recruiter_index_path, alert: "Invalid Company ID format." and return
    end

    if params[:company].to_i <= 0
      redirect_to recruiter_index_path, alert: "Invalid Company ID." and return
    end

    @recruiter = current_recruiter

    @company = RecruiterPermissionsOnCompany
            .where(recruiter_id: @recruiter.id, recruiter_status: "approved", can_manage_jobs: true, company_id: params[:company])
            .includes(:company)
            .map(&:company)
            .first

    if @company.nil?
      redirect_to recruiter_recruitment_publish_path, alert: "Invalid request." and return
    end

    @recruitment = Recruitment.new(recruitment_params)
    @recruitment.company = @company
    @recruitment.recruiter = @recruiter

    if @recruitment.save
      # redirect_to recruiter_index_path, notice: "Recruitment published successfully."
      # now we will redirect to the recruitment payment page
      flash.now[:notice] = "Recruitment created successfully."
      redirect_to recruiter_recruitment_publish_complete_path(@company.id, @recruitment.id)
    else
      flash.now[:alert] = "Failed to publish recruitment. Please check the errors in the form."
      render :recruitment_publish, status: :unprocessable_entity
    end
  end

  def recruitment_publish_complete
    unless params[:company_id].present? || params[:recruitment_id].present?
      redirect_to recruiter_index_path, alert: "URL is missing some credentials." and return
    end

    unless params[:company_id].match?(/\A\d+\z/) || params[:recruitment_id].match?(/\A\d+\z/)
      redirect_to recruiter_index_path, alert: "Invalid URL format." and return
    end

    if params[:company_id].to_i <= 0 || params[:recruitment_id].to_i <= 0
      redirect_to recruiter_index_path, alert: "Invalid URL details." and return
    end

    @recruiter = current_recruiter

    @recruitment_by_current_recruiter_of_company = Company.joins(:recruiter_permissions_on_companies, :recruitments)
                                            .where(id: params[:company_id],
                                                   recruiter_permissions_on_companies: {
                                                     recruiter_id: @recruiter.id,
                                                     can_manage_subscriptions_of_studern: true
                                                   },
                                                   recruitments: { id: params[:recruitment_id] }
                                            )
                                            .select("*").first

    if @recruitment_by_current_recruiter_of_company.nil?
      redirect_to recruiter_index_path, alert: "You are not authorized to view this recruitment." and return
    end

    # if the current_recruiter_of_company is paid then redirect to the recruiter index page
    if @recruitment_by_current_recruiter_of_company.bkash_payment_id.present?
      # check if the payment is successful
      bkash_payment = BkashPayment.find(@recruitment_by_current_recruiter_of_company.bkash_payment_id.to_i)
      redirect_to recruiter_index_path, notice: "This recruitment is already paid." and return if bkash_payment.trx_status == "success"
    end

    if @recruitment_by_current_recruiter_of_company.can_manage_subscriptions_of_studern == false
      redirect_to recruiter_index_path, alert: "You are not authorized to view this recruitment." and return
    end

    # now have the payment process for the recruitment

    @PayPackages = [
      {
        name: "Basic",
        price: 3850,
        description: [
          "This is recruitment package will be shown in the platform in basic form",
          "More differences will be added in the future"
        ]
      },
      {
        name: "Standard",
        price: 4500,
        description: [
          "This is recruitment package will be shown in the platform in more popup form",
          "More differences will be added in the future"
        ]
      },
      {
        name: "Premium",
        price: 5300,
        description: [
          "This is recruitment package will be shown in the platform in first place for 3 days then in popup form",
          "More differences will be added in the future"
        ]
      }
    ]

    if params[:package].present?

      @selected_package = @PayPackages.find { |p| p[:name].downcase == params[:package].downcase }

      unless @selected_package.present?
        redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: "Invalid package selected." and return
      end

      if @selected_package.nil?
        redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: "Invalid package selected." and return
      end

      session[:selected_package] = @selected_package
      # now call the bkash_payment_service to create a payment request
      bkash_payment_service(@selected_package[:price])
    end

    if params[:paymentID].present? && params[:status].present?
      # handle the callback from bkash
      bkash_payment_check = BkashPayment.find_by(payment_id: params[:paymentID])

      if bkash_payment_check.nil?
        redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: "Invalid payment request." and return
      end

      @bkash_pay_type = "sandbox" # "sandbox" for development or "pay" for production

      # service to handle Bkash payment requests
      bkash_keys = Rails.application.credentials.bkash.dig(@bkash_pay_type.to_sym)

      if params[:status] == "success"
        url = URI("https://tokenized.#{@bkash_pay_type}.bka.sh/v1.2.0-beta/tokenized/checkout/execute")
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true

        request = Net::HTTP::Post.new(url)
        request["content-type"] = "application/json"
        request["accept"] = "application/json"
        request["Authorization"] = "#{session[:bkash_id_token]}"
        request["X-APP-KEY"] = bkash_keys["app_key"]
        request.body = {
          paymentID: params[:paymentID]
        }.to_json

        response = http.request(request)
        response = JSON.parse(response.body)

        logger.info "Bkash Payment Response: #{response.inspect}"

        if response["statusCode"] != "0000"
          redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: response["statusMessage"] and return
        end

        bkash_payment_check.update(
          trx_id: params[:trxID],
          trx_status: params[:status],
        )

        # now update the recruitment with the bkash_payment_id
        @recruitment = Recruitment.find_by(id: params[:recruitment_id], company_id: params[:company_id], recruiter_id: @recruiter.id)

        if @recruitment.nil?
          redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: "Invalid recruitment details." and return
        end

        @recruitment.bkash_payment_id = bkash_payment_check.id
        @recruitment.application_package = session[:selected_package]["name"].downcase
        @recruitment.application_collection_status = "open" # set the application collection status to open

        if @recruitment.save
          redirect_to recruiter_index_path, notice: "Payment processed successfully. Recruitment published." and return
        end
      else
        bkash_payment_check.update(
          trx_status: params[:status],
          verification_status: "failed"
        )
        redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: "Payment failed. Please try again." and return
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

    if action_name == "account_complete"
      redirect_to recruiter_index_path, alert: "You are not allowed to access this page directly. Please complete your profile first." and return
    end
  end

  def company_params
    params.require(:company).permit(:name, :tagline, :description, :email, :phone, :website, :latitude, :longitude)
  end

  def recruitment_params
    params.require(:recruitment).permit(
      :recruitment_type,
      :title,
      :description,
      :work_type,
      :work_place,
      :latitude,
      :longitude,
      :salary_type,
      :annual_salary_range_start,
      :annual_salary_range_end,
      :experience_level,

      # applications collection process
      :number_of_vacancies,
      :application_collection_status,
      :application_collection_end_date,
      :application_package,
      :application_collection_method,
      :application_link,
      :calling_number,

      # relationships
      :company_id,
      :recruiter_id,
      :bkash_payment_id
    )
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

  def bkash_payment_service(amount)
    @bkash_pay_type = "sandbox" # "sandbox" for development or "pay" for production

    # service to handle Bkash payment requests
    bkash_keys = Rails.application.credentials.bkash.dig(@bkash_pay_type.to_sym)

    url = URI("https://tokenized.#{@bkash_pay_type}.bka.sh/v1.2.0-beta/tokenized/checkout/token/grant")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["Content-Type"] = "application/json"
    request["accept"] = "application/json"
    request["username"] = bkash_keys["username"]
    request["password"] = bkash_keys["password"]
    request.body = {
      "app_key": bkash_keys["app_key"],
      "app_secret": bkash_keys["app_secret"]
    }.to_json

    response = http.request(request)
    response = JSON.parse(response.body)

    if response["statusCode"] != "0000"
      flash.now[:alert] = response["statusMessage"]
      return redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id])
    end

    # now get the token from the response
    id_token = response["id_token"]
    # ADD to session or use it directly
    session[:bkash_id_token] = id_token

    if id_token.nil? || id_token.empty?
      flash.now[:alert] = response["statusMessage"] || "Failed to get Bkash token. Please try again."
      return redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id])
    end

    url = URI("https://tokenized.#{@bkash_pay_type}.bka.sh/v1.2.0-beta/tokenized/checkout/create")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url)
    request["content-type"] = "application/json"
    request["accept"] = "application/json"
    request["Authorization"] = id_token
    request["X-APP-KEY"] = bkash_keys["app_key"]
    request.body = {
      mode: "0011",
      amount: amount.to_s,
      currency: "BDT",
      intent: "sale",
      merchantInvoiceNumber: "Recruitment-#{params[:recruitment_id]}-#{Time.now.to_i}",
      payerReference: "Recruiter-#{current_recruiter.id}",
      callbackURL: "#{ENV['HOST'] || "http://localhost:5000"}/recruiter/recruitment-publish/#{params[:company_id]}/#{params[:recruitment_id]}/"
    }.to_json

    response = http.request(request)
    response = JSON.parse(response.body)

    if response["statusCode"] != "0000"
      flash.now[:alert] = response["statusMessage"] || "Failed to create payment request. Please try again."
      return redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id])
    end

    # now we have the payment request created successfully
    # we will save the paymentID in the database
    bkashURL = response["bkashURL"]
    payment_id = response["paymentID"]

    bkash_payment_create = BkashPayment.create(
      payment_from: "recruitment",
      payment_id: payment_id,
      amount: amount.to_s
    )

    if bkash_payment_create.persisted?
      # redirect to the bkash payment URL
      redirect_to bkashURL, allow_other_host: true
    else
      redirect_to recruiter_recruitment_publish_complete_path(params[:company_id], params[:recruitment_id]), alert: "Failed to create payment request. Please try again."
    end

    # redirect_to recruiter_recruitment_publish_complete_path(company_id: params[:company_id], recruitment_id: params[:recruitment_id]), notice: "Payment processed successfully."
  end
end
