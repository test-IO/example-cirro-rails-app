class TranslationResult < ApplicationRecord
  mount_uploader :file, TranslationFileUploader
  belongs_to :translation_file
  belongs_to :user
  has_one :translation_assignment, through: :translation_file

  validates :status, :started_at, presence: true

  state_machine :status, initial: :started do
    before_transition started: :submitted do |translation_result, _|
      translation_result.submitted_at = Time.current
    end
    after_transition submitted: [:accepted, :rejected] do |translation_result, _|
      translation_result.translation_file.review!
    end

    state :submitted do
      validate { |translation| translation.file.present? && translation.submitted_at.present? }
    end

    event :submit do
      transition started: :submitted
    end

    event :accept do
      transition submitted: :accepted
    end

    event :reject do
      transition submitted: :rejected
    end
  end
end
