# class for recruiter_permissions_on_company table
class RecruiterPermissionsOnCompany < ApplicationRecord
  # table name
  self.table_name = 'recruiter_permissions_on_company'

  # Associations
  belongs_to :recruiter
  belongs_to :company

  # Validations
  validates :recruiter_id, presence: true
  validates :company_id, presence: true
  validate :recruiter_position_validation

  # recruiter_id, company_id are unique together
  validates :recruiter_id, uniqueness: { scope: [:company_id], message: "has already been assigned to this company with the same position" }

  # Enums
  enum :recruiter_status, { pending: 0, approved: 1, rejected: 2, blocked: 3 }

  private

  def recruiter_position_validation
    if recruiter_position.blank? || recruiter_position.nil? || recruiter_position.strip.empty?
      return errors.add(:recruiter_position, "can't be blank")
    end
    if recruiter_position.length < 2
      return errors.add(:recruiter_position, "must be at least 2 characters long")
    end
    if recruiter_position.length > 50
      return errors.add(:recruiter_position, "must be at most 50 characters long")
    end
    if !recruiter_position.match?(/\A[\w.\-#&\s]*\z/)
      return errors.add(:recruiter_position, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end

end