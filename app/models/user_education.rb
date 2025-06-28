class UserEducation < ApplicationRecord
  belongs_to :user

  enum :performance_type, { percentage: 0, cgpa_out_of_4: 1, cgpa_out_of_5: 2 }

  validates :institution_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :degree, presence: true, length: { minimum: 2, maximum: 50 }
  validates :performance_type, inclusion: { in: UserEducation.performance_types.keys }
  validate :performance_data
  validate :end_date_after_start_date

  before_save :set_performance
  before_save :set_currently_studying


  def performance_data
    unless performance.present?
      return
    end

    if performance_type == "percentage"
      unless performance.is_a?(Numeric) && performance.between?(0, 100)
        errors.add(:performance, "must be a number between 0 and 100 for percentage")
      end
    elsif performance_type == "cgpa_out_of_4"
      unless performance.is_a?(Numeric) && performance.between?(0, 4)
        errors.add(:performance, "must be a number between 0 and 4 for CGPA out of 4")
      end
    elsif performance_type == "cgpa_out_of_5"
      unless performance.is_a?(Numeric) && performance.between?(0, 5)
        errors.add(:performance, "must be a number between 0 and 5 for CGPA out of 5")
      end
    end
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after the start date")
    end
  end

  def set_performance
    unless performance.present?
      self.performance_type = nil
      self.performance = nil
    end
  end

  def set_currently_studying
    if currently_studying
      self.end_date = nil
    end

    # If end_date is present and in the past, set currently_studying to false
    if end_date.present? && end_date < Date.today
      self.currently_studying = false
    end
  end
end
