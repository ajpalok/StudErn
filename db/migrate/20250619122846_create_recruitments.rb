class CreateRecruitments < ActiveRecord::Migration[8.0]
  def change
    create_table :recruitments do |t|
      # attributes
      t.integer :recruitment_type, null: false, default: 0 # 0 for job, 1 for internship, 2 for Micro-Job, 3 for Micro-Internship
      t.string :title, null: false
      t.text :description, null: false
      t.integer :experience_level, null: false, default: 0 # 0 for entry-level, 1 for mid-level, 2 for senior-level, 3 for expert-level
      t.integer :work_type, null: false, default: 0 # 0 for full-time, 1 for part-time, 2 for project, 3 for freelance
      t.integer :work_place, null: false, default: 0 # 0 for on-site, 1 for remote, 2 for hybrid
      t.float :latitude, null: false
      t.float :longitude, null: false
      t.integer :salary_type, null: false, default: 1 # 0 for fixed, 1 for negotiable, 2 for hourly, 3 for weekly, 4 for monthly, 5 for yearly
      t.float :annual_salary_range_start
      t.float :annual_salary_range_end

      # applications collection process
      t.integer :number_of_vacancies, null: false, default: 1
      t.integer :application_collection_status, default: 2 # 0 for close, 1 for open, 2 for draft
      t.datetime :application_collection_end_date # the date when the application collection ends
      t.integer :application_package, default: 0 # 0 for basic, 1 for standard, 2 for premium
      t.integer :application_collection_method, default: 0 # 0 for easy_apply, 1 for external_link, 2 for email
      t.string :application_link # link to the application form or website
      t.string :calling_number # phone number for listing the recruitment

      # relationships
      t.references :company, null: false, foreign_key: true
      t.references :recruiter, null: false, foreign_key: true
      t.references :bkash_payment, foreign_key: true # optional, if the recruitment is paid

      t.timestamps
    end

    # add new model for recruitment apply
    create_table :recruitment_applies do |t|
      t.references :user, null: false, foreign_key: true
      t.references :recruitment, null: false, foreign_key: true
      t.integer :status, null: false, default: 0 # 0 for pending, 1 for accepted, 2 for rejected
      t.boolean :has_contacted_yet, default: false # whether the recruiter has contacted the applicant yet
      t.text :message # optional message from the recruiter to the student

      t.timestamps
    end

    # add index for recruitment title
    add_index :recruitments, :title
  end
end
