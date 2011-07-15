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
  $repo_path = "${basedir}/${github_user}/${repo_name}.git"

  case $ensure {
    present: {
      if ! defined(File["${basedir}/${github_user}"]) {
        file { "${basedir}/${github_user}":
          ensure  => directory,
          owner   => $user,
          group   => $group,
        }
      }

      exec { "git-clone-${github_user}-${repo_name}":
        path      => [ "/bin", "/usr/bin", "/opt/local/bin" ],
        command   => "git clone --bare https://github.com/${github_user}/${repo_name}.git ${repo_path}",
        cwd       => $basedir,
        creates   => $repo_path,
        user      => $user,
        group     => $group,
        logoutput => on_failure,
      }

      exec { "git-update-server-info-${github_user}-${repo_name}":
        path      => [ "/bin", "/usr/bin", "/opt/local/bin" ],
        command   => "git --git-dir ${repo_path} update-server-info",
        cwd       => $basedir,
        creates   => "${repo_path}/info/refs",
        user      => $user,
        group     => $group,
        require   => Exec["git-clone-${github_user}-${repo_name}"],
        logoutput => on_failure,
      }
    }
    absent: {
      file { $repo_path:
        force => true,
        ensure => absent;
      }
    }
    default: {
      fail("Invalid ensure value $ensure on github::mirror $name")
    }
  }
}
