#!/usr/bin/env bash

export BACK_HOME="/tmp/opt/backbase"

bash $BACK_HOME/runtimes/activemq/bin/activemq start
bash $BACK_HOME/runtimes/tomcat/platform/startup.sh && $BACK_HOME/runtimes/tomcat/portal/startup.sh && $BACK_HOME/runtimes/tomcat/editorial/startup.sh
