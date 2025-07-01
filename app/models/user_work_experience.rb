class UserWorkExperience < ApplicationRecord
  # Associations
  belongs_to :user # Remove dependent: :destroy from belongs_to
  belongs_to :company, optional: true # Optional association to allow work experiences without a company
  has_many :user_skills, dependent: :nullify

  # Enums for employment types
  enum :employment_type, { full_time: 0, part_time: 1, project: 2, freelance: 3 }

  # Validations
  validates :company_name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :designation, presence: true, length: { minimum: 2, maximum: 50 }
  validates :start_date, presence: true
  validates :end_date, presence: true, comparison: { greater_than_or_equal_to: :start_date }, unless: -> { currently_working }
  validates :employment_type, presence: true, inclusion: { in: UserWorkExperience.employment_types.keys }

  before_save :set_currently_working

  private
  def set_currently_working
    if currently_working
      self.end_date = nil
    elsif end_date.present? && end_date < Date.today
      self.currently_working = false
    end
  end
end
