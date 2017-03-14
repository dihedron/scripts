#! /bin/bash

pragma start POSTGRES

pragma import LOG

#
# postgres_install installs PostegreSQL from the official Ubuntu
# repositories, and changes user "postgres" password by prompting
# the user twice.
#
postgres_install() {
    sudo apt update
    if [ $? -ne 0 ]; then
        log_e "error updating index from apt repository"
        return 1
    fi

    sudo apt -y install postgresql postgresql-contrib 
    if [ $? -ne 0 ]; then
        log_e "error installing postgresql from apt repository"
        return 1
    fi

    sudo -u postgres -i psql -c \\password postgres
    return 0
}

#
# postgres_remove removes PostgreSQL from the system.
#
postgres_remove() {
    sudo apt -y remove postgresql postgresql-contrib 
    return $? 
}

#
# phppgadmin_install installs phpPgAdmin from the official Ubuntu
# repositories and configures it for remote access.
#
phppgadmin_install() {
    sudo apt update
    if [ $? -ne 0 ]; then
        log_e "error updating index from apt repository"
        return 1
    fi

    sudo apt -y install phppgadmin 
    if [ $? -ne 0 ]; then
        log_e "error installing phppgadmin from apt repository"
        return 1
    fi

    # enable remote connections to phpPgAdmin
    config=/etc/apache2/conf-available/phppgadmin.conf
    if [ -f $config ]; then
        sudo sed -i.orig -e 's/^Require local$/Allow From all/g' $config
        sudo sed -i -e 's/^# Only allow connections from localhost:.*$/# Enable remote connections:/g' $config
    else
        log_e "file" $config "not available on disk"
        return 1
    fi

    # configure PgAdmin to enable login with user postgres
    config=/etc/phppgadmin/config.inc.php
    if [ -f $config ]; then
        sudo sed -i.orig -e "s/\(\['extra_login_security'\]\s*=\s*\)\(true\)\(\s*;\s*$\)/\1false\3/g" $config
    else 
        log_e "file" $config "not available on disk"
        return 1 
    fi

    # restart PostgreSQL and Apache2 to reload PgAdmin configuration
    systemctl restart postgresql
    systemctl restart apache2
}

#
# phppgadmin_remove uninstalls phpPgAdmin from the system and checks if
# there are nay configuration files left behind.
#
phppgadmin_remove() {
    sudo apt -y remove phppgadmin
    if [ $? -ne 0 ]; then
        log_e "error removing phppgadmin from system"
        return 1
    fi

    config1=/etc/apache2/conf-available/phppgadmin.conf
    config2=/etc/phppgadmin/config.inc.php
    if [ -f $config1 -o -f $config2 ]; then
        log_e "at least one configuration file is still on disk"
        return 1
    fi
    return 0
}

pragma end POSTGRES

