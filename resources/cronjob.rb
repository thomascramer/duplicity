#
# Cookbook Name:: duplicity
# Resource:: cronjob
#
# Copyright 2012, Chris Aumann
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

actions        :create, :delete
default_action :create

attribute :name,             :kind_of => String, :name_attribute => true
attribute :interval,         :kind_of => String, :default => 'daily'
attribute :cookbook,         :kind_of => String, :default => 'duplicity'
attribute :source,           :kind_of => String, :default => 'cronjob.sh.erb'
attribute :variables,        :kind_of => Hash,   :default => {}
attribute :duplicity_path,   :kind_of => String, :default => '/usr/bin/duplicity'
attribute :configure_zabbix, :kind_of => [ TrueClass, FalseClass ], :default => false

# data bag elements (only needed if :passphrase is nil)
attribute :data_bag,         :kind_of => String, :default => 'duplicity'
attribute :data_bag_item,    :kind_of => String, :default => node['hostname']
attribute :data_bag_secret,  :kind_of => String, :default => '/etc/chef/encrypted_data_bag_secret'
attribute :data_bag_element, :kind_of => String, :default => 'passphrase'

attribute :backend,     :kind_of => String, :required => true
attribute :passphrase,  :kind_of => String, :default => nil
attribute :include,     :kind_of => Array,  :default => [ '/etc/', '/root/', '/var/log/' ]
attribute :exclude,     :kind_of => Array,  :default => []
attribute :archive_dir, :kind_of => String, :default => '/tmp/duplicity-archive'
attribute :temp_dir,    :kind_of => String, :default => '/tmp/duplicity-tmp'
attribute :keep_full,   :kind_of => Integer, :default => 5
attribute :nice,        :kind_of => Integer, :default => 10
attribute :full_backup_if_older_than, :kind_of => String, :default => '7D'

# shell scripts that will be appended at the beginning/end of the cronjob
attribute :exec_pre,    :kind_of => [ String, Array ], :default => []
attribute :exec_before, :kind_of => [ String, Array ], :default => []
attribute :exec_after,  :kind_of => [ String, Array ], :default => []
