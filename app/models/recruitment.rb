class Recruitment < ApplicationRecord
  # Associations
  has_many :recruitment_applies, dependent: :destroy
  belongs_to :company
  belongs_to :recruiter, optional: true
  belongs_to :bkash_payment, optional: true

  # Callbacks
  before_create :set_first_recruitement_bkash_payment
  before_save :set_full_phone_number
  before_save :set_annual_salary_range
  before_save :set_application_collection_statuses, if: :new_record?

  # Enums
  enum :recruitment_type, { job: 0, internship: 1, micro_job: 2, micro_internship: 3 }
  enum :work_type, { full_time: 0, part_time: 1, project: 2, freelance: 3 }
  enum :work_place, { on_site: 0, remote: 1, hybrid: 2 }
  enum :salary_type, { fixed: 0, negotiable: 1, hourly: 2, weekly: 3, monthly: 4, yearly: 5 }
  enum :experience_level, { entry_level: 0, mid_level: 1, senior_level: 2, expert_level: 3 }
  enum :application_package, { basic: 0, standard: 1, premium: 2 } # 0 for basic, 1 for standard, 2 for premium
  enum :application_collection_status, { close: 0, open: 1, draft: 2 } # 0 for close, 1 for open, 2 for draft
  enum :application_collection_method, { easy_apply: 0, external_link: 1, email: 2 } # 0 for easy_apply, 1 for external_link, 2 for email

  # Validations
  validates :recruitment_type, presence: true, inclusion: { in: Recruitment.recruitment_types.keys }
  validates :title, presence: true, length: { minimum: 3, maximum: 50 }, format: { with: /\A[\w.\-#&\s]*\z/, message: "can only contain letters, numbers, spaces, and the characters . - # &" }
  validates :description, presence: true
  validates :work_type, presence: true, inclusion: { in: Recruitment.work_types.keys }
  validates :work_place, presence: true, inclusion: { in: Recruitment.work_places.keys }
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :salary_type, presence: true, inclusion: { in: Recruitment.salary_types.keys }
  validates :experience_level, presence: true, inclusion: { in: Recruitment.experience_levels.keys }
  validates :application_collection_status, inclusion: { in: Recruitment.application_collection_statuses.keys }
  validates :application_package, presence: true, inclusion: { in: Recruitment.application_packages.keys }
  validates :application_collection_method, presence: true, inclusion: { in: Recruitment.application_collection_methods.keys }

  # Custom Validate methods
  validate :annual_salary_range
  validate :calling_number_validation
  validate :number_of_vacancies_validation
  validate :application_collection_end_date_validation
  validate :application_link_validation, if: -> { application_collection_method == "external_link" || application_collection_method == "email" }

  def annual_salary_range
    if salary_type == "fixed" && (annual_salary_range_start.present? || annual_salary_range_end.present?)
      return errors.add(:base, "Annual salary range is not applicable for fixed salary types")
    end

    # if any one is present then both are needed
    unless annual_salary_range_start.present? && annual_salary_range_end.present?
      return
    end

    if annual_salary_range_start.present? && annual_salary_range_end.present?
      if annual_salary_range_start < 0 || annual_salary_range_end < 0
        return errors.add(:annual_salary_range, "must be positive numbers")
      end

      if annual_salary_range_start >= annual_salary_range_end
        return errors.add(:base, "Annual salary Starting range must be less than annual salary ending range")
      end

      return
    end

    # else both are not present
    errors.add(:base, "Both annual salary start and end range must be present")
  end

  def calling_number_validation
    if calling_number.blank? || calling_number.empty? || calling_number.nil?
      return
    end

    number = CustomPhone.new(calling_number)

    if !number.valid_format?
      errors.add(:calling_number, "must be a valid phone number in the format 01XXXXXXXXX")
    end
  end

  def number_of_vacancies_validation
    unless number_of_vacancies.present?
      return errors.add(:number_of_vacancies, "must be present and greater than 0")
    end

    if number_of_vacancies > 20
      return errors.add(:number_of_vacancies, "must not exceed 20")
    end

    if number_of_vacancies < 1
      errors.add(:number_of_vacancies, "must be at least 1")
    end
  end

  def application_collection_end_date_validation
    if application_collection_status != "close" && application_collection_end_date.blank?
      return errors.add(:application_collection_end_date, "must be present if application collection is open")
    end

    if application_collection_end_date.present? && application_collection_end_date < Time.current
      return errors.add(:application_collection_end_date, "must be in the future if application collection is open")
    end

    # application_collection_end_date more than 2 days and not exceed 3 months
    if application_collection_status != "close" && application_collection_end_date.present?
      if application_collection_end_date < Time.current + 2.days
        return errors.add(:application_collection_end_date, "must be at least 2 days from now")
      end

      if application_collection_end_date > Time.current + 3.months
        errors.add(:application_collection_end_date, "must not exceed 3 months from now")
      end
    end
  end

  def application_link_validation
    if application_collection_method == "external_link"
      if application_link.blank? || application_link.empty? || application_link.nil?
        return errors.add(:application_link, "must be present if application collection method is external_link or email")
      end

      if !URI.regexp(%w[http https]).match?(application_link)
        return errors.add(:application_link, "must be a valid URL")
      end

      if application_link.length > 255
        return errors.add(:application_link, "must be at most 255 characters long")
      end

      if !application_link.match?(/\Ahttps?:\/\//)
        return errors.add(:application_link, "must start with http:// or https://")
      end
    end

    if application_collection_method == "email"
      email = application_link.strip
      email = CustomEmail.new(email)

      if !email.valid_format?
        errors.add(:application_link, "must be a valid email address")
      end
    end
  end

  private
  def set_first_recruitement_bkash_payment
    return unless Recruitment.last.nil? # Check if this is the first recruitment for the company
    begin
      self.bkash_payment = BkashPayment.create(
          payment_from: "recruitment",
          payment_id: "TR0001xx1565072365492",
          trx_id: "free1bkash",
          trx_status: "Completed",
          amount: 0.0)
      self.application_collection_status = 1 # Set application collection status to open for the first recruitment
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "Failed to create first recruitment BkashPayment: #{e.message}"
      # throw :abort # Prevent the recruitment from being created
    end
  end

  def set_full_phone_number
    self.calling_number = CustomPhone.new(calling_number).getFullNumber if calling_number.present?
  end

  def set_annual_salary_range
    if salary_type == "fixed"
      self.annual_salary_range_start = nil
      self.annual_salary_range_end = nil
    end
  end

  def set_application_collection_statuses
    self.application_collection_status = 3 if application_collection_status.nil?
    self.application_link = nil if application_collection_method == "easy_apply"
  end
end
