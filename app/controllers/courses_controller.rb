class CoursesController < ApplicationController
  before_action :set_course, only: [:show, :apply]
  before_action :authenticate_user!, only: [:apply, :my_applications]

  def index
    @courses = Course.published.includes(:control_unit)
                    .order(featured: :desc, created_at: :desc)
                    .page(params[:page])
                    .per(12)
    
    @categories = Course.published.distinct.pluck(:category).compact.sort
    @featured_courses = Course.published.featured.includes(:control_unit).limit(6)
  end

  def show
    @related_courses = Course.published.where(category: @course.category)
                            .where.not(id: @course.id)
                            .includes(:control_unit)
                            .limit(4)
  end

  def apply
    unless current_user.has_complete_profile?
      redirect_to user_onboarding_path, alert: 'Please complete your profile before applying to courses.'
      return
    end

    unless @course.can_apply?(current_user)
      redirect_to course_path(@course), alert: 'You cannot apply to this course.'
      return
    end

    @application = current_user.course_applications.build(
      course: @course,
      message: params[:message]
    )

    if @application.save
      redirect_to course_path(@course), notice: 'Your application has been submitted successfully!'
    else
      redirect_to course_path(@course), alert: 'Failed to submit application. Please try again.'
    end
  end

  def my_applications
    @applications = current_user.course_applications.includes(:course)
                               .order(created_at: :desc)
                               .page(params[:page])
                               .per(10)
  end

  def withdraw_application
    @application = current_user.course_applications.find(params[:id])
    
    if @application.withdraw!
      redirect_to my_applications_courses_path, notice: 'Application withdrawn successfully.'
    else
      redirect_to my_applications_courses_path, alert: 'Failed to withdraw application.'
    end
  end

  def search
    @courses = Course.published.includes(:control_unit)
    
    if params[:category].present?
      @courses = @courses.by_category(params[:category])
    end
    
    if params[:query].present?
      @courses = @courses.where("title ILIKE ? OR description ILIKE ?", 
                               "%#{params[:query]}%", "%#{params[:query]}%")
    end
    
    @courses = @courses.order(featured: :desc, created_at: :desc)
                      .page(params[:page])
                      .per(12)
    
    @categories = Course.published.distinct.pluck(:category).compact.sort
    
    render :index
  end

  private

  def set_course
    @course = Course.published.find(params[:id])
  end
end
