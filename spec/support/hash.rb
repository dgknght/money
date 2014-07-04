class Hash
  def get_date(key)
    value = self[key]
    return nil unless value
    return value.to_date if value.respond_to?(:to_date)
    Date.parse(value)
  end

  def without(keys)
    keys = [keys] unless keys.respond_to?(:include?)
    reject { |k, v| keys.include?(k) }
  end

  def only(keys)
    keys = [keys] unless keys.respond_to?(:include?)
    select { |k, v| keys.include?(k) }
  end

  def has_only?(*keys)
    self.keys.sort == keys.sort
  end
end
