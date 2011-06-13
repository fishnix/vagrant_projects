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

  # site's id -- not needed yet
  #site_id = s9y_site["id"]
  # list of sites -- note needed yet
  #s9y_sites << site_id

#  remote_directory "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}" do
#    source "serendipity"
#    files_backup 2
#    files_mode "0644"
#    files_owner "root"
#    files_group "apache"
#    mode 0755
#    owner "root"
#    group node[:apache][:user]
#  end
  site_defs = data_bag_item('s9y_sites', s9y_site)
  site_name = site_defs['site_name']

  #git "#{node[:s9y][:base_dir]}/#{site_name}" do
  #  repository "git://github.com/fishnix/serendipity.git"
  #  reference "master"
  #  action :sync
  #end

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
              "serendipity_config_local.inc.php" => "serendipity_config_local.inc.php"
    #symlinks ({})
    symlink_before_migrate ({})
    #migration_command "touch foo"
    #environment "RAILS_ENV" => "production", "OTHER_ENV" => "foo"
    shallow_clone true
    action :deploy # or :rollback
    restart_command "touch tmp/restart.txt"
    #git_ssh_wrapper "wrap-ssh4git.sh"
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
      :docroot => "#{node[:s9y][:base_dir]}/#{site_name}",
      :server_name => "#{site_name}",
      :server_aliases => site_aliases,
      #:server_aliases => "#{s9y_site['site_aliases']}"
    })
    notifies :restart, resources(:service => "apache2")
  end

  # enable site in apache
#  link "#{node[:apache][:dir]}/sites-enabled/#{s9y_site['site_name']}.conf" do
#    to "#{node[:apache][:dir]}/sites-available/#{s9y_site['site_name']}.conf"
#    notifies :restart, resources(:service => "apache2")
#  end

end
