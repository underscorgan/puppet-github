#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'

BASE_DIR = File.dirname(__FILE__)

post '/update/:user/:repo' do

  repo = "#{BASE_DIR}/#{params[:user]}/#{params[:repo]}.git"

  if File.directory? repo
    %x{git --git-dir #{repo} fetch --all --prune}
    200
  else
    404
  end
end

not_found do
  404
end
