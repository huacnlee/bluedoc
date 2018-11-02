class GroupMembersController < Groups::ApplicationController
  before_action :set_group
  before_action :set_member, only: [:edit, :update, :destroy]

  def index
    authorize! :read, @group

    @members = @group.members.includes(user: { avatar_attachment: :blob }).order("id asc").page(params[:page]).per(20)
  end

  def create
    authorize! :manage, @group

    user = User.where(type: "User").find_by_slug(member_params[:user_slug])
    if user.blank?
      redirect_to group_members_path(@group), alert: "User #{member_params[:user_slug]} not exists"
      return
    end

    @group.add_member(user, member_params[:role])
    redirect_to group_members_path(@group), notice: "User has added as member"
  end

  def update
    authorize! :manage, @group

    @member.update(member_params)
    redirect_to group_members_path(@group), notice: "Member has update successed"
  end

  def destroy
    authorize! :manage, @group

    @member.destroy
    redirect_to group_members_path(@group), notice: "Member has remove successed"
  end

  private

    def member_params
      params.require(:member).permit(:user_slug, :role)
    end

    def set_member
      @member = Member.find(params[:id])
    end
end