module Take
  
  class ApplicationController < ::ApplicationController
    #class ApplicationController < ::ApplicationController #ActionController::Base
    before_filter :shit
    def shit
      logger.debug "TAKE CONTROLLER  #{current_user}"
    end
  end
  
end
