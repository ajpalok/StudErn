class ControlUnit::CoursesController < ApplicationController
  before_action :authenticate_control_unit!
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  before_action :ensure_authorized, only: [:show, :edit, :update, :destroy]

  def index
    @courses = current_control_unit.courses.includes(:course_applications)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(10)
  end

  def show
    @course_applications = @course.course_applications.includes(:user)
                                  .order(created_at: :desc)
                                  .page(params[:page])
                                  .per(10)
  end

  def new
    @course = current_control_unit.courses.build
  end

  def create
    @course = current_control_unit.courses.build(course_params)
    
    if @course.save
      redirect_to control_unit_course_path(@course), notice: 'Course was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @course.update(course_params)
      redirect_to control_unit_course_path(@course), notice: 'Course was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to control_unit_courses_path, notice: 'Course was successfully deleted.'
  end

  def applications
    @course = current_control_unit.courses.find(params[:id])
    @applications = @course.course_applications.includes(:user)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
  end

  def update_application_status
    @application = CourseApplication.find(params[:application_id])
    @course = @application.course
    
    # Ensure the course belongs to the current control unit
    unless @course.control_unit == current_control_unit
      redirect_to control_unit_courses_path, alert: 'Unauthorized access.'
      return
    end

    if @application.update(application_params)
      redirect_to applications_control_unit_course_path(@course), 
                  notice: "Application status updated to #{@application.status_display}."
    else
      redirect_to applications_control_unit_course_path(@course), 
                  alert: 'Failed to update application status.'
    end
  end

  def review_application
    @application = CourseApplication.find(params[:application_id])
    @course = @application.course
    
    # Ensure the course belongs to the current control unit
    unless @course.control_unit == current_control_unit
      redirect_to control_unit_courses_path, alert: 'Unauthorized access.'
      return
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def ensure_authorized
    unless @course.control_unit == current_control_unit
      redirect_to control_unit_courses_path, alert: 'Unauthorized access.'
    end
  end

  def course_params
    params.require(:course).permit(
      :title, :description, :duration, :price, :instructor, 
      :category, :status, :image_url, :syllabus, :max_students,
      :start_date, :end_date, :featured
    )
  end

  def application_params
    params.require(:course_application).permit(:status, :admin_notes)
  end
end
