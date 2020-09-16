class AddStatusToAssignment < ActiveRecord::Migration[6.0]
  def change
    add_column :translation_assignments, :status, :string

    execute "UPDATE translation_assignments SET status = 'active'"
  end
end
