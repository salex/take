module Take
  class Stash < ActiveRecord::Base
    before_save :set_data
    
    
    def self.get(session)
      self.find_or_create_by_session_id(session["session_id"])
    end
    
    def get_post(id)
      hash = self.get_data
      logger.info "GET POST   #{hash}"
      result = nil
      if hash && hash.has_key?("post")
        result = hash["post"][id]
      end
      return result
    end
    
    def set_post(id,post)
      hash = self.get_data
      logger.info "SET POST in   #{hash} #{post}"
      
      hash = hash.nil? ? {} : hash
      hash["post"] = {} unless hash["post"]
      hash["post"][id] = post
      logger.info "SET POST out   #{hash}"
      self.data = hash
      self.save
    end
    
    def get_data
      result = Take::safe_json_decode(self.data) if self.data  # returns empty has if no json or error
      return result.empty? ? nil : result 
    end
    
    def set_data
      logger.info "SET DATA 1   #{self.data}"
      
      self.data = self.data.to_json
      logger.info "SET DATA 2   #{self.data}"
      
    end
    
    
  end
end
