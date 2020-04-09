#!/usr/bin/env bash

export BACK_HOME="/tmp/opt/backbase"

bash $BACK_HOME/runtimes/activemq/bin/activemq stop
bash $BACK_HOME/runtimes/tomcat/editorial/shutdown.sh && $BACK_HOME/runtimes/tomcat/portal/shutdown.sh && $BACK_HOME/runtimes/tomcat/platform/shutdown.sh
