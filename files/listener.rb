#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'

BASE_DIR = "/home/git/gitolite/repositories"

post '/update/:user/:repo' do

  repo = "#{BASE_DIR}/#{params[:user]}/#{params[:repo]}.git"

  if File.directory? repo
    %x{git --git-dir #{repo} fetch --all --prune}
    %x{git --git-dir #{repo} update-server-info --force}
    200
  else
    404
  end
end

not_found do
  404
end
