class DraftSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :draftable_type, :draftable_id, :group_draft, :discussion_draft, :proposal_draft, :comment_draft, :vote_draft

  def group_draft
    object.payload['group_draft'] || {}
  end

  def discussion_draft
    object.payload['discussion_draft'] || {}
  end

  def proposal_draft
    object.payload['motion_draft'] || {}
  end

  def comment_draft
    object.payload['comment_draft'] || {}
  end

  def vote_draft
    object.payload['vote_draft'] || {}
  end

  def include_group_draft?
    object.draftable_type == "User"
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
