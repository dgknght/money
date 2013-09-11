class Hash
  def without(key)
    reject { |k, v| k == key }
  end
end