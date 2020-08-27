class AddLanguagesAndDomainsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :languages, :string
    add_column :users, :domains, :string
  end
end
