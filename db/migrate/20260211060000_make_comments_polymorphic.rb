class MakeCommentsPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Add polymorphic columns
    add_column :comments, :commentable_type, :string
    add_column :comments, :commentable_id, :integer

    # Migrate existing data: all comments currently belong to stays
    execute <<-SQL
      UPDATE comments SET commentable_type = 'Stay', commentable_id = stay_id
    SQL

    # Make polymorphic columns non-null now that data is migrated
    change_column_null :comments, :commentable_type, false
    change_column_null :comments, :commentable_id, false

    # Add polymorphic index
    add_index :comments, [:commentable_type, :commentable_id, :created_at],
              name: "index_comments_on_commentable_and_created_at"

    # Remove old stay-specific columns and indexes
    remove_index :comments, name: "index_comments_on_stay_id_and_created_at"
    remove_index :comments, name: "index_comments_on_stay_id"
    remove_column :comments, :stay_id
  end

  def down
    add_column :comments, :stay_id, :integer

    execute <<-SQL
      UPDATE comments SET stay_id = commentable_id WHERE commentable_type = 'Stay'
    SQL

    # Remove place comments since they can't be represented in old schema
    execute <<-SQL
      DELETE FROM comments WHERE commentable_type != 'Stay'
    SQL

    change_column_null :comments, :stay_id, false
    add_index :comments, :stay_id
    add_index :comments, [:stay_id, :created_at]

    remove_index :comments, name: "index_comments_on_commentable_and_created_at"
    remove_column :comments, :commentable_type
    remove_column :comments, :commentable_id
  end
end
