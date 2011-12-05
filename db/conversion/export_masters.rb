# This is the first step in the conversion.
#   The Master assessesments and all their questions and answers are export to a file in JSON format.
#   This is all this does. Once completed, drop the db, db create and db load schema. Then comment it out in seeds.rb

questions = Question.joins(:assessment).where("assessments.status" => "Master")
answers = Answer.joins(:question => :assessment).where("assessments.status" => "Master")
assessments = Assessment.where("assessments.status" => "Master")

filepath = Rails.root.join("db/conversion","assessments.json")
json = assessments.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote assessments records as JSON"

filepath = Rails.root.join("db/conversion","questions.json")
json = questions.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote questions records as JSON"

filepath = Rails.root.join("db/conversion","answers.json")
json = answers.to_json
File.open(filepath,'w') {|f| f.write(json)}
puts "Wrote answers records as JSON"
