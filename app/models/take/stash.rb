module Take
  class Stash < ActiveRecord::Base
    before_save :set_data
    
    
    def self.get(session)
      self.find_or_create_by_session_id(session["session_id"])
    end
    
    def get_post(id)
      data = self.get_data
      result = nil
      if data && data.has_key?("post")
        result = data["post"][id]
      end
      return result
    end
    
    def set_post(id,post)
      hash = self.get_data
      hash = hash.nil? ? {} : hash
      hash[:post] = {} unless hash[:post]
      hash[:post][id] = post
      self.data = hash
      self.save
    end
    
    def get_data
      result = Take::safe_json_decode(self.data) if self.data  # returns empty has if no json or error
      return result.empty? ? nil : result 
    end
    
    def set_data
      self.data = self.data.to_json
    end
    
    
  end
end
