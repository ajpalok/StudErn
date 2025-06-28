class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string  :name
      t.string  :tagline
      t.string  :description
      t.string  :email
      t.string  :phone
      t.string  :website
      t.float   :latitude
      t.float   :longitude

      # may have parent company
      t.references :parent_company, foreign_key: { to_table: :companies }, index: true, null: true

      t.timestamps
    end
  end
end
