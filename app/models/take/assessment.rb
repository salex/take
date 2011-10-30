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
        if ((scoreMethod == "sum")  and ((ansType == "checkbox") or (ansType == "select-multiple")))
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
    
    def publish
      self[:questions] = []
      for question in self.questions
        question[:answers] = []
        for answer in question.answers
          question[:answers] << answer
        end
        self[:questions] << question
      end
      return self.to_json
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
    
    def self.score_assessment(hash,post)
      totalScore = 0
      totalScoreWeighted = 0
      post["scores"] = {}
      hash["questions"].each do |question|
        sum = 0
        max = 0
        puts question["question_text"]
        qid = question["id"].to_s
        answered = post["answer"][qid]
        a_ids = question["answers"].collect{|i| i["id"].to_s}        
        #puts answered.inspect
        score_method = question["score_method"].downcase
        if score_method != "none"
          question["answers"].each do |answer|
            aid = answer["id"].to_s
            if !answered.index(aid).nil?
              sum += answer["value"]
              max = answer["value"] if answer["value"] > max
              #puts "#{sum} #{max}"
            end
          end
          case score_method
          when "sum"
            value = sum
          when "textcontains"
            answer = question["answers"][a_ids.index(answered[0])]
            value = self.score_textContains(answer["value"],answer["text_eval"],post["text"][answered[0]])
          when "textnumeric"
            answer = question["answers"][a_ids.index(answered[0])]
            value = self.score_textNumeric(answer["value"],answer["text_eval"],post["text"][answered[0]])
          else
            value = max
          end
        end
        totalScore += value
        totalScoreWeighted += (value * question["weight"])
        post["scores"][qid] = "#{value} #{(value * question["weight"])}"
        #puts "Totals #{totalScore} #{totalScoreWeighted}"
      end
        post["scores"]["Totals"] = "#{totalScore} #{totalScoreWeighted}"
      return totalScore, totalScoreWeighted, post, hash

    end
    
    def self.score_textNumeric(value,eval,ans)
      #ans = "3.1416"
      #value = 5
      #eval = "3.1416+-.0005::1+-.001::4"
      value = value.to_f
      ans = ans.to_f
      chunks = eval.split("+-")
      exact = chunks[0].to_f
      scores = Array.new(chunks.size)
      scores[0] = ans == exact ? value : 0.0
      1.upto(chunks.size - 1) do |i|
        deltas = chunks[i].split("::")
        delta = deltas[0].to_f
        min = exact - delta
        max = exact + delta
        
        if deltas.size > 0
          scores[i] = ans.between?(min,max) ? (value - deltas[1].to_f) : 0.0
        else
          scores[i] = ans.between?(min,max) ? value : 0.0
        end
      end
      result = scores.max
      return  result < 0.0 ? 0.0 : result
      
    end
    
    def self.score_textContains(value,eval,ans)
    
      exact = partial_plus = partial_minus = ""
      score_exact = score_partial_plus = score_partial_minus = 0.0
      sections = eval.split(">>")
      0.upto(sections.size - 1) do |i|
        if sections[i].slice(0..0) == "+"
          partial_plus = sections[i].slice(1..-1)
        elsif sections[i].slice(0..0) == "-"
          partial_minus = sections[i].slice(1..-1)
        else
          exact = sections[i]
        end
      end
      score_exact = _score_exact(value,exact,ans) unless exact.blank?
      score_partial_plus = self._score_partial(partial_plus,ans) unless partial_plus.blank?
      score_partial_minus = self._score_partial(partial_minus,ans) unless partial_minus.blank?
      score = [(score_exact - score_partial_minus),(score_partial_plus - score_partial_minus) ].max
      return score > 0 ? score : 0.0
    end
    
    def self._score_exact(value,eval,ans)
      value = value.to_f
      eq = true
      if (eval[0..0] == "!") 
        eq = false
        eval = eval[1..-1]
      end
      and_splits = eval.split("&")
      ok = true
      for chunk in and_splits
        if ok
          re = Regexp.new(chunk,true)
          chunk_ok = !( re =~ ans).nil? # it is there or not
          ok = ok && chunk_ok
        end
      end
      ok = ok && eq
      return ok ? value : 0.0
    end
    
    def self._score_partial(eval,ans)
      value = 0.0
      and_splits = eval.split("&")
      for chunk in and_splits
        chunk_split = chunk.split("::")
        chunk_value = chunk_split.size > 1 ? chunk_split[1].to_f : 0.0
        re = Regexp.new(chunk_split[0],true)
        chunk_ok = !( re =~ ans).nil? # it is there or not
        value += chunk_value if chunk_ok
      end
      return value
    end
    #score_textContains(value,eval,ans)
  end
  
  
end
