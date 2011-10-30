class Assessor < ActiveRecord::Base
  before_save :get_published
  
  
  def get_published
    self.publish_json = Take::Assessment.publish(self.assessment_id).to_json
  end
end
