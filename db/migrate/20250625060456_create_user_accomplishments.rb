class CreateUserAccomplishments < ActiveRecord::Migration[8.0]
  def change
    create_table :user_accomplishments do |t|
      t.integer :accomplishment_type, null: false # e.g., "Project" => 0, Portfolio => 1, "publication" => 2, "Certification" => 3, "Award" => 4, "Other" => 5
      t.string :accomplishment_url # URL for the accomplishment, if applicable
      t.string :accomplishment_name, null: false
      t.text :accomplishment_description, null: false
      t.date :accomplishment_start_date
      t.date :accomplishment_end_date
      t.boolean :ongoing, default: false
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
