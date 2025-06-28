class RemoveBkashIndexes < ActiveRecord::Migration[8.0]
  def change
    # Remove unique index on payment_id
    remove_index :bkash_payments, :payment_id if index_exists?(:bkash_payments, :payment_id)

    # Remove unique index on trx_id
    remove_index :bkash_payments, :trx_id if index_exists?(:bkash_payments, :trx_id)

    # Remove unique index on refund_id
    remove_index :bkash_payments, :refund_id if index_exists?(:bkash_payments, :refund_id)
  end
end
