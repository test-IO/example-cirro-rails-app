class AddLanguagesAndDomainsToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :languages, :text
    add_column :users, :domains, :text
  end
end
