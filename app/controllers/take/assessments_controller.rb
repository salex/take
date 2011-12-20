module Take
  class AssessmentsController < ApplicationController
    # GET /assessments
    # GET /assessments.json
    
    def index
      @assessments = Assessment.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @assessments }
      end
    end
  
    # GET /assessments/1
    # GET /assessments/1.json
    def show
      @assessment = Assessment.find(params[:id])
      @assmnt_hash = @assessment.publish(false)
    	
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @assessment }
      end
    end
  
    # GET /assessments/new
    # GET /assessments/new.json
    def new
      @assessment = Assessment.new
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @assessment }
      end
    end
  
    # GET /assessments/1/edit
    def edit
      @assessment = Assessment.find(params[:id])
    end
  
    # POST /assessments
    # POST /assessments.json
    def create
      @assessment = Assessment.new(params[:assessment])
  
      respond_to do |format|
        if @assessment.save
          format.html { redirect_to @assessment, notice: 'Assessment was successfully created.' }
          format.json { render json: @assessment, status: :created, location: @assessment }
        else
          format.html { render action: "new" }
          format.json { render json: @assessment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /assessments/1
    # PUT /assessments/1.json
    def update
      @assessment = Assessment.find(params[:id])
  
      respond_to do |format|
        if @assessment.update_attributes(params[:assessment])
          format.html { redirect_to @assessment, notice: 'Assessment was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render action: "edit" }
          format.json { render json: @assessment.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /assessments/1
    # DELETE /assessments/1.json
    def destroy
      @assessment = Assessment.find(params[:id])
      @assessment.destroy
  
      respond_to do |format|
        format.html { redirect_to assessments_url }
        format.json { head :ok }
      end
    end
    def display
      @stash = Stash.get(session)
      reset_stash if params[:reset] # for testing only
      @assessment = Assessment.find(params[:id])
      #if session.has_key?("post") && session["post"].has_key?(params[:id])
       data = @stash.get_data
       logger.info "hhhhhhhhhhh #{data}"
       @post = data[:post][params[:id]] ||= nil
      #end
      
      #@json = ActiveSupport::JSON.decode(@assessment.publish)
      @assmnt_hash = Assessment.publish(params[:id])
    end
    
    def post
      #@assessment = Assessment.find(params[:id])
      #@json = ActiveSupport::JSON.decode(@assessment.publish)
      @assmnt_hash = Assessment.publish(params[:id])
      results = Assess.score_assessment(@assmnt_hash,params[:post])
      set_stash
      #session[:post] = {} unless session[:post]
      #session[:post][params[:id]] = params[:post]
      #session["post"][params[:id]][:all] = all
      render :text => "Testing: post_obj =>  #{results.inspect}", :layout => true
    end
    
    private
    
    def reset_stash
      if @stash
        @stash.delete
        reset_session
        @stash = Stash.get(session)
      end
      @stash
    end
    
    def set_stash
      stash = Stash.get(session)
      data = stash.get_data 
      data = data.nil? ? {} : data
      data[:post] = {} unless data[:post]
      logger.info "ssssssssss #{data.inspect} #{params[:id]} #{params[:post]}"
      data[:post][params[:id]] = params[:post]
      stash.data = data
      stash.save
    end
  end
end
