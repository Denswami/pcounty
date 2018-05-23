class SessionsController < ApplicationController

  def new
    if params[:signin_option]="google"
    redirect_to '/auth/google_oauth2'
  else
    render 'new'
  end

  def create
      auth = request.env["omniauth.auth"]
    if auth

    user = User.where(:provider => auth['provider'],
                      :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    reset_session
    session[:user_id] = user.id
    redirect_to root_url, :notice => 'Signed in!'
  else
    reset_session
   @user = User.find_by(email: session_params[:email])

   if @user && @user.authenticate(session_params[:password])
     session[:user_id] = @user.id
     flash[:success] = 'Welcome back!'
     redirect_to root_path
   else
     flash[:error] = 'Invalid email/password combination'
     redirect_to login_path
   end
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'Signed out!'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}"
  end
  def session_params
    params.require(:session).permit(:email, :password)
  end

end
