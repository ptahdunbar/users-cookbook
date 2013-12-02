#
# Cookbook Name:: users
# Recipe:: manage_users
#
# Copyright (C) 2013 Ptah Dunbar
#
# All rights reserved - Do Not Redistribute
#

if node[:users][:manage_users]
	node[:users][:manage_users].each do |u|
		name = u['name'] ? u['name'] : u
		home_dir = u['home'] ? u['home'] : "/home/#{name}"
		manage = true unless u['action'] and 'delete' == u['action']

		user name do
			supports :manage_home => true
			shell "/bin/bash" unless u["shell"]
			password u['password'] if u['password']
			home home_dir
			action :create
			action :remove if !manage
		end

		if manage
			directory "#{home_dir}/.ssh" do
				owner name
				group name
				mode 0700
			end

			u["keys"] and u["keys"].each do |key|
				execute "authorized_keys for #{key} in #{home_dir}" do
					user name
					group name
					command "curl key >> #{home_dir}/.ssh/authorized_keys"
				end
			end

			u['github_keys'] and u['github_keys'].each do |username|
				execute "import github authorized_keys for #{username}" do
					user name
					group name
					command "curl https://github.com/#{username}.keys >> #{home_dir}/.ssh/authorized_keys"
				end
			end
		end
	end
end