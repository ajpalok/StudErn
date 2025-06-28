class CreateUserSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :user_skills do |t|
      t.string :skill_name, null: false
      t.integer :skill_level, null: false, default: 0 # 0: beginner, 1: intermediate, 2: advanced, 3: expert
      t.references :user, null: false, foreign_key: true
      t.references :user_work_experiences, foreign_key: true
      t.timestamps
    end

    add_index :user_skills, [ :user_id, :skill_name ], unique: true, name: 'index_user_skills_on_user_id_and_skill_name'
  end
end
