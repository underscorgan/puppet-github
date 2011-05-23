
class github {

  $user = $github::settings::user
  $group = $github::settings::group
  $basedir = $github::settings::basedir

  file { "$basedir/github-listener":
    ensure  => present,
    source  => "puppet:///modules/github/github-listener",
    owner   => $user,
    group   => $group,
    mode    => "0755",
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
    require   => [ File["$basedir/github-listener"], Package["sinatra"]],
    subscribe => File["$basedir/github-listener"],

  }
}
