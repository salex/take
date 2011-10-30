
class AssessorsController < ApplicationController
  # GET /assessors
  # GET /assessors.json
  
  def index
    @assessors = Assessor.all
    @hash = Take::Assessment.publish(2)
    #@html = Take::Assess.format_assessment_hash(hash)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @assessors }
    end
  end

  # GET /assessors/1
  # GET /assessors/1.json
  def show
    @assessor = Assessor.find(params[:id])
    if @assessor.publish_json
      @hash = Take.safe_json_decode( @assessor.publish_json )      
    end
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @assessor }
    end
  end

  # GET /assessors/new
  # GET /assessors/new.json
  def new
    @assessor = Assessor.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @assessor }
    end
  end

  # GET /assessors/1/edit
  def edit
    @assessor = Assessor.find(params[:id])
  end

  # POST /assessors
  # POST /assessors.json
  def create
    @assessor = Assessor.new(params[:assessor])

    respond_to do |format|
      if @assessor.save
        format.html { redirect_to @assessor, notice: 'Assessor was successfully created.' }
        format.json { render json: @assessor, status: :created, location: @assessor }
      else
        format.html { render action: "new" }
        format.json { render json: @assessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /assessors/1
  # PUT /assessors/1.json
  def update
    @assessor = Assessor.find(params[:id])

    respond_to do |format|
      if @assessor.update_attributes(params[:assessor])
        format.html { redirect_to @assessor, notice: 'Assessor was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @assessor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /assessors/1
  # DELETE /assessors/1.json
  def destroy
    @assessor = Assessor.find(params[:id])
    @assessor.destroy

    respond_to do |format|
      format.html { redirect_to assessors_url }
      format.json { head :ok }
    end
  end
  
  def display
    reset_session if params[:reset]
    @assessor = Assessor.find(params[:id])
    if @assessor.publish_json
      @hash = Take.safe_json_decode( @assessor.publish_json )      
    end
    if session.has_key?("post") && session["post"].has_key?(params[:id])
     @post = session["post"][params[:id]]
    end
  end
  
  def post
    #@assessment = Assessment.find(params[:id])
    #@json = ActiveSupport::JSON.decode(@assessment.publish)
    @assessor = Assessor.find(params[:id])
    if @assessor.publish_json
      @hash = Take.safe_json_decode( @assessor.publish_json )      
    end
    results = Take::Assess.score_assessment(@hash,params[:post])
    
    session[:post] = {} unless session[:post]
    session[:post][params[:id]] = params[:post]
    #session["post"][params[:id]][:all] = all
    render :text => "Testing: post_obj =>  #{results.inspect}", :layout => true
  end
  
end
