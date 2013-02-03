module Take
  class Assess < Assessment

    def self.get_post(id, session)
      stash = Stash.get(session)
      @post = stash.get_post(id) 
    end
    
    def self.set_post(id,post,session)
      stash = Stash.get(session)
      stash.set_post(id,post)
    end
    
    def self.get(session)
      stash = Stash.get(session)
    end
    
    def self.clear(session)
      Stash.clear(session)
    end
    
    def self.clone_assessment(id)
      assessment = self.find(id)
      return nil if assessment.nil?
      cloned_assessment = assessment.dup
      cloned_assessment.status = 'new'
      cloned_assessment.key = ''
      cloned_assessment.save
      newassid = cloned_assessment.id
      for question in assessment.questions
        answers = question.answers
        newques = question.dup
        newques.assessment_id = newassid
        newques.save
        newquesid = newques.id
        for answer in answers
          newans = answer.dup
          newans.question_id = newquesid
          newans.save
        end
      end
      return cloned_assessment
    end

    
    
    def self.score_assessment(assmnt_hash,post)
      totalScore = 0
      totalScoreWeighted = 0
      post["scores"] = {}
      assmnt_hash["questions"].each do |question|
        sum = 0
        max = 0
        #logger.debug "QUESTION" + question.inspect
        qid = question["id"].to_s
        answered = post["answer"][qid]
        a_ids = question["answers"].collect{|i| i["id"].to_s}        
        #puts answered.inspect
        score_method = question["score_method"].downcase
        if score_method != "none"
          txt_idx = 0
          question["answers"].each do |answer|
            aid = answer["id"].to_s
            if !answered.nil? && !answered.index(aid).nil?
              case score_method
              when "textcontains"
                answer = question["answers"][a_ids.index(answered[txt_idx])]
                #value = self.score_textContains(answer["value"],answer["text_eval"],post["text"][answered[0]])
                te = Take::TextEval::Contains.new(answer["text_eval"])
                aval =  te.score(post["text"][answered[txt_idx]],answer["value"])
                sum += aval
                #logger.info "Containssssssss #{aid} v #{aval} s #{sum} e #{answer["text_eval"]} a #{post["text"][answered[txt_idx]]}"
              when "textnumeric"
                answer = question["answers"][a_ids.index(answered[txt_idx])]
                #value = self.score_textNumeric(answer["value"],answer["text_eval"],post["text"][answered[0]])
                ne = Take::TextEval::Numeric.new(answer["text_eval"])
                aval = ne.score(post["text"][answered[txt_idx]],answer["value"])
                sum += aval
                
                #logger.info "Numericccccccccccc #{aid} v #{aval} s #{sum} e #{answer["text_eval"]} a #{post["text"][answered[txt_idx]]}"
                
              else
                sum += answer["value"]
                max = answer["value"] if answer["value"] > max
                #logger.debug "SUMMAX#{sum} #{max}"
              end
            end
            txt_idx += 1
          end
          #logger.debug "SUMMAX#{sum} #{max}"
          
          case score_method
          when "sum"
            value = sum
          when "textcontains"
            value = sum
            #answer = question["answers"][a_ids.index(answered[0])]
            #value = self.score_textContains(answer["value"],answer["text_eval"],post["text"][answered[0]])
            #te = Take::TextEval::Contains.new(answer["text_eval"])
            #value = te.score(post["text"][answered[0]],answer["value"])
          when "textnumeric"
            value = sum
            #answer = question["answers"][a_ids.index(answered[0])]
            #value = self.score_textNumeric(answer["value"],answer["text_eval"],post["text"][answered[0]])
            #ne = Take::TextEval::Numeric.new(answer["text_eval"])
            #value = ne.score(post["text"][answered[0]],answer["value"])
            
          else
            value = max
          end
          #if critical do something
          if question["critical"]
            if value < question["min_critical_value"]
              post['critical']  = [] unless post['critical']
              post['critical'] << qid
            end
          end
        else
          value = 0  
        end
        #logger.info "VALUE #{value} Total #{totalScore} Score Method #{score_method} Max #{max}"
        totalScore +=  value
        totalScoreWeighted += (value * question["weight"])
        post["scores"][qid] = {'raw'  => value, 'weighted'  => (value * question["weight"])}
        #puts "Totals #{totalScore} #{totalScoreWeighted}"
      end
      post["scores"]["total"] = {'raw'  => totalScore, 'weighted'  => totalScoreWeighted}
      post["scores"]["percent"] = {'raw'  => ( assmnt_hash["max_raw"] == 0.0 ? 0.0 : totalScore / assmnt_hash["max_raw"]) , 
        'weighted'  => (assmnt_hash["max_weighted"] == 0.0 ? 0.0 : totalScoreWeighted / assmnt_hash["max_weighted"])}
      all = []
      post["answer"].each do |key,value|
        all.concat(value)
      end
      post["all"] = all
      return  post

    end
  end  
end
    
