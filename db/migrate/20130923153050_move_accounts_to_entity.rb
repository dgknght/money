class MoveAccountsToEntity < ActiveRecord::Migration
  def up
    # add entity_id columns
    add_column :accounts, :entity_id, :integer
    add_column :transactions, :entity_id, :integer
    
    # create default entities for each user and transfer user_id to entity_id
    User.all.each do |user|
      entity = user.entities.create!(name: 'Default')
      User.connection.execute("update accounts set entity_id = #{entity.id} where user_id = #{user.id}")
      User.connection.execute("update transactions set entity_id = #{entity.id} where user_id = #{user.id}")
    end
    
    # add non-null constraint to entity_id column
    change_column_null :accounts, :entity_id, false
    change_column_null :transactions, :entity_id, false
    
    # remove user_id column
    remove_column :accounts, :user_id
    remove_column :transactions, :user_id
  end

  def down
    # create user_id column
    add_column :accounts, :user_id, :integer
    add_column :transactions, :user_id, :integer
    
    # transfer all entity_id to user_id
    Entity.all.each do |entity|
      Entity.connection.execute("update accounts set user_id = #{entity.user_id} where entity_id = #{entity.id}")
      Entity.connection.execute("update transactions set user_id = #{entity.user_id} where entity_id = #{entity.id}")
    end
    
    # add non-null constraint to user_id column
    change_column_null :accounts, :user_id, false
    change_column_null :transactions, :user_id, false
    
    # remove entity_id column
    remove_column :accounts, :entity_id
    remove_column :transactions, :entity_id
  end
end
