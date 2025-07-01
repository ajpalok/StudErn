class UserAccomplishment < ApplicationRecord
  # Associations
  belongs_to :user

  # Enums
  enum :accomplishment_type, { project: 0, portfolio: 1, publication: 2, certification: 3, award: 4, other: 5 }

  # Validations
  validates :accomplishment_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :accomplishment_description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :accomplishment_type, presence: true, inclusion: { in: UserAccomplishment.accomplishment_types.keys }

  # Custom validation for date format (optional)
  validate :date_format

  # Callbacks
  before_save :set_ongoing_status

  private

  def date_format
    return if accomplishment_start_date.blank?

    unless accomplishment_start_date.is_a?(Date)
      errors.add(:accomplishment_start_date, "must be a valid date")
    end
  end

  def set_ongoing_status
    if ongoing
      self.accomplishment_end_date = nil
    end
    if accomplishment_end_date.present? && accomplishment_start_date <= Date.today
      self.ongoing = false
    end
  end
end
