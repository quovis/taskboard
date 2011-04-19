class ResetPasswordRequestsController < ApplicationController
  layout "reset_password"
  before_filter :require_no_user, :only => [:create, :new, :edit, :update]

  def new

  end

  def create
    @user = User.find_by_email params[:email]
    @user.send_password_reset_information if @user.present?
    # note: if user does not exist, view that says "password request sent" is displayed anyways for security reasons!
  end

  def edit
    @user = User.find_by_perishable_token params[:id]
  end

  def update
    @user = User.find_by_perishable_token params[:id]
    if @user && @user.update_attributes(params[:user])
      flash[:notice] = "Password successfully reset"
      redirect_to root_path
    elsif @user
      flash[:error] = "Passwords do not match."
      render :edit
    else
      flash[:error] = "Invalid token"
      redirect_to root_path
    end
  end
end
