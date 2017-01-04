class DropboxController < ApplicationController

  def index
    @dropbox_link = "https://www.dropbox.com/1/oauth2/authorize?client_id=#{ENV["DROPBOX_CLIENT_ID"]}&response_type=code&redirect_uri=http://localhost:3002/dropbox_redirect"
  end

end
