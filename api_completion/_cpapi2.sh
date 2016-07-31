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

_cpapi2(){
local cur prev opts line base
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  line="${COMP_LINE}"
  base="${1##*/}"
  opts="--user --output --help AddonDomain Bandwidth Branding CSVImport Contactus Cron CustInfo DBmap DKIMUI DiskUsage DomainLookup Email EmailTrack Encoding Fileman ForcePassword Frontpage Ftp Gpg Htaccess LangMods Locale Logaholic Mime MysqlFE NVData Net News PHPINI Park Passwd PasswdStrength Postgres RoR SPFUI SSH SSL SourceIPCheck Stats StatsBar SubDomain Themes UI WebDisk ZoneEdit"

case ${prev} in
  --user )
    COMPREPLY=( $(compgen -W "$(awk -F: '($1 ~ /[:alphanum:]/) {print $1}' /etc/domainusers)" -- ${cur}) )
    return 0 ;;

  --output )
    COMPREPLY=( $(compgen -W "json jsonpretty xml yaml" -- ${cur}) )
    return 0 ;;

  AddonDomain )
    COMPREPLY=( $(compgen -W "addaddondomain deladdondomain listaddondomain" -- ${cur}) )
    return 0 ;;

  Bandwidth )
    COMPREPLY=( $(compgen -W "addhttpbandwidth getbwdata" -- ${cur}) )
    return 0 ;;

  Branding )
    COMPREPLY=( $(compgen -W "addbrandingobj applist brandingeditor createpkg cssmerge delbrandingobj delpkg gensprites getbrandingpkg getbrandingpkgstatus getdefaultbrandingpkg installbrandingpkgs installimages killimgs listimgtypes listobjecttypes preloadconf resetall resetcss resethtml resolve_file resolvelocalcss savelocalcss setbrandingpkgstatus showpkgs" -- ${cur}) )
    return 0 ;;

  CSVImport )
    COMPREPLY=( $(compgen -W "columnchoices configimport data fetchimportdata loaddata processdata uploadimport isenabled" -- ${cur}) )
    return 0 ;;

  Contactus )
    COMPREPLY=( $(compgen -W "isenabled" -- ${cur}) )
    return 0 ;;

  Cron )
    COMPREPLY=( $(compgen -W "add_line edit_line fetchcron get_email listcron remove_line" -- ${cur}) )
    return 0 ;;

  CustInfo )
    COMPREPLY=( $(compgen -W "contactemails contactprefs displaycontactinfo" -- ${cur}) )
    return 0 ;;

  DBmap )
    COMPREPLY=( $(compgen -W "status" -- ${cur}) )
    return 0 ;;

  DKIMUI )
    COMPREPLY=( $(compgen -W "available getrecords install installed" -- ${cur}) )
    return 0 ;;

  DiskUsage )
    COMPREPLY=( $(compgen -W "buildcache clearcache fetch_raw_disk_usage fetchdiskusage" -- ${cur}) )
    return 0 ;;

  DomainLookup )
    COMPREPLY=( $(compgen -W "countbaseddomains getbasedomains getdocroot getdocroots" -- ${cur}) )
    return 0 ;;

  Email )
    COMPREPLY=( $(compgen -W "accountname adddomainforward addforward addmx addpop browseboxes changemx checkmaindiscard clearpopcache deletefilter delforward delmx delpop disablefilter editquota enablefilter fetchautoresponder fetchcharmaps filteractions filterlist filtername filterrules get_archiving_configuration get_archiving_default_configuration get_archiving_types get_default_email_quota get_email_signing get_max_email_quota getabsbrowsedir getalwaysaccept getdiskusage getmxcheck has_delegated_mailman_lists list_system_filter_info listaliasbackups listautoresponders listdefaultaddresses listdomainforwards listfilterbackups listfilters listforwards listlists listmaildomains listmx listmxs listpops listpopssingle listpopswithdisk listpopswithimage loadfilter passwdpop reorderfilters set_archiving_configuration set_archiving_default_configuration set_email_signing setalwaysaccept setdefaultaddress setmxcheck storefilter search stats" -- ${cur}) )
    return 0 ;;

  EmailTrack )
    COMPREPLY=( $(compgen -W "search stats" -- ${cur}) )
    return 0 ;;

  Encoding )
    COMPREPLY=( $(compgen -W "get_encodings guess_file" -- ${cur}) )
    return 0 ;;

  Fileman )
    COMPREPLY=( $(compgen -W "autocompletedir fileop getabsdir getdir getdiractions getdiskinfo getedittype getfileactions getpath listfiles mkdir mkfile savefile search statfiles uploadfiles" -- ${cur}) )
    return 0 ;;

  ForcePassword )
    COMPREPLY=( $(compgen -W "get_force_password_flags" -- ${cur}) )
    return 0 ;;

  Frontpage )
    COMPREPLY=( $(compgen -W "fpenabled" -- ${cur}) )
    return 0 ;;

  Ftp )
    COMPREPLY=( $(compgen -W "addftp delftp listftp listftpsessions listftpwithdisk passwd" -- ${cur}) )
    return 0 ;;

  Gpg )
    COMPREPLY=( $(compgen -W "listgpgkeys listsecretgpgkeys number_of_private_keys" -- ${cur}) )
    return 0 ;;

  Htaccess )
    COMPREPLY=( $(compgen -W "listuser" -- ${cur}) )
    return 0 ;;

  LangMods )
    COMPREPLY=( $(compgen -W "getarchname getkey getprefix install langlist list_available list_installed magic_status pre_run search setup uninstall" -- ${cur}) )
    return 0 ;;

  Locale )
    COMPREPLY=( $(compgen -W "get_encoding get_html_dir_attr get_locale_name get_user_locale get_user_locale_name" -- ${cur}) )
    return 0 ;;

  Logaholic )
    COMPREPLY=( $(compgen -W "adduser adduserprofile deleteuser deleteuserprofile edituser fetchuser listuserprofiles logaholiclink" -- ${cur}) )
    return 0 ;;

  Mime )
    COMPREPLY=( $(compgen -W "list_hotlinks listhandlers listmime listredirects redirectname" -- ${cur}) )
    return 0 ;;

  MysqlFE )
    COMPREPLY=( $(compgen -W "authorizehost changedbuserpassword createdb createdbuser dbuserexists deauthorizehost deletedb deletedbuser getalldbsinfo getalldbusersanddbs getdbuserprivileges getdbusers gethosts getmysqlprivileges getmysqlserverprivileges has_mycnf_for_cpuser listdbs listdbsbackup listhosts listusers listusersindb revokedbuserprivileges setdbuserprivileges" -- ${cur}) )
    return 0 ;;

  NVData )
    COMPREPLY=( $(compgen -W "get set" -- ${cur}) )
    return 0 ;;

  Net )
    COMPREPLY=( $(compgen -W "dnszone" -- ${cur}) )
    return 0 ;;

  News )
    COMPREPLY=( $(compgen -W "does_news_exist does_news_type_exist" -- ${cur}) )
    return 0 ;;

  PHPINI )
    COMPREPLY=( $(compgen -W "getalloptions" -- ${cur}) )
    return 0 ;;

  Park )
    COMPREPLY=( $(compgen -W "listaddondomains listparkeddomains park" -- ${cur}) )
    return 0 ;;

  Passwd )
    COMPREPLY=( $(compgen -W "change_password appstrengths get_password_strength" -- ${cur}) )
    return 0 ;;

  PasswdStrength )
    COMPREPLY=( $(compgen -W "appstrengths get_password_strength" -- ${cur}) )
    return 0 ;;

  Postgres )
    COMPREPLY=( $(compgen -W "listdbs listusers listusersindb" -- ${cur}) )
    return 0 ;;

  RoR )
    COMPREPLY=( $(compgen -W "addapp changeapp importrails listapps listrewrites needsimport removeapp removerewrite restartapp setuprewrite softrestartapp startapp" -- ${cur}) )
    return 0 ;;

  SPFUI )
    COMPREPLY=( $(compgen -W "available count_settings entries_complete get_raw_record getmainserverip install installed list_settings load_current_values" -- ${cur}) )
    return 0 ;;

  SSH )
    COMPREPLY=( $(compgen -W "authkey converttoppk delkey fetchkey genkey genkey_legacy importkey" -- ${cur}) )
    return 0 ;;

  SSL )
    COMPREPLY=( $(compgen -W "fetchcabundle gencrt gencsr genkey getcnname installssl listcrts listcsrs listkeys listsslitems uploadcrt" -- ${cur}) )
    return 0 ;;

  SourceIPCheck )
    COMPREPLY=( $(compgen -W "addip delip getaccount listips loadsecquestions resetsecquestions samplequestions" -- ${cur}) )
    return 0 ;;

  Stats )
    COMPREPLY=( $(compgen -W "getmonthlybandwidth getmonthlydomainbandwidth getthismonthsbwusage lastapachehits lastvisitors listanalog listawstats listlastvisitors listrawlogs listurchin getrowcounter rowcounter setrowcounter" -- ${cur}) )
    return 0 ;;

  StatsBar )
    COMPREPLY=( $(compgen -W "getrowcounter rowcounter setrowcounter" -- ${cur}) )
    return 0 ;;

  SubDomain )
    COMPREPLY=( $(compgen -W "addsubdomain changedocroot delsubdomain getreservedsubdomains listsubdomains" -- ${cur}) )
    return 0 ;;

  Themes )
    COMPREPLY=( $(compgen -W "apply_new_theme does_cpanel_theme_exist get_available_themes get_themes_list" -- ${cur}) )
    return 0 ;;

  UI )
    COMPREPLY=( $(compgen -W "available getrecords install installed available count_settings entries_complete get_raw_record getmainserverip install installed list_settings load_current_values dynamicincludelist includelist listform paginate" -- ${cur}) )
    return 0 ;;

  WebDisk )
    COMPREPLY=( $(compgen -W "addwebdisk delwebdisk hasdigest listwebdisks passwdwebdisk set_digest_auth set_homedir set_perms" -- ${cur}) )
    return 0 ;;

  ZoneEdit )
    COMPREPLY=( $(compgen -W "add_zone_record edit_zone_record fetch_cpanel_generated_domains fetchzone fetchzone_records fetchzones get_zone_record remove_zone_record resetzone" -- ${cur}) )
    return 0 ;;

  *) ;;
esac

COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
return 0;
}
complete -F _cpapi2 cpapi2;
