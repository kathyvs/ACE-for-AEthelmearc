# vim:set ai sw=2 ts=2 et:

require File.dirname(__FILE__) + '/../test_helper'
require 'letter_controller'

# Re-raise errors caught by the controller.
class LetterController; def rescue_action(e) raise e end; end

class LetterControllerTest < ActionController::TestCase
  fixtures :users, :submissions, :letters, :comments

  def setup
    @controller = LetterController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_new
    # fail: not logged in
    get :new, {}, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    get :new, {}, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # success
    get :new, {}, :user => users(:admin)
    assert_template "new"
  end

  def test_post_new
    goodparams = { :comments => "spa fon",
        :drafts => [ submissions(:draft).id ] }
    # fail: not logged in
    post :new, goodparams, {}
    assert_redirected_to :controller => :user
    # fail: no submit flag
    post :new, goodparams, :user => users(:commenter)
    assert_redirected_to :controller => :user
    # fail: no drafts selected
    post :new, { :comments => "spa fon" }, :user => users(:submitter)
    assert_template "new"
    # success
    post :new, goodparams, :user => users(:submitter)
    assert_redirected_to :controller => :submission, :action => :drafts
  end

  def test_list
    # success
    get :list
    assert_template "list"
  end

  def test_view
    # fail: letter not found
    get :view, :id => 1209321
    assert_redirected_to :controller => :user
    # success
    get :view, :id => letters(:locked)
    assert_template "view"
  end

  def test_toggle_lock
    # fail: not logged in
    get :toggle_lock, { :id => letters(:locked) }, {}
    assert_redirected_to :controller => :user
    # fail: no admin flag
    get :toggle_lock, { :id => letters(:locked) }, :user => users(:submitter)
    assert_redirected_to :controller => :user
    # fail: letter not found
    get :toggle_lock, { :id => 12390123190 }, :user => users(:admin)
    assert_redirected_to :controller => :user
    # success
    get :toggle_lock, { :id => letters(:locked) }, :user => users(:admin)
    assert_redirected_to :action => :view, :id => letters(:locked)
    letters(:locked).reload
    assert !letters(:locked).locked
  end
end
