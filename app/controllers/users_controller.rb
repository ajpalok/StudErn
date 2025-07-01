class UsersController < ApplicationController
  layout :resolve_layout
  before_action :authenticate_user!
  # layout "authentication", only: [:onboarding, :onboarding_update]

  def index
  end

  def profile
    @user = current_user
  end

  def resume
    @user = current_user

    # Load existing records - these will be displayed as editable forms
    # The form will show all existing records and allow adding new ones
    # No need to build empty records since we're using dynamic addition via Stimulus
  end

  def resume_update
    @user = current_user

    if @user.update(user_params)
      respond_to do |format|
        format.html { redirect_to user_resume_path, notice: "Resume updated successfully." }
        format.json { render json: { success: true, message: "Resume updated successfully." } }
      end
    else
      respond_to do |format|
        format.html { render :resume, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @user.errors.full_messages }, status: :unprocessable_entity }
      end
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
      user_educations_attributes: [:id, :institution_name, :degree, :performance_type, :performance, :start_date, :end_date, :currently_studying, :_destroy],
      user_skills_attributes: [:id, :skill_name, :skill_level, :user_work_experiences_id, :_destroy],
      user_work_experiences_attributes: [:id, :company_name, :designation, :start_date, :end_date, :currently_working, :job_responsibilities, :employment_type, :company_id, :_destroy],
      user_accomplishments_attributes: [:id, :accomplishment_type, :accomplishment_url, :accomplishment_name, :accomplishment_description, :accomplishment_start_date, :accomplishment_end_date, :ongoing, :_destroy]
    )
  end

  def onboarding_params
    user_params = params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone,
      :latitude,
      :longitude,
      :career_objective,
      :dob,
      :gender,
      user_educations_attributes: {},
      user_skills_attributes: {},
      user_work_experiences_attributes: {},
      user_accomplishments_attributes: {}
    )
    
    # Handle nested attributes with dynamic keys
    if params[:user][:user_educations_attributes]
      user_params[:user_educations_attributes] = params[:user][:user_educations_attributes].permit!
    end
    
    if params[:user][:user_skills_attributes]
      user_params[:user_skills_attributes] = params[:user][:user_skills_attributes].permit!
    end
    
    if params[:user][:user_work_experiences_attributes]
      user_params[:user_work_experiences_attributes] = params[:user][:user_work_experiences_attributes].permit!
    end
    
    if params[:user][:user_accomplishments_attributes]
      user_params[:user_accomplishments_attributes] = params[:user][:user_accomplishments_attributes].permit!
    end
    
    user_params
  end

  def resolve_layout
    if %w[onboarding onboarding_update onboarding_back].include?(action_name)
      "authentication"
    else
      "user"
    end
  end
end
