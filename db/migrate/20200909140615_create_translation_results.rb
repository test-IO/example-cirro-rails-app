class CreateTranslationResults < ActiveRecord::Migration[6.0]
  def change
    create_table :translation_results do |t|
      t.string :file
      t.references :translation_file, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :started_at
      t.datetime :submitted_at
      t.string :status

      t.timestamps
    end
  end
end
