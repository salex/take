module Take
  class Assess < Assessment
    
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
      score_partial_plus = _score_partial(partial_plus,ans) unless partial_plus.blank?
      score_partial_minus = _score_partial(partial_minus,ans) unless partial_minus.blank?
      score = [(score_exact - score_partial_minus),(score_partial_plus - score_partial_minus) ].max
      score =  score > 0 ? score : 0.0
      return score > value ? value : score
    end
    
  private
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
    
