class UsersController < ApplicationController
  layout "user"
  before_action :authenticate_user!
  layout "authentication", only: [:onboarding, :onboarding_update]

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
      redirect_to user_resume_path, notice: "Resume updated successfully."
    else
      render :resume, status: :unprocessable_entity
    end
  end

  def apply_to_recruitment
    @recruitment = Recruitment.find(params[:recruitment_id])
    
    unless @recruitment.user_can_apply?(current_user)
      redirect_to recruitment_path(@recruitment), alert: "You cannot apply to this recruitment."
      return
    end

    @application = current_user.recruitment_applies.build(recruitment: @recruitment)

    if @application.save
      redirect_to recruitment_path(@recruitment), notice: "Application submitted successfully!"
    else
      redirect_to recruitment_path(@recruitment), alert: @application.errors.full_messages.join(", ")
    end
  end

  def withdraw_application
    @application = current_user.recruitment_applies.find(params[:application_id])
    
    if @application.update(status: :withdrawn)
      redirect_to user_applications_path, notice: "Application withdrawn successfully."
    else
      redirect_to user_applications_path, alert: "Failed to withdraw application."
    end
  end

  def applications
    @applications = current_user.recruitment_applies.includes(:recruitment).order(created_at: :desc)
  end

  # Onboarding methods
  def onboarding
    redirect_to user_index_path if current_user.account_status == "complete"
    redirect_to new_user_confirmation_path unless current_user.confirmed_at.present?
    @user = current_user
    @step = (params[:step] || 1).to_i
    @total_steps = 2
  end

  def onboarding_update
    @user = current_user
    @step = params[:step].to_i
    @total_steps = 2
    @user.set_onboarding_step(@step)

    if @user.update(onboarding_params)
      if @step == @total_steps
        # All steps completed, mark account as complete
        @user.update(account_status: "complete")
        redirect_to user_index_path, notice: "Profile completed successfully! You can now apply to jobs."
      else
        # Move to next step
        redirect_to user_onboarding_path(step: @step + 1)
      end
    else
      # Preserve the step when rendering due to validation errors
      render :onboarding, status: :unprocessable_entity
    end
  end

  def onboarding_back
    @step = params[:step].to_i
    if @step > 1
      redirect_to user_onboarding_path(step: @step - 1)
    else
      redirect_to user_onboarding_path(step: 1)
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

  def onboarding_params
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
