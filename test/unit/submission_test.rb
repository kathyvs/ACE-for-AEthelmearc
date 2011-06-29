# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'

class SubmissionTest < Test::Unit::TestCase
  fixtures :users, :submissions, :comments, :sub_types

  def test_create_read_update_delete
		newsub = Submission.new(
			:filing_name => "Bob the Builder",
			:content => "wakka wakka",
			:user_id => users(:submitter),
			:sub_type => sub_types(:title)
		)
		assert newsub.save # create
		test = Submission.find( newsub.id )
		assert_equal test.filing_name, newsub.filing_name #read
		newsub.resub_flag = true
		assert newsub.save # update
		assert newsub.destroy # destroy
	end

	def test_bad_subs
		s=Submission.new()
		assert !s.save
		s=Submission.new( :filing_name => "Bob" )
		assert !s.save
		s=Submission.new( :filing_name => "Bob", :user_id => users(:submitter) )
		assert !s.save
		s=Submission.new( :filing_name => "Bob", :user_id => users(:submitter),
				:content => "wakka wakka" )
		assert !s.save
	end

	def test_methods
	  posted = submissions(:posted)
		assert_equal posted.letter_name, posted.letter.name
		assert_equal posted.locked?, posted.letter.locked?
		assert_equal posted.top_comments.length, 1
	end
end


