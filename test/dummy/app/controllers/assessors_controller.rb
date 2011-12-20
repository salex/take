
class AssessorsController < ApplicationController
  # GET /assessors
  # GET /assessors.json
  
  def index
    @assessors = Assessor.all
    @assmnt_hash = Take::Assessment.publish(2)
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
      @assmnt_hash = Take.safe_json_decode( @assessor.publish_json )      
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
    @post = Assess.get_post(params[:id],session)
    @assessor = Assessor.find(params[:id])
    if @assessor.publish_json
      @assmnt_hash = Take.safe_json_decode( @assessor.publish_json )      
    end
  end
  
  def post
    @assessor = Assessor.find(params[:id])
    if @assessor.publish_json
      @assmnt_hash = Take.safe_json_decode( @assessor.publish_json )      
    end
    results = Assess.score_assessment(@assmnt_hash,params[:post])
    Assess.set_post(params[:id],params[:post],session)
    render :text => "Testing: post_obj =>  #{results.inspect}", :layout => true
  end
    
  private
  
  def reset_stash
    stash = Assess.get(session)
    stash.delete
    reset_session
  end
  
  
end
