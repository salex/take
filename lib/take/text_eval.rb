module Take  
  module TextEval
    class Numeric
      attr_reader :sections, :match, :deltas
      
      def initialize(text)
        @sections = text.split("::")
        @match = @sections[0].to_f if @sections.length > 0
        @deltas = {0.0 => 100.0} 
        if @sections.length > 1
          1.upto(@sections.length - 1) do |i|
            t = @sections[i].split(">>")
            if t.length == 2
              @deltas[t[0].to_f] = t[1].to_f
            else
              @deltas[t[0].to_f] = 100.0
            end
          end
        end
      end
  
      def score(answer,value)
        ans = answer.to_f
        result = 0.0
        @deltas.each do |delta,percent|
          test_max = @match + delta
          test_min = @match - delta
          if ans.between?(test_min,test_max)
            result = value * (percent/100.0)
            break
          end
        end
        result = result < 0 ? 0 : result
        result = result > value ? value : result
        return result
      end
    end

    class Contains
      attr_reader :sections, :match, :partial
      
      def initialize(text)
        @sections = text.split("::")
        @partial = @sections.length > 1 ? @sections[1] : nil
        @match = @sections[0]
      end
  
      def score(answer,value)
        return [exact_score(answer,value),partial_score(answer,value)].max
      end
  
      private
  
      def and_splits(section)
        ands = section.split("&")
      end
  
      def exact_score(answer,value)
        ands =  and_splits(@match)
        ok = true
        ands.each do |elem|
          eq = true
          if (elem[0..1] == "!") 
            eq = false
            elem = elem[1..-1]
          end
          if ok
            re = Regexp.new(elem,true)
            elem_ok = !( re =~ answer).nil? # it is there or not
            elem_ok = eq ? elem_ok : !elem_ok
            ok = ok && elem_ok
          end
        end
        #puts "e #{ok ? value : 0.0}"
        return ok ? value : 0.0
      end
  
      def partial_score(answer,value)
        result = 0.0
        return result if @partial.nil?
        ands =  and_splits(@partial)
        ands.each do |elem|
          eq = true
          if (elem[0..1] == "!") 
            eq = false
            elem = elem[1..-1]
          end
          tmp = elem.split(">>")
          if tmp.length == 2
             perc = tmp[1].to_f
            elem = tmp[0]
          else
            perc = 0.0
          end
          re = Regexp.new(elem,true)
          elem_ok = !( re =~ answer).nil? # it is there or not
          elem_ok = eq ? elem_ok : !elem_ok
          result += (value * (perc / 100.0)) if elem_ok
          #puts "e #{result} #{perc} #{elem_ok}"
      
        end
        result = result < 0 ? 0 : result
        result = result > value ? value : result
        #puts "p #{result}"
        return result
      end  
    end
  end
end