class AllowNullBodyOnComments < ActiveRecord::Migration[8.0]
  def change
    change_column_null :comments, :body, true
  end
end
