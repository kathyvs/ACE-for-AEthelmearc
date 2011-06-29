# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'

class SubTypeTest < Test::Unit::TestCase
  def test_create_read_update_delete
	  noob = SubType.new( :name => "flip", :abbrev => "flop" )
		assert noob.save # create
		test = SubType.find( noob.id )
		assert_equal test.name, noob.name #read
		noob.abbrev = "fred"
		assert noob.save # update
		assert noob.destroy # destroy
	end

	def test_bad_subtypes
	  st = SubType.new( :name => "foo" )
		assert !st.save
		st = SubType.new( :abbrev => "foo" )
		assert !st.save
	end
end
