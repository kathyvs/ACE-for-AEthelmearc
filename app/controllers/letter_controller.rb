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

class LetterController < ApplicationController
  layout "general"

  before_filter :require_submit_flag, :except => [:list, :view]
  before_filter :require_admin_flag, :only => [:toggle_lock]

  def new
    if request.post?
      @letter=Letter.new( params[:letter] )
      @letter.posted = Date.today
      if not drafts=params[:drafts] or drafts.length < 1
        @letter.errors.add_to_base "You must select at least one draft!"
        @drafts = session[:user].drafts
        render :action => "new"
      elsif not @letter.save
        @drafts = session[:user].drafts
        render :action => "new"
      else
        drafts.each do |id|
          if d=Submission.find_by_id(id)
            d.letter = @letter
            d.draft_flag = false
            d.save
            if d.email
              begin
                Mailer.deliver_subposted_notification( d.email, @letter, d )
              rescue Exception
                # do nothing special
              end
            end
          end
        end
        User.find_all_by_mailok_flag(true).each do |u|
          begin
            Mailer.deliver_newiloi_notification( u, @letter )
          rescue
            # do nothing special here either
          end
        end
        redirect_to :controller => "submission", :action => "drafts"
      end
    else
      @letter = Letter.new
      @drafts = session[:user].drafts
    end
  end

  def list
    @letters = Letter.find( :all, :order => "posted desc" )
    @open_letters = @letters.reject { |l| l.locked }
    @locked_letters = @letters.reject { |l| not l.locked }
  end

  def view
    unless params[:id] and @letter = Letter.find_by_id( params[:id] )
      redirect_with_error "Letter not found?"
    end
    @postable = (session[:user] and session[:user].valid_flag) &&
        !@letter.locked
    subs = @letter.submissions
    coms = subs.map { |s| s.comments }.flatten
    @commenters = coms.map { |c| c.user.sca_name }.uniq
  end

  def toggle_lock
    if params[:id] and @letter = Letter.find_by_id( params[:id] )
      if @letter.locked.nil?
        @letter.locked = Date.today
      else
        @letter.locked = nil
      end
      if @letter.save
        redirect_to :action => "view", :id => @letter
      else
        redirect_with_error "Couldn't save letter!"
      end
    else
      redirect_with_error "Letter not found?"
    end
  end
end
