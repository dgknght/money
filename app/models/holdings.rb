# Summarizes the current holdings in a commodity account
class Holdings
  include Enumerable

  def each
    []
  end

  def initialize(options = {})
    options = (options || {}).with_indifferent_access
    @account = options[:account]
    raise 'account must be specified' unless @account
  end
end
