class MakeCommentsPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Add polymorphic columns (skip if already present)
    unless column_exists?(:comments, :commentable_id)
      add_column :comments, :commentable_type, :string
      add_column :comments, :commentable_id, :bigint

      # Migrate existing data: all comments currently belong to stays
      if column_exists?(:comments, :stay_id)
        execute <<-SQL
          UPDATE comments SET commentable_type = 'Stay', commentable_id = stay_id
        SQL
      end

      # Make polymorphic columns non-null now that data is migrated
      change_column_null :comments, :commentable_type, false
      change_column_null :comments, :commentable_id, false

      # Add polymorphic index
      add_index :comments, [:commentable_type, :commentable_id, :created_at],
                name: "index_comments_on_commentable_and_created_at"
    end

    # Remove old stay-specific columns and indexes (skip if already removed)
    if column_exists?(:comments, :stay_id)
      remove_foreign_key :comments, :stays if foreign_key_exists?(:comments, :stays)
      remove_index :comments, name: "index_comments_on_stay_id_and_created_at", if_exists: true
      remove_index :comments, name: "index_comments_on_stay_id", if_exists: true
      remove_column :comments, :stay_id
    end
  end

  def down
    add_column :comments, :stay_id, :bigint

    execute <<-SQL
      UPDATE comments SET stay_id = commentable_id WHERE commentable_type = 'Stay'
    SQL

    # Remove place comments since they can't be represented in old schema
    execute <<-SQL
      DELETE FROM comments WHERE commentable_type != 'Stay'
    SQL

    change_column_null :comments, :stay_id, false
    add_foreign_key :comments, :stays
    add_index :comments, :stay_id
    add_index :comments, [:stay_id, :created_at]

    remove_index :comments, name: "index_comments_on_commentable_and_created_at"
    remove_column :comments, :commentable_type
    remove_column :comments, :commentable_id
  end
end
