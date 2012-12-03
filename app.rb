require "sinatra"
require "instagram"

class APP < Sinatra::Base

  enable :sessions

  CALLBACK_URL = "http://0.0.0.0:4567/oauth/callback"

  Instagram.configure do |config|
    config.client_id = "9d785ee618204c54a984895ac20c0c77"
    config.client_secret = "a21fb0948a4f4f8e916676cc1272ad31"
  end

  get "/" do
    '<a href="/oauth/connect">Connect with Instagram</a>'
  end

  get "/oauth/connect" do
    redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
  end

  get "/oauth/callback" do
    response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
    session[:access_token] = response.access_token
    redirect "/feed"
  end

  get "/feed" do
    client = Instagram.client(:access_token => session[:access_token])
    user = client.user

    html = "<h1>#{user.username}'s recent photos</h1>"
    for media_item in client.user_recent_media
      html << "<img src='#{media_item.images.thumbnail.url}'>"
    end
    html
  end

end