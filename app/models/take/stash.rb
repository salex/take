module Take
  class Stash < ActiveRecord::Base
    before_save :set_data
    
    
    def self.get(session)
      self.find_or_create_by_session_id(session["session_id"])
      
    end
    
    def get_data
      result = Take::safe_json_decode(self.data) if self.data
      return result.empty? ? nil : result 
    end
    
    def set_data
      self.data = self.data.to_json
    end
    
    
  end
end
