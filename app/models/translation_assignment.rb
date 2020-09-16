class TranslationAssignment < ApplicationRecord
  has_many :translation_files
  accepts_nested_attributes_for :translation_files

  attr_accessor :total_seats

  after_commit :create_gig, on: :create

  validates :title, presence: true
  validates :domain, presence: true
  validates :from_language, presence: true
  validates :to_language, presence: true
  validates :status, presence: true

  state_machine :status, initial: :active do
    after_transition active: :archived do |assignment, _|
      assignment.translation_files.available.map(&:expire)
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

  private

  def create_gig
    filter = CirroClient::WorkerInvitationFilter.new
    filter['filter-query'] = %Q({ "languages": { "$in": ["#{from_language}", "#{to_language}"] }, "domains": { "$in": ["#{domain}"] } })
    filter.save

    gig = CirroClient::Gig.new
    gig.title = title
    gig.description = description
    gig.url = Rails.application.routes.url_helpers.translation_assignment_url(id, host: Settings.host)
    gig['total-seats'] = total_seats
    gig['automatic-invites'] = true
    gig.relationships['worker-invitation-filter'] = filter
    gig.save

    update_attribute(:gig_idx, gig.id)
  end
end
