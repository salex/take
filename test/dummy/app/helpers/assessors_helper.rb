module AssessorsHelper
  include Take::AssessHelper
  
  # this makes the render_assessor method accessible by the application that use Take
  
  # module AssessHelper
  #  def render_assessor(assmnt_hash,post=nil)
  #    AssessmentRenderer.new(assmnt_hash, post, self).render_assessment
  #  end
  # end
  
  # The arguments for render_assessor are the assmnt_hash (see assessor_helper.rb), and an optional post object that has the answers from a pseudo session or previous assessment.
  
  
end
