---

### Take Engine Demo

Take is a WIP Rails:3 engine that Manages, Formats and Scores assessments.

This is a work in progress, but functional. I decided to post it on github and see if anyone could offer suggestions, opinions or offer to help. If by chance someone does offer to help, they may need to help me manage changes on github!

Assessments can be used on many different types of applications:

* Surveys
* Tests
* Job Applications
* Evaluations

Just about anything where you want to capture scores on one or more **questions** that have one or more possible **answers** can be considered an assessment. The basic assessment models are:

``` ruby
	class Assessment < ActiveRecord::Base
		has_many :questions, :order => "sequence", :dependent => :destroy
	end

	class Question < ActiveRecord::Base
		belongs_to :assessment
		has_many :answers, :order => "sequence", :dependent => :destroy

	end

	class Answer < ActiveRecord::Base
		belongs_to :question
	end
```

	
These are basically three CRUD tables build with a modified scaffold generator. The main tasks of what I consider the Engine part are:

* Manage the CRUD process
* Display the assessment in a form. The assessment\_helper method display\_assessment generates the html for the form.
* Score the assessment. The assessments model score\_assessments method scores the post of the form(s) and returns a score object. It is up to the user of the engine to take what it needs out of the score object to suit their needs.

There is some background information later in this ReadMe, but to use the engine, you need some kind of "Assessor" model that uses the Take engine and some place to store the results of the scoring.

In this demo, there is a dummy app in the test folder.

* Assessor - a multi-use model that links the assessment to the model being assessed and optionally, the model that controls the assessing

Your application might also contain
* Score - a place to store all the scores
* People - A stub that gets assessed 
* Candidate - A stub that is another form of someone that gets assessed with a multi-part assessment
* Stage - A stub of a model that controls the assessing.


### Setting up the Questions and Answers

There are numerous options on what types of questions and answers are displayed and how they are scored. A brief outline:

* sequence is used to sort questions and answers for the display action 
* answer_type controls what input elements are used - basically radio, checkbox, select, text and textarea.
	* radio - radio buttons are used for answers (multiple choice)
	* checkbox - checkboxes are used for answers to all "Check all that apply"
	* select - basically the same as a radio button, just using a select-options pulldown
	* select-multiple - basically the same as a checkbox
	* text - a single text field answer. This answer can optionally be scored using a regex scheme
	* textarea - Displays a textarea instead of a textfield to gather answers for composition type questions.

* display_type is used by the display action to generate radio buttons or checkboxes. 
	* Inline - take less space for the "rate something on a 1 to 5 scale" type questions. Buttons and answers are painted horizontally.
	* List (default) - Buttons and answers are painted vertically

* score_method defines how certain answer types are scored.
	* value (default or blank) - the value of the answer is used
	* sum - used only for checkboxes or multiple-select to generate a score based on the sum of the selected values.
	* max - the default method for checkboxes and multiple-selects where the score is based on the highest answer value checked.
	* none - used to just gather answers but not score them.
	* textContains - A scored text field that uses pattern matching to score the answer.
	* textNumeric - A scored text field that contains a scored numeric answer.
	

* requires_other - Each answer (except text or textarea) can generate a text box to gather additional information. For instance, selecting a "Completed high school with a diploma" answer could bring up an additional question to enter the name and location of the school.
* text_eval is used to score text answers and uses a regex scheme to score the text field.
* shortname - questions and answers have optional shortnames. While the answer.answer_text and question.question_text are used in the display action, a summary dump of the scored objects can be hard to read with long questions. In the summary dump, the short name will be used if it is not blank.
* critical - A question can be considered critical if the answer fails to meet a minimum value on a question. In that case you failed the assessment - even if your score was high. This is used to screen out people if they do not conform to a job requirement (e.g., willing to work rotating shifts).
* weight - the raw answer values can be weighted, meaning that some questions are more important than others. This is also optional and there are other ways of achieving the same outcome. (Answer values are floats.)

### Installation (Rails ~> 3.1 only)

* Download/clone Take from github
* bundle install # no other gems used
* rake db:create  # db is configured for sqlite3
* rake db:load:schema
* rake db:seed # seed loads about 10 test assessments/questions and answers.
* rails s

The rake db:seed uses JSON files to populate the tables. Not the fastest thing in the world, but seems to work. If you use PostgreSql, you may have to reset the ID counter since the import sets the IDs.

### Basic CRUD

You can browse through the assessments, questions and answers and have a look around. There is a short menu bar and a basic CSS layout
to help you get around. The application will come up in the dummy application and there are links to go between the dummy application and Take CRUD.

The Show link for an assessment will have a "Test Assessment" link that uses the built-in display\_assessment and score\_assessmeent methods.


### Assessments Background

Assessments was developed to handle a complex on-line job application process for a new industrial plant opening. Over 100,000 job applications were processed over the course of several months. The on-line application consisted of six sections:

* Contact Information
* General questions - asked of all applicants for any job, e.g., Are you willing to work 2nd shift?
* Basic Skills Survey - asked of all applicants for any job, e.g., How many years of welding experience do you have?
* Education Summary - asked of all applicants for any job, e.g., Check all that apply - Graduated from high school with a diploma?
* Work History - asked of all applicants for any job, e.g., Textual information on last three jobs.
* Job Specific Questions - questions that go more in depth on skills, history, attitude, etc.

Most of the sections were *scored* and the overall score was used to progress job applicants to the next phase of the application process. As you probably can assume, there were many types of questions using various formats.

The original version was written for a [4D](http://4d.com/ "Title") (aka 4th Dimension) database using a 4D web plugin called [Active4D](http://www.aparajitaworld.com/site/products/Active4D/index.php) (a PHP-like scripting language for 4D). The system was developed as a rapid prototype after evaluating several generic job sites such as CareerBuilder. Those types of sites just did not have the scoring/screening mechanisms needed to handle hundreds of thousands of applicants. The prototype was written using XML to define the assessments structure with hopes of moving to a more database-driven approach. Events progressed rapidly and the XML version was used in production and is in fact still being used today. Take is the database-driven version - in Rails 3.

### Assessments Basic

Going back to your school days and taking tests, there were several kinds of tests and/or questions used on those tests:

* Composition/Essay - _the ones you dreaded the most!_
* Completion - _not quite as bad_
* Choose One Multiple Choice - _you could at least guess!_
* Choose Many Multiple Choice - _more than one answer?_

Basic HTML form can handle all of these types:

* Composition/Essay - textarea
* Completion - text input
* Choose One Multiple Choice - radio button input or select
* Choose Many Multiple Choice - checkbox input or multiple select

Assessments were designed to handle three tasks:

* Building/Managing the assessment (assessments, questions, and answer) using a restful CRUD environment.
* Displaying the assessment using an HTML form (helper call).
* Scoring the assessment based on model attributes - many of which are defaulted or optional.

While this approach greatly reduces the development effort in creating, displaying and scoring an assessment, there is still some work needed to adapt Assessments to your use.

* A model that has an *assessible* need. 
	* A relationship from that model to the assessment must be established
	* This could include multiple assessments such as the job applicant application.
* A place to store the scoring object.
* Procedures to handle changes (version, questions added, deleted or values changed that affect previously scored assessments)

The last item is rather non-trivial. It is easy to re-score an assessment, but what to do with answers that are no longer used and new questions that were not available when the assessment was originally scored requires some thought. Testing your assessment before deploying is important. If you deploy the assessment and see a problem, correct the problem as early as possible. Misspelling is not important, just changes that affect scoring.

Rather than trying to use words to describe all the options, let's look at a screen shot of what I call my silly test assessment and a dump of the scoring results.

<img src="/images/display.png" alt="" /> 

	** See image in public/images/display.png **

The details of what is in the assessments, questions and answers is not shown at this point, but the display is completely built from the models. Basically a question has a text question to ask, what format to display the answers and a few title options. Answers have a textual answer, a value, 
and optional items such as displaying additional questions if the answer is selected.
There are a few things to note:

* Answers can be displayed inline or as a list
* Assessments can have optional instructions and headers
* Questions can have a group header (think - a 1 to 5 type survey questions)
* An answer can trigger an additional question _Why is hard the best way?_
* A text question can have multiple answers (think - HTML form)

When this assessment is posted, a *scoring object* is created; you can use all or parts of the object to suit your needs. A dump of a scoring object follows:


The scoring object is at the bottom of the screen (post.inspect) and the top part is one way to display the results in a compressed, but readable display. Let's
look a little closer at the scoring object.

``` ruby

	score_object => {"answer"=>{"35"=>["159"], "36"=>["160", "719"], "37"=>["165"], "38"=>["168"], "39"=>["169"], 
	  "40"=>["170", "171", "172"], "42"=>["179"], "43"=>["182"], "44"=>["183", "724"], "45"=>["184"], "156"=>["721", "722", "723"]},        
	  "other"=>{"719"=>"t"}, "text"=>{"168"=>"golf fish hunt", "169"=>"stuff happens", "182"=>"quick fox back", "183"=>"3.1416", 
	  "724"=>"88.3", "721"=>"fox back", "722"=>"jumps", "723"=>"beown"}, 
	  "scores"=>{"35"=>{"raw"=>10.0, "weighted"=>10.0}, "36"=>{"raw"=>2.0, "weighted"=>10.0}, "37"=>{"raw"=>3.0, "weighted"=>9.0}, 
	  "38"=>{"raw"=>0.0, "weighted"=>0.0}, "39"=>{"raw"=>1.0, "weighted"=>1.0}, "40"=>{"raw"=>12.0, "weighted"=>12.0}, 
	  "42"=>{"raw"=>3.0, "weighted"=>0.0}, "43"=>{"raw"=>10.0, "weighted"=>10.0}, "44"=>{"raw"=>3.6, "weighted"=>3.6}, "
	  45"=>{"raw"=>1.0, "weighted"=>1.0}, "156"=>{"raw"=>2.0, "weighted"=>4.0}, "total"=>{"raw"=>47.6, "weighted"=>60.6},
	  "percent"=>{"raw"=>0.7555555555555555, "weighted"=>0.6121212121212122}}, 
	  "critical"=>["38"], 
	  "all"=>["159", "160", "719", "165", "168", "169", "170", "171", "172", "179", "182", "183", "724", "184", "721", "722", "723"]}	
```

The scoring object is just a hash. While there a number of elements, the :answers element is the most important. If we only had the :answers, :other, and :text all other information can be obtained or calculated.

Both the form and the object only rely on IDs. The :answers hash format is:

* key = the question ID
* value = an array of answer ID(s)

	* if the type of answer is text, the text hash linked to the answer ID will contain the text response.

This is all the information that is needed to score the assessment.

The :all_answers array is just an extraction of the answer IDs from answers. If you know the answer ID, you can find everything except the text response. A use for this element is to create a searchable field in the record.

The :critical element comes into play if you optionally choose a question to be *critical*. If the minimum score on a question that is marked as critical is not met, it could mean that the assessment was failed - regardless of the score. You could also use it to indicate what questions were failed.

The :other collects answers for any additional questions. The key is the answer ID and the value is the text value. This field will be present if an answer has the requires\_other boolean set and this answer it is selected (radio, select and checkbox inputs only - javascript controlled).

All the rest of the elements are just computed and can be recomputed. Putting them in the object allows you to choose what elements you want to save - but then why not save it all as a JSON object?

### Scoring Mechanism 

Scoring is actually quite simple, but there are a few options that gives you quite a bit of flexibility. Back in school again, if you took a 10 question test, the teacher/instructor may have set that each question was worth 10 points and if you answered them all correctly you got 100 points. They may have also weighted the answers. You may have had a 7 question math type test where several of the questions were much more difficult or time consuming and those questions were weighted differently. You may have also received partial credit if you didn't answer the question correctly, but were close. These are all subjective methods of scoring, but Assessments can handle most of them.

Let's start simple and define a 5 question survey. Now I hate surveys, but for some reason customer satisfaction seems to be loved by marketeers. I usually refuse to take them. The 5 questions are all in the form of "Please rate your x of our y on a 5 point scale with 1 being the w and 5 being the z" (value in group_header for first question in group).

<div><input type="radio" /> 1 | <input type="radio" /> 2 | <input type="radio" /> 3 | <input type="radio" /> 4 | <input type="radio" /> 5 - Question 1 </div>
<div><input type="radio" /> 1 | <input type="radio" /> 2 | <input type="radio" /> 3 | <input type="radio" /> 4 | <input type="radio" /> 5 - Question 2 </div>
<div><input type="radio" /> 1 | <input type="radio" /> 2 | <input type="radio" /> 3 | <input type="radio" /> 4 | <input type="radio" /> 5 - Question 3 </div>
<div><input type="radio" /> 1 | <input type="radio" /> 2 | <input type="radio" /> 3 | <input type="radio" /> 4 | <input type="radio" /> 5 - Question 4 </div>
<div><input type="radio" /> 1 | <input type="radio" /> 2 | <input type="radio" /> 3 | <input type="radio" /> 4 | <input type="radio" /> 5 - Question 5 </div>

Assuming that all questions need to be answered and you use the 1 to 5 values for each answer, the minimum you could score is 5 points and the maximum is 25. You may decide that question 3 is much more important than the others and give it a weight of 3 with all the others questions weighted 1. In this case, the minimum you can score is 7 and the maximum is 35. If you didn't want to use weighting, you could just give question 3 answer values a different number; lets say 1,3,6,9,12. Your minimum would again be 1 and the maximum would be 32. You could even go wilder and give values of -4,-2,1,3,4. Now we have a minimum of 0 and a maximum of 24. The value attribute is also a decimal field and you could even assign decimal value so the highest value (5) could be worth 0.20 and the lowest 0.0 - the minimum would be 0 and the maximum would be 1.

There are numerous ways - probably too many, but our customers at the time of development had some weird ideas on scoring - at least I thought they were weird - but some people think in whole number and others in decimals or percentages.

The last example used a score\_method = "value" (or maximum value - the default score_method). Since we are using radio buttons, whatever is checked in the maximum value for that answer.

What if we changed them to checkboxes with a "Check all that applies" type question? Going back to the 1 to 5 values, the minimum is still 5 and the maximum is still 25, even if they are all checked. But then there is an option to use a *sum* scoring method. If all checkboxes for a question were checked, the maximum for each question would be 1+2+3+4+5 or 15 points! The minimum would still be 5, but the maximum would be 75.

While there are numerous options, they are not there for you to go wacko, but to use the approach you are most comfortable with.

### Text Scoring

There is also an experimental text scoring scheme. The original design did not score text answers, but our experiment looks like it could be useful. Going back to the silly assessment, several of the text answers were scored. The scheme uses a regex to evaluate the content of the answer against a text\_eval attribute.

There are two scoring methods used: one for numeric answers and one for text contains answers.

In the simplest form, it is just a simple regex match.

* Question: "What is the value of Pi rounded to 4 decimal places?". 
	* Text eval is just "3.1416".
* Question: "What are the verbs in the sentence \'The quick brown fox jumps the lazy dogs back.\'" 
	* Text eval is just "jumps".

You can have questions that have multiple answers.

* Question: "What are the nouns in the sentence \'The quick brown fox jumps the lazy dogs back.\'" 
	* Text eval is just "fox&back". The answer must contain "fox" AND "back"
* Question: "Whas is at least one adjective in the sentence \'The quick brown fox jumps the lazy dogs back.\'" 
	* Text eval is just "(quick|brown|lazy)". The answer must contain "quick" OR "brown" OR lazy.

Getting more complicated.

* Question: "What are the nouns and at least on adjective in the sentence \'The quick brown fox jumps the lazy dogs back.\'" 
	* Text eval is just "fox&back&(quick|brown|lazy)". The answer must contain "fox" AND "back" AND "quick" OR "brown" OR "lazy".
	* or knocking out wrong answers, text eval is "fox&back&(quick|brown|lazy)&!(jumps|the|dogs)"

Text contains evaluations may contain an optional "partial credit" section. The section is delimited by a double colon ("::") and follows the same syntax except each AND section has a percentage assigned to the match using ">>" as the delimiter. The percentage can be plus or minus, so "dog>>-50" would be a 50% deduction. If the exact match is not found and there is a partial section, the sum of all the ANDs in the partial section is the score. The is sum normalized between 0 and the maximum value.

* (quick|brown|lazy)&fox&back&!(the|jump|dog)::(quick|brown|lazy)>>20&fox>>40&back>>40&dog>>-50&the>>-75&jumps>>-75
	* would give plus credit for each right answer and negative credit for answers that should not have been there. Partials only come into play if there is not an exact match.
	
Numeric answers have there own form of partial credit based on "deltas" or what range is considered a correct answer.

* Question: "What is the value of Pi rounded to 4 decimal places?". 
	* Text eval of "3.1416::.000025::.0001>>80::.001>>20". Would give 100% credit if the answer was between 3.141575 and 3.141625, 80 % credit if between 3.1415 and 3.1417, and so on.
	
There is a text eval helper form that uses javascript the to help build the regex.

Text scoring also allows for multiple answer off of one basic questions.

* Please identify the parts of speech in the sentence \'The quick brown fox jumps the lazy dogs back.\'
	* Noun(s)
	* Verb(s)
	* At least on adjective
	
If there are multiple answers for a question, each answer is summed and compared against the maximum score possible for all answers.

### Using the Engine

While you can access the tables and methods using the module and classes (Take::Assessment.find(id)), the dummy application has two classes that are inherited.

### Helper

``` ruby

	module AssessorsHelper
	  include Take::AssessHelper
  
	  # this makes the render_assessor method accessible by the application that use Take
  
	  # module AssessHelper
	  #  def render_assessor(assmnt_hash,post=nil)
	  #    AssessmentRenderer.new(assmnt_hash, post, self).render_assessment
	  #  end
	  # end
  
	  # The arguments for render_assessor are the assmnt_hash (see assessor_helper.rb), and an optional post object that has the answers from a pseudo session or previous assessment.
	end

```
 
### Assess Model

``` ruby

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
	

```

### Status

I have no idea on how to build a plugin or engine. I also don't have *any* testing - never learned how to use it.

Being a plugin, assessments must be tied to something, an application, survey, evaluation. There are fields in the table that allow that connection to be made to it different ways. 


### To Do's

* There are configuration options (control state, can not edit is state is x|Y|Z)
* Do I need an is_admin? check?
* How do I deal with status to control state?


