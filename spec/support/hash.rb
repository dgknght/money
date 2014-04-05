class Hash
  def without(keys)
    keys = [keys] unless keys.respond_to?(:include?)
    reject { |k, v| keys.includle?(k) }
  end

  def only(keys)
    keys = [keys] unless keys.respond_to?(:include?)
    select { |k, v| keys.include?(k) }
  end
end
