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

# vim:set ai ts=2 sw=2:

require "fileutils"

module Graphics
    def create_image_files( io )
      uploads = File.join Rails.public_path, "uploads"
        ext = File.extname( io.original_filename )
        dirname = Time.now.strftime("%Y%m")
        fname = Time.now.strftime("%s") + ext
        unless File.exists? File.join( uploads, dirname )
            Dir.mkdir File.join( uploads, dirname )
            FileUtils.chmod( 0755, File.join( uploads, dirname ) )
            Dir.mkdir File.join( uploads, "thumbs", dirname )
            FileUtils.chmod( 0755, File.join( uploads, "thumbs", dirname ) )
        end
        begin
            img = MiniMagick::Image.from_blob io.read
            img.write( File.join uploads, dirname, fname )
            FileUtils.chmod( 0644, File.join( uploads, dirname, fname ) )
            img.resize "200" if img["width"] > 200
            img.write( File.join uploads, "thumbs", dirname, fname )
            FileUtils.chmod( 0644, File.join( uploads, "thumbs", dirname, fname ) )
        rescue
                        
            return nil
        end
        return File.join( dirname, fname )
    end
end
