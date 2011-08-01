# Puppet Github mirroring #

Mirror your massive github mirrors locally, so that you can rapidly create and
destroy repositories before the heat death of the universe!

## Synopsis ##


    class { "github::params":
      user    => "gitmirror",
      group   => "gitmirror",
      basedir => "/home/gitmirror",
      wwwroot => "/var/www/gitmirror",
      vhost_name => "git",
    }

    file { "/var/www/gitmirror":
      ensure => directory,
      owner  => "gitmirror",
      group  => "gitmirror",
      mode   => "0755",
    }

    github::mirror {
      "puppetlabs/puppet":
        ensure => present;
      "supersecret/world-domination-plans":
        ensure  => present,
        private => true;
    }
