class AddBkashPaymentIdToCourseApplications < ActiveRecord::Migration[8.0]
  def change
    add_column :course_applications, :bkash_payment_id, :integer
    add_index :course_applications, :bkash_payment_id
  end
end
