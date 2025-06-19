class CreateRecruiterPermissionsOnCompany < ActiveRecord::Migration[8.0]
  def change
    create_table :recruiter_permissions_on_company do |t|
      # Foreign keys
      t.references  :company, null: false, foreign_key: true, index: true
      t.references  :recruiter, null: false, foreign_key: true, index: true

      # Recruiter's details for the company
      t.string      :recruiter_position, null: false
      t.time        :recruiter_working_start_time
      t.time        :recruiter_working_end_time

      # Status of the joining the company
      t.integer     :recruiter_status, default: 0 # 0: pending, 1: approved, 2: rejected, 3: blocked

      # Permissions
      t.boolean     :can_manage_jobs, default: false
      t.boolean     :can_manage_applicants, default: false
      t.boolean     :can_manage_interviews, default: false
      t.boolean     :can_manage_offers, default: false
      t.boolean     :can_manage_company_profile, default: false
      t.boolean     :can_manage_recruiter_profile, default: false
      t.boolean     :can_manage_company_settings, default: false
      t.boolean     :can_manage_recruiter_settings, default: false
      t.boolean     :can_manage_company_users, default: false
      t.boolean     :can_manage_subscriptions_of_studern, default: false

      t.timestamps
    end
  end
end
