#! /bin/bash

pragma start CONCOURSE

pragma import LOG

#
# concourse_download downloads concourse version 2.7.0 
# from the official github repository
#
concourse_download() {
    url=$1
    if [ "$url" == "" ]; then
        url="https://github.com/concourse/concourse/releases/download/v2.7.0/concourse_linux_amd64"
    fi
    wget -O concourse $url
    if [ $? -eq 0 ]; then
        log_i "download from" $url "succeeded"
        return 0
    fi
    log_w "download from" $url "failed"
    return 1
}

#
# install_concourse install concourse.ci using an executable retrieved 
# from the web; the destination directory can be passed as a parameter,
# otherwise it will be installed into /opt/concourse it will be installed 
# into /opt/concourse 
#
concourse_install() {
    destdir=$1
    if [ "$destdir" == "" ]; then
        destdir=/opt/concourse
    fi

    # check if destination directory exists, along with its parents
    if [ ! -d $destdir ]; then
	mkdir -p $destdir
	if [ $? -ne 0 ]; then
            return 1
        fi
    fi 

    pushd $destdir
    
    # create security keys if necessary
    if [ ! -f "tsa_host_key" ]; then
        ssh-keygen -t rsa -f tsa_host_key -N ''
        log_d "tsa_host keypair created"
    fi

    if [ ! -f "worker_key" ]; then
        ssh-keygen -t rsa -f worker_key -N ''
        log_d "worker keypair created"
    fi

    if [ ! -f "session_signing_key" ]; then
        ssh-keygen -t rsa -f session_signing_key -N ''
        log_d "session_signing keypair created"
    fi

    if [ ! -f "authorized_worker_keys" ]; then
        cp worker_key.pub authorized_worker_keys
        log_d "authorized_worker_keys created"
    fi

    # download/copy the binary to the $destdir
    while true; do
        read -p "please enter the path to the concourse binary: [X to exit]: " concourse
        case $concourse in
        [Xx]) 
            break
            ;;
        [http]*)
            concourse_download $concourse
#            wget -O concourse $concourse
            if [ $? -eq 0 ]; then
#                log_i "download from" $concourse "succeeded"
                break
#            else
#                log_w "download from" $concourse "failed, trying again"
            fi 
            ;;
        *) 
            if [ ! -f "$concourse" ]; then
                log_w "file" $concourse "does not exist, please provide another path"
            else 
                #echo "   ... copying file ${concourse}..."
                cp "$concourse" $destdir/concourse
                log_i "file" $concourse "copied"
                break
            fi
            ;;
        esac
    done

    popd
}

concourse_configure() {
    log_i "configure"
}

pragma end CONCOURSE

