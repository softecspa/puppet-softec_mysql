class softec_mysql::params {

  $default_options  = {
    'mysqld'  => {
      'bind-address'                => '0.0.0.0',
      'open_files_limit'            => '32768',
      'innodb_file_per_table'       => true,
      'log_slave_updates'           => 'OFF',
      'lower_case_table_names'      => '0',
      'skip-external-locking'       => true,
      'skip-federated'              => true,
      'skip-name-resolve'           => true,
      'skip_slave_start'            => false,
      'innodb_rollback_on_timeout'  => 'ON',
      'innodb_lock_wait_timeout'    => '120',
    },
    'mysqld_safe' => {
      'syslog'  => true
    }
  }

}
