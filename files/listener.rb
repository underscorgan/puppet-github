#!/usr/bin/env ruby

require 'rubygems'
require 'sinatra'

class Listener < Sinatra::Base
  def verbose msg
    $stderr.puts msg if settings.verbose
  end

  helpers do
    def json_output(key, val)
      %{{"#{key}" => "#{val}"}}
    end

    def show_heads(repo_path)
      %x{git --git-dir #{repo_path} show-ref --heads}
    end

    def authenticate!(identifier)
      allowed = []

      # Parse out repositories we're allowed to update from github
      # Format is "user/repo, url", where user/repo reflects the github path
      # and url is the associated address to fetch
      begin
        File.open("#{settings.basedir}/.github-allowed") do |file|
          file.each do |line|
            allowed << line.chomp!
          end
        end
      rescue => e
        msg = "Error reading allowed github repos: #{e.message}"
        verbose msg
        halt 503, json_output("error", msg)
      end

      if allowed.include? identifier
        verbose "Authentication succeeded for #{identifier}"
      else
        msg = "Authentication failed for '#{identifier}': no entry in .github-allowed"
        verbose msg
        halt 403, json_output("error", msg)
      end
    end
  end

  before '/update/:user/:repo' do @identifier = "#{params[:user]}/#{params[:repo]}"
    @repo_path  = "#{settings.basedir}/#{params[:user]}-#{params[:repo]}.git"
    authenticate!(@identifier)
  end

  get '/update/:user/:repo' do

    if File.directory? @repo_path
      return [200, json_output("heads", show_heads(@repo_path))]
    else
      return [412, json_output("error", "#{@identifier} allowed but not cloned")]
    end
  end

  post '/update/:user/:repo' do

    if File.directory? @repo_path
      # If the requested directory exists and is allowed, pull it.
      # Otherwise, log to stderr/apache error.log why things failed
      # and 404

      cmd = %Q{git --git-dir #{@repo_path} fetch --all --verbose --prune}
      verbose %Q{Updating repo #{@identifier} with command "#{cmd}"}
      system(cmd)

      return [202, json_output("heads", show_heads(@repo_path))]
    else
      verbose "Nonexistent repo #{@repo_path}"
      return [412, json_output("error", "#{@identifier} allowed but not cloned")]
    end
  end

  not_found do
    [404, json_output("error", "not found")]
  end
end
