class CreateTakeQuestions < ActiveRecord::Migration
  def change
    create_table :take_questions do |t|
      t.integer :assessment_id
      t.integer :sequence
      t.string :short_name
      t.text :question_text
      t.text :instructions
      t.string :answer_tag
      t.string :display
      t.string :group_header
      t.float :weight,               :default => 1.0
      t.boolean :critical,               :default => false
      t.float :min_critical_value
      t.string :score_method
      t.string :key

      t.timestamps
    end
    
  end
end
