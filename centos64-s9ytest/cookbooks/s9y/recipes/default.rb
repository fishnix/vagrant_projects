#
# Cookbook Name:: s9y
# Recipe:: default
#
# Copyright 2011, E Camden Fisher
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apache2"
include_recipe "mysql::server"

package "git" do
  package_name "git"
  action :install
end


directory node[:s9y][:base_dir] do
  owner "root"
  group "apache"
  mode 0755
  action :create
end

s9y_sites = data_bag('s9y_sites')

s9y_sites.each do |s9y_site|

  site_defs = data_bag_item('s9y_sites', s9y_site)
  site_name = site_defs['site_name']

  directory "#{node[:s9y][:base_dir]}/#{site_name}" do
     mode 0775
     owner "root"
     group "root"
     action :create
  end
  
  directory "#{node[:s9y][:base_dir]}/#{site_name}/shared" do
     mode 0775
     owner "root"
     group "root"
     action :create
  end

  cookbook_file "#{node[:s9y][:base_dir]}/#{site_name}/shared/favicon.ico" do
     owner "root"
     group "root"
     mode 0444
  end
  
  cookbook_file "#{node[:s9y][:base_dir]}/#{site_name}/shared/favicon.gif" do
     owner "root"
     group "root"
     mode 0444
  end 

  directory "#{node[:s9y][:base_dir]}/#{site_name}/shared/uploads" do
     mode 0775
     owner "root"
     group "apache"
     action :create
  end

  template "#{node[:s9y][:base_dir]}/#{site_name}/shared/serendipity_config_local.inc.php" do
    source "serendipity_config_local.inc.php.erb"
    owner "root"
    group "apache"
    mode 0660
    backup false
  end

  deploy_revision "#{node[:s9y][:base_dir]}/#{site_name}" do
    repo "git://github.com/fishnix/serendipity.git"
    revision "HEAD"
    user "root"
    group "apache"
    enable_submodules false
    migrate false
    purge_before_symlink [ "uploads" ]
    symlinks  "uploads" => "uploads", 
              "serendipity_config_local.inc.php" => "serendipity_config_local.inc.php",
              "favicon.ico" => "favicon.ico",
              "favicon.gif" => "favicon.gif"
    symlink_before_migrate ({})
    migration_command ""
    shallow_clone true
    action :deploy # or :rollback
    scm_provider Chef::Provider::Git
  end

  
  directory "#{node[:s9y][:base_dir]}/#{site_name}/current/templates" do
     mode 0755
     owner "root"
     group "apache"
     action :create
  end

  directory "#{node[:s9y][:base_dir]}/#{site_name}/current/templates_c" do
     mode 0775
     owner "root"
     group "apache"
     action :create
  end
  
  site_aliases = site_defs['site_aliases']
  template "#{node[:apache][:dir]}/conf.d/#{site_name}.conf" do
    source "s9y_apache_conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :docroot => "#{node[:s9y][:base_dir]}/#{site_name}/current",
      :server_name => "#{site_name}",
      :server_aliases => site_aliases,
    })
    notifies :restart, resources(:service => "apache2")
  end
  
  dbHost = site_defs['dbHost']
  dbName = site_defs['dbName']
  dbUser = site_defs['dbUser']
  dbPass = site_defs['dbPass']

  execute "mysql-install-s9y-privileges" do
    command "/usr/bin/mysql -u root -p#{node['mysql']['server_root_password']} < #{node['mysql']['conf_dir']}/s9y-grants.sql"
    action :nothing
  end

  template "#{node['mysql']['conf_dir']}/s9y-grants.sql" do
    source "grants.sql.erb"
    owner "root"
    group "root"
    mode "0600"
    variables(
      :user     => dbUser,
      :password => dbPass,
      :database => dbName
    )
    notifies :run, "execute[mysql-install-s9y-privileges]", :immediately
  end

  execute "create #{dbName} database" do
    command "/usr/bin/mysqladmin -u root -p#{node['mysql']['server_root_password']} create #{dbName}"
    not_if do
      require 'mysql'
      m = Mysql.new("dbHost", "root", node['mysql']['server_root_password'])
      m.list_dbs.include?(dbName)
    end
    notifies :create, "ruby_block[save node data]", :immediately
  end
end

# save node data after writing the MYSQL root password, so that a failed 
# chef-client run that gets this far doesn't cause an unknown password to 
# get applied to the box without being saved in the node data.
ruby_block "save node data" do
  block do
    node.save
  end
  action :create
end

