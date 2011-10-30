class CreateTakeAnswers < ActiveRecord::Migration
  def change
    create_table :take_answers do |t|
      t.integer :question_id
      t.integer :sequence
      t.string :short_name
      t.string :answer_text
      t.float :value
      t.boolean :requires_other, :default => false
      t.string :other_question
      t.string :text_eval
      t.string :key

      t.timestamps
    end
  end
end
