class TranslationResult < ApplicationRecord
  mount_uploader :file, TranslationFileUploader
  belongs_to :translation_file
  belongs_to :user
  has_one :translation_assignment, through: :translation_file

  validates :status, :started_at, presence: true

  scope :started, -> { where(status: 'started') }

  state_machine :status, initial: :started do
    before_transition started: :submitted do |translation_result, _|
      translation_result.submitted_at = Time.current
    end
    after_transition submitted: [:accepted, :rejected] do |translation_result, _|
      translation_result.translation_file.review!
    end

    after_transition submitted: :accepted do |translation_result, _|
      translation_result.send_time_activity_to_cirro
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

    state :submitted do
      validates_presence_of :file
      validates_presence_of :submitted_at
    end
  end

  def send_time_activity_to_cirro
    app_worker = CirroClient::AppWorker.new(id: user.uid)
    gig = CirroClient::Gig.new(id: translation_assignment.gig_idx)

    gig_time_activity = CirroClient::GigTimeActivity.new
    gig_time_activity.description = "translation ##{translation_assignment.id} - #{File.basename(translation_file.file.path)} - (#{translation_assignment.from_language}>#{translation_assignment.to_language})"
    gig_time_activity.date = Time.current
    gig_time_activity['duration-in-ms'] = (submitted_at-started_at) * 1000

    gig_time_activity.relationships['gig'] = gig
    gig_time_activity.relationships['app-worker'] = app_worker

    gig_time_activity.save
  end
end
