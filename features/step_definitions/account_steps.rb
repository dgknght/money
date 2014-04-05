Given(/^(#{ENTITY}) has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of (#{DOLLAR_AMOUNT}))?$/) do |entity, type, path, balance|
  names = path.split(/\//)
  parent_chain = ensure_accounts(names.take(names.length - 1), type, entity)
  parent_id = parent_chain.any? ? parent_chain.last.id : nil
  entity.accounts.find_by_name(names.last) || entity.accounts.create!(name: names.last, account_type: type, parent_id: parent_id, balance: balance || 0)
end

Given(/^(#{USER}) has an? (liability|asset|equity|income|expense) account named "([^"]+)"(?: with a balance of (#{DOLLAR_AMOUNT}))?$/) do |user, type, name, balance|
  entity = user.entities.first
  entity.should_not be_nil
  typed_balance = balance.nil? ? 0 : BigDecimal.new(balance)
  entity.accounts.find_by_name(name) || entity.accounts.create!(name: name, account_type: type, balance: typed_balance)
end

Given(/^(#{ENTITY}) has the following accounts$/) do |entity, table|
  table.hashes.each do |row|
    FactoryGirl.create(:account,  entity: entity,
                                  account_type: row['Account type'],
                                  name: row['Name'],
                                  content_type: row['Equity'])
  end
end
