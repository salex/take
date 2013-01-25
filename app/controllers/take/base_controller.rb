module Take
  
  class BaseController < ApplicationController
    #class ApplicationController < ::ApplicationController #ActionController::Base
    def authorize_main
      if current_user.nil?
        rescue_me('Your are not authorized access without logging into the main application.')
      end
    end
  end
  
end
