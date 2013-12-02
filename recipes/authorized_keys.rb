if node[:users][:authorized_keys]
	node[:users][:authorized_keys].each do |group|
		next unless user_keys["keys"] and user_keys["user"]

		user_exists = Mixlib::ShellOut.new("id #{user_keys["user"]}")
		user_exists.run_command

		if 0 == user_exists.exitstatus
			home = `echo ~#{user_keys["user"]}`.delete("\n")
			next unless home

			user_keys["keys"] and user_keys["keys"].each do |key|
				execute "authorized_keys for #{key} in #{home}" do
					user 'root'
					command "curl key >> #{home}/.ssh/authorized_keys && chmod 400 #{home}/.ssh/authorized_keys"
				end
			end

			user_keys["github_keys"] and user_keys["github_keys"].each do |key|
				execute "github_authorized_keys for #{key} in #{home}" do
					user 'root'
					command "curl https://github.com/#{key}.keys >> #{home}/.ssh/authorized_keys && chmod 400 #{home}/.ssh/authorized_keys"
				end
			end
		end
	end
end