# frozen_string_literal: true

class DeviseCreateControlUnits < ActiveRecord::Migration[8.0]
  def change
    create_table :control_units do |t|
      ## Database authenticatable
      t.string :nid,                null: false
      t.string :name
      t.date   :dob
      t.string :address
      t.string :phone,              null: false
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      # Meta data
      t.integer :role, null: false, default: 99
      t.boolean :status, null: false, default: true

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      t.timestamps null: false
    end

    add_index :control_units, :email,                unique: true
    add_index :control_units, :reset_password_token, unique: true
    add_index :control_units, :confirmation_token,   unique: true
    # add_index :control_units, :unlock_token,         unique: true
  end
end
