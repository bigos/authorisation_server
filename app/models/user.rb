class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :access_grants, class_name: "Doorkeeper::AccessGrant",
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens, class_name: "Doorkeeper::AccessToken",
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  validate :user_has_downcased_email

  def user_has_downcased_email
    if email.downcase != email
      errors.add(:email, "You must use downcased email")
    end
  end

  def admin?
    admin_users = ['jacek.podkanski@conceptlifesciences.com',
                         'jon.adams@conceptlifesciences.com']

    admin = true if admin_users.select{ |ue| email == ue }.any?
    admin
  end
end
