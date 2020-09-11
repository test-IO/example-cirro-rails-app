class TranslationFile < ApplicationRecord
  mount_uploader :file, TranslationFileUploader
  belongs_to :translation_assignment
  has_one :translation_result

  validates :status, presence: true

  state_machine :status, initial: :available do
    event :pick do
      transition available: :in_progress
    end

    event :submit_for_review do
      transition in_progress: :waiting_for_review
    end
  end
end
