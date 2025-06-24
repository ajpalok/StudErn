class CreateBkashPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :bkash_payments do |t|
      t.string :payment_from # the class name of the payment initiator and their request model id, e.g., "Recruitment-1", "Company-1", etc.
      t.string :payment_id # the unique identifier for the payment request
      t.string :trx_id
      t.string :trx_status
      t.string :amount
      t.string :verification_status
      t.string :refund_status
      t.string :refund_amount
      t.string :refund_charge
      t.string :refund_id
      t.string :refund_reason

      t.timestamps
    end

    add_index :bkash_payments, :payment_id, unique: true
    add_index :bkash_payments, :trx_id, unique: true
    add_index :bkash_payments, :refund_id, unique: true
  end
end
