# vim:set ai sw=2 ts=2:

require File.dirname(__FILE__) + '/../test_helper'
require "oscar"

module Items
  ITEMS = <<EOI
<body>
  <table>
    <tr>
      <td>
        <a id="1" name="1"></a>
        <a href="https://oscar.sca.org/color1"></a>
        <a href="https://oscar.sca.org/bw1"></a>
        <p><b>1: Aemilia Leaena</b> - New Name (<a href="./index.php?action=107&amp;id=18869">Edit</a>)
  (<a href="./index.php?action=108&amp;id=18869">Delete</a>)</p>
      </td>
    </tr>
    <tr><td><br/></td></tr>
    <tr>
      <td>
        <a id="2" name="2"></a>
        <a href="https://oscar.sca.org/color2"></a>
        <a href="https://oscar.sca.org/bw2"></a>
        <p><b>2: Ailletha de la Mere</b> - New Name (<a href="./index.php?action=184&amp;id=17840">Correct</a>)
        (<a href="./index.php?action=120&amp;id=17840-1">Comment</a>)
        &amp; New Device (<a href="./index.php?action=184&amp;id=17841">Correct</a>)
        (<a href="./index.php?action=120&amp;id=17841-1">Comment</a>)
        </p>
        <p><em>Per fess embattled gules and azure, three plates and in base a compass rose argent.</em></p>
        <p>Submitter desires a feminine name.<br>
        No major changes.<br> Culture (Norman) most important.<br>
        <p><b>Ailletha</b> is a feminine given name dated 1202 in Talan Gwynek, <i>Feminine Given Names in a Dictionary of English Surnames</i>, <a href="http://heraldry.sca.org/laurel/reaneyAG.html">http://heraldry.sca.org/laurel/reaneyAG.html</a>.</p>
        <p><b>de la Mere</b> is dated 1273 in Bardsley, s.n. Delamere. Also, in R&W, p. 130, sn Delamar, <i>William de la Mare</i> dated to 1260.</p>
      </td>
    </tr>
    <tr><td><br/></td></tr>
    <tr>
      <td>
        <a id="3" name="3"></a>
        <a href="https://oscar.sca.org/color3"></a>
        <a href="https://oscar.sca.org/bw3"></a>
        <p><b>3: Faelan mac Colmain</b> -  Resub Name (<a href="./index.php?action=107&amp;id=18869">Edit</a>)
  (<a href="./index.php?action=108&amp;id=18869">Delete</a>)
  </p>
  <p>Submitter desires a masculine name.<br>
   No major changes.<br> Language (Old Irish Gaelic) most important.<br><p>His previous submission, <i>Faolán Mer</i> was returned at Laurel in March 2011, for conflict with <i>Fáelán Mer</i>.</p>
      </td>
    </tr>
    <tr><td><br/></td></tr>
  </table>
</body>   
EOI

  
end
class OscarParserTest < Test::Unit::TestCase
  include Items
  
  def setup
    @fake_typer = FakeTyper.new
    @parser = Oscar::OscarParser.new(@fake_typer)
  end
  
  def test_items
    items = @parser.parse(ITEMS)
    assert_equal 3, items.size
	end
	
	def test_names
	  items = @parser.parse(ITEMS)
	  assert_equal ['Aemilia Leaena', 'Ailletha de la Mere', 'Faelan mac Colmain'], \
                 items.map { |i| i.filing_name }
	end
	
	def test_sub_type_and_resub
	  @fake_typer.pair("new name", 3, false)
	  @fake_typer.pair("new name & new device", 2, false)
	  @fake_typer.pair("resub name", 3, true)
	  items = @parser.parse(ITEMS)
   	assert_equal [3, 2, 3], items.map { |i| i.sub_type_id}
    assert_equal [false, false, true], items.map {|i| i.resub_flag}
	end
	
	def test_summary
	  items = @parser.parse(ITEMS)
	  assert_equal ["", 
	                "Per fess embattled gules and azure, three plates and in base a compass rose argent.",
              	  ""], items.map {|i| i.summary}
	end
	
	def test_first_content
	  items = @parser.parse(ITEMS)
	  assert_equal "", items[0].content
  end
  
  def test_second_content
    items = @parser.parse(ITEMS)
    doc = Nokogiri.HTML(items[1].content)
    assert_equal 3, doc.xpath("html/body/p").size
  end

  def test_third_content
    items = @parser.parse(ITEMS)
    doc = Nokogiri.HTML(items[2].content)
    paragraphs = doc.xpath("html/body/p")
    assert_equal 2, paragraphs.size
    assert_match /Old Irish Gaelic/, paragraphs[0].text
  end
end

class FakeTyper

  def initialize
    @mapping = {}
  end
  
  def pair(typ, id, resub)
    @mapping[typ] = [id, resub]
  end
  
  def find_type(typ)
    @mapping[typ] or [-1, false]
  end
end

class TyperTest < Test::Unit::TestCase
  
  VALUES = {
    :badge => ["new badge", "resub badge"],
    :device => ["new device", "resub device"],
    :name => ["new name", "resub name"],
    :namedevice => ["new name & new device", "resub name & resub device"],
    :devicechange => ["new device change", "resub device change"],
    :namechange => ["new name change", "resub name change"],
    :namealt => ["new alternate name", "resub alternate name"]
  }
  
  def setup
    sub_types = []
    @expected = {}
    count = 100
    VALUES.each_key do |abbrev|
      sub_type = SubType.new(:abbrev => abbrev, :name => abbrev.to_s)
      sub_type.id = count
      sub_types << sub_type
      @expected[abbrev] = count
      count = count + 1
    end
    @typer = Oscar::Typer.new(sub_types)
  end

  VALUES.each_key do |abbrev|
    code = "def test_type_#{abbrev}() verify_typer(#{abbrev.inspect}) end" 
    module_eval(code)
  end
  
  def verify_typer(abbrev)
    new_val, resub_val = VALUES[abbrev]
    assert_equal [@expected[abbrev], false], @typer.find_type(new_val)
    assert_equal [@expected[abbrev], true], @typer.find_type(resub_val)
  end
end


