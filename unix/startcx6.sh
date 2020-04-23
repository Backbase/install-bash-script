#!/usr/bin/env bash

export BACKBASE_HOME="/tmp/opt/backbase"

bash $BACKBASE_HOME/runtimes/activemq/bin/activemq start
bash $BACKBASE_HOME/runtimes/tomcat/platform/startup.sh && $BACKBASE_HOME/runtimes/tomcat/portal/startup.sh && $BACKBASE_HOME/runtimes/tomcat/editorial/startup.sh
