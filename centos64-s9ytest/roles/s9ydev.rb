name "s9ydev"
description "Role for s9y development"
run_list(
  "recipe[apache2]",
  "recipe[openssl]",
  "recipe[php::php5]",
  "recipe[php::module_mysql]",
  "recipe[mysql::server]",
  "recipe[yum]"
)
