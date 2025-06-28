class CreateContactforms < ActiveRecord::Migration[8.0]
  def change
    create_table :contactforms do |t|
      t.string :name
      t.string :phone
      t.string :email
      t.text :message
      t.timestamps
    end
  end
end
