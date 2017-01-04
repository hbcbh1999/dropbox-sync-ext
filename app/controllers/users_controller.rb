class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
    respond_to do |format|
      format.html { @user }
      format.json { render :json => {:user => @user}, :methods => :actions }
    end
  end

  def new
    @user = User.new
    @textfile = @user.textfiles.build
  end

  def create
    @user = User.new(permitted_params)
    respond_to do |format|
      if @user.save
        params[:textfiles]['textfile'].each do |a|
          @textfile = @user.textfiles.create!(:textfile => a)
        end
        format.html { redirect_to @user, notice: 'User was successfully created.' }
      else
        format.html { render action: 'new' }
      end
    end
  end

  def permitted_params
     params.require(:user).permit(:email, textfiles_attributes: [:id, :user_id, :textfile])
  end

end
