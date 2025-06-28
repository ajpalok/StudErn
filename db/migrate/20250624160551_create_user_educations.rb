class CreateUserEducations < ActiveRecord::Migration[8.0]
  def change
    create_table :user_educations do |t|
      t.string :institution_name, null: false
      t.string :degree, null: false
      t.integer :performance_type, default: 0 # 0: percentage, 1: cgpa_out_of_4, 2: cgpa_out_of_5
      t.decimal :performance, precision: 5, scale: 2 # precision means total digits, scale means digits after decimal
      t.date :start_date
      t.date :end_date
      t.boolean :currently_studying

      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
