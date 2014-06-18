RSpec::Matchers.define :have_account_display_records do |expected|
  match do |actual|
    hashes = actual.map { |r| { caption: r.caption, balance: r.balance.to_f } }
    expect(hashes).to eq(expected)
  end

  failure_message_for_should do |actual|
    "Expected\n#{make_readable(expected)}\n\ngot\n#{make_readable(actual)}"
  end

  def make_readable(values)
    if values.respond_to?(:join)
      values = values.map { |r| "#{r[:caption]} - #{r[:balance]}" }
    else
      values = values.map { |r| "#{r.caption} - #{r.balance}" }
    end
    values.join("\n")
  end
end
