class SearchVector < ActiveRecord::Base

  belongs_to :discussion, dependent: :destroy
  self.table_name = 'discussion_search_vectors'

  validates :discussion, presence: true
  validates :search_vector, presence: true

  scope :search_for, ->(query, user, opts = {}) do
    Queries::VisibleDiscussions.apply_privacy_sql(
      user: user,
      group_ids: user.cached_group_ids,
      relation: joins(discussion: :group).search_without_privacy!(query, user, opts)
    )
  end

  scope :search_without_privacy!, ->(query, user, opts = {}) do
    query = sanitize(query.to_s)
    self.select(:discussion_id, :search_vector, 'groups.full_name as result_group_name')
        .select("ts_rank_cd('{#{search_weights}}', search_vector, #{query_for(user, query)}) as rank")
        .where("search_vector @@ #{query_for(user, query)}")
        .order('rank DESC')
        .offset(opts.fetch(:from, 0))
        .limit(opts.fetch(:per, 10))
  end

  def self.search_weights
    SearchConstants::WEIGHT_VALUES.join(',')
  end

  def self.query_for(user, query, opts = {})
    "plainto_tsquery('#{SearchConstants::LOCALES.fetch(opts[:locale] || user.locale, 'english')}', #{query})"
  end

  class << self
    def index!(discussion_ids)
      Array(discussion_ids).map(&:to_i).uniq.tap do |ids|
        existing = where(discussion_id: ids)
        existing.map(&:update_search_vector)
        (ids - existing.map(&:discussion_id)).each { |discussion_id| new(discussion_id: discussion_id).update_search_vector }
      end
    end
    handle_asynchronously :index!
  end

  def self.index_everything!
    index_without_delay! Discussion.pluck(:id)
  end

  def update_search_vector
    tap { |search_vector| build_search_vector && save }
  end

  private

  def build_search_vector
    vector = self.class.connection.execute(vector_for_discussion.to_sql).first || {}
    self.search_vector = vector.fetch('search_vector', nil)
  end

  def vector_for_discussion
    Discussion.select(self.class.discussion_field_weights + ' as search_vector')
              .joins("LEFT JOIN (#{vector_for_motions.to_sql})  motions ON TRUE")
              .joins("LEFT JOIN (#{vector_for_comments.to_sql}) comments ON TRUE")
              .where(id: self.discussion_id)
  end

  def vector_for_motions
    Motion.select("string_agg(name, ',')                     AS motion_names")
          .select("LEFT(string_agg(description, ','), 10000) AS motion_descriptions")
          .where(discussion_id: self.discussion_id)
  end

  def vector_for_comments
    Comment.select("LEFT(string_agg(body, ','), 20000) AS comment_bodies")
           .where(discussion_id: self.discussion_id)
  end

  def self.discussion_field_weights
    SearchConstants::WEIGHTED_FIELDS.map { |field, weight| "setweight(to_tsvector(coalesce(#{field}, '')), '#{weight}')" }.join ' || '
  end

end
