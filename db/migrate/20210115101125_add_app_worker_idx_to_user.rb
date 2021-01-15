class AddAppWorkerIdxToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :app_worker_idx, :string
  end
end
