class Contactform < ApplicationRecord
  validates :name, presence: true
  validates :message, presence: true
  validate :email_validate
  validate :phone_validate

  before_save :emailsave, :phonesave

  def email_validate
    unless email.present?
      return errors.add(:email, "can't be blank")
    end

    emailObject = CustomEmail.new(email)

    if !emailObject.valid_format?
      errors.add(:email, "is not valid")
    end

    self.email = emailObject.actual_email
  end

  def phone_validate
    unless phone.present?
      return errors.add(:phone, "can't be blank")
    end

    phoneObject = CustomPhone.new(phone)

    if !phoneObject.valid_format?
      errors.add(:phone, "is not valid")
    end

    self.phone = phoneObject.getFullNumber
  end

  private

  def emailsave
    emailObject = CustomEmail.new(email)
    self.email = emailObject.actual_email
  end

  def phonesave
    phoneObject = CustomPhone.new(phone)
    self.phone = phoneObject.getFullNumber
  end
end
