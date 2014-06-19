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
