# vim:set ai sw=2 ts=2 et:

require File.dirname(__FILE__) + '/../test_helper'
require 'user_controller'

# Re-raise errors caught by the controller.
class UserController; def rescue_action(e) raise e end; end

class UserControllerTest < ActionController::TestCase
  fixtures :users

  def setup
    @controller = UserController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    # success
    get :index
    assert_template "index"
  end

  def test_list
    # success
    get :list
    assert_template "list"
  end

  def test_get_login
    # success
    get :login
    assert_template "login"
  end

  def test_post_login
    # fail: login not found
    post :login, { :login => "argleblat", :password => "frog" }
    assert_template "login"
    # fail: password doesn't check
    post :login, { :login => "russ", :password => "argleblat" }
    assert_template "login"
    # success
    post :login, { :login => "russ", :password => "frog" }
    assert_redirected_to :action => :index
  end

  def test_logout
    # success
    get :logout
    assert_redirected_to :action => :index
  end

  def test_get_new
    # success
    get :new
    assert_template "new"
  end

  def test_post_new
    # fail: invalid
    post :new, { :user => { :login => "john" } }
    assert_template "new"
    # fail: confirm doesn't match
    post :new, { :user => { :login => "john", :sca_name => "John Johns",
        :email => "john@mailinator.com", :password => "frog",
        :password_confirmation => "argleblat" } }
    assert_template "new"
    # success
    post :new, { :user => { :login => "john", :sca_name => "John Johns",
        :email => "john@mailinator.com", :password => "frog",
        :password_confirmation => "frog" } }
    new_user = User.find_by_login("john")
    assert_equal 'john@mailinator.com', new_user.email
    assert_redirected_to :action => :edit, :id => new_user
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  def test_get_delete
    # fail
    get :delete, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => :index
  end

  def test_post_delete
    # fail: not logged in
    post :delete, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    post :delete, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    post :delete, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    post :delete, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
  end

  def test_get_edit
    # fail: not logged in
    get :edit, { :id => users(:bozo).id }, {}
    assert_redirected_to :action => :index
    # fail: not user or admin
    get :edit, { :id => users(:bozo).id }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # success (user)
    get :edit, { :id => users(:bozo).id }, :user => users(:bozo)
    assert_template "edit"
    # success (admin)
    get :edit, { :id => users(:bozo).id }, :user => users(:admin)
    assert_template "edit"
  end

  def test_post_edit
    goodparams = { :id => users(:bozo).id, :user => { :sca_name => "Big Bob" } }
    # fail: not logged in
    post :edit, goodparams, {}
    assert_redirected_to :action => :index
    # fail: not user or admin
    post :edit, goodparams, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    post :edit, { :id => 12312312 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # fail: invalid
    post :edit, { :id => users(:bozo).id, :user => { :sca_name => "" } },
        :user => users(:admin)
    assert_template "edit"
    # success
    post :edit, goodparams, :user => users(:admin)
    assert_redirected_to :action => :index
    users(:bozo).reload
    assert_equal users(:bozo).sca_name, "Big Bob"
  end

  def test_get_change_password
    # fail: not logged in
    get :change_password, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not user or admin
    get :change_password, { :id => users(:bozo) },
        { :user => users(:submitter) }
    assert_redirected_to :action => :index
    # success
    get :change_password, { :id => users(:bozo) },
        { :user => users(:bozo) }
    assert_template "change_password"
  end

  def test_post_change_password
    goodparams = { :id => users(:bozo),
        :user => { :password => "splat", :password_confirmation => "splat" } }
    # fail: not logged in
    post :change_password, goodparams, {}
    assert_redirected_to :action => :index
    # fail: not user or admin
    post :change_password, goodparams, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    post :change_password, { :id => 12312312 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # fail: invalid
    post :change_password, { :id => users(:bozo),
        :user => { :password => "" } }, :user => users(:bozo)
    assert_template "change_password"
    # fail: confirm doesn't match
    post :change_password, { :id => users(:bozo),
        :user => { :password => "splat", :password_confirmation => "splot" } },
        :user => users(:bozo)
    assert_template "change_password"
    # success
    post :change_password, goodparams, :user => users(:bozo)
    assert_redirected_to :action => :edit, :id => users(:bozo)
    users(:bozo).reload
    assert users(:bozo).check_password("splat")
  end

  def test_validate
    # fail: not logged in
    get :validate, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    get :validate, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    get :validate, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    get :validate, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
    users(:bozo).reload
    assert users(:bozo).valid_flag?
    assert_equal 2, ActionMailer::Base.deliveries.size
  end

  def test_unvalidate
    # fail: not logged in
    get :unvalidate, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    get :unvalidate, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    get :unvalidate, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    get :unvalidate, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
    users(:bozo).reload
    assert !users(:bozo).valid_flag?
  end

  def test_grant_submit
    # fail: not logged in
    get :grant_submit, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    get :grant_submit, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    get :grant_submit, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    get :grant_submit, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
    users(:bozo).reload
    assert users(:bozo).submit_flag?
  end

  def test_revoke_submit
    # fail: not logged in
    get :revoke_submit, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    get :revoke_submit, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    get :revoke_submit, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    get :revoke_submit, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
    users(:bozo).reload
    assert !users(:bozo).submit_flag?
  end

  def test_grant_admin
    # fail: not logged in
    get :grant_admin, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    get :grant_admin, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    get :grant_admin, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    get :grant_admin, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
    users(:bozo).reload
    assert users(:bozo).admin_flag?
  end

  def test_revoke_admin
    # fail: not logged in
    get :revoke_admin, { :id => users(:bozo) }, {}
    assert_redirected_to :action => :index
    # fail: not admin
    get :revoke_admin, { :id => users(:bozo) }, :user => users(:submitter)
    assert_redirected_to :action => :index
    # fail: user not found
    get :revoke_admin, { :id => 1231231 }, :user => users(:admin)
    assert_redirected_to :action => :index
    # success
    get :revoke_admin, { :id => users(:bozo) }, :user => users(:admin)
    assert_redirected_to :action => "list"
    users(:bozo).reload
    assert !users(:bozo).admin_flag?
  end
end
