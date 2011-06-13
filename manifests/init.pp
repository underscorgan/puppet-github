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

  file { "${basedir}/github-listener":
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
    provider  => "shell",
    command   => "${basedir}/github-listener &",
    unless    => "$ps | grep -v grep | grep github-listener",
    require   => [
      File["${basedir}/github-listener"],
      Package["sinatra"]
    ],
    subscribe => File["${basedir}/github-listener"],
  }

  exec { "git-daemon":
    path      => [ "/bin", "/usr/bin", "/opt/local/bin" ],
    user      => $user,
    group     => $group,
    command   => "git daemon --detach --reuseaddr --base-path=${basedir} --base-path-relaxed --pid-file=${basedir}/.git-daemon.pid ${basedir}",
    logoutput => true,
    unless    => "$ps | grep -v grep | grep git-daemon",
    require   => [
      User[$user],
      Group[$group],
    ],
  }
}
