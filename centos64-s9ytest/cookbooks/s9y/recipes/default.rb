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

directory node[:s9y][:base_dir] do
  owner "root"
  group "apache"
  mode 0755
  action :create
end

s9y_sites = []

search(:s9y_sites, "*:*") do |s9y_site|

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


  git "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}" do
    repository "git://github.com/fishnix/serendipity.git"
    reference "master"
    action :sync
  end

  directory "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}/uploads" do
     mode 0775
     owner "root"
     group "apache"
     action :create
  end
  
  directory "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}/templates" do
     mode 0755
     owner "root"
     group "apache"
     action :create
  end

  directory "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}/templates_c" do
     mode 0775
     owner "root"
     group "apache"
     action :create
  end

  template "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}/serendipity_config_local.inc.php" do
    source "serendipity_config_local.inc.php.erb"
    owner "root"
    group "apache"
    mode 0660
    backup false
  end

  site_aliases = []
  site_aliases = s9y_site['site_aliases']
  template "#{node[:apache][:dir]}/conf.d/#{s9y_site['site_name']}.conf" do
    source "s9y_apache_conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables({
      :docroot => "#{node[:s9y][:base_dir]}/#{s9y_site['site_name']}",
      :server_name => "#{s9y_site['site_name']}",
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
