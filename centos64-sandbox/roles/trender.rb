name "trender"
description "Role for trending server"
run_list(
  "recipe[yum]",
  "recipe[collectd]"
)
