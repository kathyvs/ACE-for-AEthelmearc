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

require "digest/sha2"

class User < ActiveRecord::Base
  has_many :submissions
  has_many :comments
  has_many :news

  def longname
    s = ""
    s = sca_name if sca_name and sca_name.length > 0
    s += " ("+title+")" if title and title.length > 0
    s
  end

  def drafts
    self.submissions.find_all_by_draft_flag(true)
  end

  def self.admins
    self.find_all_by_admin_flag(true)
  end

  def check_password(plaintext)
    Digest::SHA256.hexdigest(plaintext) == self.encrypted_password
  end

  def password
    @password
  end

  def password=(plaintext)
    @password = plaintext
    self.encrypted_password = Digest::SHA256.hexdigest(plaintext)
  end

  validates_presence_of :login
  validates_presence_of :sca_name
  validates_presence_of :email
  validates_length_of :password, :minimum => 1, :allow_nil => true
  validates_uniqueness_of :login
  validates_confirmation_of :password
end
