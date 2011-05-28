#
# Cookbook Name:: apache2
# Recipe:: thebudgetbabe

directory "/var/www/vhost/thebudgetbabe" do
  action :create
  mode 0755
  owner "root"
  group "root"
  recursive true
end

directory "/var/www/vhost/thebudgetbabe/www" do
  action :create
  mode 0755
  owner "root"
  group "root"
end

directory "/var/www/vhost/thebudgetbabe/spam" do
  action :create
  mode 0755
  owner "root"
  group "root"
end

template "#{node[:apache][:dir]}/sites-available/thebudgetbabe" do
  source "thebudgetbabe.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "apache2")
end

apache_site "thebudgetbabe"

