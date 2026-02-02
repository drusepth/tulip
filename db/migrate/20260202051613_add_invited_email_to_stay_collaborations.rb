class AddInvitedEmailToStayCollaborations < ActiveRecord::Migration[8.0]
  def change
    add_column :stay_collaborations, :invited_email, :string
    add_index :stay_collaborations, :invited_email
  end
end
