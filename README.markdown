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


	
These are basically three CRUD tables build with a modified scaffold generator. The main tasks of what I consider the Engine part are:

* Manage the CRUD process
* Display the assessment in a form. The assessment\_helper method display\_assessment generates the html for the form.
* Score the assessment. The assessments model method score\_assessments scores the post of the form.

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
	* textNumeric - A scored text field that contains a numeric answer.
	

* requires_other - Each answer (except text or textarea) can generate a text box to gather additional information. For instance, selecting a "Completed high school with a diploma" answer could bring up an additional question to enter the name and location of the school.
* answer_eval is used to score text answers and uses a regex scheme to score the text field.
* shortname - questions and answers have optional shortnames. While the answer.answer_text and question.question_text are used in the display action, a summary dump of the scored objects can be hard to read with long questions. In the summary dump, the short name will be used if it is not blank.
* critical - A question can be considered critical if the answer fails to meet a minimum value on a question. In that case you failed the assessment - even if your score was high. This is used to screen out people if they do not conform to a job requirement (e.g., willing to work rotating shifts).
* weight - the raw answer values can be weighted, meaning that some questions are more important than others. This is also optional and there are other ways of achieving the same outcome. (Answer values are floats.)

### Installation (Rails 3.1 only)

* Download/clone Take from github
* bundle install # no other gems used
* rake db:create  # db is configured for sqlite3
* rake db:load:schema
* rake db:seed # seed loads about 10 test assessments/questions and answers.
* rails s

The rake db:seed uses JSON files to populate the tables. Not the fastest thing in the world, but seems to work. If you use PostgreSql, you may have to reset the ID counter since the import sets the IDs.
### Basic CRUD

You can browse through the assessments, questions and answers and have a look around. There is a short menu bar and a basic CSS layout
to help you get around.

The Show link for an assessment will have a "Test Assessment" link that uses the built-in display\_assessment and score\_assessmeent methods.

You can Clone an assessment. Provided so the same assessment can be used, but with different scoring (see background).

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

The basic HTML form can handle all of these types:

* Composition/Essay - textarea
* Completion - text input
* Choose One Multiple Choice - radio button input or select
* Choose Many Multiple Choice - checkbox input or multiple select

Assessments was designed to handle three tasks:

* Building/Managing the assessment (assessments, questions, and answer) using a restful CRUD environment.
* Displaying the assessment using an HTML form.
* Scoring the assessment based on model attributes - many of which are defaulted or optional.

While this approach greatly reduces the development effort in creating, displaying and scoring an assessment, there is still some work needed to adapt Assessments to your use.

* A model that has an *assessible* need. 
	* A relationship from that model to the assessment must be established
	* This could include multiple assessments such as the job applicant application.
* A place to store the scoring object.
* Procedures to handle changes (questions added, deleted or values changed that affect previously scored assessments)

The last item is rather non-trivial. It is easy to re-score an assessment, but what to do with answers that are no longer used and new questions that were not available when the assessment was originally scored requires some thought. Testing your assessment before deploying is important. If you deploy the assessment and see a problem, correct the problem as early as possible. Misspelling is not important, just changes that affect scoring.

Rather than trying to use words to describe all the options, let's look at a screen shot of what I call my silly test assessment and a dump of the scoring results.

<img src="/images/display.png" alt="" /> 

	** See image in public/images/display.png **

The details of what is in the assessments, questions and answers is not shown at this point, but the display is completely built from the models. Basically a question has a text question to ask, what format to display the answers and a few title options. Answers have a textual answer, a value, 
and optional items such as displaying additional questions if the answer is selected.
There are a few things to note:

* Answers can be displayed inline or as a list
* Assessments can have instructions
* Questions can have a group header (think - a 1 to 5 type survey questions)
* An answer can trigger an additional question _Why is hard the best way?_
* A text question can have multiple answers (think - HTML form)

When this assessment is posted, a *scoring object* is created; you can use all or parts of the object to suit your needs. A dump of a scoring object follows:

<img src="/images/dump.png" alt="" /> 

	** See image in public/images/dump.png **

The scoring object is at the bottom of the screen (post.inspect) and the top part is one way to display the results in a compressed, but readable display. Let's
look a little closer at the scoring object.

{% uvhighlight ruby %}

{
	:answers=>{"35"=>["155"], "36"=>["160"], "37"=>["164"], "38"=>["168", "golf"], 
		"39"=>["169", "someone lost and someone won"],"40"=>["170", "171", "172"], 
		"41"=>["174", "Alex", "175", "Steve", "176", "555-444-2323"], "42"=>["177"], 
		"43"=>["182", "quick fox back"],"44"=>["183", "3.1415"], "45"=>["185"], 
		"156"=>["721", "fox back", "722", "jumps", "723", "brown"]}, 
	:all_answers=>[155, 160, 164, 168, 169, 170, 171, 172, 174, 175, 176, 177, 
		182, 183, 185, 721, 722, 723], 
	:failed=>[38], 
	:answers_other=>{"164"=>"because", "177"=>"AH"}, 
	:question_raw=>{"35"=>3.0, "36"=>1.0, "37"=>2.0, "38"=>0.0, "39"=>0, "40"=>12.0, 
		"41"=>0, "42"=>0, "43"=>3.0, "44"=>2.0, "45"=>2.0, "156"=>3.0}, 
	:total_raw=>28.0, 
	:total_weighted=>39.0, 
	:category=>"application.silly", 
	:max_raw=>47.0, 
	:max_weighted=>88.0, 
	:assessment_id=>"6"
}
	
{% enduvhighlight ruby %}

The scoring object is just a hash. While there a number of elements, the :answers element is the most important. If we only had the :answers (and the :answers\_other if used), all other information can be obtained or calculated.

Both the form and the object only rely on IDs. The :answers hash format is:

* key = the question ID
* value = an array of answer ID(s)

	* if the type of answer is text, it will also contain the text response.

This is all the information that is needed to score the assessment.

The :all_answers array is just an extraction of the answer IDs from answers. If you know the answer ID, you can find everything except the text response. A use for this element is to create a searchable field in the record.

The :failed element comes into play if you optionally choose a question to be *critical*. If the minimum score on a question that is marked as critical is not met, it could mean that the assessment was failed - regardless of the score. You could also use it to indicate what questions were failed.

The :answers\_other collects answers for any additional questions. The key is the answer ID and the value is the text value. This field will be present if an answer has the requires\_other boolean set and this answer is selected (radio and checkbox inputs only - javascript controlled).

All the rest of the elements are just computed and can be recomputed. Putting them in the object allows you to choose what elements you want to save - but then why not save it all as a JSON or XML object.

### Scoring Mechanism 

Scoring is actually quite simple, but there are a few options that gives you quite a bit of flexibility. Back in school again, if you took a 10 question test, the teacher/instructor may have set that each question was worth 10 points and if you answered them all correctly you got 100 points. They may have also weighted the answers. You may have had a 7 question math type test where several of the questions were much more difficult or time consuming and those questions were weighted differently. You may have also received partial credit if you didn't answer the question correctly, but were close. These are all subjective methods of scoring, but Assessments can handle some of them.

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

There is also an experimental text scoring scheme. The original design did not score text answers, but our experiment looks like it could be useful. Going back to the silly assessment, several of the text answers were scored. The scheme uses a regex to evaluate the content of the answer against a text_eval attribute.

The question "What do you do when you're not working (hobbies, etc.)?" was set up as a critical question with an evaluation that would pass the question, unless it contained the word golf, hunt or fish! The answer_eval field was set to `!(golf|fish|hunt)` and parsed into a regex that was then negated.  

The question on nouns and at least on adjectives is a little more complex in that it allows for partial credit option.  The answer eval for that question is `1::back&1::fox&-0.5::dog&1::(quick|brown|lazy)` The positive values are summed and a ratio computed that is multiplied with the answer value. Again it is parsed into chunks (& or ands) of regex and evaluated. If you said that dog was a noun, you would have 2.5/3 times the answer value - or a deduction for thinking that dogs was a noun in this sentence. While the regex scheme works, my challenge is to find a non-geek way of having it created for the user.

### Status

I have no idea on how to build a plugin or engine. I also don't have *any* testing - never learned how to use it.

Being a plugin, assessments must be tied to something, an application, survey, evaluation. There are fields in the table that allow that connection to be made it different ways. 


### To Do's

* What attributes in assessments, questions, and answers need to trigger (dirty?) a recompute of max_score and max_weighted.
* There are configuration options (control state, can not edit is state is x|Y|Z)
* Do I need an is_admin? check?
* How do I deal with status to control state?


