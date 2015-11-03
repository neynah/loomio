require 'rails_helper'
describe API::DraftsController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create :group }
  let(:another_group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:motion) { create :motion, discussion: discussion }

  let(:group_draft) { create :draft, user: user, draftable: group }
  let(:discussion_draft) { create :draft, user: user, draftable: discussion }
  let(:motion_draft) { create :draft, user: user, draftable: motion }

  let(:group_draft_params) {{
    discussion: {
      title: 'Draft discussion title',
      description: 'Draft discussion description'
    }
  }}
  let(:discussion_draft_params) {{
    motion: {
      name: 'Draft motion name',
      description: 'Draft motion description'
    },
    comment: {
      body: 'Draft comment body'
    }
  }}
  let(:motion_draft_params) {{
    vote: {
      statement: 'Draft vote statement'
    }
  }}

  before do
    sign_in user
    group.members << user
  end

  describe 'create' do
    it 'creates a new group draft' do
      post :create, draft: group_draft_params, group_id: group.id
      expect(response.status).to eq 200

      draft = Draft.last
      expect(draft.draftable).to eq group
      expect(draft.user).to eq user
      expect(draft.payload['discussion']['title']).to eq group_draft_params[:discussion][:title]
      expect(draft.payload['discussion']['description']).to eq group_draft_params[:discussion][:description]

      json = JSON.parse(response.body)
      expect(json['drafts'][0]['discussion_draft']['title']).to eq group_draft_params[:discussion][:title]
      expect(json['drafts'][0]['discussion_draft']['description']).to eq group_draft_params[:discussion][:description]
    end

    it 'creates a new discussion draft' do
      post :create, draft: discussion_draft_params, discussion_id: discussion.id
      expect(response.status).to eq 200

      draft = Draft.last
      expect(draft.draftable).to eq discussion
      expect(draft.user).to eq user
      expect(draft.payload['motion']['name']).to eq discussion_draft_params[:motion][:name]
      expect(draft.payload['motion']['description']).to eq discussion_draft_params[:motion][:description]
      expect(draft.payload['comment']['body']).to eq discussion_draft_params[:comment][:body]

      json = JSON.parse(response.body)
      expect(json['drafts'][0]['proposal_draft']['name']).to eq discussion_draft_params[:motion][:name]
      expect(json['drafts'][0]['proposal_draft']['description']).to eq discussion_draft_params[:motion][:description]
      expect(json['drafts'][0]['comment_draft']['body']).to eq discussion_draft_params[:comment][:body]
    end

    it 'creates a new motion draft' do
      post :create, draft: motion_draft_params, motion_id: motion.id
      expect(response.status).to eq 200

      draft = Draft.last
      expect(draft.draftable).to eq motion
      expect(draft.user).to eq user
      expect(draft.payload['vote']['statement']).to eq motion_draft_params[:vote][:statement]

      json = JSON.parse(response.body)
      expect(json['drafts'][0]['vote_draft']['statement']).to eq motion_draft_params[:vote][:statement]
    end

    it 'overwrites a group draft' do
      group_draft
      post :create, draft: group_draft_params, group_id: group.id
      expect(response.status).to eq 200

      group_draft.reload
      expect(group_draft.draftable).to eq group
      expect(group_draft.user).to eq user
      expect(group_draft.payload['discussion']['title']).to eq group_draft_params[:discussion][:title]
      expect(group_draft.payload['discussion']['description']).to eq group_draft_params[:discussion][:description]

      json = JSON.parse(response.body)
      expect(json['drafts'][0]['discussion_draft']['title']).to eq group_draft_params[:discussion][:title]
      expect(json['drafts'][0]['discussion_draft']['description']).to eq group_draft_params[:discussion][:description]
    end

    it 'overwrites a discussion draft' do
      discussion_draft
      post :create, draft: discussion_draft_params, discussion_id: discussion.id
      expect(response.status).to eq 200

      discussion_draft.reload
      expect(discussion_draft.draftable).to eq discussion
      expect(discussion_draft.user).to eq user
      expect(discussion_draft.payload['motion']['name']).to eq discussion_draft_params[:motion][:name]
      expect(discussion_draft.payload['motion']['description']).to eq discussion_draft_params[:motion][:description]
      expect(discussion_draft.payload['comment']['body']).to eq discussion_draft_params[:comment][:body]

      json = JSON.parse(response.body)
      expect(json['drafts'][0]['proposal_draft']['name']).to eq discussion_draft_params[:motion][:name]
      expect(json['drafts'][0]['proposal_draft']['description']).to eq discussion_draft_params[:motion][:description]
      expect(json['drafts'][0]['comment_draft']['body']).to eq discussion_draft_params[:comment][:body]
    end

    it 'overwrites a motion draft' do
      motion_draft
      post :create, draft: motion_draft_params, motion_id: motion.id
      expect(response.status).to eq 200

      motion_draft.reload
      expect(motion_draft.draftable).to eq motion
      expect(motion_draft.user).to eq user
      expect(motion_draft.payload['vote']['statement']).to eq motion_draft_params[:vote][:statement]

      json = JSON.parse(response.body)
      expect(json['drafts'][0]['vote_draft']['statement']).to eq motion_draft_params[:vote][:statement]
    end

    it 'cannot access a group the user does not have access to' do
      expect { post :create, draft: group_draft_params, group_id: another_group.id }.not_to change { Draft.count }
      expect(response.status).to eq 403      
    end
  end

  describe 'destroy' do
    it 'destroys a group draft' do
      group_draft
      expect { delete :destroy, group_id: group.id }.to change { Draft.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'destroys a discussion draft' do
      discussion_draft
      expect { delete :destroy, discussion_id: discussion.id }.to change { Draft.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'destroys a motion draft' do
      motion_draft
      expect { delete :destroy, motion_id: motion.id }.to change { Draft.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'doesnt destroy random stuff' do
      discussion_draft
      expect { delete :destroy }.not_to change { Draft.count }
    end

    it 'doesnt destroy stuff the user does not have access to' do
      expect { delete :destroy, group_id: another_group.id }.not_to change { Draft.count }
      expect(response.status).to eq 403
    end
  end
end
