require 'spec_helper'

describe HashingDocument do
  it 'is creatable with valid parameters' do
    doc = HashingDocument.new(->(data){}, "test")
    expect(doc).not_to be_nil
  end

  def parse(*element_names, xml)
    data = []
    doc = HashingDocument.new(->(name, datum){data<<[name, datum]}, *element_names)
    parser = Nokogiri::XML::SAX::Parser.new(doc)
    parser.parse(xml.strip)
    data
  end

  it 'notifies on named elements' do
    data = parse("root", '<?xml version="1.0"?><root>This is a test</root>')
    expect(data).to have(1).item
    expect(data.first).to eq(["root", "This is a test"])
  end

  it 'includes multiple lines of content' do
    data = parse("root", "<?xml version=\"1.0\"?><root>This is\na test</root>")
    expect(data).to have(1).item
    expect(data.first).to eq(["root", "This is\na test"])
  end

  it 'includes inner elements in hash values' do
    data = parse("person", '<people><person><name>Doug</name><job>Programmer</job></person></people>')
    expect(data).to have(1).items
    expect(data.first).to eq(["person", {"name" => "Doug", "job" => "Programmer"}])
  end

  it 'handles ampersands correctly' do
    xml = <<-eos
      <?xml version="1.0"?>
      <places>
        <place>Dave &amp; Busters</place>
        <place>Main Event</place>
      </places>
    eos
    data = parse("place", xml)
    expect(data).to have(2).item
    expect(data.first).to eq(["place", "Dave & Busters"])
  end

  it 'includes nested hashes for nested elements' do
    xml = <<-eos
      <?xml version="1.0"?>
      <people>
        <person>
          <name>Doug</name>
          <car>
            <make>Mazda</make>
            <model>Mazda 3</model>
          </car>
        </person>
      </people>
    eos
    data = parse("person", xml)
    expect(data).to have(1).item
    expect(data.first).to eq(["person", {"name" => "Doug", "car" => {"make" => "Mazda", "model" => "Mazda 3"}}])
  end

  it 'includes nested hashes for deeply nested elements' do
    xml = <<-eos
      <?xml version="1.0"?>
      <people>
        <person>
          <name>Doug</name>
          <transportation>
            <car>
              <make>Mazda</make>
              <model>Mazda 3</model>
            </car>
          </transportation>
        </person>
      </people>
    eos
    data = parse("person", xml)
    expect(data).to have(1).item
    expect(data.first).to eq(["person", {"name" => "Doug", "transportation" => {"car" => {"make" => "Mazda", "model" => "Mazda 3"}}}])
  end

  it 'puts multiple values with the same element name in an array' do
    xml = <<-eos
      <?xml version="1.0"?>
      <people>
        <person>
          <name>Doug</name>
          <car>Mazda 3</car>
          <car>Volkswagon Passat</car>
        </person>
        <person>
          <name>Eli</name>
        </person>
      </people>
    eos
    data = parse("person", xml)
    expect(data).to eq([["person", {"name" => "Doug", "car" => ["Mazda 3", "Volkswagon Passat"]}],
                        ["person", {"name" => "Eli"}]])
  end

  it 'puts multiple nested values with the same element name in an array' do
    xml = <<-eos
      <?xml version="1.0"?>
      <people>
        <person>
          <name>Doug</name>
          <cars>
            <car>Mazda 3</car>
            <car>Volkswagon Passat</car>
          </cars>
        </person>
        <person>
          <name>Eli</name>
        </person>
      </people>
    eos
    data = parse("person", xml)
    expect(data).to eq([["person", {"name" => "Doug", "cars" => {"car" => ["Mazda 3", "Volkswagon Passat"]}}],
                        ["person", {"name" => "Eli"}]])
  end
end
