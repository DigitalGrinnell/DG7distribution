#!/bin/bash
# This is dynmotd.sh, as part of Puppet module "dynmotd".
# facter
PROCCOUNT=`ps -Afl | wc -l`
PROCCOUNT=`expr $PROCCOUNT - 5`
GROUPZ=`groups`
if [[ $GROUPZ == *irc* ]]; then
ENDSESSION=`cat /etc/security/limits.conf | grep "@irc" | grep maxlogins | awk {'print $4'}`
PRIVLAGED="IRC Account"
else
ENDSESSION="Unlimited"
PRIVLAGED="Regular User"
fi
echo -e "\033[1;32m`hostname | figlet -f /usr/share/figlet/small.flf`"
echo -e "\033[0;35m+++++++++++++++++: \033[0;37mSystem Data\033[0;35m :+++++++++++++++++++
\033[0;35m+  \033[0;37mHostname \033[0;35m= \033[1;32m`hostname`
\033[0;35m+        \033[0;37mOS \033[0;35m= \033[1;32m<%= @lsbdistdescription %>
\033[0;35m+   \033[0;37mAddress \033[0;35m= \033[1;32meth0: `/sbin/ip -4 -o addr show dev eth0| awk '{split($4,a,"/");print a[1]}'`
\033[0;35m+   \033[0;37m        \033[0;35m= \033[1;32meth1: `/sbin/ip -4 -o addr show dev eth1| awk '{split($4,a,"/");print a[1]}'`
\033[0;35m+   \033[0;37m        \033[0;35m= \033[1;32meth2: `/sbin/ip -4 -o addr show dev eth2| awk '{split($4,a,"/");print a[1]}'`
\033[0;35m+    \033[0;37mKernel \033[0;35m= \033[1;32m`uname -r`
\033[0;35m+    \033[0;37mMemory \033[0;35m= \033[1;32m`cat /proc/meminfo | grep MemTotal | awk {'print $2'}` kB"
echo -e "\033[0;35m++++++++++++++++++: \033[0;37mUser Data\033[0;35m :++++++++++++++++++++
\033[0;35m+  \033[0;37mUsername \033[0;35m= \033[1;32m`whoami`
\033[0;35m+ \033[0;37mPrivlages \033[0;35m= \033[1;32m$PRIVLAGED
\033[0;35m+  \033[0;37mSessions \033[0;35m= \033[1;32m`who | grep $USER | wc -l` of $ENDSESSION MAX
\033[0;35m+ \033[0;37mProcesses \033[0;35m= \033[1;32m$PROCCOUNT of `ulimit -u` MAX"
echo -e "\033[0;35m++++++++++++++++++: \033[0;37mDisk Data\033[0;35m :++++++++++++++++++++
\033[1;32m`df -h | grep '/dev/\|Filesystem'`"
echo -e "\033[0;35m+++++++++++++: \033[0;37mHelpful Information\033[0;35m :+++++++++++++++
\033[0;35m+ \033[0;37mMOTD Script \033[0;35m= \033[1;32m/usr/local/bin/dynmotd
\033[0;35m+ \033[0;37mMaintenance Info \033[0;35m= \033[1;32m/etc/motd-maint
\033[0;35m+ \033[0;37mFor documentation see GitHub \033[0;35m= \033[1;32mSummittDweller/docs"
echo -e "\033[0;35m+++++++++++: \033[0;31mMaintenance Information\033[0;35m :+++++++++++++
\033[0;35m+\033[1;32m `cat /etc/motd-maint`
\033[0;35m+++++++++++++++++++++++++++++++++++++++++++++++++++\033[0;37m"
