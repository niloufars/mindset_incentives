module SessionsHelper
  # Logs in the given user.
  def log_in(worker_id)
    session[:worker_id] = worker_id
  end
  def curr_worker_id
    @curr_worker_id ||= session[:worker_id]
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !curr_worker_id.nil?
  end
  
  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
  # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please enter your worker ID to continue."
        redirect_to start_url
      end
    end  
end
