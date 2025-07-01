class CreateCourseApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :course_applications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.integer :status, default: 0, null: false
      t.text :message
      t.datetime :applied_at, null: false
      t.datetime :reviewed_at
      t.text :admin_notes

      t.timestamps
    end
    
    add_index :course_applications, [:user_id, :course_id], unique: true
    add_index :course_applications, :status
  end
end
