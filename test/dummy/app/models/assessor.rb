class Assessor < ActiveRecord::Base
  default_scope :order => :sequence
  before_save :get_published
  belongs_to :assessing, :polymorphic => true
  
  
  def get_published
    self.publish_json = Assess.publish(self.assessment_id).to_json
  end
end
