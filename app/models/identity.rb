class Identity < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider

  def self.find_for_oauth(auth)
    where(uid: auth.uid, provider: auth.provider).first_or_create do |i|
      i.uid = auth.uid
      i.provider = auth.provider
      i.email = auth.info.email
    end
  end
end
