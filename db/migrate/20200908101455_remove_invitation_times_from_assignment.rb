class RemoveInvitationTimesFromAssignment < ActiveRecord::Migration[6.0]
  def change
    remove_column :translation_assignments, :invitation_start_time
    remove_column :translation_assignments, :invitation_expiry_time
  end
end
