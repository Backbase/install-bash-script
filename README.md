# Backbase IPS and CX6 installation via bash script

![Alt Text](install.gif)

## Description

This repository contains a bash script to install IPS and CX6 Backbase services in an automated way: from the download
of all the software needed until the import of the CX Manager experience, all the steps happen automatically one after the
other.

By default, everything is installed in the `/tmp/opt/backbase` directory.

The steps followed in the script are:

* `setConstants` - sets the different constants which are needed, such as versions, paths, etc.
* `initMysql` - deletes and creates CX6 databases
* `buildCXFileSystemDir` - creates required directories in the filesystem (e.g. statics)
* `importCertificate` - imports certificates to expose the Edge Service in HTTPS
* `configTomcatInstances` - copies Tomcat configuration
* `downloadAll` - downloads Tomcat, ActiveMQ, IPS and CX6 services
* `installAndConfigLocalActiveMQ` - installs and configures ActiveMQ listening on the port 61616
* `installAndConfigLocalTomcat` - installs and configures the different Tomcat instances
  * IPS Tomcat - HTTP : 8080
  * CX6 Portal Tomcat - HTTP : 8081
  * CX6 Editorial Tomcat - HTTP : 8082
* `installLocalCx6` - installs and configures CX6 and IPS services
* `startAllCX6` - starts all Tomcat instances
* `fn_check_health "auth"` - checks health endpoint on the Authentication Service
* `fn_check_health "portal"` - checks health endpoint on Portal Services
* `fn_check_health "contentservices"` - checks health endpoint on Content Services
* `fn_check_health "provisioning"` - checks health endpoint on Provisioning Service
* `provisionCX6ExpMgr` - provisions `editorial-collection`, `web-sdk`, `experience-mananger`, `collection-approvals-page` and `collection-approvals-portal` using the CX Importer Tool


## Requirements

1. Internet access

2. Unix machine (the script has been tested on MacOS)

3. Access to [Backbase Maven repositories](https://repo.backbase.com/) (to be able to download the dependencies)

4. [MySQL](https://www.mysql.com/downloads/) 5.6 or 5.7 running (`root` password must be `backbase`). Make sure you copy the needed configuration (an example [here](common/mysql-configs/my.cnf)).
    ```
    sudo mkdir -p /usr/local/mysql/etc/
    sudo cp ../common/mysql-configs/my.cnf /usr/local/mysql/etc/
    ```

5. Make sure you have [wget](https://www.gnu.org/software/wget/) installed:

    For MacOS you can use
    ```
    brew install wget
    ```

    Ubuntu
    ```
    apt-get install wget
    ```

    RHEL / CentOS / Fedora
    ```
    yum install wget
    ```
5. The following ports must be free
   * 61616 (will be used by ActiveMQ)
   * 8080/8443 (will be used by IPS Tomcat)
   * 8081 (will be used by CX6 Portal Tomcat)
   * 8082 (will be used by CX6 Editorial Tomcat)


## Configuration

All the configurations needed for the different components (ActiveMQ, MySQL, Tomcat and the different services) are inside the `common` directory

- [ActiveMQ Config](common/activemq-configs)
- [MySQL Config](common/mysql-configs)
- [Tomcat Structure](common/tomcat-structure)
- [Tomcat Configs](common/tomcat-configs)
- [Services Configs](common/service-configs)


## Running the script

    cd unix
    sh installcx6.sh
    
All the steps happen automatically, just wait for the script to finish.

The progress can be monitored on http://localhost:8080/registry/

When the scripts has finished running, CX Manager should be available here on http://localhost:8080/gateway/api/cxp-manager/login


## Common problems
* Do not try to run the script using MySQL 8.x. Make sure that you are using MySQL 5.6/5.7. When istalling MySQL through `brew` on MacOS, make sure for example to pin a specific version
    ```
    brew install mysql@5.7
    ```
* If the configuration for the database is not applied, the `max-allowed-packet` will be small, therefore the import of some big collections will fail (the error will be visible in the log files of the Portal Tomcat instance).
* Make sure you sare not setting `JAVA_OPTS` that may be in conflict with what is set in the `startup.sh` scripts inside the `tomcat-configs` sub-directories. An example could be some conflicting collector combinations that will prevent the JVM from starting.
* Running the script by using `./installCX6.sh` instead of the more explicit `sh installCX6.sh` may lead to weird behaviours of the `curl` statements (the first attempts to check if a service is alive are expected to fail and this may break the script if not run using `sh installCX6.sh`). 
* The certificate which is included to expose the Edge Service in HTTPS is self-signed (for practical reasons), therefore the browsers will complain. If the browser allows this, you can set an exception and safely ignore the error.


## Roadmap

* A similar script compatible with Windows
* Making the script idempotent
* Possibility to ovveride some default values (e.g. base directory)
* Ability to detect busy ports
* Investigate an issue with `wget` and slow connections when using `ipv6`


## How to contribute
* `master` branch is the stable branch and contains the latest released version
* `develop` is the *work in progress* branch (i.e. we will have the next snapshot version or any new functionality to test, can be unstable)

For previous versions of the product we will have tags, in the format: v6.0.24

We follow gitflow for the contributions so, if there is a bug, please open a PR against the branch you want to fix with the format:

    bugfix/small_description

If there is a new feature or functionality you would like to add want to add, please create a branch with the format 

    feature/small_description
    

## Issues

Feel free to report issues https://github.com/Backbase/install-bash-script/issues


## Owners

Andrés Torres [email](mailto:andres@backbase.com)
