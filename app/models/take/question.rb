module Take
  class Question < ActiveRecord::Base
    belongs_to :assessment
    has_many :answers, :order => "sequence", :dependent => :destroy
    #before_validation :set_defaults
    before_save :valid_score_method
    after_save :updateMax
    after_destroy :updateMax
    validates_numericality_of :min_critical_value, :if => :critical, :message => "must be a number if critical checkbox checked"
    accepts_nested_attributes_for :answers, :reject_if => lambda { |a| a[:answer_text].blank? }, :allow_destroy => true
    attr_accessible :assessment_id, :sequence, :short_name,  :question_text, :instructions, :answer_tag, :type_display, :group_header, :weight, :critical, :min_critical_value, :score_method, :key, :answers_attributes

    def ans_hos_others
      #used by renderor to not start data-behavior unless one at least on of the anwers requires another response
      self.answers.where(:requires_other => true).count > 0
    end
    
    def clone
      max = self.assessment.questions.maximum(:sequence) 
      new_sequence = max.nil? ? 1  : max + 1
      
      answers = self.answers
      new_ques = self.dup
      new_ques.assessment_id = self.assessment_id
      new_ques.question_text = "Cloned #{new_ques.question_text}"
      new_ques.sequence = new_sequence
      new_ques.save
      new_quesid = new_ques.id
      for answer in answers
        new_ans = answer.dup
        new_ans.question_id = new_quesid
        new_ans.save
      end
      return new_ques
    end
    def self.console_clone(aid,qid,ques)
      # This is sort of an import. If you have a bunch of 1..5 radio type question/answers
      # You can create the first question/answers and then send the id's of that assessment/question
      # and a string array of the questions you want to create.
      return nil if ques.class != Array
      assmnt = Assessment.find(aid)
      return nil if assmnt.nil?
      question = assmnt.questions.find(qid)
      return nil if question.nil?
      max = assmnt.questions.maximum(:sequence) 
      new_sequence = max.nil? ? 1  : max + 1
      ques.each do |q|
        answers = question.answers
        new_ques = question.dup
        new_ques.assessment_id = question.assessment_id
        new_ques.question_text = q.strip
        new_ques.short_name = "" # not dealing with sort_names here, yet
        new_ques.sequence = new_sequence
        new_ques.save
        new_quesid = new_ques.id
        for answer in answers
          new_ans = answer.dup
          new_ans.question_id = new_quesid
          new_ans.save
        end
        new_sequence += 1
      end
      return question
    end
 
 
 
    private

    def set_defaults
      if ((self.score_method.downcase == "sum") || (self.score_method.downcase == "max")) && ((self.answer_tag.downcase == "checkbox") || (self.answer_tag.downcase == "select-multiple") )
        self.score_method = self.score_method.capitalize
      else
        self.score_method = "Value" unless self.score_method.downcase == "none"
      end
    end

    def updateMax
      if self.assessment
        Assessment.computeMax(self.assessment.id) if is_dirty?
      end
    end
    
    def valid_score_method
      if ((self.answer_tag.downcase == "checkbox") || (self.answer_tag.downcase == "select-multiple") )
        unless ((self.score_method.downcase == "sum") || (self.score_method.downcase == "max")  || (self.score_method.downcase == "none")) 
          self.errors[:base] << "Score Method must be None, Sum or Max for Checkbox or Select-multiple tags"
          return false
        end
      elsif ((self.answer_tag.downcase == "text") || (self.answer_tag.downcase == "textare") )
        unless ((self.score_method.downcase == "textcontains") || (self.score_method.downcase == "textnumeric")  || (self.score_method.downcase == "none")) 
          self.errors[:base] << "Score Method must be None, TextCompletion or TextNumeric for Text or Textarea tags"
          return false
        end
      else
        unless ((self.score_method.downcase == "value") || (self.score_method.downcase == "none")) 
          self.errors[:base] << "Score Method #{self.score_method} invalid for tag #{self.answer_tag}"
          return false
        end
      end
    end

    def is_dirty?
       dirty = false
       self.changed.each{|attrib|
         dirty =  (dirty || !( /score_method|weight|critical|minimum_value/i =~ attrib ).nil?)
       }
      return dirty
    end
    
      
  end
end
