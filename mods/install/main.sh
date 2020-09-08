#!/bin/bash
############# https://github.com/plexguide/PlexGuide.com/graphs/contributors ###
mkdir -p /pg/var/
if [[ -e "/pg/var/pg.noinstall" ]]; then pgcmd=true; else pgcmd=false; fi
rm -rf /pg/var/pg.noinstall
################################################################################
if [[ ! -e "/usr/bin/docker" ]]; then echo "" > /bin/docker; else rm -rf /bin/docker; fi
if [[ -e "/bin/docker" ]]; then chmod 0755 /bin/docker && chown 1000:1000 /bin/docker; fi
################################################################################
if [[ "$pgcmd" != "true" ]]; then
rm -rf /pg/mods
rm -rf /pg/tmp/checkout
git clone -b alpha --single-branch https://github.com/johnkennyuk/PlexGuide.com.git /pg/tmp/checkout
mv -f /pg/tmp/checkout/mods /pg; fi
################################################################################
fpath="/pg/mods/functions"; source "$fpath"/install_sudocheck; install_sudocheck
################################################################################
bash "$fpath"/.create.sh; source "$fpath"/.master.sh
################################################################################

#$echo "COMMAND IS - $pgcmd"
if [[ "$pgcmd" != "true" ]]; then

common_message "🌎 INSTALLING: PlexGuide.com GNUv3 License" "By Installing PlexGuide, you are agreeing to the terms and conditions of the
GNUv3 License!

If you have a chance to donate, please visit https://plexguide.com/donate

At anytime you can Press CTRL+Z to STOP the Installation"
common_timer_v2 "1" ## set back to 5
fi

################################################################################
mkdir -p /pg/var/install/
install_check

common_install install_folders
install_cmds
#install_oldpg ## not need unless we come out with PG11+ that requires a block
common_install install_drivecheck
common_install install_webservercheck
common_install install_oscheck
common_install install_basepackage
common_install install_pyansible
common_install install_dependency

# ansible-playbook /pg/mods/motd/motd.yml

common_install install_docker
common_install install_docker_start
common_install install_rclone
common_install install_mergerfs
common_install install_gcloud_sdk
common_install install_nvidia

# Pull Apps First Time # Personal Not Required #################################
if [[ ! -e /pg/var/.first.app.pull ]]; then
common_header "🚀  Pulling Applications for the 1st Time"
sleep 1.5
apps_interface_start
sapp=primary
repo1=$(cat /pg/var/repos/repo.${sapp}1)
repo2=$(cat /pg/var/repos/repo.${sapp}2)
common_header "💬 Pulling Repo - $sapp"
rm -rf /pg/var/$sapp
git clone -b ${repo2} --single-branch https://github.com/${repo1}.git /pg/var/$sapp
common_fcreate_silent /pg/var/$sapp
bash /pg/mods/functions/.create.sh 1>/dev/null 2>&1
bash /pg/mods/functions/.$sapp_apps.sh 1>/dev/null 2>&1

sapp=community
repo1=$(cat /pg/var/repos/repo.${sapp}1)
repo2=$(cat /pg/var/repos/repo.${sapp}2)
common_header "💬 Pulling Repo - $sapp"
rm -rf /pg/var/$sapp
git clone -b ${repo2} --single-branch https://github.com/${repo1}.git /pg/var/$sapp
common_fcreate_silent /pg/var/$sapp
bash /pg/mods/functions/.create.sh 1>/dev/null 2>&1
bash /pg/mods/functions/.$sapp_apps.sh 1>/dev/null 2>&1

sapp=personal
repo1=$(cat /pg/var/repos/repo.${sapp}1)
repo2=$(cat /pg/var/repos/repo.${sapp}2)
common_header "💬 Pulling Repo - $sapp"
rm -rf /pg/var/$sapp
git clone -b ${repo2} --single-branch https://github.com/${repo1}.git /pg/var/$sapp
common_fcreate_silent /pg/var/$sapp
bash /pg/mods/functions/.create.sh 1>/dev/null 2>&1
bash /pg/mods/functions/.$sapp_apps.sh 1>/dev/null 2>&1
common_header "🚀  First Time App Pull Completed!"

touch /pg/var/.first.app.pull
fi
############# DO NOT ACTIVE TILL PGUNION
#common_header "⌛ INSTALLING: MergerFS Update"; sleep 2
#ansible-playbook /pg/mods/ymls/pg.yml --tags mergerfsupdate

################################################################################
bash /pg/mods/start/start.sh
exit
