class Admin::SharesController < Admin::ApplicationController
  before_action :set_share, only: [:show, :edit, :update, :destroy]

  def index
    @shares = Share.order("id desc")
    @shares = @shares.page(params[:page])
  end

  def destroy
    @share.destroy
    redirect_to admin_shares_path, notice: t(".Share was successfully deleted")
  end

  private

    def set_share
      @share = Share.find(params[:id])
    end

    def share_params
      params.require(:share).permit!
    end
end
