#
# default s9y attributes
#

default[:s9y][:base_dir]	= "/var/www/vhost"
default[:s9y][:version]		= "1.5.5"
default[:s9y][:dbName]		= "serendipity"
default[:s9y][:dbPrefix]	= "serendipity_"
default[:s9y][:dbHost]		= "localhost"
default[:s9y][:dbUser]		= "serendipity"
default[:s9y][:dbPass]		= "serendipity"
default[:s9y][:dbType]		= "mysql"
default[:s9y][:dbPersistent]	= "false"
default[:s9y][:dbCharset]	= "utf8"
