class ChangeDisplayColumnNameInQuestions < ActiveRecord::Migration
  def up
    rename_column :take_questions, :display, :type_display
  end

  def down
    rename_column :take_questions,  :type_display, :display
  end
end
