class SessionsController < ApplicationController

  def new
  end

  def create
  	worker_id = params[:session][:worker_id]
    if worker_id != ""
      log_in worker_id
      redirect_back_or root_path
    else
      flash.now[:danger] = 'Invalid worker ID'
      render 'new'
    end
  end

  def destroy
  end
end