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
		next unless u["name"]

		home_dir = u['home'] ? u['home'] : "/home/#{u['name']}"
		manage = true unless u['action'] and 'delete' == u['action']

		user u["name"] do
			supports :manage_home => true
			shell "/bin/bash" unless u["shell"]
			password u['password'] if u['password']
			home home_dir
			action :create
			action :remove if !manage
		end

		if manage
			directory "#{home_dir}/.ssh" do
				owner u['name']
				group u['name']
				mode 0700
			end

			u['ssh_keys'] and file "#{home_dir}/.ssh/authorized_keys" do
				owner u['name']
				group u['name']
				content "#{u['ssh_keys']}\n"
				mode 0600
			end

			u['github_ssh_keys'] and u['github_ssh_keys'].split(' ').each do |username|
				execute "import_github_authorized_keys" do
					user u['name']
					group u['name']
					command "curl https://github.com/#{username}.keys >> #{home_dir}/.ssh/authorized_keys"
				end
			end
		end
	end
end