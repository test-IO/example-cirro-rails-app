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

  def archive_gig
    gig = CirroIO::Client::Gig.includes('gig_tasks').find(gig_idx).first
    results = translation_results.accepted

    gig_results = results.map(&:user).uniq.map do |user|
      CirroIO::Client::GigResult.new(app_worker: CirroIO::Client::AppWorker.new(id: user.app_worker_idx),
                                     title: "translation ##{id}",
                                     gig_task: gig.gig_tasks.first,
                                     description: "Language: #{from_language} > #{to_language}",
                                     quantity: results.select {|result| result.user_id == user.id}.count)
    end

    gig_time_activities = results.map(&:user).uniq.map do |user|
      CirroIO::Client::GigTimeActivity.new(app_worker: CirroIO::Client::AppWorker.new(id: user.app_worker_idx),
                                           description: "translation ##{id}: #{from_language} > #{to_language}",
                                           date: Time.current,
                                           duration_in_ms: results.select {|result| result.user_id == user.id}.map{|result| result.submitted_at - result.started_at }.sum * 1000)
    end

    gig.bulk_archive_with(gig_results, gig_time_activities)
  end

  private

  def create_gig_with_tasks_and_invitation_filter
    price_per_translation_result = 500
    worker_invitation_filter = CirroIO::Client::WorkerInvitationFilter.new(filter_query: %Q({ "languages": { "$in": ["#{from_language}", "#{to_language}"] }, "domains": { "$in": ["#{domain}"] } }))
    task = CirroIO::Client::GigTask.new(title: self.class.name, base_price: price_per_translation_result)

    gig = CirroIO::Client::Gig.new(title: title,
                                   description: description,
                                   total_seats: 10,
                                   automatic_invites: true,
                                   archive_at: 1.month.from_now,
                                   url: Rails.application.routes.url_helpers.translation_assignment_url(id, host: Settings.host)
                                  )

    created_gig = gig.bulk_create_with(worker_invitation_filter, [task])

    update_attribute(:gig_idx, created_gig.id)
  end
end
