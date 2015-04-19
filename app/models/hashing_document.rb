# SAX parsing document that returns XML contents in a ruby hash
class HashingDocument < Nokogiri::XML::SAX::Document
  class ElementContext
    attr_reader :parent
    attr_accessor :content
    def initialize(parent = nil)
      @parent = parent
    end
    def store_content(key)
      @values ||= HashWithIndifferentAccess.new
      @values[key] = content
      self.content = nil
    end
    def value
      @values || content
    end
  end

  def initialize(notify_method, *element_names)
    @notify_method = notify_method
    @element_names = element_names
  end

  def start_element(name, attrs=[])
    if @storage
      @storage = ElementContext.new(@storage)
    elsif @element_names.include?(name)
      @storage = ElementContext.new
    end
  end

  def characters(value)
    @storage.content = value if @storage
  end

  def end_element(name)
    if @element_names.include?(name)
      @notify_method.call(@storage.value)
      @storage = @storage.parent
    else
      @storage.store_content(name) if @storage
    end
  end
end
