2 char delimiters to avoid stuff in asnser
!! negate match 
>>{+,-} section delimiter{partial credit/debit} (+ add value, - subtract value)
+- delta value::points for numeric
:: value  (default minus for numeric)

Numeric 

5 point
3.1416+-.000025+-.0001::1+-.001::4

exact delta1 delta2

score = max(exact, delta..) >= 0

if 3.1416 => 5 5 4 1 = 5
if 3.14159 => 0 5 4 1 = 5
if 3.1417 => 0 0 4 1 = 4
if 3.1406 => 0 0 0 1 = 1
if 3.1405 => 0 0 0 0 = 0

10 points
(quick|brown|lazy)&fox&back>>+quick::2&brown::2&lazy::2&fox::4&back::4>>-dog::1
1::back&1::fox&-0.5::dog&1::(quick|brown|lazy)
sections
    exact >>+ partial plus >>- partial minus


score = max( (exact - partial minus), (partial plus - partial minus)) >= 0
quick brown lazy fox => [10 - 0] [2 2 2 1 0 - 0] [0] = 10
quick dog lazy fox => [0 - 1] [2 0 2 1 0 - 1] [0] = 4
quick brown lazy => [0 - 1] [2 2 2 0 0 - 0] [0] = 5

etc


entire scoring

  def self.score_assessment(hash,post)
    # hash is a collection made from a VERSION of assessments<questions<answers. VERSION saved as json and 
    # used to build and score assessment
    
    #post = collection of answers, text, and other all added merging answer arrays
    # eg {"answer"=>{"3"=>["1"], "4"=>["9"]}, "other"=>{"1"=>"jjjjj", "8"=>""}}
    totalScore = 0
    totalScoreWeighted = 0
    
    hash["questions"].each do |question|
      sum = 0
      max = 0
      puts question["question_text"]
      qid = question["id"].to_s
      answered = post["answer"][qid]
      puts answered.inspect
      score_method = question["score_method"].downcase
      if score_method != "none"
        question["answers"].each do |answer|
          aid = answer["id"].to_s
          if !answered.index(aid).nil?
            sum += answer["value"]
            max = answer["value"] if answer["value"] > max
            puts "#{sum} #{max}"
          end
        end
        case score_method
        when "sum"
          value = sum
        when "textcontains"
          value = 1 #call
        when "textnumeric"
          value = 1 #call
        else
          value = max
        end
      end
      totalScore += value
      totalScoreWeighted += (value * question["weight"])
      puts "Totals #{totalScore} #{totalScoreWeighted}"
    end

    return totalScore, totalScoreWeighted, post, hash

  end
  
  def score_textNumeric(value,eval,ans)
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
  
  def score_textContains(value,eval,ans)
  
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
    return score > 0 ? score : 0.0
  end
  
  def _score_exact(value,eval,ans)
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
  
  def _score_partial(eval,ans)
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
