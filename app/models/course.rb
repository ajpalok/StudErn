class Course < ApplicationRecord
  belongs_to :control_unit
  has_many :course_applications, dependent: :destroy
  has_many :users, through: :course_applications

  # Enums
  enum :status, { draft: 0, published: 1, archived: 2, suspended: 3 }

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :duration, presence: true
  validates :instructor, presence: true, length: { minimum: 2, maximum: 50 }
  validates :category, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :max_students, numericality: { greater_than: 0 }, allow_nil: true
  validates :start_date, presence: true, if: :published?
  validates :end_date, presence: true, if: :published?
  validate :end_date_after_start_date, if: -> { start_date.present? && end_date.present? }

  # Scopes
  scope :published, -> { where(status: :published) }
  scope :featured, -> { where(featured: true) }
  scope :active, -> { published.where('start_date > ?', Time.current) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(created_at: :desc) }

  # Callbacks
  before_save :set_applied_at_for_applications, if: :status_changed_to_published?

  # Instance methods
  def can_apply?(user)
    return false unless published?
    return false if max_students && course_applications.count >= max_students
    return false if user.course_applications.exists?(course: self)
    true
  end

  def available_seats
    return nil unless max_students
    [max_students - course_applications.count, 0].max
  end

  def is_full?
    max_students && course_applications.count >= max_students
  end

  def formatted_price
    if price == 0
      "Free"
    else
      "৳#{price}"
    end
  end

  def duration_display
    duration
  end

  def status_display
    status.humanize
  end

  def featured_display
    featured? ? "Yes" : "No"
  end

  private

  def end_date_after_start_date
    if end_date <= start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def status_changed_to_published?
    status_changed? && published?
  end

  def set_applied_at_for_applications
    course_applications.update_all(applied_at: Time.current)
  end
end
