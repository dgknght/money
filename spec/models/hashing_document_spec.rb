require 'spec_helper'

describe HashingDocument do
  it 'should be creatable with valid parameters' do
    doc = HashingDocument.new(->(data){}, "test")
    expect(doc).not_to be_nil
  end

  def parse(*element_names, xml)
    data = []
    doc = HashingDocument.new(->(datum){data<<datum}, *element_names)
    parser = Nokogiri::XML::SAX::Parser.new(doc)
    parser.parse(xml)
    data
  end

  it 'should notify on named elements' do
    data = parse("root", '<?xml version="1.0"?><root>This is a test</root>')
    expect(data).to have(1).item
    expect(data.first).to eq("This is a test")
  end

  it 'should include multiple lines of content' do
    data = parse("root", "<?xml version=\"1.0\"?><root>This is\na test</root>")
    expect(data).to have(1).item
    expect(data.first).to eq("This is\na test")
  end

  it 'should include inner elements in hash values' do
    data = parse("person", '<people><person><name>Doug</name><job>Programmer</job></person></people>')
    expect(data).to have(1).items
    expect(data.first).to eq({"name" => "Doug", "job" => "Programmer"})
  end
end
