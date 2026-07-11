class UserViewsController < ApplicationController
  before_action :set_user_view, only: [ :edit, :update, :destroy, :activate ]

  def index
    @user_views = Current.user.user_views.alphabetically
    render layout: "settings"
  end

  def new
    @user_view = Current.user.user_views.new
  end

  def create
    @user_view = Current.user.user_views.new(user_view_params)
    if @user_view.save
      session[:active_view_id] = @user_view.id
      redirect_to root_path, notice: t(".created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user_view.update(user_view_params)
      redirect_to user_views_path, notice: t(".updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:active_view_id) if session[:active_view_id] == @user_view.id
    @user_view.destroy
    redirect_to user_views_path, notice: t(".destroyed")
  end

  # POST /user_views/:id/activate — flip the session pointer and bounce to home.
  # Also handles the "clear filter" case via id = "all".
  def activate
    session[:active_view_id] = @user_view.id
    redirect_back_or_to root_path
  end

  # POST /user_views/clear — remove any active filter.
  def clear
    session.delete(:active_view_id)
    redirect_back_or_to root_path
  end

  private
    def set_user_view
      @user_view = Current.user.user_views.find(params[:id])
    end

    def user_view_params
      params.require(:user_view).permit(:name, account_ids: [], owner_ids: [])
    end
end
