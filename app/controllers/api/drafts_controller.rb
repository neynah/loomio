class API::DraftsController < API::RestfulController

  def show
    load_resource
    respond_with_resource
  end

  alias :create :update

  private

  def load_resource
    self.resource = Draft.find_or_initialize_by(user: current_user, draftable: draftable)
  end

  def draftable
    return unless ['group', 'discussion', 'motion'].include? resource_params[:draftable_type]
    @draftable ||= resource_params[:draftable_type].classify.constantize.find(params[:draftable_id])
  end

  def resource_params
    params.require(:draft)
  end

end
