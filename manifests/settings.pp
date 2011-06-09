# Class: github::settings
#
# This class provides for the overriding of the default user, group, and
# basedir
#
# Parameters:
#   - user
#   - group
#   - basedir
#
# Actions:
#
# Requires:

# Sample Usage:
#   See README
class github::settings (
  $user = "git",
  $group = "git",
  $basedir = "/home/git"
) {
}
