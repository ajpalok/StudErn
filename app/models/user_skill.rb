class UserSkill < ApplicationRecord
  # Associations
  belongs_to :user, dependent: :destroy # dependent destroy ensures that if a user is deleted, their skills are also deleted
  belongs_to :user_work_experience, optional: true # Optional association to allow skills without a work experience

  # Enums for skill levels
  enum :skill_level, { beginner: 0, intermediate: 1, advanced: 2, expert: 3 }

  # Attributes
  attribute :skill_name, :string
  attribute :skill_level, :integer, default: 0 # Default to beginner

  # Validations
  validates :skill_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :skill_level, presence: true, inclusion: { in: %w[beginner intermediate advanced expert] }
  validate :skill_name_format

  private

  def skill_name_format
    unless skill_name.present?
      errors.add(:skill_name, "can't be blank")
      return
    end
    if skill_name.length < 2
      return errors.add(:skill_name, "must be at least 2 characters long")
    end
    if skill_name.length > 50
      return errors.add(:skill_name, "must be at most 50 characters long")
    end
    # Regex to allow letters, numbers, spaces, and the characters . - # &
    unless skill_name.match?(/\A[\w.\-#&\s]*\z/)
      errors.add(:skill_name, "can only contain letters, numbers, spaces, and the characters . - # &")
    end
  end
end
