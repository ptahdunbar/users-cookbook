#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright (C) 2013 YOUR_NAME
# 
# All rights reserved - Do Not Redistribute
#

include_recipe 'users::manage_users'
include_recipe 'users::manage_groups'
include_recipe 'users::authorized_keys'