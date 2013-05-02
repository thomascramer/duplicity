#
# Cookbook Name:: duplicity
# Provider:: cronjob
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

action :create do
  package 'duplicity'
  package 'ncftp' if new_resource.backend.include?('ftp://')

  # unless passphrase is given, try getting it from data bag
  if new_resource.passphrase
    passphrase = new_resource.passphrase
  else
    duplicity_secret = Chef::EncryptedDataBagItem.load_secret(new_resource.data_bag_secret)
    passphrase = Chef::EncryptedDataBagItem.load(new_resource.data_bag, new_resource.data_bag_item, duplicity_secret)['passphrase']
  end

  directory ::File.dirname(new_resource.logfile) do
    mode '0750'
  end

  template "/etc/cron.#{new_resource.interval}/duplicity-#{new_resource.name}" do
    mode     '0750'
    source   new_resource.source
    cookbook new_resource.cookbook

    if new_resource.variables.empty?
      variables :logfile => new_resource.logfile,
                :backend => new_resource.backend,
                :passphrase => passphrase,
                :include => new_resource.include,
                :exclude => new_resource.exclude,
                :archive_dir => new_resource.archive_dir,
                :temp_dir => new_resource.temp_dir,
                :full_backup_if_older_than => new_resource.full_backup_if_older_than,
                :nice => new_resource.nice,
                :ionice => new_resource.ionice,
                :keep_full => new_resource.keep_full,
                :exec_pre => new_resource.exec_pre,
                :exec_before => new_resource.exec_before,
                :exec_after => new_resource.exec_after
    else
      variables new_resource.variables
    end
  end

  if new_resource.configure_zabbix
    zabbix_agent_userparam 'duplicity' do
      identifier "duplicity.last_backup"
      command    %\expr $(date "+%s") - $(date --date "$(\ +
                 %\sudo duplicity collection-status --archive-dir #{new_resource.archive_dir} --tempdir #{new_resource.temp_dir} #{new_resource.backend} |\ +
                 %#tail -n3 |head -n1 |sed -r 's/^\\s+\\S+\\s+(\\w+\\s+\\w+\\s+\\w+\\s+\\S+\\s+\\w+).*$/\\1/'# +
                 %\)" "+%s")\
    end

    # zabbix user needs root access to check backup status (tmpfiles)
    sudo 'zabbix_duplicity' do
      user     'zabbix'
      nopasswd true
      commands [ "#{new_resource.duplicity_path} collection-status *" ]
    end
  end
end


action :delete do
  file "/etc/cron.#{new_resource.interval}/duplicity-#{new_resource.name}" do
    action :delete
  end

  if new_resource.configure_zabbix
    zabbix_agent_userparam "duplicity-#{new_resource.name}" do
      action :delete
    end

    sudo 'zabbix_duplicity' do
      action  :remove
      only_if 'ls /etc/zabbix/zabbix_agentd.conf.d/duplicity_*.conf &> /dev/null'
    end
  end
end
