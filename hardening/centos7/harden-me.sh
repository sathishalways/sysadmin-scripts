yum -y install ntp ntpdate
ntpdate pool.ntp.org
systemctl enable ntpd
systemctl start ntpd

# Disable prelinking altogether
#
if grep -q ^PRELINKING /etc/sysconfig/prelink
then
  sed -i 's/PRELINKING.*/PRELINKING=no/g' /etc/sysconfig/prelink
else
  echo -e "\n# Set PRELINKING=no per security requirements" >> /etc/sysconfig/prelink
  echo "PRELINKING=no" >> /etc/sysconfig/prelink
fi
/usr/sbin/prelink -ua

yum -y install aide -y && /usr/sbin/aide --init && cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz && /usr/sbin/aide --check
echo "05 4 * * * root /usr/sbin/aide --check" >> /etc/crontab
authconfig --passalgo=sha512 —update
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.orig
cat > /etc/security/pwquality.conf << EOF
difok = 5
minlen = 14
dcredit = 1
ucredit = 1
lcredit = 1
ocredit = 1
minclass = 4
maxrepeat = 3
maxclassrepeat = 3
gecoscheck = 1
EOF
cp /etc/login.defs /etc/login.defs.bak
cat > /etc/login.defs << EOF
MAIL_DIR        /var/spool/mail
PASS_MAX_DAYS   99999
PASS_MIN_DAYS   1
PASS_MIN_LEN    14
PASS_WARN_AGE   60
UID_MIN                  1000
UID_MAX                 60000
SYS_UID_MIN               201
SYS_UID_MAX               999
GID_MIN                  1000
GID_MAX                 60000
SYS_GID_MIN               201
SYS_GID_MAX               999
CREATE_HOME     yes
UMASK           027
USERGROUPS_ENAB yes
ENCRYPT_METHOD SHA512
EOF
cp /etc/pam.d/system-auth /etc/pam.d/system-auth.orig
cat > /etc/pam.d/system-auth << EOF
#%PAM-1.0
# This file is auto-generated.
# User changes will be destroyed the next time authconfig is run.
auth        required      pam_env.so
auth        sufficient    pam_unix.so nullok try_first_pass
auth        requisite     pam_succeed_if.so uid >= 1000 quiet_success
auth        required      pam_deny.so

account     required      pam_unix.so
account     sufficient    pam_localuser.so
account     sufficient    pam_succeed_if.so uid < 1000 quiet
account     required      pam_permit.so

password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
password    sufficient    pam_unix.so sha512 shadow nullok try_first_pass use_authtok
password    required      pam_deny.so

session     optional      pam_keyinit.so revoke
session     required      pam_limits.so
session     required      pam_lastlog.so showfailed
-session     optional      pam_systemd.so
session     [success=1 default=ignore] pam_succeed_if.so service in crond quiet use_uid
session     required      pam_unix.so
EOF

chmod 600 /boot/grub2/grub.cfg
echo 'SINGLE=/sbin/sulogin'
perl -npe 's/umask\s+0\d2/umask 077/g' -i /etc/bashrc
perl -npe 's/umask\s+0\d2/umask 077/g' -i /etc/csh.cshrc
echo "Idle users will be removed after 15 minutes"
echo "readonly TMOUT=900" >> /etc/profile.d/os-security.sh
echo "readonly HISTFILE" >> /etc/profile.d/os-security.sh
chmod +x /etc/profile.d/os-security.sh
echo "Locking down Cron"
touch /etc/cron.allow
chmod 600 /etc/cron.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/cron.deny
echo "Locking down AT"
touch /etc/at.allow
chmod 600 /etc/at.allow
awk -F: '{print $1}' /etc/passwd | grep -v root > /etc/at.deny
echo 'net.ipv4.ip_forward = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.send_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.send_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_max_syn_backlog = 1280' >> /etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_broadcasts = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.accept_source_route = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.accept_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.secure_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.log_martians = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.accept_source_route = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.accept_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.secure_redirects = 0' >> /etc/sysctl.conf
echo 'net.ipv4.icmp_echo_ignore_broadcasts = 1' >> /etc/sysctl.conf
echo 'net.ipv4.icmp_ignore_bogus_error_responses = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_syncookies = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.all.rp_filter = 1' >> /etc/sysctl.conf
echo 'net.ipv4.conf.default.rp_filter = 1' >> /etc/sysctl.conf
echo 'net.ipv4.tcp_timestamps = 0' >> /etc/sysctl.conf
echo "ALL:ALL" >> /etc/hosts.deny
echo "sshd:ALL" >> /etc/hosts.allow
echo "install dccp /bin/false" > /etc/modprobe.d/dccp.conf
echo "install sctp /bin/false" > /etc/modprobe.d/sctp.conf
echo "install rds /bin/false" > /etc/modprobe.d/rds.conf
echo "install tipc /bin/false" > /etc/modprobe.d/tipc.conf
yum -y -y install rsyslog
systemctl enable rsyslog
systemctl start rsyslog
systemctl enable auditd
systemctl start auditd
cat > /etc/default/grub << EOF
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap video=800x600 biosdevname=0 net.ifnames=0 console=ttyS0 audit=1"
GRUB_DISABLE_RECOVERY="true"
EOF
grub2-mkconfig > /boot/grub2/grub.cfg
echo 'max_log_file = 30MB' >> /etc/audit/auditd.conf
echo 'max_log_file_action = rotate' >> /etc/audit/auditd.conf
echo 'space_left_action = email' >> /etc/audit/auditd.conf
echo 'admin_space_left_action = halt' >> /etc/audit/auditd.conf
echo 'action_mail_acct = root' >> /etc/audit/auditd.conf
sed -i 's/active = no/active = yes/g' /etc/audisp/plugins.d/syslog.conf
systemctl restart auditd
cat audit.rules >> /etc/audit/audit.rules
yum -y remove telnet-server rsh-server rsh-server rsh ypbind ypserv tftp-server cronie-anacron dovecot squid net-snmpd
systemctl enable irqbalance psacct crond
systemctl figgle xinetd rexec rsh rlogin ypbind tftp certmonger cgconfig \
  cgred cpuspeed kdump mdmonitor messagebus netconsole ntpdate oddjobd \
  portreserve quota_nld rdisc rhnsd rhsmcertd saslauthd smartd sysstat \
  atd nfslock named httpd dovecot squid snmpd rpcgssd rpcsvcgssd \
  rpcidmapd netfs nfs avahi-daemon cups dhcpd
rm /etc/hosts.equiv
rm ~/.rhosts
yum -y erase dhcp sendmail
systemctl enable postfix
postconf -e 'inet_interfaces = localhost'
echo "install cramfs /bin/false" > /etc/modprobe.d/cramfs.conf
echo "install freevxfs /bin/false" > /etc/modprobe.d/freevxfs.conf
echo "install jffs2 /bin/false" > /etc/modprobe.d/jffs2.conf
echo "install hfs /bin/false" > /etc/modprobe.d/hfs.conf
echo "install hfsplus /bin/false" > /etc/modprobe.d/hfsplus.conf
echo "install squashfs /bin/false" > /etc/modprobe.d/squashfs.conf
echo "install udf /bin/false" > /etc/modprobe.d/udf.conf
echo 'kernel.exec-shield = 1' >> /etc/sysctl.conf
echo 'kernel.randomize_va_space = 2' >> /etc/sysctl.conf
systemctl enable restorecond
systemctl start restorecond
sed -i 's/\<nullok\>//g' /etc/pam.d/system-auth
