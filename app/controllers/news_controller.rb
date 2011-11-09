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

class NewsController < ApplicationController
  layout "general"

  before_filter :require_submit_flag

  def new
    if request.post?
      @news=News.new(params[:news])
      @news.user_id = session[:user_id]
      @news.posted = Time.now
      if @news.save
        redirect_to :controller => "user", :action => "index"
      end
    else
      @news=News.new
    end
  end

  def delete
    if not request.post?
      redirect_with_error "Insecure attempt to delete news!"
    else
      @news=News.find_by_id( params[:id] )
      if @news.nil?
        redirect_with_error "News item not found?"
      else
        @news.destroy
        redirect_to :controller => "user", :action => "index"
      end
    end
  end
end
