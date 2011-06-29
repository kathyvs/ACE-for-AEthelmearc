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

class Letter < ActiveRecord::Base
  has_many :submissions

  def name
    self.posted.to_s
  end

  def last_comment
    subs = self.submissions.reject { |s| s.last_comment.nil? }
    subs = subs.sort_by { |s| s.last_comment.posted }
    subs[-1].last_comment if subs[-1]
  end

  validates_presence_of :posted
end

