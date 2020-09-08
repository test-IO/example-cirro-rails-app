class CreateTranslationFiles < ActiveRecord::Migration[6.0]
  def change
    create_table :translation_files do |t|
      t.string :file
      t.string :status
      t.references :translation_assignment

      t.timestamps
    end
  end
end
