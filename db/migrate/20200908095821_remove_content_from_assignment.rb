class RemoveContentFromAssignment < ActiveRecord::Migration[6.0]
  def change
    remove_column :translation_assignments, :content, :string
  end
end
