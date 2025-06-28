class PublicController < ApplicationController
  before_action :redirect_if_user_signed_in, only: [ :home ]

  def home
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
    .order(created_at: :desc)

    # if params are available then filter the objects
  end

  def jobs
    @jobs = Recruitment.where(
      recruitment_type: "job",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .order(created_at: :desc)

    # if params are available then filter the objects
  end

  def micro_jobs
    @micro_jobs = Recruitment.where(
      recruitment_type: "micro_job",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .order(created_at: :desc)

    # if params are available then filter the objects
  end

  def internships_all
    @internships = Recruitment.where(
      recruitment_type: [ "internship", "micro_internship" ],
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .order(created_at: :desc)

    # if params are available then filter the objects
  end

  def internships
    @internships = Recruitment.where(
      recruitment_type: "internship",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .order(created_at: :desc)

    # if params are available then filter the objects
  end

  def micro_internships
    @micro_internships = Recruitment.where(
      recruitment_type: "micro_internship",
    )
    .joins(:bkash_payment)
    .where(bkash_payments: { trx_status: "success" })
    .order(created_at: :desc)

    # if params are available then filter the objects
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
end
