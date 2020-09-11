class TranslationResult < ApplicationRecord
  mount_uploader :file, TranslationFileUploader
  belongs_to :translation_file
  belongs_to :user
  has_one :translation_assignment, through: :translation_file

  validates :status, :started_at, presence: true

  state_machine :status, initial: :started do
    before_transition started: :submittes do |translation_result, _|
      translation_result.submitted_at = Time.current
    end

    state :submitted do
      validate { |translation| translation.file.present? && translation.submitted_at.present? }
    end

    event :submit do
      transition started: :submitted
    end
  end
end
