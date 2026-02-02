class AllowNullDatesOnStays < ActiveRecord::Migration[8.0]
  def change
    change_column_null :stays, :check_in, true
    change_column_null :stays, :check_out, true
  end
end
