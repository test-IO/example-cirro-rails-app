class AddScreennameToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :screenname, :string
  end
end
