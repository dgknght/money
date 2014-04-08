class Hash
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
