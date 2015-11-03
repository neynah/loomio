class API::DraftsController < API::RestfulController

  alias :create :update

  private

  def load_resource
    self.resource = Draft.find_or_initialize_by(user: current_user, draftable: draftable)
  end

  def draftable
    (params[:group_id]      && load_and_authorize(:group, :add_discussion)) ||
    (params[:discussion_id] && load_and_authorize(:discussion, :add_comment)) ||
    (params[:motion_id]     && load_and_authorize(:motion, :vote))
  end

  def resource_params
    params.require(:draft)
  end

end
