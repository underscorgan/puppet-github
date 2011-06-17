# Class: github
#
# This class provides for the mirroring of github repos
#
# Parameters:
#
# Actions:
#   - Realizes the github::settings::user
#   - Realizes the github::settings::group
#   - Starts up github-listener
#   - Starts up git-daemon
# Requires:
#   - github::settings
#
# Sample Usage:
#   See README
class github {

  $user = $github::settings::user
  $group = $github::settings::group
  $basedir = $github::settings::basedir

  realize(User[$user])
  realize(Group[$group])

  file { "${basedir}/config.ru":
    ensure  => present,
    source  => "puppet:///modules/github/config.ru",
    owner   => $user,
    group   => $group,
    mode    => "0755",
  }

  file { "${basedir}/listener.rb":
    ensure  => present,
    source  => "puppet:///modules/github/listener.rb",
    owner   => $user,
    group   => $group,
    mode    => "0755",
  }

  package { "sinatra":
    ensure    => present,
    provider  => "gem",
  }
}
