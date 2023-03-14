class TranslationAssignment < ApplicationRecord
  has_many :translation_files
  has_many :translation_results, through: :translation_files

  accepts_nested_attributes_for :translation_files

  attr_accessor :total_seats

  after_commit :create_gig_with_tasks_and_invitation_filter, on: :create

  validates :title, presence: true
  validates :domain, presence: true
  validates :from_language, presence: true
  validates :to_language, presence: true
  validates :status, presence: true

  state_machine :status, initial: :active do
    after_transition active: :archived do |assignment, _|
      assignment.translation_files.available.map(&:expire)
      assignment.archive_gig
    end

    state :archived do
      validate { |assignment| assignment.archivable? }
    end

    event :archive do
      transition active: :archived
    end
  end

  def archivable?
    translation_files.in_progress.empty? && translation_files.pending_review.empty?
  end

  def title_with_id
    "##{id} #{title}"
  end

  # In a real application interaction with cirro should be happening inside a background job
  def archive_gig
    # Normally we would store the gig task's id
    # so that we don't need to fetch the gig here
    gig = CIRRO_V2_CLIENT.Gig.find(gig_idx)
    task = gig.tasks.data.first
    results = translation_results.accepted

    gig_results = results.group_by(&:user).map do |user, res|
      CIRRO_V2_CLIENT.GigResult.create(gig_task_id: task.id,
                                       user_id: user.uid,
                                       title: "translation ##{id}",
                                       description: "Language: #{from_language} > #{to_language}",
                                       quantity: res.count,
                                       delivery_date: res.first.submitted_at,
                                       cost_center_key: 'EPMCIR') # epam project code to which the cost is booked
    end

    gig_time_activities = results.group_by(&:user).map do |user, res|
      CIRRO_V2_CLIENT.GigTimeActivity.create(gig_id: gig.id,
                                             user_id: user.uid,
                                             date: Time.current,
                                             description: "translation ##{id}: #{from_language} > #{to_language}",
                                             duration_in_ms: res.map { |result| result.submitted_at - result.started_at }.sum * 1000) # need to split it into different days
    end

    CIRRO_V2_CLIENT.Gig.archive(gig_idx)
  end

  private

  def create_gig_with_tasks_and_invitation_filter
    price_per_translation_result = 500

    created_gig = CIRRO_V2_CLIENT.Gig.create(
      title: title,
      description: description,
      seats_min: 10,
      invitation_mode: 'auto',
      archive_at: 1.month.from_now,
      start_at: Time.current,
      end_at: 1.week.from_now,
      url: Rails.application.routes.url_helpers.translation_assignment_url(id, host: Settings.host),
      filter_query: {
        languages: {
          '$in': [from_language, to_language]
        },
        domains: [domain]
      },
      tasks: [
        { title: self.class.name, base_price: price_per_translation_result }
      ]
    )

    update_attribute(:gig_idx, created_gig.id)
  end
end
