class TranslationAssignment < ApplicationRecord
  has_many :translation_files
  accepts_nested_attributes_for :translation_files

  validates :title, presence: true
  validates :domain, presence: true
  validates :from_language, presence: true
  validates :to_language, presence: true

  attr_accessor :total_seats

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
    gig['total-seats'] = total_seats
    gig['automatic-invites'] = true
    gig.relationships['worker-invitation-filter'] = filter
    gig.save
  end
end
