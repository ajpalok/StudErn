class ControlUnitsController < ApplicationController
  layout 'control_unit'
  before_action :authenticate_control_unit!

  def index
    # System-wide statistics
    @system_stats = {
      total_users: User.count,
      total_recruiters: Recruiter.count,
      total_companies: Company.count,
      total_recruitments: Recruitment.count,
      total_applications: RecruitmentApply.count,
      total_courses: Course.count,
      total_course_applications: CourseApplication.count,
      total_control_units: ControlUnit.count
    }

    # User statistics
    @user_stats = {
      confirmed_users: User.where.not(confirmed_at: nil).count,
      unconfirmed_users: User.where(confirmed_at: nil).count,
      users_this_month: User.where(created_at: 1.month.ago..Time.current).count,
      users_this_week: User.where(created_at: 1.week.ago..Time.current).count
    }

    # Recruiter statistics
    @recruiter_stats = {
      confirmed_recruiters: Recruiter.where.not(confirmed_at: nil).count,
      unconfirmed_recruiters: Recruiter.where(confirmed_at: nil).count,
      recruiters_this_month: Recruiter.where(created_at: 1.month.ago..Time.current).count,
      recruiters_this_week: Recruiter.where(created_at: 1.week.ago..Time.current).count
    }

    # Recruitment statistics
    @recruitment_stats = {
      active_recruitments: Recruitment.where(application_collection_status: "open").count,
      draft_recruitments: Recruitment.where(application_collection_status: "draft").count,
      closed_recruitments: Recruitment.where(application_collection_status: "close").count,
      recruitments_this_month: Recruitment.where(created_at: 1.month.ago..Time.current).count
    }

    # Application statistics
    @application_stats = {
      pending_applications: RecruitmentApply.where(status: "pending").count,
      accepted_applications: RecruitmentApply.where(status: "accepted").count,
      rejected_applications: RecruitmentApply.where(status: "rejected").count,
      withdrawn_applications: RecruitmentApply.where(status: "withdrawn").count,
      applications_this_month: RecruitmentApply.where(created_at: 1.month.ago..Time.current).count
    }

    # Course statistics
    @course_stats = {
      active_courses: Course.where(status: "active").count,
      inactive_courses: Course.where(status: "inactive").count,
      featured_courses: Course.where(featured: true).count,
      courses_this_month: Course.where(created_at: 1.month.ago..Time.current).count
    }

    # Monthly trends
    @monthly_trends = get_monthly_trends

    # Recent activity
    @recent_users = User.order(created_at: :desc).limit(5)
    @recent_recruiters = Recruiter.order(created_at: :desc).limit(5)
    @recent_recruitments = Recruitment.includes(:company, :recruiter).order(created_at: :desc).limit(5)
    @recent_applications = RecruitmentApply.includes(:user, recruitment: :company).order(created_at: :desc).limit(5)
    @recent_courses = Course.includes(:control_unit).order(created_at: :desc).limit(5)

    # Top performing companies
    @top_companies = Company.joins(:recruitments)
                           .group('companies.id, companies.name')
                           .order('COUNT(recruitments.id) DESC')
                           .limit(5)
                           .count('recruitments.id')

    # Top performing recruitments
    @top_recruitments = Recruitment.joins(:recruitment_applies, :company)
                                  .group('recruitments.id, recruitments.title, companies.name')
                                  .order('COUNT(recruitment_applies.id) DESC')
                                  .limit(5)
                                  .count('recruitment_applies.id')
  end

  def profile
  end

  private

  def get_monthly_trends
    trends = []
    6.times do |i|
      month_start = i.months.ago.beginning_of_month
      month_end = i.months.ago.end_of_month
      
      month_stats = {
        month: month_start.strftime("%B %Y"),
        users: User.where(created_at: month_start..month_end).count,
        recruiters: Recruiter.where(created_at: month_start..month_end).count,
        recruitments: Recruitment.where(created_at: month_start..month_end).count,
        applications: RecruitmentApply.where(created_at: month_start..month_end).count,
        courses: Course.where(created_at: month_start..month_end).count
      }
      
      trends.unshift(month_stats)
    end
    
    trends
  end
end
