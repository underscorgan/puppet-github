# Class: github
#
# This class provides for the mirroring of github repos
#
# Parameters:
#
# Actions:
#   - Instantiates the github::settings::user
#   - Instantiates the github::settings::group
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

  file { "$basedir/github-listener":
    ensure  => present,
    source  => "puppet:///modules/github/github-listener",
    owner   => $user,
    group   => $group,
    mode    => "0755",
    require => [
      User[$user],
      Group[$group],
    ],
  }

  package { "sinatra":
    ensure    => present,
    provider  => "gem",
  }

  exec { "github-listener":
    path      => [ "/bin", "/usr/bin" ],
    user      => $user,
    group     => $group,
    command   => "$basedir/github-listener &",
    refresh   => "(pkill -f github-listener; sleep 10; $basedir/github-listener &) &",
    unless    => "$ps | grep -v grep | grep github-listener",
    require   => [
      User[$user],
      Group[$group],
      File["$basedir/github-listener"],
      Package["sinatra"]
    ],
    subscribe => File["$basedir/github-listener"],
  }

  exec { "git-daemon":
    path      => [ "/bin", "/usr/bin" ],
    user      => $user,
    group     => $group,
    command   => "git daemon --detach --reuseaddr --base-path=$basedir --base-path-relaxed --pid-file=$basedir/.git-daemon.pid $basedir",
    logoutput => true,
    unless    => "pgrep -U $user git-daemon",
    require   => [
      User[$user],
      Group[$group],
    ],
  }
}
