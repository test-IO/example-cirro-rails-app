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

  def update_cirro_access_token(auth)
    update(cirro_access_token: auth.credentials.token)
  end

  private

  def create_or_update_app_worker
    return if (previous_changes.keys & ['languages', 'domains']).empty?

    worker_document = { 'languages' => languages, 'domains' => domains }
    CIRRO_V2_CLIENT.User.worker(uid, {document: worker_document})
  end
end
