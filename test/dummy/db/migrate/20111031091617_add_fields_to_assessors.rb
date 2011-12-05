class AddFieldsToAssessors < ActiveRecord::Migration
  def change
    add_column :assessors, :assessable_id, :integer
    add_column :assessors, :assessable_type, :string
    add_column :assessors, :sequence, :integer
  end
end
