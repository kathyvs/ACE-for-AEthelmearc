# This file is part of ACE, a heraldic commentary system authored by
# and copyright 2007,2008,2009,2010,2011 R. Francis Smith, rfrancis@randomang.com.
#
# ACE is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ACE is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with ACE.  If not, see <http://www.gnu.org/licenses/>.

# vim:set ai sw=2 ts=2:

require "rubygems"
require "mini_magick"

class Submission < ActiveRecord::Base
  belongs_to :user
  belongs_to :letter
  has_many :comments
  belongs_to :sub_type

	include Graphics

  def letter_name
    self.letter.name
  end

	def locked?
	  self.letter && self.letter.locked?
	end

	def top_comments
	  self.comments.find_all_by_reply_to(nil, :order => "posted")
	end

	def last_comment
		coms=self.comments.sort_by { |com| com.posted }
		coms[-1]
	end

	def bwimg=( io )
	  unless io.blank?
			f=create_image_files( io )
			write_attribute( :bwimg, f )
		end
	end

	def colorimg=( io )
	  unless io.blank?
			f=create_image_files( io )
			write_attribute( :colorimg, f )
		end
	end

	validates_presence_of :filing_name, :user, :content
	validates_presence_of :sub_type, :message => "must be chosen"
end

