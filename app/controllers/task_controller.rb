class TaskController < ApplicationController
  before_action :logged_in_user, only: [:dashboard, :choosetask]
  def new
  end
  def dashboard
  	@curr_task = Task.find(params[:taskid])
    if @curr_task.state == "waiting" || @curr_task.started_at == nil
      @curr_task.state = "active"
      @curr_task.started_at = Time.now+5
      @curr_task.save
    end
  	@audioID = @curr_task.tasktype
  end
  def finished
    @complete_code = (0...8).map { (65 + rand(26)).chr }.join
  end
  def getnexttask
    # move stuff in dashboard here, redirect to dashboard if task stage = 0
    my_tasks = Task.where(workerID: curr_worker_id).order(:id)
    @curr_task = nil

    if my_tasks.length == 0 # if this is the first task
      cond = nil
      if rand(0..1) == 0 
        cond = "c"
      else
        cond = "g"
      end
      @curr_task = Task.create(workerID: curr_worker_id, condition: cond, tasktype: 1, taskstage: 0, stagelimit: 2, state: "active", timelimit: (10*60))
      redirect_to controller: 'task', action: 'dashboard', taskid: @curr_task.id
    elsif my_tasks.length == 6 && my_tasks[-1].state == "finished"# if the last task is complete
      redirect_to controller: 'task', action: 'finished'
    else
      latest_task = my_tasks[-1]
      if latest_task.state == "active"
        @curr_task = latest_task
        redirect_to controller: 'task', action: 'dashboard', taskid: @curr_task.id
      elsif latest_task.state == "waiting" 
        @curr_task = latest_task
        if latest_task.taskstage == nil
          render 'choosetaskstage'
        else
          redirect_to controller: 'task', action: 'dashboard', taskid: @curr_task.id
        end
      else #latest_task.state == "finished" || latest_task.state == "expired"
        @curr_task = Task.create(workerID: curr_worker_id, condition: latest_task.condition, tasktype: latest_task.tasktype+1, taskstage: nil, stagelimit: latest_task.stagelimit, state: "waiting") 
        if @curr_task.tasktype == 2
          @curr_task.taskstage = 0
          @curr_task.timelimit = 15*60
          @curr_task.save
        end
        if (latest_task.taskstage+1>@curr_task.stagelimit) && (latest_task.taskstage+1<6)
          @curr_task.stagelimit = latest_task.taskstage+1
          @curr_task.save
        end
        if @curr_task.taskstage != nil # if there's no stage to choose
          redirect_to controller: 'task', action: 'dashboard', taskid: @curr_task.id
        else
          render 'choosetaskstage'
        end
         
      end

    end

  end
  def posttask
  	curr_task = Task.find(params[:taskid])
  	curr_task.text = params[:text_data]
    curr_task.state = "finished"
  	curr_task.save
  	redirect_to :controller => 'task', :action => 'getnexttask'
  end

  def submitchoice
    @curr_task = Task.find(params[:taskid])
    @curr_task.taskstage = params[:level]
    if @curr_task.taskstage == 1
      @curr_task.timelimit = 10*60
    elsif @curr_task.taskstage == 2
      @curr_task.timelimit = 7*60
    elsif @curr_task.taskstage == 3
      @curr_task.timelimit = 5*60
    elsif @curr_task.taskstage == 4
      @curr_task.timelimit = 3*60
    elsif @curr_task.taskstage == 5
      @curr_task.timelimit = 10*60
    end
    @curr_task.save
    redirect_to :controller => 'task', :action => 'getnexttask'
  end 

  def auto_save_text
    #logger.debug "params: "
    #logger.debug params
    curr_task = Task.find(params[:id])
    curr_task.text = params[:text_data]
    curr_task.save
    respond_to do |format|
      format.json { render json: ["ok"], status: :ok }
    end
  end

  def start

  end
end
