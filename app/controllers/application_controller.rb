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
# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  session :session_key => '_hcs.randomgang.com_session_id'

  before_filter :fetch_login

  private

    def fetch_login
      @session_user = session[:user_id] && User.find(session[:user_id])
      return true
    end

    def session_user
      @session_user
    end

    def redirect_with_error(message)
      flash[:error_message] = message
      if request.env["HTTP_REFERER"]
        redirect_to :back
      else
        redirect_to :controller => "user", :action => "index"
      end
    end
    def require_login
      if session_user.nil?
        redirect_with_error "You must log in first!"
        return false
      end
      true
    end
    def require_admin_flag
      unless session_user and session_user.admin_flag?
        redirect_with_error "You must be an admin to do that!"
        return false
      end
      true
    end
    def require_submit_flag
      unless session_user and session_user.submit_flag?
        redirect_with_error "You must be a submission herald to do that!"
        return false
      end
      true
    end
    def require_valid_flag
      unless session_user and session_user.valid_flag?
        redirect_with_error "You must be a valid user to do that!"
        return false
      end
      true
    end
    def user_controls(obj)
      session[:user_id] and
          (session[:user_id] == obj.user.id or session_user.admin_flag?)
    end
end
