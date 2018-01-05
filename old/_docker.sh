#! /bin/bash

pragma start DOCKER

pragma import LOG

#
# docker_install installs docker from the uniffocial repo
#
docker_install() {
    sudo apt-get update
    if [ $? -ne 0 ]; then
        log_e "error updating apt repository"
        return 1
    fi

    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    if [ $? -ne 0 ]; then
        log_e "error adding docker official repository to apt keys"
        return 1
    fi

    sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main' 
    if [ $? -ne 0 ]; then
        log_e "error adding docker official repository to sources"
        return 1
    fi
    
    sudo apt-get update
    if [ $? -ne 0 ]; then
        log_e "error updating apt repository"
        return 1
    fi

    apt-cache policy docker-engine | grep  https://apt.dockerproject.org/repo
    if [ $? -ne 0 ]; then
        log_e "the configured repository does not appear to be the docker one"
        return 1
    fi
   
    sudo apt-get install -y docker-engine 
    if [ $? -ne 0 ]; then
        log_e "error installing docker-engine from repository"
        return 1
    fi

    sudo systemctl status docker | grep "active (running)"
    if [ $? -ne 0 ]; then
        log_e "docker engine is not running as a daemon"
        return 1
    fi

    return 0
}

#
# docker_configure_proxy creates a configuration file for the docker
# daemon under systemd and adds the HTTP_PROXY environment variable to 
# it, picking either the value passed in as first argument or the
# $http_proxy environment variable; if none is available, the configuration
# is not performed.
docker_configure_proxy() {
    proxy=$1
    if [ -z "$proxy" ]; then
        proxy="$http_proxy"
    fi

    if [ -z "$proxy" ]; then
        log_e "no proxy available on the cli or in the environment"
        return 1
    fi

    # configure docker to go through a proxy
    log_i "configuring docker proxy support: $proxy"

    if [ ! -d /etc/systemd/system/docker.service.d ]; then
        sudo mkdir -p /etc/systemd/system/docker.service.d
        if [ $? -ne 0 ]; then
            log_e "docker engine is not running as a daemon"
            return 1
        fi
    fi

    if [ ! -f /etc/systemd/system/docker.service.d/http-proxy.conf ]; then
        log_i "creating docker http-proxy configuration under systemd"

        sudo cat <<EOF > /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$proxy"
EOF

        if [ $? -ne 0 ]; then
            log_e "error creating docker http-proxy configuration under systemd"
            return 1
        fi
    fi

    sudo systemctl daemon-reload
    if [ $? -ne 0 ]; then
        log_e "error reloading systemd configuration"
        return 1
    fi

    sudo systemctl show --property Environment docker | grep -i $proxy    
    if [ $? -ne 0 ]; then
        log_e "proxy configuration under systemd is different from expected"
        return 1
    fi

    sudo systemctl restart docker
    if [ $? -ne 0 ]; then
        log_e "error restarting docker daemon"
        return 1
    fi

    return 0
}

docker_add_user() {
    user=$1
    if [ "$user" == "" ]; then
        user=$(whoami)
    fi

    sudo usermod -aG docker $user
    if [ $? -ne 0 ]; then
        log_e "error adding user $user to docker group"
        return 1
    fi

    return 0
}
    
if [ -z ${_libraries+x} ]; then
    declare -a _libraries
fi
export _libraries+=" $libname"

docker_configure_proxy

    
