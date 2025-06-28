class UserAccomplishment < ApplicationRecord
  # Associations
  belongs_to :user, dependent: :destroy # dependent destroy ensures that if a user is deleted, their accomplishments are also deleted

  # Attributes
  attribute :title, :string
  attribute :description, :text
  attribute :date, :date

  # Enums
  enum :accomplishment_type, { project: 0, portfolio: 1, publication: 2, certification: 3, award: 4, other: 5 }

  # Validations
  validates :title, presence: true, length: { minimum: 2, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 500 }
  validates :date, presence: true

  # Custom validation for date format (optional)
  validate :date_format

  # Callbacks
  before_save :set_ongoing_status

  private

  def date_format
    return if date.blank?

    unless date.is_a?(Date)
      errors.add(:date, "must be a valid date")
    end
  end

  def set_ongoing_status
    if ongoing
      self.accomplishment_end_date = nil
    end
    if accomplishment_end_date.present? && date <= Date.today
      self.ongoing = false
    end
  end
end
