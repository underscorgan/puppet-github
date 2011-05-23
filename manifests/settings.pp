class github::settings (
  $user,
  $group,
  $basedir
) {
  User <| name == $user |>
  Group <| name == $group |>
}
