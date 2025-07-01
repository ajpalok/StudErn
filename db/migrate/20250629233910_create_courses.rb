class CreateCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :courses do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :duration, null: false
      t.decimal :price, precision: 10, scale: 2, default: 0.0
      t.string :instructor, null: false
      t.string :category, null: false
      t.integer :status, default: 0, null: false
      t.references :control_unit, null: false, foreign_key: true
      t.string :image_url
      t.text :syllabus
      t.integer :max_students
      t.datetime :start_date
      t.datetime :end_date
      t.boolean :featured, default: false

      t.timestamps
    end
    
    add_index :courses, :title
    add_index :courses, :category
    add_index :courses, :status
    add_index :courses, :featured
  end
end
