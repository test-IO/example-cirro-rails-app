class TranslationFile < ApplicationRecord
  mount_uploader :file, TranslationFileUploader
  belongs_to :translation_assignment

  validates :status, presence: true

  state_machine :status, initial: :available do
    event :pick do
      transition available: :in_progress
    end
  end
end
