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

_uapi(){
local cur prev line opts base
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    line="${COMP_LINE}"
    base="${1##*/}"
    opts="--user --output --help Backup Bandwidth Batch Brand Branding CacheBuster Chkservd Chrome Contactus cPAddons cPGreyList DAV DCV DNS DomainInfo Email ExternalAuthentication Features Fileman Ftp Integration LangPHP Locale Market Mime ModSecurity Mysql Notifications NVData Parser PasswdStrength Postgresql Pushbullet Quota Resellers Session SiteTemplates SSH SSL StatsBar Styles Themes TwoFactorAuth UserManager WebDisk Webmailapps WebVhosts"

case ${prev} in
  --user )
    COMPREPLY=( $(compgen -W "$(awk -F: '($1 ~ /[:alphanum:]/) {print $1}' /etc/domainusers)" -- ${cur}) )
    return 0 ;;

  --output )
    COMPREPLY=( $(compgen -W "json jsonpretty xml yaml" -- ${cur}) )
    return 0 ;;

  Backup )
    COMPREPLY=( $(compgen -W "list_backups" -- ${cur}) )
    return 0 ;;

  Bandwidth )
    COMPREPLY=( $(compgen -W "get_retention_periods query" -- ${cur}) )
    return 0 ;;

  Batch )
    COMPREPLY=( $(compgen -W "strict" -- ${cur}) )
    return 0 ;;

  Brand )
    COMPREPLY=( $(compgen -W "read file get_application_information get_applications get_available_applications get_information_for_applications image include spritelist" -- ${cur}) )
    return 0 ;;

  Branding )
    COMPREPLY=( $(compgen -W "file get_application_information get_applications get_available_applications get_information_for_applications image include spritelist" -- ${cur}) )
    return 0 ;;

  CacheBuster )
    COMPREPLY=( $(compgen -W "read update" -- ${cur}) )
    return 0 ;;

  Chkservd )
    COMPREPLY=( $(compgen -W "get_exim_ports get_exim_ports_ssl" -- ${cur}) )
    return 0 ;;

  Chrome )
    COMPREPLY=( $(compgen -W "get_dom" -- ${cur}) )
    return 0 ;;

  Contactus )
    COMPREPLY=( $(compgen -W "is_enabled" -- ${cur}) )
    return 0 ;;

  cPAddons )
    COMPREPLY=( $(compgen -W "get_available_addons" -- ${cur}) )
    return 0 ;;

  cPGreyList )
    COMPREPLY=( $(compgen -W "disable_all_domains disable_domains enable_all_domains enable_domains has_greylisting_enabled list_domains" -- ${cur}) )
    return 0 ;;

  DAV )
    COMPREPLY=( $(compgen -W "disable_shared_global_addressbook enable_shared_global_addressbook get_calendar_contacts_config has_shared_global_addressbook is_dav_service_enabled is_horde_enabled" -- ${cur}) )
    return 0 ;;

  DCV )
    COMPREPLY=( $(compgen -W "ensure_domains_can_pass_dcv" -- ${cur}) )
    return 0 ;;

  DNS )
    COMPREPLY=( $(compgen -W "ensure_domains_reside_only_locally" -- ${cur}) )
    return 0 ;;

  DomainInfo )
    COMPREPLY=( $(compgen -W "domains_data list_domains single_domain_data" -- ${cur}) )
    return 0 ;;

  Email )
    COMPREPLY=( $(compgen -W "account_name add_auto_responder add_domain_forwarder add_forwarder add_list add_mailman_delegates add_mx add_pop add_spam_filter browse_mailbox change_mx check_fastmail check_pipe_forwarder delete_auto_responder delete_domain_forwarder delete_filter delete_forwarder delete_list delete_mx delete_pop disable_filter disable_spam_assassin disable_spam_autodelete edit_pop_quota enable_filter enable_spam_assassin enable_spam_autodelete fetch_charmaps generate_mailman_otp get_auto_responder get_charsets get_default_email_quota get_disk_usage get_filter get_mailman_delegates get_main_account_disk_usage get_max_email_quota get_max_email_quota_mib get_pop_quota get_spam_settings get_webmail_settings has_delegated_mailman_lists has_plaintext_authentication is_integer list_auto_responders list_default_address list_domain_forwarders list_filters list_filters_backups list_forwarders list_forwarders_backups list_lists list_mail_domains list_mxs list_pops list_pops_with_disk list_system_filter_info passwd_list passwd_pop remove_mailman_delegates reorder_filters set_always_accept set_default_address set_list_privacy_options store_filter suspend_incoming suspend_login trace_filter unsuspend_incoming unsuspend_login verify_password" -- ${cur}) )
    return 0 ;;

  ExternalAuthentication )
    COMPREPLY=( $(compgen -W "add_authn_link configured_modules get_authn_links remove_authn_link" -- ${cur}) )
    return 0 ;;

  Features )
    COMPREPLY=( $(compgen -W "has_feature list_features" -- ${cur}) )
    return 0 ;;

  Fileman )
    COMPREPLY=( $(compgen -W "autocompletedir get_file_content get_file_information list_files save_file_content transcode upload_files" -- ${cur}) )
    return 0 ;;

  Ftp )
    COMPREPLY=( $(compgen -W "add_ftp allows_anonymous_ftp allows_anonymous_ftp_incoming delete_ftp ftp_exists get_ftp_daemon_info get_port get_quota get_welcome_message kill_session list_ftp list_ftp_with_disk list_sessions passwd server_name set_anonymous_ftp set_anonymous_ftp_incoming set_homedir set_quota set_welcome_message" -- ${cur}) )
    return 0 ;;

  Integration )
    COMPREPLY=( $(compgen -W "fetch_url" -- ${cur}) )
    return 0 ;;

  LangPHP )
    COMPREPLY=( $(compgen -W "php_get_installed_versions php_get_system_default_version php_get_vhost_versions php_ini_get_user_basic_directives php_ini_get_user_content php_ini_get_user_paths php_ini_set_user_basic_directives php_ini_set_user_content php_set_vhost_versions" -- ${cur}) )
    return 0 ;;

  Locale )
    COMPREPLY=( $(compgen -W "get_attributes" -- ${cur}) )
    return 0 ;;

  Market )
    COMPREPLY=( $(compgen -W "cancel_pending_ssl_certificate get_all_products get_login_url get_pending_ssl_certificates get_providers_list get_ssl_certificate_if_available process_ssl_pending_queue request_ssl_certificates set_status_of_pending_queue_items set_url_after_checkout start_polling_for_ssl_certificates validate_login_token" -- ${cur}) )
    return 0 ;;

  Mime )
    COMPREPLY=( $(compgen -W "add_handler add_hotlink add_mime add_redirect delete_handler delete_hotlink delete_mime delete_redirect list_handlers list_hotlinks list_mime list_redirects redirect_info" -- ${cur}) )
    return 0 ;;

  ModSecurity )
    COMPREPLY=( $(compgen -W "disable_all_domains disable_domains enable_all_domains enable_domains has_modsecurity_installed list_domains" -- ${cur}) )
    return 0 ;;

  Mysql )
    COMPREPLY=( $(compgen -W "add_host check_database create_database create_user delete_database delete_host delete_user get_privileges_on_database get_restrictions get_server_information locate_server rename_database rename_user repair_database revoke_access_to_database set_password set_privileges_on_database" -- ${cur}) )
    return 0 ;;

  Notifications )
    COMPREPLY=( $(compgen -W "get_notifications_count" -- ${cur}) )
    return 0 ;;

  NVData )
    COMPREPLY=( $(compgen -W "get set" -- ${cur}) )
    return 0 ;;

  Parser )
    COMPREPLY=( $(compgen -W "firstfile_relative_uri" -- ${cur}) )
    return 0 ;;

  PasswdStrength )
    COMPREPLY=( $(compgen -W "get_required_strength" -- ${cur}) )
    return 0 ;;

  Postgresql )
    COMPREPLY=( $(compgen -W "create_database create_user delete_database get_restrictions grant_all_privileges rename_database rename_user rename_user_no_password revoke_all_privileges set_password" -- ${cur}) )
    return 0 ;;

  Pushbullet )
    COMPREPLY=( $(compgen -W "send_test_message" -- ${cur}) )
    return 0 ;;

  Quota )
    COMPREPLY=( $(compgen -W "get_quota_info" -- ${cur}) )
    return 0 ;;

  Resellers )
    COMPREPLY=( $(compgen -W "list_accounts" -- ${cur}) )
    return 0 ;;

  Session )
    COMPREPLY=( $(compgen -W "create_temp_user" -- ${cur}) )
    return 0 ;;

  SiteTemplates )
    COMPREPLY=( $(compgen -W "list_site_templates list_user_settings publish" -- ${cur}) )
    return 0 ;;

  SSH )
    COMPREPLY=( $(compgen -W "get_port" -- ${cur}) )
    return 0 ;;

  SSL )
    COMPREPLY=( $(compgen -W "check_shared_cert delete_cert delete_csr delete_key delete_ssl disable_mail_sni enable_mail_sni fetch_best_for_domain fetch_cert_info fetch_key_and_cabundle_for_certificate find_certificates_for_key find_csrs_for_key generate_cert generate_csr generate_key get_cabundle get_cn_name install_ssl installed_host installed_hosts is_mail_sni_supported is_sni_supported list_certs list_csrs list_keys list_ssl_items mail_sni_status rebuild_mail_sni_config rebuildssldb set_cert_friendly_name set_csr_friendly_name set_key_friendly_name set_primary_ssl set_ssl_share show_cert show_csr show_key upload_cert upload_key" -- ${cur}) )
    return 0 ;;

  StatsBar )
    COMPREPLY=( $(compgen -W "get_stats" -- ${cur}) )
    return 0 ;;

  Styles )
    COMPREPLY=( $(compgen -W "current list set_default update" -- ${cur}) )
    return 0 ;;

  Themes )
    COMPREPLY=( $(compgen -W "get_theme_base list update" -- ${cur}) )
    return 0 ;;

  TwoFactorAuth )
    COMPREPLY=( $(compgen -W "generate_user_configuration get_user_configuration remove_user_configuration set_user_configuration" -- ${cur}) )
    return 0 ;;

  UserManager )
    COMPREPLY=( $(compgen -W "check_account_conflicts create_user delete_user dismiss_merge edit_user list_users lookup_user merge_service_account unlink_service_account" -- ${cur}) )
    return 0 ;;

  WebDisk )
    COMPREPLY=( $(compgen -W "set_homedir set_password set_permissions" -- ${cur}) )
    return 0 ;;

  Webmailapps )
    COMPREPLY=( $(compgen -W "listwebmailapps" -- ${cur}) )
    return 0 ;;

  WebVhosts )
    COMPREPLY=( $(compgen -W "list_domains" -- ${cur}) )
    return 0 ;;

  *) ;;
esac

COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
return 0;
}
complete -F _uapi uapi;
