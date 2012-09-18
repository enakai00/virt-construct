#!/bin/sh -x

GitRepository=$1    # Repository URL
ConfigTag=$2        # Restore Tag
RepoName=${GitRepository##*/}
RepoName=${RepoName%\.git}

# restore configs to /tmp/gittmp/$RepoName
function git_restore {
    rm -rf /tmp/gittmp
    mkdir -p /tmp/gittmp
    cd /tmp/gittmp
    git clone $GitRepository
    cd $RepoName
    if [[ ! -z $ConfigTag ]]; then
        git checkout $ConfigTag
    fi
}

yum -y install postgresql-server
service postgresql initdb
service postgresql start
su - postgres -c \
    "psql -c \"ALTER USER postgres encrypted password 'pas4pgsql'\""
service postgresql stop

git_restore

cp -rv /tmp/gittmp/$RepoName/* /var/lib/pgsql/
restorecon -r /var/lib/pgsql
chkconfig postgresql on
