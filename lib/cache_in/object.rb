class Object
  def memo_store
    @memo_store ||= {}
  end

  def self.memoize(method, ttl = nil)
    old_method = "orig_#{method}".to_sym
    alias_method old_method, method
    define_method method do |*args|
      key = "method_#{args.map(&:to_s).join("_")}"
      stored_value = memo_store[key]
      unless stored_value && stored_value[:expiration] > DateTime.now
        raw_result = send(old_method, *args)
        stored_value = {value: raw_result, expiration: DateTime.now + 5.minutes}
        memo_store[key] = stored_value
      end
      stored_value[:value]
    end
  end
end
