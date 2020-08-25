class AddCirroTokenToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :cirro_access_token, :string
  end
end
