class Recruiter < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :confirmable, :rememberable, :trackable, :validatable

  # Associations
  # has_many :recruitments, dependent: :destroy
  has_many :recruiter_permissions_on_companies, dependent: :destroy
  has_many :companies, through: :recruiter_permissions_on_companies #this will allow us to get all the companies the recruiter is associated with
  has_many :recruitments, dependent: :destroy # this will allow us to get all the recruitments the recruiter has published

  # Callbacks
  before_save :set_default_account_status, if: :new_record?

  # Enums
  enum :gender, { male: 1, female: 2, other: 3 }
  enum :account_status, { incomplete: 0, complete: 1, suspended: 2, closed: 3 }

  # Validations
  validate :firstname_validation
  validate :lastname_validation
  validate :phone_validation
  validate :gender_validation

  def full_name
    "#{first_name} #{last_name}"
  end

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

  def gender_validation
    if gender.blank? || gender.nil? || gender.empty?
      return errors.add(:gender, "can't be blank")
    end

    # get the value of the gender enum
    gender_integer = User.genders[self.gender.to_s].to_i
    if gender_integer < 1 || gender_integer > 3
      raise "Gender Value passed: #{self.gender} which's type is #{self.gender.class}"
      return errors.add(:gender, "must be male, female or other")
    end
  end
end
