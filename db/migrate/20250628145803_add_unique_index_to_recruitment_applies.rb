class AddUniqueIndexToRecruitmentApplies < ActiveRecord::Migration[8.0]
  def change
    add_index :recruitment_applies, [:user_id, :recruitment_id], unique: true, name: 'index_recruitment_applies_on_user_and_recruitment_unique'
  end
end
