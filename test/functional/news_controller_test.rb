# vim: set ai sw=2 ts=2 et:

require File.dirname(__FILE__) + '/../test_helper'
require 'news_controller'

# Re-raise errors caught by the controller.
class NewsController; def rescue_action(e) raise e end; end

class NewsControllerTest < Test::Unit::TestCase
  fixtures :news, :users

  def setup
    @controller = NewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_get_new
    # fail: not logged in
    get :new, {}, {}
    assert_redirected_to :controller => "user"
    # fail: not submitter
    get :new, {}, :user => users(:bozo)
    assert_redirected_to :controller => "user"
    # success
    get :new, {}, :user => users(:admin)
    assert_template "new"
  end

  def test_post_new
    goodparams = { :news => { :content => "aloha" } }
    # fail: not logged in
    post :new, goodparams, {}
    assert_redirected_to :controller => "user"
    # fail: not submitter
    post :new, goodparams, :user => users(:bozo)
    assert_redirected_to :controller => "user"
    # fail: invalid
    post :new, { :news => {} }, :user => users(:admin)
    assert_template "new"
    # success
    post :new, goodparams, :user => users(:admin)
    assert News.find_by_content( "aloha" )
    assert_redirected_to :controller => "user", :action => "index"
  end

  def test_get_delete
    # fail
    get :delete, { :id => news(:first) }, :user => users(:admin)
    assert_redirected_to :controller => "user"
  end

  def test_post_delete
    # fail: not logged in
    post :delete, { :id => news(:first) }, {}
    assert_redirected_to :controller => "user"
    # fail: not submitter
    post :delete, { :id => news(:first) }, :user => users(:bozo)
    assert_redirected_to :controller => "user"
    # fail: not found
    post :delete, { :id => 12309321 }, :user => users(:admin)
    assert_redirected_to :controller => "user"
    # success
    post :delete, { :id => news(:first) }, :user => users(:admin)
    assert !News.find_by_id( news(:first).id )
    assert_redirected_to :controller => "user", :action => "index"
  end
end
