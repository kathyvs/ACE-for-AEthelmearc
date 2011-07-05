# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  fixtures :users, :submissions, :comments, :letters

  def test_create_read_update_delete
	  noob = Comment.new(
			:posted => Time.now,
			:submission => submissions(:posted),
			:user => users(:commenter),
			:content => "hoo ha"
		)
		assert noob.save # create
		test = Comment.find( noob.id )
		assert_equal test.posted.to_s, noob.posted.to_s #read
		noob.content = "fred"
		assert noob.save # update
		assert noob.destroy # destroy
	end

	def test_bad_comments
	  # everything missing
		c=Comment.new()
		assert !c.save
		# submission missing
		c=Comment.new( :user => users(:commenter) )
		assert !c.save
		# user missing
		c=Comment.new( :submission => submissions(:posted) )
		assert !c.save
		# user doesn't exist
		c=Comment.new( :user_id => 100, :submission => submissions(:posted) )
		assert !c.save
		# submission doesn't exist
		c=Comment.new( :user_id => users(:commenter), :submission_id => 100 )
		assert !c.save
	end

	def test_reply
	  c1=Comment.new(
			:user => users(:commenter),
			:submission => submissions(:posted),
			:content => "hoo ha"
		)
		c1.save
	  c2=Comment.new(
			:user => users(:commenter),
			:submission => submissions(:posted),
			:parent => c1,
			:content => "hoo ha hee"
		)
		assert c2.save
		assert_equal c2.parent.id, c1.id
		assert c1.replies.include?(c2)
	end

	def test_methods
		c1=Comment.new(
			:user => users(:commenter),
			:submission => submissions(:posted)
		)
		assert_equal c1.email, users(:commenter).email
		assert_equal c1.longname, users(:commenter).longname
		assert_equal c1.filing_name, submissions(:posted).filing_name
		assert_equal c1.letter, submissions(:posted).letter
		assert_equal c1.letter_name, submissions(:posted).letter_name
		assert_equal c1.locked?, submissions(:posted).locked?
	end
end
