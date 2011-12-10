module Take
  module AssessHelper
    def render_assessor(assmnt_hash,post=nil)
      AssessmentRenderer.new(assmnt_hash, post, self).render_assessment
    end
  end
end
