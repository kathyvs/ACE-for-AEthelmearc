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

# vim:set ai sw=2 ts=2 et:

class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :submission
  belongs_to :parent, :class_name => "Comment", :foreign_key => "reply_to"
  has_many :replies, :class_name => "Comment", :foreign_key => "reply_to"

  validates_presence_of :user, :submission, :content
  validate :validate_locked

  include Graphics

  def img1=( io )
    unless io.blank?
      f=create_image_files( io )
      write_attribute( :img1, f )
    end
  end

  def img2=( io )
    unless io.blank?
      f=create_image_files( io )
      write_attribute( :img2, f )
    end
  end

  def img3=( io )
    unless io.blank?
      f=create_image_files( io )
      write_attribute( :img3, f )
    end
  end

  def email
    self.user && self.user.email
  end

  def letter_name
    self.submission && self.submission.letter_name
  end

  def longname
    self.user && self.user.longname
  end

  def filing_name
    self.submission && self.submission.filing_name
  end

  def locked?
    self.submission && self.submission.locked?
  end

  def letter
    self.submission && self.submission.letter
  end

  def validate_locked
    errors.add("submission","is in a locked letter") if self.locked?
  end
end
