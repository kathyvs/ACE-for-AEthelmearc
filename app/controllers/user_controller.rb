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

class UserController < ApplicationController
  require "net/smtp"
  layout "general"

  before_filter :require_admin_flag, :except => [ :login, :logout, :index, :list, :new, :edit, :change_password ]

  def index
    Time.zone = "America/Chicago"
    @news = News.find(:all, :order => "posted desc")
  end

  def list
    @oldusers = User.find_all_by_valid_flag(true, :order => "sca_name" )
    @newusers = User.find_all_by_valid_flag(false, :order => "sca_name" )
  end

  def login
    if request.post?
      @user = User.find_by_login( params[:login] )
      if @user and @user.check_password( params[:password] )
        session[:user] = @user
        redirect_to :action => "index"
      else
        flash.now[:error_message] = "Incorrect login or password!"
      end
    end
  end

  def logout
    reset_session
    redirect_to :action => "index"
  end

  def new
    if request.post?
      @user = User.new( params[:user] )
      if @user.save
        session[:user] = @user
        admins = User.admins.map { |u| u.email }
        begin
          Mailer::deliver_newuser_notification(admins,@user)
        rescue
          # do nothing, who cares about mail really
        end
        flash[:error_message] = "Account created, now edit your profile!"
        redirect_to :action => "edit", :id => @user
      end
    else
      @user=User.new
    end
  end

  def delete
    if request.post?
      if @user=User.find_by_id( params[:id] )
        @user.destroy
        redirect_to :action => "list"
      else
        redirect_with_error "User missing?"
      end
    else
      redirect_with_error "Insecure attempt to delete user!"
    end
  end

  def edit
    unless session[:user] and ( session[:user].id == params[:id].to_i or
        session[:user].admin_flag )
      redirect_with_error "You can't modify this profile!"
      return
    end
    @user = User.find_by_id( params[:id] )
    if request.post?
      if @user.nil?
        redirect_with_error "No such user!"
      else
        @user.update_attributes( params[:user] )
        if @user.save
          session[:user].reload if session[:user].id == params[:id].to_i
          flash.now[:error_message] = "Profile saved!"
          redirect_to :action => "index"
        end
      end
    end
  end

  def change_password
    @user = User.find_by_id( params[:id] )
    unless session[:user] and ( session[:user] == @user or
        session[:user].admin_flag? )
      redirect_with_error "You can't change this password!"
      return
    end
    if request.post?
      if @user.nil?
        redirect_with_error "User missing?"
      else
        @user.update_attributes( params[:user] )
        if @user.save
          flash[:error_message] = "Password saved!"
          redirect_to :action => :edit, :id => @user
        end
      end
    end
  end

  def validate
    @user=setflag(params[:id], :valid_flag, true)
    if @user and @user.email
      begin
        Mailer.deliver_validate_notification(@user)
      rescue
        # yawn
      end
    end
  end

  def unvalidate
    setflag(params[:id], :valid_flag, false)
  end

  def grant_submit
    setflag(params[:id], :submit_flag, true)
  end

  def revoke_submit
    setflag(params[:id], :submit_flag, false)
  end

  def grant_admin
    setflag(params[:id], :admin_flag, true)
  end

  def revoke_admin
    setflag(params[:id], :admin_flag, false)
  end

  private
    def setflag(id,flag,value)
      if id and u=User.find_by_id(id)
        u[flag]=value
        if u.save
          redirect_to :action => "list"
        else
          redirect_with_error "Flag changed failed!"
        end
      else
        redirect_with_error "Can't find user?"
      end
      return u
    end
end
