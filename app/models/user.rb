class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :stays, dependent: :destroy # Stays this user owns
  has_many :stay_collaborations, dependent: :destroy
  has_many :collaborated_stays, through: :stay_collaborations, source: :stay

  # All stays this user can access (owned + collaborated)
  # Returns an ActiveRecord::Relation for chainability
  def accessible_stays
    Stay.left_joins(:stay_collaborations)
        .where('stays.user_id = :user_id OR (stay_collaborations.user_id = :user_id AND stay_collaborations.invite_accepted_at IS NOT NULL)', user_id: id)
        .distinct
  end

  # Stays where user has edit permissions (owned or editor role)
  def editable_stays
    Stay.left_joins(:stay_collaborations)
        .where('stays.user_id = :user_id OR (stay_collaborations.user_id = :user_id AND stay_collaborations.role = :role AND stay_collaborations.invite_accepted_at IS NOT NULL)', user_id: id, role: 'editor')
        .distinct
  end
end
