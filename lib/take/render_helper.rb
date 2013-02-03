module Take
  class AssessmentRenderer
    def initialize(assmnt, post, template)
      @assmnt = assmnt
      @post = post
      @template = template
    end
  
    def render_assessment
      result =  <<-HERE
      <div id="take">
        #{h_make_instruction(@assmnt["instructions"])}
        <div class="take-questions">
          #{h_make_questions}
        </div>
      </div>
      HERE
      return result.html_safe
    end
    
    private
    
    def h_make_instruction(text)
      result = <<-HERE
      <div class="take-instructions">
        #{text}
      </div>
      HERE
      return result
    end
    
    def h_make_questions
      result = ""
      @assmnt["questions"].each do |question|
        if question["type_display"].downcase != "none"
          result << h_make_group_header(question["group_header"]) unless question["group_header"].blank?
          # TODO atempt , set requires_other at question level if any answer requires other
          question["answers"].map{|r| question["requires_other"] = r["requires_other"] if r["requires_other"]  }
          if question["type_display"].downcase == "inline"
            result << h_make_inline_question(question)
          else
            result << h_make_list_question(question)
          end
        end
      end
      return result
    end
    
    def h_make_group_header(text)
      result = <<-HERE
      <div class="take-group-header">
        #{text}
      </div>
      HERE
      return result
    end
    
    def h_make_list_question(question)
      result = ""
      result << 
      result << <<-HERE
      <div class="take-question">
        #{h_make_question_instructions(question["instructions"]) unless question["instructions"].blank?}
        <div id="err_qa_#{question["id"]}">
        
          <div class="take-question-text">
            #{question["question_text"]}
          </div>
          <div class="take-answers">
            <table>
              #{h_make_list_answers(question)}
            </table>
            <div id="err_qa_#{question["id"]}"></div>
          
          </div>
        </div>
      </div>
      HERE
      return result
    end
    
    def h_make_inline_question(question)
      result = ""
      result << h_make_question_instructions(question["instructions"]) unless question["instructions"].blank?
      result << <<-HERE
      <div class="take-question">
        <div class="take-answers-inline">
          <div id="err_qa_#{question["id"]}">
            <table>
              <tr>
                #{h_make_inline_answers(question)}
                <td class="take-question-text">
                  <div >
                    #{question["question_text"]}
                    #{h_make_other_question(question)}
                  </div>
                </td>
              </tr>
            </table>
          </div>
        </div>
      </div>
      HERE
      return result
    end
    
    def h_make_question_instructions(text)
      result = <<-HERE
      <div class="take-question-instructions">
        #{text}
      </div>
      HERE
      return result
    end
    
    def h_make_inline_answers(question)
      result = ""
      if !(question["answer_tag"] =~   /select/i).nil?
        result << "<td>#{ h_make_select_tag(question)}</td>\n"
        
      else
        question["answers"].each do |answer|
          result << "<th>#{h_make_input_tag(question,answer)} #{answer["answer_text"]}</th>\n"
        end
      end
      return result
    end
    
    def h_make_list_answers(question)
      result = ""
      if !(question["answer_tag"] =~   /select/i).nil?
        result << "<tr><td>#{ h_make_select_tag(question)}#{h_make_other_question(question)}</td></tr>\n"
      else
        question["answers"].each do |answer|
          result << "<tr><td>#{h_make_input_tag(question,answer)}</td><td> #{answer["answer_text"]}#{h_make_other_question(question,answer)}</td></tr>\n"
        end
      end
      return result
    end
    
    def h_make_other_question(question,ans=nil)
      result = ""
      if ans.nil?
        # inline
        question["answers"].each do |answer|
          if answer["requires_other"] && (question["answer_tag"] =~ /text/i).nil?
            text, exists, other = h_getAnswerData(answer["id"].to_s)
            dsp = exists ? "block" : "none"
            result << <<-HERE
            <div class="take-other-question" id="other_qa_#{question["id"]}_#{answer["id"]}" style="display:#{dsp}">
            #{text_field_tag("post[other][#{answer["id"].to_s}]",other, :id => "text_qa_#{question["id"]}_#{answer["id"]}", :disabled => !exists)} 
            #{answer["answer_text"]}: #{answer["other_question"]}
            </div>
            HERE
          end
        end
      else
        if ans["requires_other"] && (question["answer_tag"] =~ /text/i).nil?
          text, exists, other = h_getAnswerData(ans["id"].to_s)
          dsp = exists ? "block" : "none"
          result = <<-HERE
            <div class="take-other-question" id="other_qa_#{question["id"]}_#{ans["id"]}" style="display:#{dsp}">
            #{text_field_tag("post[other][#{ans["id"].to_s}]",other, :id => "text_qa_#{question["id"]}_#{ans["id"]}", :disabled => !exists)} 
            #{ans["other_question"]}
            </div>
          HERE
        end
      end
      return result
    end
    
    def h_getAnswerData(answer_id)
      text = ""
      exists = false
      other = ""
      if @post
        #Answers from a previous application or session are in the Params collection - values are extracted
        #into the variables ans, chkd, and othans 
        if !@post["all"].index(answer_id).nil?
          exists = true
          other = @post["other"][answer_id] if @post["other"]
          text = @post["text"][answer_id]if @post["text"]
        end
      end
      return text, exists, other
    end
    
    
    def h_make_select_tag(question)
      
      answers = question["answers"]
      options = ""
      answers.each do |answer|
        text, exists, other = h_getAnswerData(answer["id"].to_s)
        
        sel = exists ? 'selected="selected"' : ""        
        options << <<-HE
        <option value="#{answer["id"]}" #{sel}>#{answer["answer_text"]}</option>
        HE
      end
      data_behavior = question["requires_other"] ? "toggle_other_sel" : ""
      mult = question["answer_tag"].downcase == "select" ? false : true
      required = question["score_method"].downcase == "none" ? "" : "required-one"
      
      result = select_tag("post[answer][#{question["id"]}][]", options.html_safe, :id => "qa_#{question["id"]}", 
      :class => required, :include_blank => !mult, :multiple => mult, :"data-behavior" => data_behavior )
      
    end
    
    def h_make_input_tag(question,answer)
      result = ""
      text, exists, other = h_getAnswerData(answer["id"].to_s)
      #Rails.logger.debug "MAKE RADO button  #{question["requires_other"]}"
      
      case question["answer_tag"].downcase
      when "radio"
        required = question["score_method"].downcase == "none" ? "" : "required-one"
        # behavior =  "toggle_other" 
        #TODO Make temp obj in question ans_requires_other if any of the answers for a questiion
        # as a requires_other tag. set behavior but this flag
        #behavior = answer["requires_other"] ? "toggle_other" : "none"
        behavior = question["requires_other"] ? "toggle_other" : ""
        
        result = radio_button_tag("post[answer][#{question["id"]}][]",answer["id"].to_s, exists,
         :class => required, :"data-behavior" => behavior , :id => "qa_#{question["id"]}_#{answer["id"]}")
      when "checkbox"
        required = question["score_method"].downcase == "none" ? "" : "required-one"
        behavior = answer["requires_other"] ? "toggle_other" : "none"
        chkd = false
        result = check_box_tag("post[answer][#{question["id"]}][]",answer["id"].to_s, exists,
         :class => required, :"data-behavior" => behavior, :id => "qa_#{question["id"]}_#{answer["id"]}")
      when "textarea"
        required = question["score_method"].downcase == "none" ? "" : "required"
        hidden_elem = hidden_field_tag("post[answer][#{question["id"]}][]",answer["id"].to_s,:id => nil ) 
        result = hidden_elem + text_area_tag("post[text][#{answer["id"]}]",text,
         :class => required,  :id => "qa_#{question["id"]}_#{answer["id"]}")
      when /text/i
        required = question["score_method"].downcase == "none" ? "" : "required"
        hidden_elem = hidden_field_tag("post[answer][#{question["id"]}][]",answer["id"].to_s,:id => nil ) 
        result = hidden_elem + text_field_tag("post[text][#{answer["id"]}]",text,
         :class => required,  :id => "qa_#{question["id"]}_#{answer["id"]}")
      end
    end
    
    def method_missing(*args, &block)
      @template.send(*args, &block)
    end
    
  end
end
