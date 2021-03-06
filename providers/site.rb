#
# Cookbook Name:: openresty
# Provider:: site
#
# Author:: Panagiotis Papadomitsos (<pj@ezgr.net>)
#
# Copyright 2012, Panagiotis Papadomitsos
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

action :enable do
  link_name = (new_resource.name == 'default') ? '000-default' : new_resource.name
  tpl = if new_resource.template
    template "#{node['openresty']['dir']}/sites-available/#{link_name}" do
      source new_resource.template
      owner 'root'
      group 'root'
      mode 00644
      variables new_resource.variables
      notifies :reload, node['openresty']['service']['resource'], new_resource.timing
    end
  end
  site = execute "nxensite #{new_resource.name}" do
    command "/usr/sbin/nxensite #{new_resource.name}"
    notifies :reload, node['openresty']['service']['resource'], new_resource.timing
    not_if { ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/#{link_name}") }
  end
  new_resource.updated_by_last_action(site.updated_by_last_action? ||
                                      (tpl.updated_by_last_action? rescue false))
end

action :disable do
  link_name = (new_resource.name == 'default') ? '000-default' : new_resource.name
  site = execute "nxdissite #{new_resource.name}" do
    command "/usr/sbin/nxdissite #{new_resource.name}"
    notifies :reload, node['openresty']['service']['resource'], new_resource.timing
    only_if { ::File.symlink?("#{node['openresty']['dir']}/sites-enabled/#{link_name}") }
  end
  new_resource.updated_by_last_action(site.updated_by_last_action?)
end
