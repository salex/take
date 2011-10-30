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


    private

    def set_defaults
      if ((self.score_method.downcase == "sum") || (self.score_method.downcase == "max")) && ((self.answer_tag.downcase == "checkbox") || (self.answer_tag.downcase == "select-multiple") )
        self.score_method = self.score_method.capitalize
      else
        self.score_method = "Value" unless self.score_method.downcase == "none"
      end
    end

    def updateMax
      Assessment.computeMax(self.assessment.id) if is_dirty?
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
