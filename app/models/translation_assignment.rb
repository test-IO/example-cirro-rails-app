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
    gig = CirroClient::Gig.find(gig_idx).first
    results = translation_results.accepted

    results.map(&:user).uniq.each do |user|
      app_worker = CirroClient::AppWorker.new(id: user.uid)
      gig_time_activity = CirroClient::GigTimeActivity.new
      gig_time_activity.description = "translation ##{id}: #{from_language} > #{to_language}"
      gig_time_activity.date = Time.current
      gig_time_activity['duration-in-ms'] = results.select {|result| result.user_id == user.id}.map{|result| result.submitted_at - result.started_at }.sum * 1000

      gig_time_activity.relationships['gig'] = gig
      gig_time_activity.relationships['app-worker'] = app_worker

      gig_time_activity.save
    end

    gig.update_attributes('archive-at': Time.current)
  end

  private

  def create_gig_with_tasks_and_invitation_filter
    price_per_translation_result = 500
    payload = {
      data: {
        attributes: {
          title: title,
          description: description,
          url: Rails.application.routes.url_helpers.translation_assignment_url(id, host: Settings.host),
          total_seats: 10,
          automatic_invites: true,
          archive_at: 1.month.from_now,
        },
        relationships: {
          worker_invitation_filter: {
            filter_query: %Q({ "languages": { "$in": ["#{from_language}", "#{to_language}"] }, "domains": { "$in": ["#{domain}"] } })
          },
          gig_tasks: [
            { title: self.class.name, base_price: price_per_translation_result }
          ]
        }
      }
    }
    response = CirroClient::BulkActions::Gig.bulk_create(payload)

    update_attribute(:gig_idx, response['id']) if response.present?
  end
end
