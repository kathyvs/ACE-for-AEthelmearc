# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'

class LetterTest < Test::Unit::TestCase
  fixtures :users

  def test_create_read_update_delete
	  noob = Letter.new( :posted => Date.today )
		assert noob.save # create
		test = Letter.find( noob.id )
		assert_equal test.posted, noob.posted #read
		noob.comments = "fred"
		assert noob.save # update
		assert noob.destroy # destroy
	end
	
	def test_bad_letter
	  noob = Letter.new()
		assert !noob.save
	end

	def test_methods
	  l=Letter.new( :posted => Date.today )
		assert_equal l.name, l.posted.to_s
	end
end

