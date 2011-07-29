#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'

class Listener < Sinatra::Base

  post '/update/:user/:repo' do
    status = 404
    allowed = {}

    # Parse out repositories we're allowed to update from github
    begin
      File.open("#{settings.basedir}/.github-allowed") do |file|
        file.each do |line|
          line.chomp!
          identifier, url = line.split(', ', 2)
          allowed[identifier] = url
        end
      end
    rescue => e
      $stderr.puts "Error reading allowed github repos: #{e.backtrace.join('\n')}"
      halt 403
    end

    repo_path = "#{settings.basedir}/#{params[:user]}-#{params[:repo]}.git"
    identifier = "#{params[:user]}/#{params[:repo]}"
    if File.directory? repo_path
      if allowed.keys.include? identifier
        cmd = %Q{git --git-dir #{repo_path} fetch #{allowed[identifier]} --prune}
        $stderr.puts %Q{Updating repo #{identifier} with command "#{cmd}"}
        %x{#{cmd}}
        status = 200
      else
        $stderr.puts "Disallowed repo #{repo_path}"
      end
    else
      $stderr.puts "Non existent repo #{repo_path}"
    end

    status
  end

  not_found do
    404
  end
end
