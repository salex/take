module Take
  class Answer < ActiveRecord::Base
    belongs_to :question
    after_save :updateMax
    after_destroy :updateMax
    validates_numericality_of :value
    
    attr_accessible :question_id, :sequence, :short_name, :answer_text, :value, :requires_other, :other_question, :text_eval, :key

    private

    def updateMax
      if self.question
        Assessment.computeMax(self.question.assessment.id) if is_dirty?
      end
    end

    def is_dirty?
       dirty = false
       self.changed.each{|attrib|
         dirty =  (dirty || !( /value|answer_eval/i =~ attrib ).nil?)
       }
      return dirty
    end
  end
end
