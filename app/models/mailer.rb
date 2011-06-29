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

class Mailer < ActionMailer::Base
  def comment_notification(to,comment)
    recipients to.email
    from APP_CONFIG['admin_mail']
    subject "reply posted to your comment"
    body :comment => comment
  end

  def validate_notification(to)
    recipients to.email
    from APP_CONFIG['admin_mail']
    subject "you have been validated"
    body :to => to
  end

  def newuser_notification(to,newuser)
    recipients to
    from APP_CONFIG['admin_mail']
    subject "new ace user "+newuser.login
    body :newuser => newuser
  end

  def newiloi_notification(to,letter)
    recipients to.email
    from APP_CONFIG['admin_mail']
    subject "new ILoI posted"
    body :letter => letter
  end

  def subposted_notification(to_email,letter,submission)
    recipients to_email
    from APP_CONFIG['submission_mail']
    cc APP_CONFIG['submission_mail']
    subject "submission in progress"
    body :letter => letter, :submission => submission
  end
end
