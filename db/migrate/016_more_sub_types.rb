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

class MoreSubTypes < ActiveRecord::Migration
  NewTypes = [
    [ "augment", "Augmentation of Arms" ],
    [ "awardname", "Award or Order Name" ],
    [ "awardnamebadge", "Award or Order Name and Badge" ],
    [ "badgechange", "Badge Change" ],
    [ "devicechange", "Device Change" ],
    [ "housebadge", "Household Badge" ],
    [ "housename", "Household Name" ],
    [ "housenamebadge", "Household Name and Badge" ],
    [ "jointbadge", "Joint Badge" ],
    [ "namebadge", "Name and Badge" ],
    [ "namedevice", "Name and Device" ],
    [ "namechange", "Name Change" ],
    [ "namealt", "Name for Alternate Persona" ],
    [ "namealtbadge", "Name for Alternate Persona and Badge" ],
    [ "title", "Title" ],
    [ "transferbadge", "Transfer of Badge" ],
    [ "transferdevice", "Transfer of Device" ],
    [ "acctransferbadge", "Acceptance of Transfer of Badge" ],
    [ "acctransferdevice", "Acceptance of Transfer of Device" ]
  ]

  def self.up
    NewTypes.each do |entry|
      abbrev, name = entry
      SubType.create( :abbrev => abbrev, :name => name )
    end
  end

  def self.down
    NewTypes.each do |entry|
      abbrev, name = entry
      s=SubType.find_by_abbrev( abbrev )
      s.destroy if s
    end
  end
end
