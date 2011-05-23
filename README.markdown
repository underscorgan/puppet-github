# Puppet Github #

Mirrors github repositories locally

## Synopsis ##

    @user { "git":
      ensure      => present,
      managehome  => true,
      system      => true,
      before      => Group["git"],
    }

    @group { "git":
      ensure  => present,
    }

    class { "github::settings":
      user    => "git",
      group   => "git",
      basedir => "/home/git"
    }

    include github

    github::mirror { 
      "puppetlabs/puppet":
        ensure => present;
      "puppetlabs/facter":
        ensure => present;
    }

