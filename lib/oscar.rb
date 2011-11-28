require 'nokogiri'

module Oscar

  class OscarParser
    
    def initialize(typer)
      @typer = typer
    end
    
    def parse(html)
      doc = Nokogiri::HTML(html)
      doc.xpath("//td[.//a/@name > 0]").map do |e|
        parse_item(e) 
      end
    end
    
    def parse_item(e)
      result = Submission.new
      result.filing_name = find_name(e)
      result.sub_type_id, result.resub_flag = find_sub_type_and_resub(e)
      result.summary = find_summary(e)
      result.content = find_content(e)
      return result
    end
    
    NAME_PATTERN = /[0-9]+:\s*(.*)\s*$/
    def find_name(e)
      text = e.xpath('p[1]/b').text
      if (match = NAME_PATTERN.match(text)) 
        match[1]
      else
        text
      end
    end
    
    TYPE_PATTERN = /.*-\s*(.*)/m
    TRIM_PATTERN = /\s*\(.*\)\s*/
    def find_sub_type_and_resub(e)
      text = e.xpath('p[1]').text
      if (match = TYPE_PATTERN.match(text))
        sub_type = match[1].gsub(TRIM_PATTERN, ' ')
        sub_type = sub_type.gsub(/\s+/, ' ').strip.downcase
        @typer.find_type(sub_type)
      end
    end
    
    def find_summary(e)
      summaries = e.xpath('p/em')
      return "" if summaries.empty?
      return summaries[0].text.strip
    end
    
    def find_content(e)
      paragraphs = e.xpath('p').drop(1).find_all do |p|
        p.xpath('em').empty?
      end
      return (paragraphs.map {|p| p.to_s}).join("\n")
    end
  end
  
  class Typer
    
    KNOWN_TYPES = {
      "new badge" => [:badge, false],
      "resub badge" => [:badge, true],
      "new device" => [:device, false],
      "resub device" => [:device, true],
      "new device change" => [:devicechange, false],
      "resub device change" => [:devicechange, true],
      "new name" => [:name, false],
      "resub name" => [:name, true],
      "new alternate name" => [:namealt, false],
      "resub alternate name" => [:namealt, true],
      "new name change" => [:namechange, false],
      "resub name change" => [:namechange, true],
      "new name & new device" => [:namedevice, false],
      "resub name & resub device" => [:namedevice, true]
    }
    
    def initialize(sub_types)
      @abbrevs_to_ids = {}
      sub_types.each do |sub_type|
        @abbrevs_to_ids[sub_type.abbrev] = sub_type.id
      end
    end
    
    def find_type(type_name)
      abbrev, resub = KNOWN_TYPES.fetch(type_name, [:namealt, false])
      return [@abbrevs_to_ids.fetch(abbrev, -1), resub]
    end
  end
  
end