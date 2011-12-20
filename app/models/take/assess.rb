module Take
  class Assess < Assessment

    def self.get_post(id, session)
      stash = Take::Stash.get(session)
      @post = stash.get_post(id) 
    end
    
    def self.set_post(id,post,session)
      stash = Stash.get(session)
      stash.set_post(id,post)
    end
    
    def self.score_assessment(assmnt_hash,post)
      totalScore = 0
      totalScoreWeighted = 0
      post["scores"] = {}
      assmnt_hash["questions"].each do |question|
        sum = 0
        max = 0
        #puts question["question_text"]
        qid = question["id"].to_s
        answered = post["answer"][qid]
        a_ids = question["answers"].collect{|i| i["id"].to_s}        
        #puts answered.inspect
        score_method = question["score_method"].downcase
        if score_method != "none"
          txt_idx = 0
          question["answers"].each do |answer|
            aid = answer["id"].to_s
            if !answered.index(aid).nil?
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
                #puts "#{sum} #{max}"
              end
            end
            txt_idx += 1
          end
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
              post[:critical]  = [] unless post[:critical]
              post[:critical] << qid
            end
          end
          
        end
        totalScore += value
        totalScoreWeighted += (value * question["weight"])
        post["scores"][qid] = {raw: value, weighted: (value * question["weight"])}
        #puts "Totals #{totalScore} #{totalScoreWeighted}"
      end
      post["scores"]["total"] = {raw: totalScore, weighted: totalScoreWeighted}
      post["scores"]["percent"] = {raw: (totalScore / assmnt_hash["max_raw"]) , weighted: (totalScoreWeighted / assmnt_hash["max_weighted"])}
      all = []
      post["answer"].each do |key,value|
        all.concat(value)
      end
      post["all"] = all
      return  post

    end
  end  
end
    
