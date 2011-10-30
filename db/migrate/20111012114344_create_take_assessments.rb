class CreateTakeAssessments < ActiveRecord::Migration
  def change
    create_table :take_assessments do |t|
      t.string :name
      t.text :description
      t.text :instructions
      t.string :status
      t.string :category
      t.string   "default_answer_tag"
      t.string   "default_display"
      t.float    "max_raw"
      t.float    "max_weighted"
      t.string   "key"

      t.timestamps
    end
    add_index :take_assessments, :key
    add_index :take_assessments, :category
    
  end
end
