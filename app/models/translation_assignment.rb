class TranslationAssignment < ApplicationRecord
  validates :title, presence: true
  validates :content, presence: true
  validates :domain, presence: true
  validates :from_language, presence: true
  validates :to_language, presence: true
  validates :invitation_start_time, presence: true
  validates :invitation_expiry_time, presence: true

  after_commit :create_gig, on: :create

  private

  def create_gig
    filter = CirroClient::WorkerInvitationFilter.new
    filter['filter-query'] = %Q({ "languages": { "$in": ["#{from_language}", "#{to_language}"] }, "domains": { "$in": ["#{domain}"] } })
    filter.save

    gig = CirroClient::Gig.new
    gig.title = title
    gig.description = description
    gig.url = 'http://blah'
    gig['invitation-start-time'] = invitation_start_time
    gig['invitation-expiry-time'] = invitation_expiry_time
    gig.relationships['worker-invitation-filter'] = filter
    gig.save
  end
end
