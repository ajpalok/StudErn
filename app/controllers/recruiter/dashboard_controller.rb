class Recruiter::DashboardController < ApplicationController
  before_action :authenticate_recruiter!

  def index
    @companies = Company.joins(:recruiter_permissions_on_companies)
                       .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                       .includes(:recruitments)
    
    # Overall statistics across all companies
    @stats = {
      total_companies: @companies.count,
      total_recruitments: Recruitment.where(recruiter: current_recruiter).count,
      total_applications: RecruitmentApply.joins(:recruitment)
                                         .where(recruitments: { recruiter: current_recruiter })
                                         .count,
      pending_requests: current_recruiter.recruiter_permissions_on_companies
                                        .where(recruiter_status: 0) # pending
                                        .count
    }

    # Recent recruitments across all companies
    @recent_recruitments = Recruitment.where(recruiter: current_recruiter)
                                     .includes(:company)
                                     .order(created_at: :desc)
                                     .limit(5)

    # Recent applications across all companies
    @recent_applications = RecruitmentApply.joins(:recruitment)
                                          .where(recruitments: { recruiter: current_recruiter })
                                          .includes(:user, recruitment: :company)
                                          .order(created_at: :desc)
                                          .limit(5)
  end
end 