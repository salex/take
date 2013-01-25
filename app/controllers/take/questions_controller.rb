module Take
  class QuestionsController < BaseController
    before_filter :get_question, :except => [:index, :new, :create, :update, :edit]
    layout "take/application"
    before_filter :authorize_main
    
    # GET /questions
    # GET /questions.json
    # def index
    #   @questions = Question.all
    #   
    #   respond_to do |format|
    #     format.html # index.html.erb
    #     format.json { render json: @questions }
    #   end
    # end
  
    # GET /questions/1
    # GET /questions/1.json
    def show
      #@question = Question.find(params[:id])
  
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @question }
      end
    end
  
    # GET /questions/new
    # GET /questions/new.json
    def new
      @assessment = Assessment.find(params[:assessment_id])
      @question = Question.new
      setNewDefaults
  
      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @question }
      end
    end
  
    # GET /questions/1/edit
    def edit
      @question = Question.find(params[:id])
    end
  
    # POST /questions
    # POST /questions.json
    def create
      @question = Question.new(params[:question])
      @question.assessment_id = params[:assessment_id]
      @assessment = Assessment.find(params[:assessment_id])
  
      respond_to do |format|
        if @question.save
          format.html { redirect_to @question, notice: 'Question was successfully created.' }
          format.json { render json: @question, status: :created, location: @question }
        else
          format.html { render action: "new" }
          format.json { render json: @question.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # PUT /questions/1
    # PUT /questions/1.json
    def update
      @question = Question.find(params[:id])
      respond_to do |format|
        if @question.update_attributes(params[:question])
          format.html { redirect_to @question, notice: 'Question was successfully updated.' }
          format.json { head :ok }
        else
          if params[:question][:answers_attributes]
            format.html { render action: "show" }
          else
            format.html { render action: "edit" }
            
          end
          format.json { render json: @question.errors, status: :unprocessable_entity }
        end
      end
    end
  
    # DELETE /questions/1
    # DELETE /questions/1.json
    def destroy
      @question = Question.find(params[:id])
      @question.destroy
  
      respond_to do |format|
        format.html { redirect_to questions_url }
        format.json { head :ok }
      end
    end
    
    def edit_answers
      @question = Question.find(params[:id])
      max = @question.answers.maximum(:sequence) 
      seq = max.nil? ? 0  : max 
      cnt = @question.answers.count > 0 ? 2 : 5
      cnt.times do
        seq += 1
        answer = @question.answers.build({:sequence => seq})
      end
      #render :text => params.inspect, :layout => true
    end
    
    def clone
      clone_question = Question.find(params[:id])
      @question = clone_question.clone
      render  template: "edit"
    end
    
    
    private
    def setNewDefaults
      max = @assessment.questions.maximum(:sequence) 
      @question.sequence = max.nil? ? 1  : max + 1
      @question.answer_tag = @assessment.default_answer_tag.blank? ? "" : @assessment.default_answer_tag
      @question.type_display = @assessment.default_display.blank? ? "" : @assessment.default_display
      @question.assessment_id = @assessment.id
    end
  
    def get_question
      if params[:id]
        @question = Question.find(params[:id])
        @assessment = @question.assessment
      end
    end
    
  end
end
