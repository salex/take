class Assess < Take::Assess
  
  # The Assess model/class inherits Take::Assess, which adds some class methods to Take::Assessment, which it inherits.  The methods available are:
  # 
  # Two methods for getting an assessment hash
  #   The assessment hash is used to both display and score the assessment
  #   
  #   def publish(tojson = true)
  #     creates hash and optional converts it to JSON where it can be stored an Assessor model. Assessment is loaded
  #   
  #   def self.publish(aid)
  #     creates hash from assessment using ID. 
  #   
  # Getter and Setter methods for storing the post hash (returned from form) in a table Take::Stashes. This is mainly to maintain state in an assessor 
  # that has multiple assessment. This is used in lieu of sessions, which are limited to 4096 characters.
  # 
  #   def self.get_post(id, session)
  #     Arguments are the id of the assessor(or assessment) and the session, which only the session_id is used as the key to the Stashes table
  #     Result is the serialized post decoded to a hash.
  #     
  #   def self.set_post(id,post,session)
  #     Arguments are the id of the assessor(or assessment) 
  #     The post object from the params (or score object). This is serialized in JSON and stored 
  #     The session, which only the session_id is used as the key to the Stashes table
  # 
  #   
  # The scoring method
  # 
  #   def self.score_assessment(assmnt_hash,post)
  #     Arguments are the published assmnt_hash, and params[:post] from the form
      
  
end
