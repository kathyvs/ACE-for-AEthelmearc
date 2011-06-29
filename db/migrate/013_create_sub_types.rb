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

class CreateSubTypes < ActiveRecord::Migration
  def self.up
    create_table :sub_types do |t|
      t.column :name, :string, :null => false
      t.column :abbrev, :string, :null => false
    end
    SubType.create :abbrev => "name", :name => "Name"
    SubType.create :abbrev => "device", :name => "Device"
    SubType.create :abbrev => "badge", :name => "Badge"
  end

  def self.down
    drop_table :sub_types
  end
end
