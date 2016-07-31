#!/bin/bash
#                                                          +----+----+----+----+
#                                                          |    |    |    |    |
# Author: Mark David Scott Cunningham                      | M  | D  | S  | C  |
#                                                          +----+----+----+----+
# Created: 2016-06-21
# Updated: 2016-06-28
#
# Purpose: Add bash tab completion to WHM/cPanel command line api utilities
#

#NOTES
# http://www.linuxjournal.com/content/more-using-bash-complete-command
# https://blog.heckel.xyz/2015/03/24/bash-completion-with-sub-commands-and-dynamic-options/

_whmapi1(){
local cur prev opts line base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    line="${COMP_LINE}"
    base="${1##*/}"
    opts="--help --output _getpkgextensionform abort_transfer_session accesshash accountsummary acctcounts add_configclusterserver add_override_features_for_user adddns addips addpkg addzonerecord addzonerecord analyze_transfer_session_remote applist authorizesshkey available_transfer_modules background_mysql_upgrade_status backup_config_get backup_config_set backup_date_list backup_destination_add backup_destination_delete backup_destination_get backup_destination_list backup_destination_set backup_destination_validate backup_set_list backup_skip_users_all backup_skip_users_all_status backup_user_list batch changepackage check_remote_ssh_connection configurebackgroundprocesskiller configureservice  convert_addon_fetch_domain_details  convert_addon_initiate_conversion  convert_addon_list_addon_domains convertopensshtoputty cpgreylist_is_server_netblock_trusted cpgreylist_list_entries_for_common_mail_provider cpgreylist_load_common_mail_providers_config cpgreylist_save_common_mail_providers_config cpgreylist_status cpgreylist_trust_entries_for_common_mail_provider cpgreylist_untrust_entries_for_common_mail_provider cphulk_status create_cpgreylist_trusted_host create_cphulk_record create_featurelist create_integration_group create_integration_link create_remote_root_transfer_session create_remote_user_transfer_session create_user_session createacct current_mysql_version delete_configclusterserver delete_cpgreylist_trusted_host delete_cphulk_record delete_featurelist delete_hook delete_rpm_version deletesshkey delip disable_authentication_provider disable_cpgreylist disable_cphulk disable_failing_authentication_providers disable_mail_sni disable_market_provider domainuserdata dumpzone edit_hook edit_rpm_version editpkg editquota editzonerecord emailtrack_search emailtrack_stats emailtrack_user_stats enable_authentication_provider enable_cpgreylist enable_cphulk enable_mail_sni enable_market_provider enable_monitor_all_enabled_services enqueue_transfer_item exim_configuration_check fetch_mail_queue fetch_service_ssl_components fetch_ssl_vhosts fetch_transfer_session_log fetch_vhost_ssl_components fetchcrtinfo fetchsslinfo flush_cphulk_login_history flush_cphulk_login_history_for_ips forcepasswordchange generate_mobileconfig generatesshkeypair generatessl get_adjusted_market_providers_products get_appconfig_application_list get_available_authentication_providers get_available_featurelists get_available_tiers get_best_ssldomain_for_service get_cphulk_brutes get_cphulk_excessive_brutes get_cphulk_failed_logins get_feature_metadata get_feature_names get_featurelist_data get_integration_link_user_config get_market_providers_commission_config get_market_providers_list get_market_providers_product_metadata get_market_providers_products get_nameserver_config get_password_strength get_provider_client_configurations get_provider_configuration_fields get_remote_access_hash get_rpm_version_data get_transfer_session_state get_tweaksetting get_update_availability get_user_email_forward_destination get_users_authn_linked_accounts get_users_links getdiskusage getfeaturelist gethostname getlongtermsupport getpkginfo getresellerips getzonerecord has_digest_auth has_mycnf_for_cpuser hold_outgoing_email importsshkey install_service_ssl_certificate installable_mysql_versions installssl ipv6_disable_account ipv6_enable_account ipv6_range_add ipv6_range_edit ipv6_range_list ipv6_range_remove ipv6_range_usage is_sni_supported killdns killpkg latest_available_mysql_version limitbw link_user_authn_provider list_configclusterservers list_cparchive_files list_database_users list_databases list_hooks list_integration_groups list_integration_links  list_mysql_databases_and_users list_pops_for list_rpms listaccts listacls listcrts listips listlockedaccounts listmxs listpkgs listresellers listsshkeys listsuspended listzones load_cpgreylist_config load_cphulk_config load_style loadavg lookupnsip mail_sni_status manage_features matchpkgs modifyacct modsec_add_rule modsec_add_vendor modsec_batch_settings modsec_clone_rule modsec_deploy_all_rule_changes modsec_deploy_rule_changes modsec_deploy_settings_changes modsec_disable_rule modsec_disable_vendor modsec_disable_vendor_configs modsec_disable_vendor_updates modsec_discard_all_rule_changes modsec_discard_rule_changes modsec_edit_rule modsec_enable_vendor modsec_enable_vendor_configs modsec_enable_vendor_updates modsec_get_config_text modsec_get_configs modsec_get_configs_with_changes_pending modsec_get_log modsec_get_rules modsec_get_settings modsec_get_vendors modsec_is_installed modsec_make_config_active modsec_make_config_inactive modsec_preview_vendor modsec_remove_rule modsec_remove_setting modsec_remove_vendor modsec_report_rule modsec_set_config_text modsec_set_setting modsec_undisable_rule modsec_update_vendor myprivs nameserver_add nat_checkip nat_set_public_ip nvget nvset passwd pause_transfer_session php_get_handlers php_get_installed_versions php_get_system_default_version php_get_vhost_versions php_ini_get_content php_ini_get_directives php_ini_set_content php_ini_set_directives php_set_handler php_set_system_default_version php_set_vhost_versions read_cpgreylist_deferred_entries read_cpgreylist_trusted_host read_cphulk_records read_featurelist reboot rebuild_mail_sni_config rebuildinstalledssldb rebuildusersssldb release_outgoing_email remote_basic_credential_check remote_mysql_create_profile remote_mysql_create_profile_via_ssh remote_mysql_delete_profile remote_mysql_initiate_profile_activation remote_mysql_monitor_profile_activation remote_mysql_read_profile remote_mysql_read_profiles remote_mysql_update_profile remote_mysql_validate_profile remove_in_progress_exim_config_edit remove_integration_group remove_integration_link remove_logo remove_override_features_for_user removeacct removezonerecord rename_mysql_database rename_mysql_user rename_postgresql_database rename_postgresql_user reorder_hooks resellerstats reset_service_ssl_certificate resetzone resolvedomainname restartservice restore_modules_summary restore_queue_activate restore_queue_add_task restore_queue_clear_all_completed_tasks restore_queue_clear_all_failed_tasks restore_queue_clear_all_pending_tasks restore_queue_clear_all_tasks restore_queue_clear_completed_task restore_queue_clear_pending_task restore_queue_is_active restore_queue_list_active restore_queue_list_completed restore_queue_list_pending restore_queue_state restoreaccount retrieve_transfer_session_remote_analysis save_cpgreylist_config save_cphulk_config save_spamd_config save_style saveacllist savemxs send_test_posturl send_test_pushbullet_note servicestatus set_cpanel_updates set_digest_auth set_local_mysql_root_password set_market_product_attribute set_market_provider_commission_id set_mysql_password set_postgresql_password set_primary_servername set_provider_client_configurations set_tier set_tweaksetting set_user_email_forward_destination setacls sethostname setminimumpasswordstrengths setresellerips setresellerlimits setresellermainip setresellernameservers setresellerpackagelimit setresolvers setsiteip setupreseller showbw start_background_mysql_upgrade start_background_pkgacct start_transfer_session suspend_outgoing_email suspendacct suspendreseller systemloadavg terminatereseller ticket_grant ticket_list ticket_revoke ticket_ssh_test toggle_user_backup_state transfer_module_schema twofactorauth_disable_policy twofactorauth_enable_policy twofactorauth_generate_tfa_config twofactorauth_get_issuer twofactorauth_get_user_configs twofactorauth_policy_status twofactorauth_remove_user_config twofactorauth_set_issuer twofactorauth_set_tfa_config unlink_user_authn_provider unsetupreseller unsuspend_outgoing_email unsuspendacct unsuspendreseller update_configclusterserver update_featurelist update_integration_link_token update_updateconf validate_current_installed_exim_config validate_exim_configuration_syntax validate_system_user verify_aim_access verify_icq_access verify_oscar_access verify_posturl_access verify_pushbullet_access verify_user_has_feature version"

case ${prev} in
  user)
    local userlist=$(awk -F: '($1 ~ /[:alphanum:]/) {print $1}' /etc/domainusers)
    COMPREPLY=( $(compgen -W "${userlist}" -- ${cur}) )
    return 0 ;;

  --output )
    COMPREPLY=( $(compgen -W "json jsonpretty xml yaml" -- ${cur}) )
    return 0 ;;

  _getpkgextensionform )
    COMPREPLY=( $(compgen -W "pkg" -- ${cur}) )
    return 0 ;;

  abort_transfer_session )
    COMPREPLY=( $(compgen -W "transfer_session_id" -- ${cur}) )
    return 0 ;;

  accesshash )
    COMPREPLY=( $(compgen -W "generate user" -- ${cur}) )
    return 0 ;;

  accountsummary )
    COMPREPLY=( $(compgen -W "domain user" -- ${cur}) )
    return 0 ;;

  acctcounts )
    COMPREPLY=( $(compgen -W "user" -- ${cur}) )
    return 0 ;;

  add_configclusterserver )
    COMPREPLY=( $(compgen -W "key name user" -- ${cur}) )
    return 0 ;;

  add_override_features_for_user )
    COMPREPLY=( $(compgen -W "user features" -- ${cur}) )
    return 0 ;;

  adddns )
    COMPREPLY=( $(compgen -W "domain ip template trueowner" -- ${cur}) )
    return 0 ;;

  addips )
    COMPREPLY=( $(compgen -W "ips netmask excludes" -- ${cur}) )
    return 0 ;;

  addpkg )
    COMPREPLY=( $(compgen -W "name featurelist quota ip cgi cpmod language maxftp maxsql maxpop maxlists maxsub maxpark maxaddon hasshell bwlimit MAX_EMAIL_PER_HOUR MAX_DEFER_FAIL_PERCENTAGE digestauth _PACKAGE_EXTENSIONS" -- ${cur}) )
    return 0 ;;

  addzonerecord )
    COMPREPLY=( $(compgen -W "domain name class ttl type" -- ${cur}) )
    return 0 ;;

  analyze_transfer_session_remote )
    COMPREPLY=( $(compgen -W "transfer_session_id" -- ${cur}) )
    return 0 ;;

  applist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  authorizesshkey )
    COMPREPLY=( $(compgen -W "file text user authorize options" -- ${cur}) )
    return 0 ;;

  available_transfer_modules )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  background_mysql_upgrade_status )
    COMPREPLY=( $(compgen -W "upgrade_id" -- ${cur}) )
    return 0 ;;

  backup_config_get )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  backup_config_set )
    COMPREPLY=( $(compgen -W "backup_daily_enable postbackup backupenable backup_monthly_enable usebinarypkgacct backuptype backup_daily_retention backupdays backup_monthly_dates backupfiles backupaccts prebackup psqlbackup keeplocal localzonesonly backupbwdata dieifnotmounted backuplogs linkdest backupsuspendedaccounts gziprsyncopts backupdir errorthreshhold backupmount mysqlbackup backup_monthly_retention" -- ${cur}) )
    return 0 ;;

  backup_date_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  backup_destination_add )
    COMPREPLY=( $(compgen -W "name type disabled upload_system_backup" -- ${cur}) )
    return 0 ;;

  backup_destination_delete )
    COMPREPLY=( $(compgen -W "id" -- ${cur}) )
    return 0 ;;

  backup_destination_get )
    COMPREPLY=( $(compgen -W "id" -- ${cur}) )
    return 0 ;;

  backup_destination_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  backup_destination_set )
    COMPREPLY=( $(compgen -W "id name type disable disable_reason upload_system_backup" -- ${cur}) )
    return 0 ;;

  backup_destination_validate )
    COMPREPLY=( $(compgen -W "id disableonfail" -- ${cur}) )
    return 0 ;;

  backup_set_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  backup_skip_users_all )
    COMPREPLY=( $(compgen -W "backupversion state" -- ${cur}) )
    return 0 ;;

  backup_skip_users_all_status )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  backup_user_list )
    COMPREPLY=( $(compgen -W "restore_point" -- ${cur}) )
    return 0 ;;

  batch )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  changepackage )
    COMPREPLY=( $(compgen -W "user pkg" -- ${cur}) )
    return 0 ;;

  check_remote_ssh_connection )
    COMPREPLY=( $(compgen -W "host port" -- ${cur}) )
    return 0 ;;

  configurebackgroundprocesskiller )
    COMPREPLY=( $(compgen -W "processes_to_kill trusted_users" -- ${cur}) )
    return 0 ;;

  configureservice )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  convert_addon_fetch_domain_details )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  convert_addon_initiate_conversion )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  convert_addon_list_addon_domains )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  convertopensshtoputty )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_is_server_netblock_trusted )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_list_entries_for_common_mail_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_load_common_mail_providers_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_save_common_mail_providers_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_status )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_trust_entries_for_common_mail_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cpgreylist_untrust_entries_for_common_mail_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  cphulk_status )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_cpgreylist_trusted_host )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_cphulk_record )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_featurelist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_integration_group )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_integration_link )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_remote_root_transfer_session )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_remote_user_transfer_session )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  create_user_session )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  createacct )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  current_mysql_version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delete_configclusterserver )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delete_cpgreylist_trusted_host )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delete_cphulk_record )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delete_featurelist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delete_hook )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delete_rpm_version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  deletesshkey )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  delip )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  disable_authentication_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  disable_cpgreylist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  disable_cphulk )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  disable_failing_authentication_providers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  disable_mail_sni )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  disable_market_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  domainuserdata )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  dumpzone )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  edit_hook )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  edit_rpm_version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  editpkg )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  editquota )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  editzonerecord )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  emailtrack_search )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  emailtrack_stats )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  emailtrack_user_stats )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enable_authentication_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enable_cpgreylist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enable_cphulk )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enable_mail_sni )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enable_market_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enable_monitor_all_enabled_services )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  enqueue_transfer_item )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  exim_configuration_check )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetch_mail_queue )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetch_service_ssl_components )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetch_ssl_vhosts )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetch_transfer_session_log )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetch_vhost_ssl_components )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetchcrtinfo )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  fetchsslinfo )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  flush_cphulk_login_history )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  flush_cphulk_login_history_for_ips )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  forcepasswordchange )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  generate_mobileconfig )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  generatesshkeypair )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  generatessl )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_adjusted_market_providers_products )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_appconfig_application_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_available_authentication_providers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_available_featurelists )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_available_tiers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_best_ssldomain_for_service )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_cphulk_brutes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_cphulk_excessive_brutes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_cphulk_failed_logins )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_feature_metadata )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_feature_names )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_featurelist_data )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_integration_link_user_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_market_providers_commission_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_market_providers_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_market_providers_product_metadata )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_market_providers_products )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_nameserver_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_password_strength )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_provider_client_configurations )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_provider_configuration_fields )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_remote_access_hash )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_rpm_version_data )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_transfer_session_state )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_tweaksetting )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_update_availability )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_user_email_forward_destination )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_users_authn_linked_accounts )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  get_users_links )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  getdiskusage )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  getfeaturelist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  gethostname )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  getlongtermsupport )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  getpkginfo )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  getresellerips )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  getzonerecord )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  has_digest_auth )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  has_mycnf_for_cpuser )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  hold_outgoing_email )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  importsshkey )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  install_service_ssl_certificate )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  installable_mysql_versions )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  installssl )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_disable_account )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_enable_account )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_range_add )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_range_edit )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_range_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_range_remove )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ipv6_range_usage )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  is_sni_supported )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  killdns )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  killpkg )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  latest_available_mysql_version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  limitbw )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  link_user_authn_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_configclusterservers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_cparchive_files )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_database_users )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_databases )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_hooks )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_integration_groups )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_integration_links )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_mysql_databases_and_users )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_pops_for )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  list_rpms )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listaccts )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listacls )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listcrts )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listips )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listlockedaccounts )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listmxs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listpkgs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listresellers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listsshkeys )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listsuspended )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  listzones )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  load_cpgreylist_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  load_cphulk_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  load_style )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  loadavg )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  lookupnsip )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  mail_sni_status )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  manage_features )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  matchpkgs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modifyacct )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_add_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_add_vendor )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_batch_settings )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_clone_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_deploy_all_rule_changes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_deploy_rule_changes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_deploy_settings_changes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_disable_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_disable_vendor )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_disable_vendor_configs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_disable_vendor_updates )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_discard_all_rule_changes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_discard_rule_changes )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_edit_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_enable_vendor )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_enable_vendor_configs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_enable_vendor_updates )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_config_text )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_configs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_configs_with_changes_pending )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_log )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_rules )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_settings )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_get_vendors )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_is_installed )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_make_config_active )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_make_config_inactive )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_preview_vendor )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_remove_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_remove_setting )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_remove_vendor )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_report_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_set_config_text )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_set_setting )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_undisable_rule )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  modsec_update_vendor )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  myprivs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  nameserver_add )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  nat_checkip )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  nat_set_public_ip )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  nvget )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  nvset )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  passwd )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  pause_transfer_session )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_get_handlers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_get_installed_versions )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_get_system_default_version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_get_vhost_versions )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_ini_get_content )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_ini_get_directives )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_ini_set_content )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_ini_set_directives )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_set_handler )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_set_system_default_version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  php_set_vhost_versions )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  read_cpgreylist_deferred_entries )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  read_cpgreylist_trusted_host )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  read_cphulk_records )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  read_featurelist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  reboot )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rebuild_mail_sni_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rebuildinstalledssldb )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rebuildusersssldb )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  release_outgoing_email )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_basic_credential_check )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_create_profile )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_create_profile_via_ssh )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_delete_profile )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_initiate_profile_activation )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_monitor_profile_activation )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_read_profile )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_read_profiles )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_update_profile )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remote_mysql_validate_profile )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remove_in_progress_exim_config_edit )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remove_integration_group )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remove_integration_link )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remove_logo )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  remove_override_features_for_user )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  removeacct )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  removezonerecord )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rename_mysql_database )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rename_mysql_user )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rename_postgresql_database )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  rename_postgresql_user )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  reorder_hooks )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  resellerstats )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  reset_service_ssl_certificate )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  resetzone )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  resolvedomainname )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restartservice )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_modules_summary )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_activate )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_add_task )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_clear_all_completed_tasks )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_clear_all_failed_tasks )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_clear_all_pending_tasks )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_clear_all_tasks )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_clear_completed_task )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_clear_pending_task )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_is_active )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_list_active )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_list_completed )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_list_pending )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restore_queue_state )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  restoreaccount )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  retrieve_transfer_session_remote_analysis )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  save_cpgreylist_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  save_cphulk_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  save_spamd_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  save_style )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  saveacllist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  savemxs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  send_test_posturl )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  send_test_pushbullet_note )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  servicestatus )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_cpanel_updates )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_digest_auth )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_local_mysql_root_password )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_market_product_attribute )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_market_provider_commission_id )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_mysql_password )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_postgresql_password )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_primary_servername )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_provider_client_configurations )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_tier )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_tweaksetting )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  set_user_email_forward_destination )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setacls )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  sethostname )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setminimumpasswordstrengths )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setresellerips )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setresellerlimits )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setresellermainip )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setresellernameservers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setresellerpackagelimit )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setresolvers )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setsiteip )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  setupreseller )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  showbw )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  start_background_mysql_upgrade )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  start_background_pkgacct )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  start_transfer_session )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  suspend_outgoing_email )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  suspendacct )
    COMPREPLY=( $(compgen -W "user reason disallowun" -- ${cur}) )
    return 0 ;;

  suspendreseller )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  systemloadavg )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  terminatereseller )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ticket_grant )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ticket_list )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ticket_revoke )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  ticket_ssh_test )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  toggle_user_backup_state )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  transfer_module_schema )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_disable_policy )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_enable_policy )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_generate_tfa_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_get_issuer )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_get_user_configs )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_policy_status )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_remove_user_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_set_issuer )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  twofactorauth_set_tfa_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  unlink_user_authn_provider )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  unsetupreseller )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  unsuspend_outgoing_email )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  unsuspendacct )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  unsuspendreseller )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  update_configclusterserver )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  update_featurelist )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  update_integration_link_token )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  update_updateconf )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  validate_current_installed_exim_config )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  validate_exim_configuration_syntax )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  validate_system_user )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  verify_aim_access )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  verify_icq_access )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  verify_oscar_access )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  verify_posturl_access )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  verify_pushbullet_access )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  verify_user_has_feature )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  version )
    COMPREPLY=( $(compgen -W "" -- ${cur}) )
    return 0 ;;

  *) ;;
esac

COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
return 0;
}
complete -F _whmapi1 whmapi1;
