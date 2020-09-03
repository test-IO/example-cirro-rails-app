class CreateTranslationAssignment < ActiveRecord::Migration[6.0]
  def change
    create_table :translation_assignments do |t|
      t.string :title
      t.text :description
      t.text :content
      t.string :domain
      t.string :from_language
      t.string :to_language
      t.datetime :invitation_start_time
      t.datetime :invitation_expiry_time
      t.timestamps null: false
    end
  end
end
