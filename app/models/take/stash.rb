module Take
  class Stash < ActiveRecord::Base
    before_save :set_data
    validates_uniqueness_of :session_id
    store :session, :assessors => [:apply, :assess, :user_id, :loginable_id, :loginable_type]
    
    
    
    def self.get(session)
      Stash.sweep
      self.find_or_create_by_session_id(session["session_id"])
    end
    
    def self.clear(session)
      sess = self.find_by_session_id(session["session_id"])
      if sess
        sess.destroy
      end
    end
    
    def self.sweep(time = 2)
      #self.where('updated_at < ?',2.hour.ago).map(&:delete)
      self.delete_all "updated_at < '#{time.hours.ago}' OR created_at < '#{2.days.ago}'"
    end
    
    def get_post(id)
      hash = self.get_data
      result = nil
      if hash && hash.has_key?("post")
        result = hash["post"][id.to_s]
      end
      return result
    end
    
    def set_post(id,post)
      hash = self.get_data
      #logger.info "SET POST in   #{id} #{post}"
      
      hash = hash.nil? ? {} : hash
      hash["post"] = {} unless hash["post"]
      hash["post"][id.to_s] = post
      #logger.info "SUMMING POST out   #{hash}"
      self.data = hash
      self.save
      return self
    end
    
    def get_data
      result = Take::safe_json_decode(self.data) if self.data  # returns empty has if no json or error
      #logger.info "SUMMING RESULT  out   #{result}"
      #logger.info "GET DATA 1   #{result.inspect}"
      return result.nil? || result.empty? ? nil : result 
    end
    
    def set_data
      #logger.info "SET DATA 1   #{self.data.class}"
      
      self.data = self.data.to_json if self.data.class == Hash
      #logger.info "SET DATA 2   #{self.data.class}"
      
    end
    
    
  end
end
