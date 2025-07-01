class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :confirmable, :rememberable, :validatable

  # Associations
  # has_many :recruitments, dependent: :destroy
  has_many :recruitment_applies, dependent: :destroy
  has_many :applied_recruitments, through: :recruitment_applies, source: :recruitment
  has_many :user_educations, dependent: :destroy
  has_many :user_work_experiences, dependent: :destroy
  has_many :user_skills, dependent: :destroy
  has_many :user_accomplishments, dependent: :destroy
  has_many :course_applications, dependent: :destroy
  has_many :applied_courses, through: :course_applications, source: :course

  # Nested attributes
  accepts_nested_attributes_for :user_educations, allow_destroy: true
  accepts_nested_attributes_for :user_work_experiences, allow_destroy: true
  accepts_nested_attributes_for :user_skills, allow_destroy: true
  accepts_nested_attributes_for :user_accomplishments, allow_destroy: true

  # Callbacks
  before_save :set_default_account_status, if: :new_record?

  # Enums
  enum :gender, { male: 1, female: 2, other: 3 }
  enum :account_status, { incomplete: 0, complete: 1, suspended: 2, closed: 3 }

  # Validations
  validate :firstname_validation, if: :should_validate_profile?
  validate :lastname_validation, if: :should_validate_profile?
  validate :phone_validation, if: :should_validate_profile?
  validate :coordinates_validation, if: :should_validate_profile?
  validate :career_objective_validation, if: :should_validate_profile?
  validate :dob_validation, if: :should_validate_profile?
  validate :gender_validation, if: :should_validate_profile?

  # Onboarding validations
  validate :onboarding_step_validation, if: :onboarding_in_progress?

  # Public method for controller usage
  def set_onboarding_step(step)
    @onboarding_step = step
  end

  def full_name
    [first_name, last_name].compact.join(' ').strip.presence || email
  end

  def has_complete_profile?
    account_status == "complete"
  end

  def can_apply_to_recruitment?(recruitment)
    return false unless has_complete_profile?
    return false if recruitment_applies.exists?(recruitment: recruitment)
    recruitment.user_can_apply?(self)
  end

  private
  def set_default_account_status
    self.account_status ||= 0 # Default to incomplete if not set
  end

  def should_validate_profile?
    # Only validate profile fields if user is confirmed and account is not complete
    confirmed_at.present? && account_status != "complete"
  end

  def firstname_validation
    if first_name.blank?
      return errors.add(:first_name, "can't be blank")
    end
    if first_name.length < 2
      return errors.add(:first_name, "must be at least 2 characters long")
    end
    if first_name.length > 50
      return errors.add(:first_name, "must be at most 50 characters long")
    end
    if !first_name.match?(/\A[\w.\-#&\s]*\z/)
      errors.add(:first_name, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end

  def lastname_validation
    if last_name.blank?
      return errors.add(:last_name, "can't be blank")
    end
    if last_name.length < 2
      return errors.add(:last_name, "must be at least 2 characters long")
    end
    if last_name.length > 50
      return errors.add(:last_name, "must be at most 50 characters long")
    end
    if !last_name.match?(/\A[\w.\-#&\s]*\z/)
      errors.add(:last_name, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end

  def phone_validation
    if phone.blank?
      return errors.add(:phone, "can't be blank")
    end

    custom_phone = CustomPhone.new(phone)

    if custom_phone.isEmpty?
      return errors.add(:phone, "can't be blank")
    end

    unless custom_phone.valid_size?
      return errors.add(:phone, "must be 11 digits long")
    end

    unless custom_phone.valid_format?
      return errors.add(:phone, "must be a valid Bangladeshi phone number")
    end

    self.phone = custom_phone.getFullNumber
  end

  def coordinates_validation
    if latitude.present? && (latitude < -90 || latitude > 90) && longitude.present? && (longitude < -180 || longitude > 180)
      errors.add(:base, "Location is not valid.")
    end
  end

  def career_objective_validation
    if career_objective.blank?
      return
    end
    if career_objective.length < 10
      return errors.add(:career_objective, "must be at least 10 characters long")
    end
    if career_objective.length > 500
      return errors.add(:career_objective, "must be at most 500 characters long")
    end
    if !career_objective.match?(/\A[\w.,\+\-#&\*\s]*\z/)
      errors.add(:career_objective, "can only contain letters, numbers, spaces, and the characters . , + - # & *")
    end
  end

  def dob_validation
    if dob.blank?
      return errors.add(:base, "Date of Birth can't be blank")
    end
    if dob > Date.today
      return errors.add(:base, "Date of Birth can't be in the future")
    end
    if dob > 18.years.ago.to_date
      errors.add(:base, "Date of Birth must be at least 18 years old")
    end
  end

  def gender_validation
    if gender.blank? || gender.nil? || gender.empty?
      return errors.add(:gender, "can't be blank")
    end

    # get the value of the gender enum
    gender_integer = User.genders[self.gender.to_s].to_i
    if gender_integer < 1 || gender_integer > 3
      raise "Gender Value passed: #{self.gender} which's type is #{self.gender.class}"
      errors.add(:gender, "must be male, female or other")
    end
  end

  def onboarding_in_progress?
    @onboarding_step.present?
  end

  def onboarding_step_validation
    case @onboarding_step
    when 1
      validate_step_1_fields
    when 2
      validate_step_2_fields
    end
  end

  def validate_step_1_fields
    # Step 1: Basic information validation
    if first_name.blank?
      errors.add(:first_name, "can't be blank")
    end

    if last_name.blank?
      errors.add(:last_name, "can't be blank")
    end

    if phone.blank?
      errors.add(:phone, "can't be blank")
    end

    if gender.blank?
      errors.add(:gender, "can't be blank")
    end

    if dob.blank?
      errors.add(:dob, "can't be blank")
    end
  end

  def validate_step_2_fields
    # Step 2: Location validation
    if latitude.blank?
      errors.add(:latitude, "can't be blank")
    end

    if longitude.blank?
      errors.add(:longitude, "can't be blank")
    end

    if latitude.present? && (latitude < -90 || latitude > 90)
      errors.add(:latitude, "must be between -90 and 90")
    end

    if longitude.present? && (longitude < -180 || longitude > 180)
      errors.add(:longitude, "must be between -180 and 180")
    end
  end
end
