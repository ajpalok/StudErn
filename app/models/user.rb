class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :confirmable, :rememberable, :validatable

  # Associations
  # has_many :recruitments, dependent: :destroy

  # Callbacks
  before_save :set_default_account_status, if: :new_record?

  # Enums
  enum :gender, { male: 0, female: 1, other: 2 }

  # Validations
  validate :firstname_validation
  validate :lastname_validation
  validate :phone_validation
  validate :coordinates_validation
  validate :career_objective_validation
  validate :dob_validation
  validate :gender_validation
  validate :account_status_validation

  private
  def set_default_account_status
    self.account_status ||= 0 # Default to pending if not set
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
      return errors.add(:first_name, "can only contain letters, numbers, spaces, and the characters . - # &")
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
      return errors.add(:last_name, "can only contain letters, numbers, spaces, and the characters . - # &")
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
      return errors.add(:base, "Location is not valid.")
    end
  end

  def career_objective_validation
    if career_objective.blank?
      return errors.add(:career_objective, "can't be blank")
    end
    if career_objective.length < 10
      return errors.add(:career_objective, "must be at least 10 characters long")
    end
    if career_objective.length > 500
      return errors.add(:career_objective, "must be at most 500 characters long")
    end
    if !career_objective.match?(/\A[\w.\-#&\*\s]*\z/)
      return errors.add(:career_objective, "can only contain letters, numbers, spaces, and the characters . - # & *")
    end
  end

  def dob_validation
    if dob.blank?
      return errors.add(:dob, "can't be blank")
    end
    if dob > Date.today
      return errors.add(:dob, "can't be in the future")
    end
    if dob < 13.years.ago.to_date
      return errors.add(:dob, "must be at least 13 years old")
    end
  end

  def gender_validation
    if gender.blank?
      return errors.add(:gender, "can't be blank")
    end
    if gender < 0 || gender > 2
      return errors.add(:gender, "must be male, female, or other")
    end
  end

  def account_status_validation
    if account_status.blank?
      return errors.add(:account_status, "can't be blank")
    end
    if account_status < 0 || account_status > 3
      return errors.add(:account_status, "must be pending, active, suspended, or closed")
    end
  end
end
