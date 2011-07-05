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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
# swiped from http://blade.nagaokaut.ac.jp/cgi-bin/scat.rb/ruby/ruby-talk/116621
SIMPLE_TAG_RE = %r{<[^<>]+?>}   # Ensure that only the tag is grabbed.
  HTML_TAG_RE   = %r{\A<          # Tag must be at start of match.
                        (/)?      # Closing tag?
                        ([\w:]+)  # Tag name
                        (?:\s+    # Space
                         ([^>]+)  # Attributes
                         (/)?     # Singleton tag?
                        )?        # The above three are optional
                       >}x
  ATTRIBUTES_RE = %r{([\w:]+)(=(?:\w+|"[^"]+?"|'[^']+?'))?}x
  ALLOWED_ATTR  = %w(href src alt)
  ALLOWED_HTML  = %w(a br img i p em strong b blockquote sup sub u ol ul li pre hr)
  URL_RE = %r{\[((https?|ftp|gopher|telnet|file|notes|ms-help):((//)|(\\\\))+[\w\d:\#@%/;$()~_?\+-=\\\.&]*)\]}
    # Clean the content of unsupported HTML and attributes. This includes
    # XML namespaced HTML. Sorry, but there's too much possibility for
    # abuse.
  def html_clean(content)
    content.strip!
    content.gsub! /$/, "<br>"
    content = content.gsub(SIMPLE_TAG_RE) do |tag|
      tagset = HTML_TAG_RE.match(tag)

      if tagset.nil?
        tag = h(tag)
      else
        closer, name, attributes, single = tagset.captures

        if ALLOWED_HTML.include?(name.downcase)
          unless closer or attributes.nil?
            attributes = attributes.scan(ATTRIBUTES_RE).map do |set|
              if ALLOWED_ATTR.include?(set[0].downcase)
                set.join
              else
                ""
              end
            end.compact.join(" ")
            tag = "<#{closer}#{name} #{attributes}#{single}>"
          else
            tag = "<#{closer}#{name}>"
          end
        else
          tag = h(tag)
        end
      end

      tag
    end
    content = content.gsub(URL_RE) do |url|
      %Q{<a href="#{$1}">#{$1}</a>}
    end
  end

  def kingdom
    APP_CONFIG['kingdom']
  end

  def banner
    APP_CONFIG['banner']
  end

end
