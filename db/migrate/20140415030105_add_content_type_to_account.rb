class AddContentTypeToAccount < ActiveRecord::Migration
  def up
    add_column :accounts, :content_type, :string, limit: 20
    Account.connection.execute("update accounts set content_type = 'currency'")
    change_column :accounts, :content_type, :string, limit: 20, nil: false
  end

  def down
    remove_column :accounts, :content_type
  end
end
