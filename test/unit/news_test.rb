# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'

class NewsTest < Test::Unit::TestCase

  fixtures :users

  def test_create_read_update_delete
	  noob = News.new( :content => "noob", :user_id => users(:admin) )
		assert noob.save # create
		test = News.find( noob.id )
		assert_equal test.content, noob.content #read
		noob.content = "fred"
		assert noob.save # update
		assert noob.destroy # destroy
	end

	def test_bad_news
	  # missing user
	  n = News.new( :content => "foo" )
		assert !n.save
	  # missing content
	  n = News.new( :user_id => users(:admin) )
		assert !n.save
	end

	def test_methods
	  news = News.new( :content => "noob", :user_id => users(:admin) )
		news.save
		assert_equal news.longname, users(:admin).longname
	end
end
