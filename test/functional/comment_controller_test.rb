# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'
require 'comment_controller'

# Re-raise errors caught by the controller.
class CommentController; def rescue_action(e) raise e end; end

class CommentControllerTest < ActionController::TestCase
  fixtures :submissions, :users, :letters, :comments

#  def setup
#    @controller = CommentController.new
#    @request    = ActionController::TestRequest.new
#    @response   = ActionController::TestResponse.new
#  end

  def assert_redirected_to_submission(submission_id)
    letter = Submission.find(submission_id).letter
    assert_redirected_to  :controller => :letter, :action => :view, :id => letter, :anchor => "sub-#{submission_id}"
  end

  def test_new_get
    # fail: not logged in
    get :new, :submission => submissions(:posted)
    assert_redirected_to :controller => :user
    # fail: logged in as unvalidated user
    get :new, { :submission => submissions(:posted) }, :user => users(:bozo)
    assert_redirected_to :controller => :user
    # fail: missing submission
    get :new, {}, :user => users(:commenter)
    assert_tag :tag => "p", :content => "Submission missing?"
    # success
    get :new, { :submission => submissions(:posted) },
        :user => users(:commenter)
    assert_tag  :tag => "p", :content => /Commenting on/
  end

  def test_new_post
    good_params = { :comment => {
      :content => "zowie",
      :submission_id => submissions(:posted).id,
      :user_id => users(:commenter).id,
      :posted => Time.now
    } }
    # fail: not logged in
    post :new, good_params
    assert_redirected_to :controller => :user
    # fail: logged in as unvalidated user
    post :new, good_params, :user => users(:bozo)
    assert_redirected_to :controller => :user
    # fail: invalid
    post :new, { :comment => { :posted => Time.now } },
        :user => users(:commenter)
    assert_template "new"
    # success (top)
    post :new, good_params, :user => users(:commenter)
    assert Comment.find_by_content( "zowie" )
    assert_redirected_to_submission submissions(:posted).id
    # success (reply)
    good_params[:comment][:reply_to] = comments(:top)
    post :new, good_params, :user => users(:commenter)
    assert Comment.find_by_content( "zowie" )
    assert_equal ActionMailer::Base.deliveries.size, 1
    assert_redirected_to_submission submissions(:posted).id
  end

  def test_edit_get
    # fail: not logged in
    get :edit, :id => comments(:reply)
    assert_redirected_to :controller => :user
    # fail: logged in as unvalidated user
    get :edit, { :id => comments(:reply) }, :user => users(:bozo)
    assert_redirected_to :controller => :user
    # fail: no such comment
    get :edit, { :id => 12390321 }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: locked comment
    get :edit, { :id => comments(:locked) }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: doesn't control comment
    get :edit, { :id => comments(:reply) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # success
    get :edit, { :id => comments(:reply) }, :user => users(:commenter)
    assert_template "edit"
  end

  def test_edit_post
    good_params = { :comment => { :content => "zowie" },
        :id => comments(:reply) }
    # fail: not logged in
    post :edit, good_params
    assert_redirected_to :controller => :user
    # fail: logged in as unvalidated user
    post :edit, good_params, :user => users(:bozo)
    assert_redirected_to :controller => :user
    # fail: doesn't control comment
    post :edit, good_params, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: invalid
    post :edit, { :comment => { :content => "" },
        :id => comments(:reply) }, :user => users(:commenter)
    assert_template "edit"
    # success
    post :edit, good_params, :user => users(:commenter)
    assert Comment.find_by_content( "zowie" )
    assert_redirected_to_submission 2
  end

  def test_delete_get
    # fail
    get :delete, {}, :user => users(:admin)
    assert_redirected_to :controller => :user
  end

  def test_delete_post
    # fail: not logged in
    post :delete, { :id => comments(:reply) }
    assert_redirected_to :controller => :user
    # fail: logged in as unvalidated user
    post :delete, { :id => comments(:reply) }, :user => users(:bozo)
    assert_redirected_to :controller => :user
    # fail: doesn't control comment
    post :delete, { :id => comments(:reply) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: no such comment
    post :delete, { :id => 12390321 }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: locked comment
    post :delete, { :id => comments(:locked) }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: has replies
    post :delete, { :id => comments(:top) }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # success
    post :delete, { :id => comments(:reply) }, :user => users(:commenter)
    assert_redirected_to_submission 2
    assert !Comment.find_by_id(comments(:reply).id)
  end
end
