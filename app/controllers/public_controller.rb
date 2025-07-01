class PublicController < ApplicationController
  layout :resolve_layout
  before_action :redirect_if_user_signed_in, only: [ :home ]

  def home
    # Fetch latest jobs (recruitment_type: job) with successful payments
    @latest_jobs = Recruitment.where(recruitment_type: "job")
                             .joins(:bkash_payment, :company)
                             .where(bkash_payments: { trx_status: "success" })
                             .where(application_collection_status: "open")
                             .order(created_at: :desc)
                             .limit(6)

    # Fetch latest internships (recruitment_type: internship) with successful payments
    @latest_internships = Recruitment.where(recruitment_type: "internship")
                                   .joins(:bkash_payment, :company)
                                   .where(bkash_payments: { trx_status: "success" })
                                   .where(application_collection_status: "open")
                                   .order(created_at: :desc)
                                   .limit(6)

    # Fetch latest published courses
    @latest_courses = Course.published
                           .includes(:control_unit)
                           .order(featured: :desc, created_at: :desc)
                           .limit(6)
  end

  def about
  end

  def contact
    @contact = Contactform.new
  end

  def contact_post
    unless params[:contactform].present?
      flash.now[:alert] = "Please fill out the contact form."
      render :contact and return
    end
    @contact = Contactform.new(params.require(:contactform).permit(
      :name,
      :email,
      :phone,
      :message
    ))

    if @contact.save
      redirect_to root_path, notice: "Thank you for contacting us. We will get back to you soon."
    else
      flash.now[:alert] = "Failed to send your message. Please try again."
    end
  end
  def jobs_all
    # recruitment type job and micro jobs will be here
    @jobs = Recruitment.where(
      recruitment_type: [ "job", "micro_job" ],
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .where(application_collection_status: "open")
    .includes(:company)
    .order(created_at: :desc)

    # Apply filters if parameters are present
    @jobs = apply_filters(@jobs)
  end

  def jobs
    @jobs = Recruitment.where(
      recruitment_type: "job",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .where(application_collection_status: "open")
    .includes(:company)
    .order(created_at: :desc)

    # Apply filters if parameters are present
    @jobs = apply_filters(@jobs)
  end

  def micro_jobs
    @micro_jobs = Recruitment.where(
      recruitment_type: "micro_job",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .where(application_collection_status: "open")
    .includes(:company)
    .order(created_at: :desc)

    # Apply filters if parameters are present
    @micro_jobs = apply_filters(@micro_jobs)
  end

  def internships_all
    @internships = Recruitment.where(
      recruitment_type: [ "internship", "micro_internship" ],
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .where(application_collection_status: "open")
    .includes(:company)
    .order(created_at: :desc)

    # Apply filters if parameters are present
    @internships = apply_filters(@internships)
  end

  def internships
    @internships = Recruitment.where(
      recruitment_type: "internship",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .where(application_collection_status: "open")
    .includes(:company)
    .order(created_at: :desc)

    # Apply filters if parameters are present
    @internships = apply_filters(@internships)
  end

  def micro_internships
    @micro_internships = Recruitment.where(
      recruitment_type: "micro_internship",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .where(application_collection_status: "open")
    .includes(:company)
    .order(created_at: :desc)

    # Apply filters if parameters are present
    @micro_internships = apply_filters(@micro_internships)
  end

  def recruitment
    unless params[:recruitment_id].present? && params[:recruitment_id].match?(/^\d+$/)
      redirect_to root_path, alert: "Invalid recruitment ID."
      return
    end

    @recruitment = Recruitment.joins(:bkash_payment)
                             .where(bkash_payments: { trx_status: "success" })
                             .find_by(id: params[:recruitment_id])

    if @recruitment.nil?
      redirect_to root_path, alert: "Recruitment not found or not available."
    else
      @company = @recruitment.company
      @recruiter = @recruitment.recruiter
      @bkash_payment = @recruitment.bkash_payment if @recruitment.bkash_payment.present?
    end
  end


  def privacy_policy
  end

  def map_demo
  end

  private
  def redirect_if_user_signed_in
    if user_signed_in?
      redirect_to user_index_path, notice: "You are already signed in."
    end
  end

  def resolve_layout
    # if the user is signed in then return the user layout
    if user_signed_in?
      "user"
    else
      "application"
    end
  end

  def apply_filters(recruitments)
    # Search filter
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      recruitments = recruitments.joins(:company)
                                .where("recruitments.title LIKE ? OR companies.name LIKE ? OR recruitments.description LIKE ?", 
                                       search_term, search_term, search_term)
    end

    # Work place filter
    if params[:work_place].present?
      recruitments = recruitments.where(work_place: params[:work_place])
    end

    # Work type filter
    if params[:work_type].present?
      recruitments = recruitments.where(work_type: params[:work_type])
    end

    # Experience level filter
    if params[:experience_level].present?
      recruitments = recruitments.where(experience_level: params[:experience_level])
    end

    # Salary type filter
    if params[:salary_type].present?
      recruitments = recruitments.where(salary_type: params[:salary_type])
    end

    # Date range filter
    if params[:date_range].present?
      recruitments = apply_date_filter(recruitments, params[:date_range])
    end

    recruitments
  end

  def apply_date_filter(recruitments, date_range)
    case date_range
    when 'today'
      recruitments.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)
    when 'week'
      recruitments.where(created_at: 1.week.ago..Time.current)
    when 'month'
      recruitments.where(created_at: 1.month.ago..Time.current)
    when '3months'
      recruitments.where(created_at: 3.months.ago..Time.current)
    when '6months'
      recruitments.where(created_at: 6.months.ago..Time.current)
    when 'year'
      recruitments.where(created_at: 1.year.ago..Time.current)
    else
      recruitments
    end
  end
end
