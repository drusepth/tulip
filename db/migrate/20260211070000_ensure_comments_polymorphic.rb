class EnsureCommentsPolymorphic < ActiveRecord::Migration[8.0]
  def up
    # Safety-net migration: ensures the polymorphic columns exist even if
    # the original migration (20260211060000) was recorded as "up" in
    # schema_migrations without the DDL changes actually being applied.

    unless column_exists?(:comments, :commentable_id)
      add_column :comments, :commentable_type, :string
      add_column :comments, :commentable_id, :bigint

      if column_exists?(:comments, :stay_id)
        execute <<-SQL
          UPDATE comments SET commentable_type = 'Stay', commentable_id = stay_id
        SQL
      end

      change_column_null :comments, :commentable_type, false
      change_column_null :comments, :commentable_id, false

      unless index_exists?(:comments, [:commentable_type, :commentable_id, :created_at], name: "index_comments_on_commentable_and_created_at")
        add_index :comments, [:commentable_type, :commentable_id, :created_at],
                  name: "index_comments_on_commentable_and_created_at"
      end
    end

    if column_exists?(:comments, :stay_id)
      remove_foreign_key :comments, :stays if foreign_key_exists?(:comments, :stays)
      remove_index :comments, name: "index_comments_on_stay_id_and_created_at", if_exists: true
      remove_index :comments, name: "index_comments_on_stay_id", if_exists: true
      remove_column :comments, :stay_id
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
