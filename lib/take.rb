require "take/engine"
require "take/render_helper"

module Take
    
  class Post
    attr_accessor :answer, :all, :text, :other, :scores


    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

  end
  def hello(who)
    return "Hello #{who}!"
  end
  
  
  def self.safe_json_decode( json )
    return {} if !json
    begin
      ActiveSupport::JSON.decode json
    rescue ; {} end
  end
  
  
  
end
