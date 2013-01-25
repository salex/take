module Take
  class Assessment < ActiveRecord::Base
    has_many :questions, :order => "sequence", :dependent => :destroy
    attr_accessible  :default_answer_tag, :category,  :created_at, :description, :default_display, :id, :instructions, :max_raw, :max_weighted, :name, :status, :updated_at, :key

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
    
    # DEPRACATED, wrong approach anyhow!!!
    # def publish(tojson = true)
    #   self[:questions] = []
    #   for question in self.questions
    #     question[:answers] = []
    #     for answer in question.answers
    #       question[:answers] << answer
    #     end
    #     self[:questions] << question
    #   end
    #   return  tojson ? self.to_json : self
    # end
    
    def publish(tojson = true)
      json = self.to_json(:include => {:questions => {:include => :answers}})
      return tojson ? json : Take.safe_json_decode(json)
    end
  
    def self.publish(aid)
      assmnt = Assessment.find(aid)
      return assmnt.publish(false)
    end
  end
  
  
end
