class SearchedGridCell < ApplicationRecord
  STALE_AFTER = 1.week

  validates :grid_key, presence: true, uniqueness: true
  validates :category, presence: true
  validates :searched_at, presence: true

  scope :for_grid, ->(key) { where(grid_key: key) }
  scope :fresh, -> { where("searched_at > ?", STALE_AFTER.ago) }
  scope :stale, -> { where("searched_at <= ?", STALE_AFTER.ago) }

  class << self
    def fresh_cache?(grid_key)
      for_grid(grid_key).fresh.exists?
    end

    def mark_searched!(grid_key, category:)
      record = find_or_initialize_by(grid_key: grid_key)
      record.category = category
      record.searched_at = Time.current
      record.save!
      record
    end
  end

  def stale?
    searched_at < STALE_AFTER.ago
  end
end
