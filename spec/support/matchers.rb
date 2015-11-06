RSpec::Matchers.define :have_account_display_records do |expected|
  match do |actual|
    hashes = actual.map { |r| to_hash(r) }
    expect(hashes).to eq(expected)
  end

  failure_message_for_should do |actual|
    "Expected\n#{make_readable(expected)}\n\ngot\n#{make_readable(actual)}"
  end

  def make_readable(values)
    if values.respond_to?(:join)
      values = values.map { |r| readable_hash(r) }
    else
      values = values.map { |r| readable_record(r) }
    end
    values.join("\n")
  end

  def readable_hash(hash)
    "#{hash[:caption]} - #{hash[:balance]} - #{hash[:depth]}"
  end

  def readable_record(record)
    "#{record.caption} - #{record.balance} - #{record.depth}"
  end

  def to_hash(record)
    {
      caption: record.caption,
      balance: record.balance,
      depth: record.depth
    }
  end
end

RSpec::Matchers.define :include_account_display_record do |expected|
  match do |actual|
    actual.any? do |record|
      expected.all?{|k,v| record.send(k) == v}
    end
  end
end

RSpec::Matchers.define :json_match do |expected|

  # expect(this_result_from_the_service).to json_match(this_model)

  # Currently, this will not distinguish between a single return value and an array return value with a single element 
  match do |actual|
    diff = difference(actual)
    diff.length == 0
  end

  failure_message do |actual|
    "expected #{json_to_comparable(actual)} to match #{active_record_to_comparable(expected)}, but they differed as follows: #{difference(actual)}"
  end

  failure_message_when_negated do |actual|
    "expected #{json_to_comparable(actual)} not to match #{active_record_to_comparable(expected)}, but they are the same"
  end

  def difference(actual)
    actual = json_to_comparable(actual)
    expected = active_record_to_comparable(expected)
    expected.each_with_index do |e, index|
      a = actual[index]
      [
        e - a,
        a - e,
        e & a
      ]
    end.reject{|a| a.first.length == 0 && a.second.length == 0}
  end

  def active_record_to_comparable(record)
    Array(record).map(&:serializable_hash)
  end

  def json_to_comparable(json)
    Array(JSON.parse(actual))
  end
end
