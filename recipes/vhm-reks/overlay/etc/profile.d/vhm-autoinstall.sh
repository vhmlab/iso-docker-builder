# Live ISO only: offer the VHM install when root logs in on the first console.
# Does nothing on the installed system (root is not tmpfs), over SSH, or a second time.
if [ "$(id -u)" = 0 ] && [ -f /etc/vhm/setup-alpine.answers ] \
	&& [ "$(awk '$2 == "/" {print $3}' /proc/mounts | tail -1)" = tmpfs ] \
	&& [ "$(tty)" = /dev/tty1 ] && [ ! -e /tmp/.vhm-install-offered ]; then
	touch /tmp/.vhm-install-offered
	printf '\nInstall VHM Alpine (Docker-ready) on this machine? [Y/n] '
	read -r vhm_ans
	case "$vhm_ans" in
	[nN]*)
		echo "Skipped. To install later: setup-alpine -f /etc/vhm/setup-alpine.answers" ;;
	*)
		if setup-alpine -f /etc/vhm/setup-alpine.answers; then
			printf '\nInstallation finished. Remove the USB drive and type: reboot\n'
		else
			printf '\nInstallation did not finish. Retry with:\n  setup-alpine -f /etc/vhm/setup-alpine.answers\n'
		fi ;;
	esac
	unset vhm_ans
fi
