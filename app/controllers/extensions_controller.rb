class ExtensionsController < ApplicationController

  def show
    @user = User.find_by_uuid(params[:user_uuid])
    name = "Dropbox Sync"
    supported_types = ["Note"]
    actions = [
      {
        :label => "Auto-push changes",
        :url => "http://localhost:3002/ext/#{@user.uuid}/push",
        :type => "watch:post:5",
        :structures => [
          {
            :type => "Note",
            :fields => [
              {
                :name => "uuid",
                :modifies => false
              },
              {
                :name => "content.title",
                :modifies => false
              },
              {
                :name => "content.text",
                :modifies => false
              }
            ]
          }
        ]
      }
    ]
    render :json => {:name => name, :supported_types => supported_types, :actions => actions}
  end

  def push
    require 'dropbox'
    @user = User.find_by_uuid(params[:user_uuid])
    items = params[:items]
    dropbox = Dropbox::Client.new(@user.dropbox_token)
    items.each do |item|
      dropbox.upload("/#{item[:uuid]}.txt", "#{item[:content][:title]}\n\n#{item[:content][:text]}", {:mode => "overwrite"})
    end

    render :json => {:success => true}
  end

  def dropbox_auth_complete
    @user = User.new
    code = params[:code]

    url = "https://api.dropboxapi.com/1/oauth2/token"
    request_params = {
      :code => code,
      :grant_type => "authorization_code",
      :client_id => ENV["DROPBOX_CLIENT_ID"],
      :client_secret => ENV["DROPBOX_CLIENT_SECRET"],
      :redirect_uri => "http://localhost:3002/dropbox_redirect"
      }

    resp = HTTP.headers(content_type: 'application/json').post(url, :params => request_params)

    if resp.code != 200
      @error = "Unable to authenticate. Please try again."
    else
      data = JSON.parse(resp.to_s)
      @user.dropbox_token = data["access_token"]
      @user.save!
      @secret_url = "http://localhost:3002/ext/#{@user.uuid}"
    end

  end
end
