class UsersController < ApplicationController
  layout "user"
  before_action :authenticate_user!

  def index
  end

  def profile
    @user = current_user
  end

  def resume
    @user = current_user

    @user.user_educations.build if @user.user_educations.empty?
    @user.user_skills.build if @user.user_skills.empty?
    @user.user_work_experiences.build if @user.user_work_experiences.empty?
    @user.user_accomplishments.build if @user.user_accomplishments.empty?
  end

  def resume_update
    @user = current_user

    if @user.update(user_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Resume updated successfully."
          render turbo_stream: turbo_stream.replace("resume_form", partial: "users/resume_form", locals: { user: @user, refresh_token: SecureRandom.hex(4) })
        end
        format.html { redirect_to user_resume_path, notice: "Resume updated successfully." }
      end
      # redirect_to user_resume_path, notice: "Resume updated successfully."
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Failed to update resume."
          render turbo_stream: turbo_stream.replace("resume_form", partial: "users/resume_form", locals: { user: @user, refresh_token: SecureRandom.hex(4) })
        end
        format.html { render :resume, alert: "Failed to update resume." }
      end
      # render :resume, alert: "Failed to update resume."
    end
  end

  private
  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :latitude,
      :longitude,
      :career_objective,
      :dob,
      :gender,
      user_educations_attributes: [ :id, :degree, :institution_name, :performance_type, :performance, :start_date, :end_date, :currently_studying, :_destroy ],
      user_skills_attributes: [ :id, :skill_name, :skill_level, :_destroy ],
      user_work_experiences_attributes: [ :id, :designation, :company_name, :start_date, :end_date, :currently_working, :job_responsibilities, :employment_type, :_destroy ],
      user_accomplishments_attributes: [ :id, :accomplishment_type, :accomplishment_url, :accomplishment_name, :accomplishment_description, :accomplishment_start_date, :accomplishment_end_date, :ongoing, :_destroy ]
    )
  end
end
