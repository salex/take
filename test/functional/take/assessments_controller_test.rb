require 'test_helper'

module Take
  class AssessmentsControllerTest < ActionController::TestCase
    setup do
      @assessment = assessments(:one)
    end
  
    test "should get index" do
      get :index
      assert_response :success
      assert_not_nil assigns(:assessments)
    end
  
    test "should get new" do
      get :new
      assert_response :success
    end
  
    test "should create assessment" do
      assert_difference('Assessment.count') do
        post :create, assessment: @assessment.attributes
      end
  
      assert_redirected_to assessment_path(assigns(:assessment))
    end
  
    test "should show assessment" do
      get :show, id: @assessment.to_param
      assert_response :success
    end
  
    test "should get edit" do
      get :edit, id: @assessment.to_param
      assert_response :success
    end
  
    test "should update assessment" do
      put :update, id: @assessment.to_param, assessment: @assessment.attributes
      assert_redirected_to assessment_path(assigns(:assessment))
    end
  
    test "should destroy assessment" do
      assert_difference('Assessment.count', -1) do
        delete :destroy, id: @assessment.to_param
      end
  
      assert_redirected_to assessments_path
    end
  end
end
