#!/bin/bash -ex


function get_puppet_master_dns() {

  if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
    echo "ERROR: AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set!"
  fi

  PUPPET_MASTER_IP=$(aws ec2 describe-instances  --filters "Name=tag:Name,Values=Puppet Master Server" --query "Reservations[*].Instances[*].PublicDnsName" --output=text)

  echo "$PUPPET_MASTER_IP"
}

function ssh_to_puppet_master() {

  DNS=$(get_puppet_master_dns)

  if [[ -z "${SSH_PRIVATE_KEY_PATH}" ]]; then
    echo "ERROR: SSH_PRIVATE_KEY_PATH must be set!"
  fi

  ssh -i ${SSH_PRIVATE_KEY_PATH} ec2-user@${DNS}
}