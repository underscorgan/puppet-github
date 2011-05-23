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

      # This would be the preferred method of handling this, but vcsrepo
      # cannot user switch, not can it handle ownership of the files  changing.
      #vcsrepo { "$repo":
      #  ensure    => bare,
      #  provider  => "git",
      #  source    => "https://github.com/$github_user/$repo_name.git",
      #  require   => File["$basedir/$github_user"],
      #}

      #file { "$repo":
      #  ensure  => directory,
      #  owner   => $user,
      #  group   => $group,
      #  recurse => true,
      #  backup  => false,
      #  require => Vcsrepo[$repo],
      #}

      exec { "git-clone-$github_user-$repo_name":
        path      => [ "/bin", "/usr/bin" ],
        command   => "git clone --bare https://github.com/$github_user/$repo_name.git $repo",
        cwd       => $basedir,
        creates   => $repo,
        user      => $user,
        group     => $group,
        logoutput => on_failure,
      }

      exec { "git-export-$github_user-$repo_name":
        path      => [ "/bin", "/usr/bin" ],
        command   => "touch $repo/git-daemon-export-ok",
        creates   => "$repo/git-daemon-export-ok",
        user      => $user,
        group     => $group,
        logoutput => true,
        require   => Exec["git-clone-$github_user-$repo_name"],
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
