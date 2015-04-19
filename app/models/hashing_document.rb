# SAX parsing document that returns XML contents in a ruby hash
class HashingDocument < Nokogiri::XML::SAX::Document
  def initialize(notify_method, *element_names)
    @notify_method = notify_method
    @element_names = element_names
  end

  def start_element(name, attrs=[])
    if @element_names.include?(name)
      @storage = HashWithIndifferentAccess.new
    end
  end

  def characters(value)
    @content = value
  end

  def end_element(name)
    if @element_names.include?(name)
      @notify_method.call(@storage.empty? ? @content : @storage)
      @storage = nil
    else
      @storage[name] = @content if @storage
    end
  end
end
