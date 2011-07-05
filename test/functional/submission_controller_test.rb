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

  def test_get_new
    # fail: not logged in
    get :new, {}, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    get :new, {}, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # success
    get :new, {}, :user => users(:submitter)
    assert_template "new"
  end

  def test_post_new
    goodparams = { :submission => {
      :filing_name => "Joe Bob Briggs",
      :sub_type_id => sub_types(:title),
      :resub_flag => false,
      :content => "hoo hoo ha"
    } }
    # fail: not logged in
    post :new, goodparams, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    post :new, goodparams, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: invalid
    post :new, {}, :user => users(:submitter)
    assert_template "new"
    # success
    post :new, goodparams, :user => users(:submitter)
    assert_redirected_to :action => :drafts
  end

  def test_get_edit
    # fail: not logged in
    get :edit, { :id => submissions(:draft) }, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    get :edit, { :id => submissions(:draft) }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: submission not found
    get :edit, { :id => 1231231321 }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: not a draft
    get :edit, { :id => submissions(:posted) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # success
    get :edit, { :id => submissions(:draft) }, :user => users(:submitter)
    assert_template "edit"
  end

  def test_post_edit
    goodparams = { :id => submissions(:draft), :submission => {
      :filing_name => "Joe Bob Briggs",
      :sub_type_id => sub_types(:title),
      :resub_flag => false,
      :content => "hoo hoo ha"
    } }
    # fail: not logged in
    post :edit, goodparams, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    post :edit, goodparams, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: submission not found
    post :edit, { :id => 123901231 }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: not a draft
    post :edit, { :id => submissions(:posted) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: invalid
    post :edit, { :id => submissions(:draft),
        :submission => { :content => "" } }, :user => users(:submitter)
    assert_template "edit"
    # success
    post :edit, goodparams, :user => users(:submitter)
    assert_redirected_to :action => "drafts"
  end

  def test_get_delete
    # fail: not logged in
    get :delete, { :id => submissions(:draft) }, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    get :delete, { :id => submissions(:draft) }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail
    get :delete, { :id => submissions(:draft) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
  end

  def test_post_delete
    # fail: not logged in
    post :delete, { :id => submissions(:draft) }, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    post :delete, { :id => submissions(:draft) }, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: submission not found
    post :delete, { :id => 1231231231 }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: not a draft
    post :delete, { :id => submissions(:posted) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # success
    post :delete, { :id => submissions(:draft) }, :user => users(:submitter)
    assert_redirected_to :action => :drafts
  end

  def test_drafts
    # fail: not logged in
    get :drafts, {}, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    get :drafts, {}, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # success
    get :drafts, {}, :user => users(:submitter)
    assert_template "drafts"
  end
end
