class ControlUnit < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable, :rememberable, :confirmable, :trackable

  # Validations
  validate :name_validation
  validate :nid_validation
  validate :dob_validation
  validate :address_validation
  validate :phone_validation
  before_save :validate_role_change

  enum :role, { super_admin: 0, admin: 1, unauthorized: 99 }

  # after_initialize :set_default_role, if: :new_record?
  before_save :set_default_role, if: :new_record?

  # Validation Functions
  def name_validation
    if name.blank? || name.nil?
      errors.add(:base, "Name can't be blank")
      return
    end

    if name.length < 3
      errors.add(:base, "Name is too short")
      return
    end

    if name.length > 50
      errors.add(:base, "Name is too long")
      return
    end

    if !name.match(/\A[a-zA-Z\ \-\,\.\(\)]{3,50}\z/)
      errors.add(:base, "Name should only contain alphabets")
      nil
    end
  end

  def nid_validation
    if nid.blank? || nid.nil?
      errors.add(:base, "NID can't be blank")
      return
    end

    nid_valid_length = %w[10 13 17]
    if !nid_valid_length.include?(nid.length.to_s)
      errors.add(:base, "NID should be 10, 13 or 17 digits long")
      nil
    end
  end

  def address_validation
    if address.blank? || address.nil?
      errors.add(:base, "Address can't be blank")
      return
    end

    if address.length < 5
      errors.add(:base, "Address is too short")
      return
    end

    if address.length > 100
      errors.add(:base, "Address is too long")
      return
    end

    if !address.match(/[a-zA-Z0-9\s\,\-\/]{5,100}/)
      errors.add(:base, "Address should only contain alphabets, numbers, hyphens and commas")
      nil
    end
  end

  def phone_validation
    phone_number = CustomPhone.new(phone)
    if phone_number.isEmpty?
      errors.add(:base, "Phone can't be blank")
      return
    end

    if !phone_number.valid_size?
      errors.add(:base, "Phone number should be 11 digits long at the main part")
      return
    end

    if !phone_number.valid_format?
      errors.add(:base, "Phone number should start with 01 / +8801 and contain 11 digits at the main part")
      nil
    end
  end

  def dob_validation
    if dob.nil? || dob.blank?
      errors.add(:base, "Date of Birth can't be blank")
      return
    end

    # if dob is nil then skip the following validations
    if dob.nil?
      return
    end

    if dob.blank? || dob.nil?
      errors.add(:base, "Date of Birth can't be blank")
      return
    end

    if dob > Date.today
      errors.add(:base, "Date of Birth can't be in the future")
      return
    end

    if dob < Date.today - 100.years
      errors.add(:base, "Date of Birth can't be more than 100 years old")
      nil
    end
  end

  private

  def set_default_role
    self.role = ControlUnit.exists? ? :unauthorized : :super_admin
    # self.role ||= :unauthorized
  end

  def validate_role_change
    # Skip validation if role isn't changing
    return unless role_changed?

    # Get the actual current user (you'll need to implement this)
    current_user = ControlUnit.find_by(id: id)
    # Check if current_user is nil
    if current_user.nil?
      errors.add(:base, "Current user not found")
      return
    end

    # Prevent users from assigning higher privileges than they have
    if role_was.to_sym < role.to_sym
      errors.add(:base, "You cannot assign a higher role than your own")
      return
    end

    # Prevent unauthorized users from changing their role
    if self.role == "unauthorized"
      errors.add(:base, "You cannot change your role to unauthorized")
      return
    end
  end
end
