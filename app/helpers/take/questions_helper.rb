module Take
  module QuestionsHelper
    def render_text_contains(eval_text,seq)
      eval_text = eval_text.nil? ? "" : eval_text
      @obj = Take::TextEval::Contains.new(eval_text)
      @seq = seq
      result =  <<-HERE
      <div id="eval_#{@seq}_div" style="display:none" class="assmnt-questions">
        <div class="assmnt-group-header">
          Text Contains Evaluation
        </div>
        #{contains_format}
        <div class="actions">
          #{button_to_function "Update Text Eval",nil, :id => "seq_#{@seq}_update", "data-behavior" => "contains_update"}
          #{link_to_function "Cancel",nil, :id => "seq_#{@seq}_cancel", "data-behavior" => "contains_cancel", :class => "breadcrumb"}
        </div>
      </div>
      HERE
      return result.html_safe
    end
    
    def render_text_numeric(eval_text,seq)
      eval_text = eval_text.nil? ? "" : eval_text
      @obj = Take::TextEval::Numeric.new(eval_text)
      @seq = seq
      result =  <<-HERE
      <div id="eval_#{@seq}_div" style="display:none" class="assmnt-questions">
        <div class="assmnt-group-header">
          Numeric Evaluation
        </div>
        #{numeric_format}
        <div class="actions">
          #{button_to_function "Update Text Eval",nil, :id => "seq_#{@seq}_update", "data-behavior" => "numeric_update"}
          #{link_to_function "Cancel",nil, :id => "seq_#{@seq}_cancel", "data-behavior" => "numeric_cancel", :class => "breadcrumb"}
        </div>
      </div>
      HERE
      return result.html_safe
    end
    
    def numeric_format
      deltas = @obj.deltas.keys
      result =  <<-HERE
      <div class="assmnt-question">
        <div class="assmnt-question-instructions">
          Match instruction
        </div>
        <div class="assmnt-answers-inline">
          <table>
            <tr>
              <th>Exact Match<input type="text"  value="#{@obj.match}" id="numeric_match_#{@seq}" size="30" /></th>
              <th>Delta&#177;<input class="seq_#{@seq}_delta" type="text"  value="#{deltas[0] if @obj.sections.length > 0}" id="numeric_delta_#{@seq}_0" size="10" /> (100%)
                <input type="hidden" value="100" id="numeric_perc_#{@seq}_0" />
              </th>
            </tr>
          </table>
        </div>
      </div>
      <div class="assmnt-question">
        <div class="assmnt-question-instructions">
          Delta instruction
        </div>
      HERE
      1.upto(deltas.length - 1 ) do |i|
        result +=  <<-HERE
        <div class="assmnt-answers-inline">
          <table>
            <tr>
              <th>Delta&#177;<input class="seq_#{@seq}_delta" type="text" value="#{deltas[i]}" id="numeric_delta_#{@seq}_#{i}" size="10" /></th>
              <th>Percent<input type="text" value="#{@obj.deltas[deltas[i]]}" id="numeric_perc_#{@seq}_#{i}" size="3" /></th>
            </tr>
          </table>
        </div>
        HERE
      end
      deltas.length.upto(deltas.length + 1 ) do |i|
        result +=  <<-HERE
        <div class="assmnt-answers-inline">
          <table>
            <tr>
              <th>Delta&#177;<input class="seq_#{@seq}_delta" type="text" value="" id="numeric_delta_#{@seq}_#{i}" size="10" /></th>
              <th>Percent<input type="text" value="" id="numeric_perc_#{@seq}_#{i}" size="3" /></th>
            </tr>
          </table>
        </div>
        HERE
      end
      
      result +=  <<-HERE
      </div>
      HERE
      return result.html_safe
      
    end
    
    def contains_format
      matchands = @obj.match ? @obj.match.split('&') : []
      partialands = @obj.partial ? @obj.partial.split("&") : []
      result =  <<-HERE
      <div class="assmnt-question">
        <div class="assmnt-question-instructions">
          Match Instruction
        </div>
        #{match_ands(matchands)}
      </div>
      <div class="assmnt-question">
        <div class="assmnt-question-instructions">
          Patial Instruction
        </div>
        #{partial_ands(partialands)}
      </div>
      HERE
      
    end
    
    def match_ands(match_ands)
      result = ""
      0.upto(match_ands.length - 1 ) do |i|
        words = match_ands[i]
        if words[0..0] == "!"
          nchecked = 'checked="checked"'
          words = words[1..-1]
        else
          nchecked = ''
        end
        if words[0..0] == "("
          ochecked = 'checked="checked"'
          words = words[1..-2]
        else
          ochecked = ""
        end
        
        result +=  <<-HERE
        <div class="assmnt-answers-inline">
          <table>
            <tr>
            <td>Or <input type="checkbox" id="contain_or_#{@seq}_#{i}" value="or" #{ochecked} /></td>
            <td>Not <input type="checkbox" id="contain_not_#{@seq}_#{i}" value="not" #{nchecked} /></td>
            <td>Word(s) <input class="seq_#{@seq}_match" type="text" id="contain_words_#{@seq}_#{i}" value="#{words}"  size="30" /></td>
            </tr>
          </table>
        </div>
        HERE
      end
      match_ands.length.upto(match_ands.length + 1) do |i|
        result +=  <<-HERE
        <div class="assmnt-answers-inline">
          <table>
            <tr>
            <td>Or <input type="checkbox" id="contain_or_#{@seq}_#{i}" value="or"  /></td>
            <td>Not <input type="checkbox" id="contain_not_#{@seq}_#{i}" value="not"  /></td>
            <td>Word(s) <input class="seq_#{@seq}_match" type="text" id="contain_words_#{@seq}_#{i}" value=""  size="30" /></td>
            </tr>
          </table>
        </div>
        HERE
      end
      return result
    end
    
    def partial_ands(partial_ands)
      result = ""
      0.upto(partial_ands.length - 1 ) do |i|
        tmp = partial_ands[i].split(">>")
        words = tmp[0]
        perc = tmp.length == 2 ? tmp[1] : 0
        if words[0..0] == "!"
          nchecked = 'checked="checked"'
          words = words[1..-1]
        else
          nchecked = ''
        end
        if words[0..0] == "("
          ochecked = 'checked="checked"'
          words = words[1..-2]
        else
          ochecked = ""
        end
        
        result +=  <<-HERE
        <div class="assmnt-answers-inline">
          <table>
            <tr>
            <td>Or <input type="checkbox" id="partial_or_#{@seq}_#{i}" value="or" #{ochecked} /></td>
            <td>Not <input type="checkbox" id="partial_not_#{@seq}_#{i}" value="not" #{nchecked} /></td>
            <td>Word(s) <input class="seq_#{@seq}_partial" type="text" id="partial_words_#{@seq}_#{i}" value="#{words}"  size="30" /></td>
            <td>Percent <input type="text" id="partial_perc_#{@seq}_#{i}" value="#{perc}"  size="3" /></td>
            </tr>
          </table>
        </div>
        HERE
      end
      partial_ands.length.upto(partial_ands.length + 1) do |i|
        result +=  <<-HERE
        <div class="assmnt-answers-inline">
          <table>
            <tr>
            <td>Or <input type="checkbox" id="partial_or_#{@seq}_#{i}" value="or"  /></td>
            <td>Not <input type="checkbox" id="partial_not_#{@seq}_#{i}" value="not"  /></td>
            <td>Word(s) <input class="seq_#{@seq}_partial" type="text" id="partial_words_#{@seq}_#{i}" value=""  size="30" /></td>
            <td>Percent <input type="text" id="partial_perc_#{@seq}_#{i}" value=""  size="3" /></td>
            </tr>
          </table>
        </div>
        HERE
      end
      
      return result
      
    end
  end
end

