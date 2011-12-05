# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111031091617) do

  create_table "assessors", :force => true do |t|
    t.integer  "assessment_id"
    t.string   "version"
    t.text     "publish_json"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "assessable_id"
    t.string   "assessable_type"
    t.integer  "sequence"
  end

  create_table "take_answers", :force => true do |t|
    t.integer  "question_id"
    t.integer  "sequence"
    t.string   "short_name"
    t.string   "answer_text"
    t.float    "value"
    t.boolean  "requires_other", :default => false
    t.string   "other_question"
    t.string   "text_eval"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "take_assessments", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "instructions"
    t.string   "status"
    t.string   "category"
    t.string   "default_answer_tag"
    t.string   "default_display"
    t.float    "max_raw"
    t.float    "max_weighted"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "take_assessments", ["category"], :name => "index_take_assessments_on_category"
  add_index "take_assessments", ["key"], :name => "index_take_assessments_on_key"

  create_table "take_questions", :force => true do |t|
    t.integer  "assessment_id"
    t.integer  "sequence"
    t.string   "short_name"
    t.text     "question_text"
    t.text     "instructions"
    t.string   "answer_tag"
    t.string   "type_display"
    t.string   "group_header"
    t.float    "weight",             :default => 1.0
    t.boolean  "critical",           :default => false
    t.float    "min_critical_value"
    t.string   "score_method"
    t.string   "key"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
