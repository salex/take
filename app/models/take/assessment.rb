module Take
  class Assessment < ActiveRecord::Base
    has_many :questions, :order => "sequence", :dependent => :destroy
  
    def self.computeMax(id)
      if id.nil?
        return false
      end
      assessment = Assessment.find(id)
      maxRaw = 0
      maxWeighted = 0
      for question in assessment.questions
        maxQues = 0
        sumQues = 0
        weight = question.weight.nil? ? 0 : question.weight.to_f
        ansType = question.answer_tag.blank? ? "" : question.answer_tag.downcase
        scoreMethod = question.score_method.blank? ? "value" : question.score_method.downcase
        isScored = ((scoreMethod.downcase != "none") ) # and (weight > 0)
        isText =  !(ansType =~ /text/i).nil?
        for answer in question.answers
          isTextScored =  !answer.text_eval.blank? 
          value = answer.value.to_f
          if isScored
            if ((isText  and isTextScored) or (!isText ))
              if (value > maxQues)
                maxQues = value
              end if
              sumQues += value        
            end
          end
        end
        if ((scoreMethod == "sum")  and ((ansType == "checkbox") || (ansType == "select-multiple")))
          maxRaw += sumQues
          maxWeighted += (sumQues * weight)
        elsif ((scoreMethod == "textcontains") || (scoreMethod == "textnumeric"))
          maxRaw += sumQues
          maxWeighted += (sumQues * weight)
        else
          maxRaw += maxQues
          maxWeighted += (maxQues * weight)
        end
      end
      assessment.max_raw = maxRaw
      assessment.max_weighted = maxWeighted
      assessment.save
      return true
    end
    
    def publish(tojson = true)
      self[:questions] = []
      for question in self.questions
        question[:answers] = []
        for answer in question.answers
          question[:answers] << answer
        end
        self[:questions] << question
      end
      return  tojson ? self.to_json : self
    end
    
    def self.publish(aid)
      assessment = Assessment.find(aid)
      assessment[:questions] = []
      for question in assessment.questions
        question[:answers] = []
        for answer in question.answers
          question[:answers] << answer
        end
        assessment[:questions] << question
      end
      return assessment
    end
    
  end
end
