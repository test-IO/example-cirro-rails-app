class AddGigIdxToAssignment < ActiveRecord::Migration[6.0]
  def change
    add_column :translation_assignments, :gig_idx, :integer
  end
end
