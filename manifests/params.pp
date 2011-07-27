# Class: github::params
#
# This class provides for the overriding of the default user, group, and
# basedir
#
# Parameters:
#   - user
#   - group
#   - basedir
#   - wwwroot
#
class github::params (
  $user = "git",
  $group = "git",
  $wwwroot = "/var/www/html",
  $basedir = "/home/git"
) {
}
