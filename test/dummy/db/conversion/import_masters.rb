# This is the second step in the conversion.
#   what was exported from the development master assessments is imported

Take::Assessment.destroy_all
filepath = Rails.root.join("db/conversion","assessments.json")
json = File.read(filepath)
assessments = json_parse(json)
assessments.each {|i| 
  assessment = Take::Assessment.new(i["assessment"])
  assessment.id = i["assessment"]["id"]
  assessment.save(:validate => false)
}
puts "Wrote assessment records"
Take::Question.destroy_all

filepath = Rails.root.join("db/conversion","questions.json")
json = File.read(filepath)
questions = json_parse(json)
questions.each {|i| 
  question = Take::Question.new(i["question"])
  question.id = i["question"]["id"]
  question.save(:validate => false)
}
puts "Wrote question records"
Take::Answer.destroy_all

filepath = Rails.root.join("db/conversion","answers.json")
json = File.read(filepath)
answers = json_parse(json)
answers.each {|i| 
  answer = Take::Answer.new(i["answer"])
  answer.id = i["answer"]["id"]
  answer.save(:validate => false)
}
puts "Wrote answer records"

