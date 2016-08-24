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
    @bonus = params[:b].to_i
    c = params[:c]
    @complete_code = (0...8).map { (97 + rand(26)).chr }.join+c
  end
  def getnexttask
    # move stuff in dashboard here, redirect to dashboard if task stage = 0
    my_tasks = Task.where(workerID: curr_worker_id).order(:id)
    @curr_task = nil

    if my_tasks.length == 0 # if this is the first task
      
      gp = Mycounter.where(condition: "gp")[0].count
      gn = Mycounter.where(condition: "gn")[0].count
      cp = Mycounter.where(condition: "cp")[0].count
      cn = Mycounter.where(condition: "cn")[0].count
      min_count = 1000
      min_cond = ""
      if gp<min_count
        min_count = gp
        min_cond = "gp"
      end
      if gn<min_count
        min_count = gn
        min_cond = "gn"
      end
      if cp<min_count
        min_count = cp
        min_cond = "cp"
      end
      if cn<min_count
        min_count = cn
        min_cond = "cn"
      end

      m = Mycounter.where(condition: min_cond)[0]
      m.count = m.count+1
      m.save
      #coin = rand(0..3)
      #if coin == 0 
      #  cond = "cp"
      #elsif coin == 1
      #  cond = "cn"
      #elsif coin == 2
      #  cond = "gp"
      #elsif coin == 3
      #  cond = "gn"
      #end
      @curr_task = Task.create(workerID: curr_worker_id, condition: min_cond, tasktype: 1, taskstage: 0, stagelimit: 2, state: "active", timelimit: (10*60), bonus: 0)
      redirect_to controller: 'task', action: 'dashboard', taskid: @curr_task.id
    elsif my_tasks.length == 6 && my_tasks[-1].state == "finished"# if the last task is complete
      redirect_to controller: 'task', action: 'finished', b: my_tasks[-1].bonus, c:my_tasks[-1].condition[1]
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
        @curr_task = Task.create(workerID: curr_worker_id, condition: latest_task.condition, tasktype: latest_task.tasktype+1, taskstage: nil, stagelimit: latest_task.stagelimit, state: "waiting", bonus: latest_task.bonus) 
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
    

    accuracy = evaluate(curr_task.text, curr_task.tasktype, curr_task.taskstage)
    response_text = ""
    if curr_task.tasktype == 2
      response_text = "Thanks for completing the summary task."
    else
      response_text = "Thanks for completing the transcription task. Accuracy: "+accuracy.to_s+"%."
    end
    flash[:success] = response_text
    curr_task.accuracy = accuracy
    if curr_task.bonus != nil && curr_task.condition[1] == 'p' && (accuracy > 70)
      newbonus = 0
      if curr_task.taskstage == 1
        newbonus = 0
      elsif curr_task.taskstage == 2
        newbonus = 25
      elsif curr_task.taskstage == 3
        newbonus = 50
      elsif curr_task.taskstage == 4
        newbonus = 75
      elsif curr_task.taskstage == 5
        newbonus = 100
      end
      curr_task.bonus = curr_task.bonus + newbonus
    end

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
      @curr_task.timelimit = 4*60
    elsif @curr_task.taskstage == 5
      @curr_task.timelimit = 3*60
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
  def index
    all_tasks = Task.where(created_at: Time.strptime("8-22-2016", "%m-%d-%Y")..Time.now).order(:id)
    @all_users = []
    @all_conditions = []
    all_tasks.each do |t|
      if t.tasktype == 6 && t.condition.length > 1 && t.state == "finished"
        @all_users << t.workerID
        @all_conditions << t.condition
      end
    end
    @gp = 0
    @gp_n = 0
    @gn = 0
    @gn_n = 0
    @cn = 0
    @cn_n = 0
    @cp = 0
    @cp_n = 0
    
    @gp_l = []
    @gn_l = []
    @cp_l = []
    @cn_l = []

    @all_users.each do |u|
      lev = 0
      cond = ""
      all_tasks.where(workerID: u).each do |t|
        cond = t.condition
        if (t.tasktype > 2 && t.accuracy != 0 )
          lev += t.taskstage
        end      
        if ( t.condition == 'gp' && t.accuracy!=0  ) 
          @gp += t.accuracy
          #@gp += t.taskstage
          @gp_n += 1
        elsif ( t.condition == 'gn' && t.accuracy!=0) 
          @gn += t.accuracy 
          #@gn += t.taskstage
          @gn_n += 1
        elsif ( t.condition == 'cp' && t.accuracy!=0) 
          @cp += t.accuracy 
          #@cp += t.taskstage
          @cp_n += 1
        elsif ( t.condition == 'cn' && t.accuracy!=0 ) 
          @cn += t.accuracy 
          #@cn += t.taskstage
          @cn_n += 1
        end
      end
      if cond == 'gp'
        @gp_l << ((lev.to_f)/4).round(2)
      elsif cond == 'gn'
        @gn_l << ((lev.to_f)/4).round(2)
      elsif cond == 'cp'
        @cp_l << ((lev.to_f)/4).round(2)
      elsif cond == 'cn'
        @cn_l << ((lev.to_f)/4).round(2)
      end
    end
    
    @gp = @gp_n>0 ? @gp.to_f/@gp_n : @gp
    @gn = @gn_n>0 ? @gn.to_f/@gn_n : @gn
    @cp = @cp_n>0 ? @cp.to_f/@cp_n : @cp
    @cn = @cn_n>0 ? @cn.to_f/@cn_n : @cn

    @tasks = all_tasks

  end
  def evaluate(text, task_type, task_stage)
    correct_text = ''
    if task_type == 1
      correct_text = "Whether I do in fact know it depends on how things stand outside my mind. The various causal links between the world and my perceptions and so forth, as long as they're working fine then I can have knowledge, just as the dog can have knowledge. I don't have to be an expert philosopher or an expert in human perception for my perceptual faculties to operate correctly and give me knowledge. But the skeptic is still lurking in the wings. Lets suppose we accept all I've said, suppose we accept that the word knowledge, as it's used in ordinary language, fits with this sort of externalist account and can quite properly be used in the various loose ways I've described. That doesn't actually defeat the skeptic because the skeptic can say, 'Well, look. If what you say is right, if your beliefs are in fact true, then I'll accept that you know all these things in this ordinary language sense."
    elsif task_type == 2
      correct_text = nil
    elsif task_type == 3
      correct_text = "And there's another problem with Putnam's approach. Let's step back from the vat for a moment and return me to real life. Okay. I know what a hand is. There's a hand. I'm walking along in Oxford one day, on my way to a lecture, and I get kidnapped and invatted. Some mad scientist extracts my brain and puts it in a vat. I forget about all this of course, I'm given the illusion of coming to a lecture. I look at this and I say, here's a hand, but actually, it's just a hand image. And now it looks like Putnam's approach isn't going to work. Because I learnt the use of the word hand by referring to real hands. So when I say hand I mean a real hand. I don't mean a hand image. In which case, I can raise the skeptical worry. Maybe this isn't a real hand. Maybe I am a brain in a vat."
    elsif task_type == 4
      correct_text = "Well I think most philosophers would agree with Hume that suspension of all belief is just impossible for us. The way we're made, we just cannot help believing certain things. And it's probably a good thing that we're made that way. Because if we weren't, then we'd be in serious trouble. Notice also that this approach goes well with contemporary externalism. The thought is that we shouldn't aim for all our beliefs to be such that we can justify them internally. We shouldn't expect to be able to work out internally the justification for everything we believe. Perhaps we have to rely on our animal nature that leads us inevitably to believe certain things and to trust in general that our faculties are thankfully more or less reliable. Of course that doesn't mean we should become undiscriminating and there remain big questions about how to distinguish between things that remain justified and things that aren't but if we want to hold out against the skeptic we probably have to be prepared to accept standards that are less than absolute."
    elsif task_type == 5
      correct_text = "Now you might well think that's a little bit too quick. It's not really a satisfactory answer to the skeptic. And I think that worry's right. Here's how I might spell it out. When I look at this thing, I think there's an object there which is actually moving in space, and whose movement is systematically correlated with my perception, in such a way that my perceptions give a directly reliable indicator of where it is. I have an idea of the sort of causal interaction which is responsible for these perceptions, in terms of light shining on my hand, bouncing off, I see it with my eyes, and so forth. And that's a very different picture from the picture of some mad scientist manipulating electrodes or running some computer program which is bringing it about that my perceptions correlate as though there were an object there. So maybe I can make some sense of a God's eye point of view"
    elsif task_type == 6
      correct_text = "so newton was asked what do you make of gravity? well he said slightly different things at slightly different times. but the most famous response of that of his was to say: I'm not going to try to make up any information of how gravity works, why it does what it does all I'm going to say is that the observations are consistent with it working as I describe. so I've got these equations which explain how gravity works, ok, it's proportional to the masses of the two objects, inversely proportionate to the square of the distance between them if you postulate a force like that it explains the phenomenon. I'm not going to go further, I'm not going to try to explain why. Maybe it's god's action, maybe there's some sort of ethereal fluid that somehow brings it about. But if the behavior of things is explained by this theory that's good enough."
    end  
    accuracy = 0
    if task_type != 2 
      l = text.length > correct_text.length ? text.length : correct_text.length
      accuracy = (((Diff::LCS.LCS(text, correct_text).length).to_f/l)*100).to_i
    end
    accuracy
  end
end
