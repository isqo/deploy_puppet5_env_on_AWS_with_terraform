#!/bin/bash -ex

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo BEGIN

# Initialize the variables #
declare -x INPUT_JSON=$(cat <<EOF
'{
    "HostedZoneId": "${hosted_zone_id}", 
    "ChangeBatch": {
        "Comment": "Update the A record set", 
        "Changes": [
            {
                "Action": "UPSERT", 
                "ResourceRecordSet": {
                    "Name": "${master_hostname}", 
                    "Type": "A",            
                    "TTL": 300, 
                    "ResourceRecords": [
                        {
                            "Value": "$(curl --silent --show-error --retry 3 http://169.254.169.254/latest/meta-data/local-ipv4)"
                        }
                    ]
                }
            }
        ]
    }
}'
EOF
)

function mountefs {
    yum install -y amazon-efs-utils
    mkdir /etc/puppetlabs
    mount -t efs ${efs_id}:/ /etc/puppetlabs
}

function installpuppet {
    rpm -Uvh ${puppet_repo}
    yum -y install puppetserver
    export PATH=/opt/puppetlabs/bin:$PATH

    ### Configure the puppet master ###
    puppet config set certname ${master_hostname} --section main
    puppet config set server ${master_hostname} --section main
    puppet config set dns_alt_names puppet,${master_hostname} --section master
    puppet config set autosign true --section master

    echo "puppet is installed."
}

function backupmaster {
    echo "backing up puppetlabs folder"
    mkdir /tmp/puppetbackup
    rm -rf /tmp/puppetbackup/*
    cp -a /etc/puppetlabs/. /tmp/puppetbackup
}

function restoremaster {
    rm -rf /etc/puppetlabs/*
    cp -a /tmp/puppetbackup/. /etc/puppetlabs
    echo "puppet is recovered."
}

function generater10kconfig {
    if [ ! -f /etc/puppetlabs/r10k/r10k.yaml ]; then
        echo -e "\nGenerating a r10k.yaml file"

        # Generate default r10k.yaml 
        mkdir /etc/puppetlabs/r10k
        cat > /etc/puppetlabs/r10k/r10k.yaml <<EOL
---
:cachedir: '/var/cache/r10k'

#debug

:sources:
  :base:
    remote: '${r10k_repo}'
    basedir: '/etc/puppetlabs/code/environments'
EOL
    fi
}

function installr10k {
    sudo yum -y install git gcc libz-dev zlib-devel perl-Data-Dumper libopenssl-devel openssl-devel libxml2-devel libxslt-devel libtool bison libffi libffi-devel readline-devel libyaml
    export PATH=/opt/puppetlabs/puppet/bin:$PATH
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
    export RBENV_ROOT=/root/.rbenv
    echo 'export PATH="/root/.rbenv/bin:$PATH"' | sudo tee -a  ~/.bashrc
    echo 'eval "$(rbenv init -)"' | sudo tee -a  ~/.bashrc
    export PATH="/root/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
    if [ ! -d "$(rbenv root)/plugins/ruby-build" ]; then
      git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build
    else
      echo "$(rbenv root)/plugins/ruby-build does exist!"
    fi
    rbenv -v
    rbenv install 2.7.7 -v
    rbenv global 2.7.7
    sudo yum install -y rubygems
    # TODO: improvement, we can restrict the access by groups access for example -----
    mkdir -p /var/cache/r10k && sudo chmod -R 777 /var/cache/r10k
    mkdir -p /etc/puppetlabs/code && sudo chmod -R 777 /etc/puppetlabs/code
    # TODO: ---------------------------------------
    gem install r10k
}

export LC_ALL=C

# Set up the host name of the master node #
hostname ${master_hostname}

# Update the system #
yum -y update

# Create/Update DNS record of the puppet master node #
eval aws route53 change-resource-record-sets --cli-input-json $INPUT_JSON

# Mount EFS Volume #
mountefs

# Install Puppet#

## Folder /etc/puppetlabs is not empty, use existing puppet ##
if find /etc/puppetlabs -mindepth 1 -print -quit | grep -q .; then
    backupmaster
    installpuppet
    installr10k
    restoremaster

## Folder /etc/puppetlabs is empty, install and configure puppet master ##
else
    installpuppet
    installr10k
    generater10kconfig
fi

# Start the puppet master and add the service to start up #
systemctl enable puppetserver
systemctl start puppetserver
systemctl status puppetserver

r10k deploy environment

puppet cert list --all
echo END