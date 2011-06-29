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

# vim:ai sw=2 ts=2 et:

class SubmissionController < ApplicationController
  before_filter :require_submit_flag

  layout "general"

  def new
    if request.post?
      @submission = session[:user].submissions.build( params[:submission] )
      @submission.draft_flag = true
      if @submission.save
        redirect_to :action => "drafts"
      end
    else
      @submission = Submission.new
    end
  end

  def edit
    @submission = Submission.find_by_id( params[:id] )
    if @submission.nil?
      redirect_with_error "Draft not found?"
    elsif not @submission.draft_flag?
      redirect_with_error "Submission not draft!"
    elsif not user_controls(@submission)
      redirect_with_error "You don't own that draft!"
    elsif request.post?
      @submission.update_attributes( params[:submission] )
      if @submission.save
        redirect_to :action => "drafts"
      end
    end
  end

  def delete
    if not request.post?
      redirect_with_error "Unsafe attempt to delete draft!"
    else
      @submission = Submission.find_by_id( params[:id] )
      if not @submission
        redirect_with_error "No such draft!"
      elsif not @submission.draft_flag?
        redirect_with_error "That submission is no longer a draft!"
      elsif not user_controls(@submission)
        redirect_with_error "You don't own that draft!"
      else
        @submission.destroy
        redirect_to :action => "drafts"
      end
    end
  end

  def drafts
    @drafts = session[:user].drafts
  end
end
