class User < ApplicationRecord
  serialize :languages
  serialize :domains

  has_many :translation_results

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :omniauthable, omniauth_providers: %i[cirro]

  validates :screenname, presence: true

  after_commit :create_or_update_app_worker, on: :update

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.screenname = auth.info.screenname
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def update_cirro_access_token(auth)
    update(cirro_access_token: auth.credentials.token)
  end

  private

  def create_or_update_app_worker
    return if (previous_changes.keys & ['languages', 'domains']).empty?

    app_user = CirroIO::Client::AppUser.includes(:app_worker).find(uid).first

    if app_user.app_worker.nil?
      app_worker = CirroIO::Client::AppWorker.create(relationships: { app_user: app_user },
                                                     worker_document: { 'languages' => languages, 'domains' => domains })
    else
      app_worker = app_user.app_worker
      worker_document = app_worker.worker_document.dup
      worker_document['languages'] = languages
      worker_document['domains'] = domains
      worker_document.delete('updated_at')
      app_worker.update_attributes(worker_document: worker_document)
    end

    self.update(app_worker_idx: app_worker.id)
  end
end
