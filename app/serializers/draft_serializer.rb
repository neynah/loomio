class DraftSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :user_id, :draftable_type, :draftable_id, :discussion_draft, :proposal_draft, :comment_draft, :vote_draft

  def discussion_draft
    object.payload['discussion'] || {}
  end

  def proposal_draft
    object.payload['motion'] || {}
  end

  def comment_draft
    object.payload['comment'] || {}
  end

  def vote_draft
    object.payload['vote'] || {}
  end

  def include_discussion_draft?
    object.draftable_type == "Group"
  end

  def include_proposal_draft?
    object.draftable_type == "Discussion"
  end

  def include_comment_draft?
    object.draftable_type == "Discussion"
  end

  def include_vote_draft?
    object.draftable_type == "Motion"
  end

end
