#!/bin/sh

### BEGIN INIT INFO
# Provides:          HA-Proxy
# Required-Start:    networking
# Required-Stop:     networking
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: HA-Proxy TCP/HTTP reverse proxy
# Description:       HA-Proxy is a TCP/HTTP reverse proxy
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/haproxy
NAME=haproxy
DESC="HA-Proxy TCP/HTTP reverse proxy"
PIDFILE="/var/run/$NAME.pid"
LOGFILE="/var/log/$NAME.log"
OPTS="-D -V -f /etc/haproxy/haproxy.cfg -p $PIDFILE"
RETVAL=0
TAG="HA-PROXY INIT.D"

haproxy_log() {
    echo "$@"
    logger -t ${TAG} -s $@ >> $LOGFILE 2>&1
}

start() {
    if [ -e $PIDFILE ]; then
        PIDDIR=/proc/$(cat $PIDFILE)
        if [ -d $PIDDIR ]; then
            haproxy_log "$DESC already running"
            return
        else
            haproxy_log "Removing stale PID file $PIDFILE"
            rm -f $PIDFILE
        fi
    fi

    haproxy_log "Starting $DESC..."

    start-stop-daemon --verbose --start --pidfile $PIDFILE -x "$DAEMON" -- $OPTS >> $LOGFILE 2>&1
    RETVAL=$?
    if [ $RETVAL -eq 0 ]; then
        haproxy_log "$NAME started"
    else
        haproxy_log "$NAME failed to start RETVAL=$RETVAL"
    fi
}

stop() {

    if [ ! -e $PIDFILE ]; then
        haproxy_log "$DESC already stopped"
        return
    fi

    haproxy_log "Stopping $DESC..."

    start-stop-daemon --verbose --stop --retry 3 --oknodo --pidfile $PIDFILE -x "$DAEMON"
    if [ -n "`pidof $DAEMON`" ] ; then
        pkill -KILL -f $DAEMON
    fi
    haproxy_log "$NAME stopped"

    rm -f $PIDFILE
    rm -f /var/lock/subsys/$NAME
}

status() {
    pid=`cat $PIDFILE 2>/dev/null`
    if [ -n "$pid" ]; then
        if ps -p $pid &>/dev/null ; then
            echo "$DESC is running"
            RETVAL=0
            return
        else
            RETVAL=1
        fi
    fi
    echo "$DESC is not running"
    RETVAL=1
}

check() {
    /usr/sbin/$NAME -c -V -f /etc/$NAME/$NAME.cfg
}

# See how we were called.
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart|force-reload|reload)
        stop
        start
        ;;
    status)
        status
        ;;
    check)
        check
        ;;
    *)
        echo "Usage: $0 {start|stop|force-reload|restart|reload|status|check}"
        RETVAL=1
        ;;
esac

exit $RETVAL
