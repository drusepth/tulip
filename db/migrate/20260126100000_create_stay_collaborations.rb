class CreateStayCollaborations < ActiveRecord::Migration[8.0]
  def change
    create_table :stay_collaborations do |t|
      t.references :stay, null: false, foreign_key: true
      t.references :user, foreign_key: true # Can be null for pending invites
      t.string :role, null: false, default: 'editor'
      t.string :invite_token
      t.datetime :invite_accepted_at

      t.timestamps
    end

    add_index :stay_collaborations, [:stay_id, :user_id], unique: true, where: 'user_id IS NOT NULL'
    add_index :stay_collaborations, :invite_token, unique: true
  end
end
