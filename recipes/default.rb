#
# Cookbook Name:: redis
# Recipe:: default
#
# Copyright 2011, Opscode, Inc.
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

if node["redis2"]["install_from"] == "package"
  include_recipe "redis2::package"
else
  include_recipe "redis2::source"
end

user node["redis2"]["user"] do
  home node["redis2"]["data_dir"]
  system true
end

directory node["redis2"]["instances"]["default"]["data_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
  recursive true
end

directory node["redis2"]["conf_dir"]

directory node["redis2"]["pid_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
  recursive true
end

directory node["redis2"]["log_dir"] do
  owner node["redis2"]["user"]
  mode "0750"
end

# Set up vm.covercommit_memory correctly - see redis.io/topics/faq
# under the topic "Background saving is failing with a fork() error 
# under Linux even if I've a lot of free RAM!" for discussion.

execute "set vm.overcommit_memory=1 in /etc/sysctl.conf" do
  command "echo 'vm.overcommit_memory=1' >> /etc/sysctl.conf"
  not_if "grep 'vm.overcommit_memory\s*=\s*1' /etc/sysctl.conf"
end

execute "set vm.overcommit_memory=1 in current parameter set" do
  command "sysctl vm.overcommit_memory=1"
  not_if "sysctl vm.overcommit_memory | grep 1"
end
