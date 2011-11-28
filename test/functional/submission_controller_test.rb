# vim:set ai sw=2 ts=2 et:

require File.dirname(__FILE__) + '/../test_helper'
require 'submission_controller'

# Re-raise errors caught by the controller.
class SubmissionController; def rescue_action(e) raise e end; end


class SubmissionControllerTest < ActionController::TestCase
  def setup
    @controller = SubmissionController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  fixtures :users, :submissions, :sub_types

  def requires_submitter(&call)
    # fail: not logged in
    call.call({})
    assert_redirected_to :controller => :user
    # fail: no submit flag
    call.call(:user_id => users(:commenter).id)
    assert_redirected_to :controller => :user
  end
  
  def good_session
    {:user_id => users(:submitter).id}
  end

  def test_get_new
    requires_submitter do |session|
      get :new, {}, session
    end
    get :new, {}, good_session
    assert_template "new"
  end

  def test_post_new
    goodparams = { :submission => {
      :filing_name => "Joe Bob Briggs",
      :sub_type_id => sub_types(:title),
      :resub_flag => false,
      :content => "hoo hoo ha"
    } }
    requires_submitter do |session|
       post :new, goodparams, session
    end
    # fail: invalid
    post :new, {}, good_session
    assert_template "new"
    # success
    post :new, goodparams, good_session
    assert_redirected_to :action => :drafts
  end

  def test_get_edit
    requires_submitter do |session|
      get :edit, { :id => submissions(:draft) }, session
    end
    # fail: submission not found
    get :edit, { :id => 1231231321 }, good_session
    assert_redirected_to :controller => :user
    # fail: not a draft
    get :edit, { :id => submissions(:posted) }, good_session
    assert_redirected_to :controller => :user
    # success
    get :edit, { :id => submissions(:draft) }, good_session
    assert_template "edit"
  end

  def test_post_edit
    goodparams = { :id => submissions(:draft), :submission => {
      :filing_name => "Joe Bob Briggs",
      :sub_type_id => sub_types(:title),
      :resub_flag => false,
      :content => "hoo hoo ha"
    } }
    requires_submitter do |session|
      post :edit, goodparams, session
    end
    # fail: not a draft
    post :edit, { :id => submissions(:posted) }, good_session
    assert_redirected_to :controller => :user
    # fail: invalid
    post :edit, { :id => submissions(:draft),
        :submission => { :content => "" } }, good_session
    assert_template "edit"
    # success
    post :edit, goodparams, good_session
    assert_redirected_to :action => "drafts"
  end

  def test_get_delete
    requires_submitter do |session|
      get :delete, { :id => submissions(:draft) }, session
    end
    # fail
    get :delete, { :id => submissions(:draft) }, good_session
    assert_redirected_to :controller => :user
  end

  def test_post_delete
    requires_submitter do |session|
      post :delete, { :id => submissions(:draft) }, session
    end
    # fail: submission not found
    post :delete, { :id => 1231231231 }, good_session
    assert_redirected_to :controller => :user
    # fail: not a draft
    post :delete, { :id => submissions(:posted) }, good_session
    assert_redirected_to :controller => :user
    # success
    post :delete, { :id => submissions(:draft) }, good_session
    assert_redirected_to :action => :drafts
  end

  def test_drafts
    requires_submitter do |session|
      get :drafts, {}, session
    end
    # success
    get :drafts, {}, good_session
    assert_template "drafts"
  end
  
  def test_get_upload
    requires_submitter do |session|
      get :upload, {}, session
    end
    # success
    get :upload, {}, good_session
    assert_template "upload"
  end
  
  def test_post_upload
    goodparams = { :submission => {
          :filing_name => "Joe Bob Briggs",
          :sub_type_id => sub_types(:title),
          :resub_flag => false,
          :content => "hoo hoo ha"
        } }
    requires_submitter do |session|
      post :upload, goodparams, session 
    end
    # success
    post :upload, goodparams, good_session
    #fail "Not yet implemented"
  end

end
