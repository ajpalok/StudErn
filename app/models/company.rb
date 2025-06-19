class Company < ApplicationRecord
  # Associations
  has_many :recruiter_permissions_on_companies, dependent: :destroy
  has_many :recruiters, through: :recruiter_permissions_on_companies # this will allow us to get all the recruiters associated with the company

  # callbacks
  # before_save :attribute_sanitization

  # Validations
  validate :name_validation
  validate :tagline_validation
  validate :description_validation
  validate :email_validation
  validate :phone_validation
  validate :website_validation
  validate :coordinates_validation
  
  validate :parent_company_validation

  validates :name, uniqueness: true
  validates :email, uniqueness: true
  validates :phone, uniqueness: true
  
  private
  def name_validation
    if name.blank? || name.nil? || name.strip.empty?
      return errors.add(:name, "can't be blank")
    end
    if name.length < 3
      return errors.add(:name, "must be at least 3 characters long")
    end
    if name.length > 50
      return errors.add(:name, "must be at most 50 characters long")
    end
    if !name.match?(/\A[\w.\-#&\s]*\z/)
      return errors.add(:name, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end

  def tagline_validation
    if tagline.blank? || tagline.nil? || tagline.strip.empty?
      return
    end
    if tagline.length < 3
      return errors.add(:tagline, "must be at least 3 characters long")
    end
    if tagline.length > 100
      return errors.add(:tagline, "must be at most 100 characters long")
    end
    if !tagline.match?(/\A[\w.\-#&\s]*\z/)
      return errors.add(:tagline, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end

  def description_validation
    if description.blank? || description.nil? || description.strip.empty?
      return errors.add(:description, "can't be blank")
    end
    if description.length < 10
      return errors.add(:description, "must be at least 10 characters long")
    end
    if description.length > 500
      return errors.add(:description, "must be at most 500 characters long")
    end
    if !description.match?(/\A[\w.\-#&\s]*\z/)
      return errors.add(:description, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end

  def email_validation
    if email.blank? || email.nil? || email.strip.empty?
      return errors.add(:email, "can't be blank")
    end
    # if the email does not contain an @ symbol, return an error
    unless email.include?('@')
      return errors.add(:email, "must contain an @ symbol")
    end

    custom_email = CustomEmail.new(self.email)
    if !custom_email.valid_format?
      return errors.add(:email, "is not valid")
    end
    self.email = custom_email.actual_email
  end

  def phone_validation
    if phone.blank? || phone.nil? || phone.strip.empty?
      return errors.add(:phone, "can't be blank")
    end
    custom_phone = CustomPhone.new(self.phone)
    if !custom_phone.valid_format?
      return errors.add(:phone_number, "is not valid")
    end
    self.phone = custom_phone.getFullNumber
  end

  def website_validation
    return if website.blank? # optional
    uri = URI.parse(website) rescue nil
    if uri.nil? || !uri.kind_of?(URI::HTTP)
      return errors.add(:website, "must be a valid URL starting with http:// or https://")
    end
  end

  def coordinates_validation
    if latitude.present? && (latitude < -90 || latitude > 90) && longitude.present? && (longitude < -180 || longitude > 180)
      return errors.add(:base, "Location is not valid.")
    end
  end

  def parent_company_validation
    return if parent_company_id.blank? || parent_company_id.nil?

    if parent_company_id == id
      return errors.add(:parent_company, "cannot be itself")
    end

    unless Company.exists?(parent_company_id)
      return errors.add(:parent_company, "must be a valid company")
    end
  end
end
