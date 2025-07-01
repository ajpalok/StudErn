class Recruiter::AnalyticsController < ApplicationController
  before_action :authenticate_recruiter!

  def index
    # Get all companies the recruiter is associated with (any status)
    @companies = Company.joins(:recruiter_permissions_on_companies)
                       .where(recruiter_permissions_on_companies: { recruiter_id: current_recruiter.id })
                       .includes(:recruitments)
    
    # Overall statistics
    @total_companies = @companies.count
    @total_recruitments = Recruitment.where(recruiter: current_recruiter).count
    @total_applications = RecruitmentApply.joins(:recruitment)
                                         .where(recruitments: { recruiter: current_recruiter })
                                         .count
    
    # Monthly trends
    @monthly_recruitments = get_monthly_recruitments
    @monthly_applications = get_monthly_applications
    
    # Status breakdowns
    @recruitment_status_breakdown = get_recruitment_status_breakdown
    @application_status_breakdown = get_application_status_breakdown
    
    # Top performing recruitments
    @top_recruitments = get_top_recruitments
    
    # Recent activity
    @recent_applications = RecruitmentApply.joins(:recruitment)
                                          .where(recruitments: { recruiter: current_recruiter })
                                          .includes(:user, recruitment: :company)
                                          .order(created_at: :desc)
                                          .limit(10)
    
    @recent_recruitments = Recruitment.where(recruiter: current_recruiter)
                                     .includes(:company)
                                     .order(created_at: :desc)
                                     .limit(10)
  end

  private

  def get_monthly_recruitments
    Recruitment.where(recruiter: current_recruiter)
               .where(created_at: 6.months.ago.beginning_of_month..Time.current.end_of_month)
               .group("strftime('%Y-%m', created_at)")
               .count
               .transform_keys { |k| k.present? ? Date.strptime(k, '%Y-%m').strftime("%B %Y") : "Unknown" }
  end

  def get_monthly_applications
    RecruitmentApply.joins(:recruitment)
                    .where(recruitments: { recruiter: current_recruiter })
                    .where(created_at: 6.months.ago.beginning_of_month..Time.current.end_of_month)
                    .group("strftime('%Y-%m', recruitment_applies.created_at)")
                    .count
                    .transform_keys { |k| k.present? ? Date.strptime(k, '%Y-%m').strftime("%B %Y") : "Unknown" }
  end

  def get_recruitment_status_breakdown
    Recruitment.where(recruiter: current_recruiter)
               .group(:application_collection_status)
               .count
  end

  def get_application_status_breakdown
    RecruitmentApply.joins(:recruitment)
                    .where(recruitments: { recruiter: current_recruiter })
                    .group(:status)
                    .count
  end

  def get_top_recruitments
    Recruitment.joins(:recruitment_applies)
               .where(recruiter: current_recruiter)
               .group('recruitments.id, recruitments.title')
               .order('COUNT(recruitment_applies.id) DESC')
               .limit(5)
               .count('recruitment_applies.id')
  end
end 