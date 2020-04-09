#!/bin/sh

CURRENT_DIR=`dirname $0`

export CATALINA_HOME=/tmp/opt/backbase/runtimes/tomcat/8.5.51
export CATALINA_BASE=$CURRENT_DIR

$CATALINA_HOME/bin/catalina.sh stop
