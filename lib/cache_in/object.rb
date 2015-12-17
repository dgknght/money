class Object

  DEFAULT_MEMOIZE_OPTIONS = {ttl: 15.minutes}

  def memo_store
    @memo_store ||= {}
  end

  class << self
    def memoize(methods, options = {})
      options = DEFAULT_MEMOIZE_OPTIONS.merge(options || {})
      Array(methods).each{|m| _memoize m, options}
    end

    def _memoize(method, options)
      old_method = "orig_#{method}".to_sym
      alias_method old_method, method
      define_method method do |*args|
        key = "#{method}_#{args.map(&:to_s).join("_")}"
        stored_value = memo_store[key]
        unless stored_value && stored_value[:expiration] > DateTime.now
          raw_result = send(old_method, *args)
          stored_value = {value: raw_result, expiration: DateTime.now + options[:ttl]}
          memo_store[key] = stored_value
        end
        stored_value[:value]
      end
    end
    private :_memoize
  end
end
