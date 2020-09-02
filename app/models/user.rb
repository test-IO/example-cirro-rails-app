class User < ApplicationRecord
  serialize :languages
  serialize :domains
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :omniauthable, omniauth_providers: %i[cirro]

  after_commit :update_app_worker, on: :update

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def update_cirro_access_token(auth)
    update(cirro_access_token: auth.credentials.token)
  end

  private

  def update_app_worker
    app_worker = CirroClient::AppWorker.find(uid).first
    worker_document = app_worker['worker-document'].dup
    worker_document['languages'] = languages
    worker_document['domains'] = domains
    worker_document.delete('updated_at')
    app_worker.update_attributes('worker-document': worker_document)
  end
end
