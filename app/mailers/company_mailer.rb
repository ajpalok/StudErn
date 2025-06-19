class CompanyMailer < ApplicationMailer
  default from: 'no-reply@2haas.com'

  def join_request_email
    @recruiter = params[:recruiter]
    @company = params[:company]

    mail(
      to: @company.email,
      subject: "New join request from #{@recruiter.full_name}"
    )
  end
end
