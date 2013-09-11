require 'spec_helper'

describe Account do
  let(:attributes) do
    {
      :name => 'Cash',
      :account_type => Account.asset
    }
  end
  
  it 'should be creatable from valid attributes' do
    account = Account.new(attributes)
    account.should be_valid
  end
end