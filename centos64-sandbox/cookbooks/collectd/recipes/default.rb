#
# Cookbook Name:: yum
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

if platform?("centos","redhat","fedora")

  package "rpmforge-release" do
    action :install
    source "http://apt.sw.be/redhat/el5/en/x86_64/rpmforge/RPMS//rpmforge-release-0.3.6-1.el5.rf.x86_64.rpm"
    provider Chef::Provider::Package::Rpm
  end

  %w{ collectd collectd-apache collectd-dns collectd-email collectd-mysql collectd-rrdtool collectd-virt collectd-web }.each do |pkg|
    yum_package "#{pkg}" do
      arch "x86_64"
      action [ :install, :upgrade ]
    end
  end

end