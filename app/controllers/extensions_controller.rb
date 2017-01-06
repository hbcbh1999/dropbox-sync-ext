class ExtensionsController < ApplicationController

  before_action {
    if params[:user_uuid]
      @user = User.find_by_uuid(params[:user_uuid])
    end
  }

  def show
    if !@user
      render :json => {:error => "Unable to load extension."}
    end
    name = "Dropbox Sync"
    supported_types = ["Note"]
    actions = [
      {
        :label => "Auto-push changes",
        :desc => "Pushes note changes to Dropbox folder.",
        :url => "http://localhost:3002/ext/#{@user.uuid}/push",
        :type => "watch:post:7",
        :structures => [
          {
            :type => "Note",
            :mode => "read",
            :decrypted => true
          }
        ]
      },
      {
        :label => "Perform initial sync",
        :desc => "Syncs all your current notes. This can take several minutes, depending on how many notes you have.",
        :url => "http://localhost:3002/ext/#{@user.uuid}/initial_sync",
        :type => "all:post",
        :structures => [
          {
            :type => "Note",
            :mode => "read",
            :decrypted => true
          }
        ]
      },
      {
        :label => "Download import file",
        :desc => "Downloads import file in standard format.",
        :url => "http://localhost:3002/ext/#{@user.uuid}/download",
        :type => "show"
      }
    ]
    render :json => {:name => name, :supported_types => supported_types, :actions => actions}
  end

  def dropbox
    require 'dropbox'
    dropbox = Dropbox::Client.new(@user.dropbox_token)
  end

  def push
    items = params[:items]

    # write individual files
    items.each do |item|
      dropbox.upload("/#{item[:uuid]}.txt", "#{JSON.pretty_generate(item.as_json)}", {:mode => "overwrite"})
    end

    # write to master file
    begin
      file, body = dropbox.download("/master.txt")
      contents = JSON.parse(body.to_s)
    rescue
      contents = []
    end

    items.each do |item|
      existing = contents.find { |e| e["uuid"] == item[:uuid]  }
      if existing
        existing.merge!(item.to_unsafe_h)
      else
        contents.push(item.to_unsafe_h)
      end
    end

    dropbox.upload("/master.txt", JSON.pretty_generate(contents.as_json), {:mode => "overwrite"})

    render :json => {:success => true}
  end

  def initial_sync
    self.push
  end

  def download
    file, body = dropbox.download("/master.txt")
    send_data body.to_s, filename: "dropbox-notes.txt"
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
