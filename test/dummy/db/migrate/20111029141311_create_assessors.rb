class CreateAssessors < ActiveRecord::Migration
  def change
    create_table :assessors do |t|
      t.integer :assessment_id
      t.string :version
      t.text :publish_json

      t.timestamps
    end
  end
end
