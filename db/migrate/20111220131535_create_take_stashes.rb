class CreateTakeStashes < ActiveRecord::Migration
  def change
    create_table :take_stashes do |t|
      t.string :session_id
      t.text :session
      t.text :data

      t.timestamps
    end
    add_index :take_stashes, :session_id
    
  end
end
