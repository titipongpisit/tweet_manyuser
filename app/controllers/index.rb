get '/' do
  erb :index
end

get '/sign_in' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  redirect request_token.authorize_url
end

get '/sign_out' do
  session.clear
  redirect '/'
end

get '/auth' do
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier])
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)
  p "hi"
  p @access_token 
  oauth_token_secret = @access_token.params[:oauth_token_secret]
  oauth_token = @access_token.params[:oauth_token]
  screen_name = @access_token.params[:screen_name]

  # at this point in the code is where you'll need to create your user account and store the access token
  User.create(username: screen_name, oauth_token: oauth_token, oauth_secret: oauth_token_secret)
  @user = User.find_by_username(screen_name)
  erb :tweet_page
  
end

post '/tweet/:id' do
  @user = User.find(params[:id]) 
  p "hi2"
  p @user.oauth_token
  user = Twitter::Client.new(:oauth_token => @user.oauth_token, :oauth_token_secret => @user.oauth_secret)
  user.update(params[:tweet])
  # Thread.new{user.update(params[:tweet])}
end   
