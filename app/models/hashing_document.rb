# SAX parsing document that returns XML contents in a ruby hash
class HashingDocument < Nokogiri::XML::SAX::Document
  class ElementContext
    attr_reader :parent
    attr_accessor :content

    def initialize(parent = nil)
      @parent = parent
    end

    def store_content(key)
      return unless @parent
      parent.put(key, value)
      self.content = nil
    end

    def put(key, value)
      values[key] = value
    end

    def value
      @values || content
    end

    private

    def values
      @values ||= HashWithIndifferentAccess.new
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
    return unless @storage

    @notify_method.call(@storage.value) if @element_names.include?(name)
    @storage.store_content(name)
    @storage = @storage.parent
  end
end
