# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

def json_parse(json)
  return ActiveSupport::JSON.decode(json)
end

#require File.expand_path('../conversion/export_masters', __FILE__)
require File.expand_path('../conversion/import_masters', __FILE__)
#require File.expand_path('../conversion/test_users', __FILE__)
#require File.expand_path('../conversion/stages', __FILE__)
#require File.expand_path('../conversion/stage_users', __FILE__)
#require File.expand_path('../conversion/stage_scores', __FILE__)

