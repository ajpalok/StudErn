class RecruitmentApply < ApplicationRecord
  belongs_to :user
  belongs_to :recruitment

  # Validations
  validates :user_id, uniqueness: { scope: :recruitment_id, message: "You have already applied to this recruitment" }
  validate :recruitment_must_be_open
  validate :recruitment_must_have_payment_completed
  validate :recruitment_must_be_easy_apply
  validate :user_must_have_complete_profile

  # Enums
  enum :status, { pending: 0, accepted: 1, rejected: 2, withdrawn: 3 }

  # Callbacks
  before_create :set_default_status

  private

  def set_default_status
    self.status ||= :pending
  end

  def recruitment_must_be_open
    unless recruitment.application_collection_status == "open"
      errors.add(:base, "This recruitment is not accepting applications")
    end
  end

  def recruitment_must_have_payment_completed
    unless recruitment.bkash_payment.present? && 
           recruitment.bkash_payment.trx_id.present? && 
           recruitment.bkash_payment.trx_status == "success"
      errors.add(:base, "This recruitment is not available for applications")
    end
  end

  def recruitment_must_be_easy_apply
    unless recruitment.application_collection_method == "easy_apply"
      errors.add(:base, "This recruitment does not support easy apply")
    end
  end

  def user_must_have_complete_profile
    unless user.account_status == "complete"
      errors.add(:base, "Please complete your profile before applying")
    end
  end
end 