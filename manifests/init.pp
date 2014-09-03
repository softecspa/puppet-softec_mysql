class softec_mysql (
  $root_password    = 'UNSET',
  $old_root_password= '',
  $manage_service   = true,
  $restart          = 'UNSET',
  $monitoring_user  = false,
  $monitoring_pass  = '',
  $replication_user = false,
  $replication_pass = '',
  $override_options = {},
  $runtime          = 'UNSET',
  $runtime_allowed  = 'UNSET',
  $nrpe_checks      = false,
  $nrpe_user_checks = {},
) inherits softec_mysql::params {

  $options = mysql_deepmerge($softec_mysql::params::default_options, $override_options)

  if $monitoring_user {
    if ($monitoring_pass == '') {
      fail('Specify pass for monitoring_user')
    }
  }

  if $replication_user {
    if ($replication_pass == '') {
      fail('Specify pass for replication_user')
    }
  }

  $service_restart = $restart? {
    'UNSET' => $manage_service,
    default => $restart
  }

  $real_runtime = $runtime?{
    'UNSET' => $service_restart? {
      true  => false,
      false => true
    },
    default => $runtime
  }

  class {'mysql::server':
    root_password     => $root_password,
    old_root_password => $old_root_password,
    service_manage    => $manage_service,
    restart           => $service_restart,
    override_options  => $options,
    runtime           => $real_runtime,
    runtime_variables => $runtime_allowed,
    purge_conf_dir    => true,
  }

  if $monitoring_user {
    mysql_user {"$monitoring_user@%":
      ensure        => present,
      password_hash => mysql_password($monitoring_pass)
    }

    mysql_grant{"$monitoring_user@%/*.*":
      ensure      => present,
      options     => ['GRANT'],
      privileges  => [ 'REPLICATION CLIENT', 'PROCESS', 'SELECT' ],
      table       => ['*.*'],
      user        => "$monitoring_user@%"
    }

    if $nrpe_checks {
      $overriden_port = $override_options['mysqld']['port']

      $check_port = $overriden_port? {
        ''      => '3306',
        default => $override_options['mysqld']['port'],
      }

      class {'softec_mysql::monitoring':
        host        => 'localhost',
        port        => $check_port,
        user        => $monitoring_user,
        password    => $monitoring_pass,
        user_checks => $nrpe_user_checks
      }
    }
  }

  if $replication_user {
    mysql_user {"$replication_user@%":
      ensure        => present,
      password_hash => mysql_password($replication_pass)
    }

    mysql_grant{"$replication_user@%/*.*":
      ensure      => present,
      options     => ['GRANT'],
      privileges  => [ 'SUPER', 'REPLICATION SLAVE' ],
      table       => ['*.*'],
      user        => "$replication_user@%"
    }
  }
}
