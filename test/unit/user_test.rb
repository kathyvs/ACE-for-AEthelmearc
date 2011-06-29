# vim:set ts=2 sw=2 ai:

require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users

  def test_create_read_update_delete
	  noob = User.new( :login => "noob", :sca_name => "noob", :email => "noob" )
		assert noob.save # create
		test = User.find( noob.id )
		assert_equal test.login, noob.login #read
		noob.password = "fred"
		assert noob.save # update
		assert noob.destroy # destroy
	end

	def test_bad_user
		u=User.new()
		assert !u.save
		u=User.new( :login => "" )
		assert !u.save
		u=User.new( :login => "foo" )
		assert !u.save
		u=User.new( :login => "foo", :sca_name => "Foo" )
		assert !u.save
		u=User.new( :login => users(:admin).login, :sca_name => "Foo", :email => "foo" )
		assert !u.save
	end

  def test_methods
		russ=users(:admin)
		assert_equal russ.longname, russ.sca_name+" ("+russ.title+")"
		assert_equal User.admins.length, 1
		assert_equal users(:submitter).drafts.length, 1
		assert russ.check_password("frog")
		russ.password="test"
		russ.save
		assert_equal russ.password, "test"
		assert russ.check_password("test")
  end
end
