#!/usr/bin/env bash

#
# memcached - this script starts and stops the memcached daemon
#
# chkconfig: - 85 15
# description: Memcached is an in-memory key-value store for small chunks of arbitrary data (strings, objects) from results of database calls,
# 			   API calls, or page rendering.
# processname: memcached
# config: /etc/sysconfig/memcached
# pidfile: /var/run/memcached.pid

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/memcached ]; then
	. /etc/sysconfig/memcached
fi

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

MEMCACHED_HOME="/usr/local/memcached"
memcached=$MEMCACHED_HOME"/bin/memcached"
PROG=$(basename $memcached)
pidfile=${PIDFILE-/var/run/memcached.pid}
lockfile=${LOCKFILE-/var/lock/subsys/memcached}
USER="daemon"
PORT=11211
MAX_MEMORY=1024
MAX_CONNEXTIONS=1024
MAX_REQUESTS=100

RETVAL=0

start() {
    [ -x $memcached ] || exit 5
    echo -n $"Starting $PROG: "
    ${memcached} -p ${PORT} -u ${USER} -m ${MAX_MEMORY} -c ${MAX_CONNEXTIONS} -R ${MAX_REQUESTS} -P ${pidfile} -d start
    RETVAL=$?
    echo
    [ $RETVAL -eq 0 ] && touch $lockfile
    return $RETVAL
}

stop() {
	echo -n $"Stopping $PROG: "
	killproc $memcached -QUIT
	RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}

case "$1" in
    start)
        start
		;;
	reload|restart)
        stop
        start
		;;
    stop)
        stop
		;;
	condrestart|try-restart)
		if status >&/dev/null; then
			stop
			start
		fi
		;;
	status)
		status -p ${pidfile} $memcached
		RETVAL=$?
		;;
	help)
		$memcached --help
		RETVAL=$?
		;;
    *)
		echo $"Usage: $PROG {start|reload|restart|condrestart|try-restart|stop|status|help}"
		RETVAL=2
		;;
esac

exit $RETVAL