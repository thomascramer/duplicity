# Description

Cookbook for installing duplicity backup cronjobs

# Providers

To use the providers, append the following to your metadata.rb

    depends 'duplicity'

## duplicity_cronjob

Installs a duplicity cronjob

    duplicity_cronjob 'myduplicity' do
      name             'myduplicity'        # cronjob filename (name_attribute)

      # attributes for the default cronjob template
      interval         'daily'              # cron interval (hourly, daily, monthly)
      duplicity_path   '/usr/bin/duplicity' # path to duplicity
      configure_zabbix false                # automatically configure zabbix user paremeters
      logfile          '/dev/null'          # log cronjob output to this file



      # duplicity parameters
      backend          'ftp://server.com/folder' # backend to use (default: nil, required!)
      passphrase       'supersecret'             # passphrase (leave empty to use data bag)

      include        [ '/etc/', '/root/', '/var/log/' ] # default directories to backup
      exclude        []                                 # default directories to exclude from backup
      archive_dir    '/tmp/duplicity-archive'           # duplicity archive directory
      temp_dir       '/tmp/duplicity-tmp'               # duplicity temp directory
      keep_full      5                                  # keep 5 full backups
      nice           10                                 # be nice (cpu)
      ionice         3                                  # ionice class (3 => idle)
      full_backup_if_older_than '7D'                    # take a full backup after this interval

      # command(s) to run at the very beginning of the cronjob (default: empty)
      exec_pre %\if [ -f "/nobackup" ]; then exit 0; fi\

      # command(s) to run after cleanup, but before the backup (default: empty)
      exec_before [ 'pg_dumpall -U postgres |bzip2 > /tmp/dump.sql.bz2']

      # command(s) to run after the backup has finished (default: empty)
      exec_after  [ 'touch /backup-sucessfull', 'echo yeeeh' ]

      # take duplicity passphrase from databag
      data_bag         'duplicity'
      data_bag_item    node['hostname']
      data_bag_secret  '/etc/chef/encrypted_data_bag_secret'
      data_bag_element 'passphrase'

      # alternatively, you can specify your own template to use
      cookbook         'duplicity'          # cookbook to take erb template from
      source           'cronjob.sh.erb'     # erb template to use
      variables        {}                   # custom variables for erb template
    end
