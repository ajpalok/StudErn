class CourseApplication < ApplicationRecord
  belongs_to :user
  belongs_to :course

  # Enums
  enum :status, { pending: 0, approved: 1, rejected: 2, withdrawn: 3 }

  # Validations
  validates :user_id, uniqueness: { scope: :course_id, message: "has already applied to this course" }
  validates :message, length: { maximum: 1000 }, allow_blank: true
  validates :admin_notes, length: { maximum: 1000 }, allow_blank: true

  # Callbacks
  before_create :set_applied_at
  before_update :set_reviewed_at, if: :status_changed?

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :pending_review, -> { where(status: :pending) }

  # Instance methods
  def status_display
    status.humanize
  end

  def can_be_approved?
    pending?
  end

  def can_be_rejected?
    pending?
  end

  def can_be_withdrawn?
    pending?
  end

  def approve!
    update!(status: :approved) if can_be_approved?
  end

  def reject!
    update!(status: :rejected) if can_be_rejected?
  end

  def withdraw!
    update!(status: :withdrawn) if can_be_withdrawn?
  end

  def formatted_applied_at
    applied_at&.strftime("%B %d, %Y at %I:%M %p")
  end

  def formatted_reviewed_at
    reviewed_at&.strftime("%B %d, %Y at %I:%M %p")
  end

  private

  def set_applied_at
    self.applied_at = Time.current
  end

  def set_reviewed_at
    self.reviewed_at = Time.current if status_changed? && !pending?
  end
end
