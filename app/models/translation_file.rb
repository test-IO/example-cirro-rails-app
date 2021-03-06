class TranslationFile < ApplicationRecord
  mount_uploader :file, TranslationFileUploader
  belongs_to :translation_assignment
  has_one :translation_result

  validates :status, presence: true

  scope :for_user, ->(user) {
    includes(:translation_result).references(:translation_result).where("translation_files.status = 'available' OR translation_results.user_id = ?", user.id)
  }
  scope :available, -> { where(status: :available) }
  scope :in_progress, -> { where(status: :in_progress) }
  scope :pending_review, -> { where(status: :waiting_for_review) }


  state_machine :status, initial: :available do
    event :pick do
      transition available: :in_progress
    end

    event :submit_for_review do
      transition in_progress: :waiting_for_review
    end

    event :review do
      transition waiting_for_review: :reviewed
    end
    
    event :expire do
      transition available: :expired
    end
  end
end
