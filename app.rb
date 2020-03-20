# frozen_string_literal: true

require 'rubygems'
require 'open-uri'
require 'oauth2'
require 'sinatra'
require 'sinatra/json'
require 'securerandom'
require 'digest/md5'
require 'dotenv/load'

use Rack::Logger

set :root, File.dirname(__FILE__)
set :logger, Logger.new(STDOUT)

enable :sessions


ZOOM_CONSUMER_KEY = ENV['ZOOM_CONSUMER_KEY']
ZOOM_CONSUMER_SECRET = ENV['ZOOM_CONSUMER_SECRET']

ZOOM_OAUTH_HOST = ENV['ZOOM_OAUTH_HOST'] || 'https://zoom.us'
ZOOM_OAUTH_AUTHORIZE_URL = ENV['ZOOM_OAUTH_AUTHORIZE_URL'] || '/oauth/authorize'

CLIENT_HOST = ENV['CLIENT_HOST'] || 'http://localhost'
CLIENT_CALLBACK_URL = ENV['CLIENT_CALLBACK_URL'] || '/oauth/callback'

def client
  OAuth2::Client.new(
    ZOOM_CONSUMER_KEY,
    ZOOM_CONSUMER_SECRET,
    site: ZOOM_OAUTH_HOST,
    authorize_url: ZOOM_OAUTH_AUTHORIZE_URL
  )
end

configure do
  set :client, client
end

get '/redirect' do
  redirect_uri = "#{CLIENT_HOST}#{CLIENT_CALLBACK_URL}"

  begin
    authorization_uri = settings.client.auth_code.authorize_url(redirect_uri: redirect_uri)

    logger.info authorization_uri
    redirect authorization_uri
  rescue OAuth2::Error => e
    p e.description
  end
end

get '/oauth/callback' do
  redirect_uri = "#{CLIENT_HOST}#{CLIENT_CALLBACK_URL}"

  begin
    access_token = settings.client.auth_code.get_token(
      params[:code], redirect_uri: redirect_uri
    )

    session[:token] = access_token.token
    logger.info access_token.token

    redirect '/meetings'
  rescue OAuth2::Error => e
    return p e.message
  end
end

get '/meetings' do
  response = open(
    'https://api.zoom.us/v2/users/me/meetings?page_number=1&page_size=30&type=live',
    'authorization' => "Bearer #{session[:token]}"
  )

  payload = JSON.parse(response.read)

  logger.info payload.inspect

  erb :meetings, locals: payload
end

get '/meetings/:id' do
  meeting_id = params[:id]

  response = open(
    "https://api.zoom.us/v2/report/meetings/#{meeting_id}/participants?page_size=300",
    'authorization' => "Bearer #{session[:token]}"
  )

  payload = JSON.parse(response.read)

  participants = payload['participants'].reduce({}) do |items, item|
    items.merge! item['name'] => item['user_email']
  end

  logger.info payload.inspect

  payload.merge! participants: participants, winner: participants.keys.sample
  erb :meeting, locals: payload
end

__END__

@@ layout
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">

    <title>Sorteio Zoom Meeting</title>
  </head>
  <body>

    <%= yield %>

    <script src="https://code.jquery.com/jquery-3.2.1.slim.min.js" integrity="sha384-KJ3o2DKtIkvYIK3UENzmM7KCkRr/rE9/Qpg6aAZGJwFDMVNA/GpGFF93hXpG5KkN" crossorigin="anonymous"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js" integrity="sha384-ApNbgh9B+Y1QKtv3Rn7W3mgPxhU9K/ScQsAP7hUibX39j7fakFPskvXusvfa0b4Q" crossorigin="anonymous"></script>
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" integrity="sha384-JZR6Spejh4U02d8jOt6vLEHfe/JQGiRRSQQxSfFWpi1MquVdAyjUar5+76PVCmYl" crossorigin="anonymous"></script>
  </body>
</html>


@@ meetings

<h2>Reuniões</h2>

<% unless meetings %>
  <div class="alert alert-warning">
    <strong>Nenhuma reunião foi encontrada!</strong>
  </div>
<% end %>

<% meetings.each do |meeting| %>
  <div>
  <p><strong><%= meeting['topic'] %></strong></p>
  <p><a href="/meetings/<%= meeting['id'] %>">Sortear</a></p>
  </div>
<% end %>


@@ meeting

<h2>Sorteado</h2>

<div class="center">
  <img src="https://www.gravatar.com/avatar/<%= Digest::MD5.hexdigest(participants[winner]) %>?s=200&d=mp" alt=""><br />
  <strong><%= winner %></strong>
</div>


