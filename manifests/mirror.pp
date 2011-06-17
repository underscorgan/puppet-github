# Class: github::mirror
#
# This class instantiates a github mirror and sets up
#
# Parameters:
#
# Actions:
# Requires:
#   - github::settings
#
# Sample Usage:
#   See README
define github::mirror (
  $ensure
) {

  include github

  $user = $github::settings::user
  $group = $github::settings::group
  $basedir = $github::settings::basedir

  $github_user = regsubst($name, '^(.*?)/.*$', '\1')
  $repo_name = regsubst($name, '^.*/(.*$)', '\1')

  # The location of the repository on the disk
  $repo = "$basedir/$github_user/$repo_name.git"

  case $ensure {
    present: {
      if ! defined(File["$basedir/$github_user"]) {
        file { "$basedir/$github_user":
          ensure  => directory,
          owner   => $user,
          group   => $group,
        }
      }

      exec { "git-clone-$github_user-$repo_name":
        path      => [ "/bin", "/usr/bin", "/opt/local/bin" ],
        command   => "git clone --bare https://github.com/$github_user/$repo_name.git $repo",
        cwd       => $basedir,
        creates   => $repo,
        user      => $user,
        group     => $group,
        logoutput => on_failure,
      }
    }
    absent: {
      file { "$repo":
        force => true,
        ensure => absent;
      }
    }
    default: {
      fail("Invalid ensure value $ensure on github::mirror $name")
    }
  }
}
