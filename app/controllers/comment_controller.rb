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

class CommentController < ApplicationController
  layout "general"

  before_filter :require_valid_flag

  def new
    if request.post?
      @comment=Comment.new(params[:comment])
      @comment.posted = Time.now
      @comment.user_id = session[:user_id]
      if @comment.save
        if @comment.parent and @comment.parent.email
          begin
            Mailer.deliver_comment_notification( @comment.parent.user, @comment )
          rescue Exception
            # do nothing much
          end
        end
        redirect_to :controller => "letter", :action => "view",
            :id => @comment.letter,
            :anchor => ( "sub-%d" % @comment.submission.id )
      else
        @submission = @comment.submission
        @parent = @comment.parent
      end
    else
      @comment = Comment.new
      @submission ||= Submission.find_by_id(params[:submission])
      @parent ||= Comment.find_by_id(params[:parent])
    end
  end

  def edit
    @comment = Comment.find_by_id( params[:id] )
    if @comment.nil?
      redirect_with_error "Comment not found?"
    elsif @comment.locked?
      redirect_with_error "Can't edit comment on locked letter!"
    elsif user_controls(@comment)
      if request.post?
        @comment.update_attributes( params[:comment] )
        @comment.edited = Time.now
        if @comment.save
          redirect_to :controller => "letter", :action => "view",
              :id => @comment.letter,
              :anchor => ( "sub-%d" % @comment.submission.id )
        end
      end
    else
      redirect_with_error "You don't own that comment!"
    end
  end

  def delete
    if not request.post?
      redirect_with_error "Unsafe attempt to delete comment!"
    else
      @comment = Comment.find_by_id( params[:id] )
      if not @comment
        redirect_with_error "No such comment!"
      elsif @comment.locked?
        redirect_with_error "Can't delete comment from locked letter!"
      elsif not @comment.replies.empty?
        redirect_with_error "Can't delete comment with replies!"
      elsif not user_controls( @comment )
        redirect_with_error "You don't own that comment!"
      else
        letter = @comment.letter
        sub = @comment.submission
        @comment.destroy
        redirect_to :controller => "letter", :action => "view", :id => letter,
          :anchor => ( "sub-%d" % sub.id )
      end
    end
  end
end
