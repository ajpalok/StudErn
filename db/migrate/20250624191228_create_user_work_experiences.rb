class CreateUserWorkExperiences < ActiveRecord::Migration[8.0]
  def change
    create_table :user_work_experiences do |t|
      t.string :company_name, null: false
      t.string :designation, null: false
      t.date :start_date
      t.date :end_date
      t.boolean :currently_working, default: false
      t.text :job_responsibilities
      t.integer :employment_type, default: 0 # 0: full_time, 1: part_time, 2: project, 3: freelance

      t.references :user, null: false, foreign_key: true
      t.references :company, foreign_key: true
      t.timestamps
    end
  end
end
