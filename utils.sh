#!/bin/bash -ex


function get_puppet_master_dns() {

  if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]] || [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "ERROR: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set!"
  fi

  PUPPET_MASTER_IP=$(aws ec2 describe-instances  --filters "Name=tag:Name,Values=Puppet Master Server" --query "Reservations[*].Instances[*].PublicDnsName" --output=text)

  if [[ -z "${PUPPET_MASTER_IP}" ]]; then
    echo "ERROR: Unable to fetch IP of Puppet Master Server!"
  fi
  echo "$PUPPET_MASTER_IP"
}

function ssh_to_puppet_master() {
  LOCAL_ENV_FILE=${${1}:-.env}
  # shellcheck disable=SC2046
  export $(cat $LOCAL_ENV_FILE | xargs)

  DNS=$(get_puppet_master_dns)

  if [[ -z "${SSH_PRIVATE_KEY_PATH}" ]]; then
    echo "ERROR: SSH_PRIVATE_KEY_PATH must be set!"
  fi

  ssh -i ${SSH_PRIVATE_KEY_PATH} ec2-user@${DNS}
}

function update_infra() {
  LOCAL_ENV_FILE=${${1}:-.env}

  # shellcheck disable=SC2046
  export $(cat $LOCAL_ENV_FILE | xargs)

  if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]] || [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "ERROR: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set!"
  fi

   terraform -chdir=terraform plan && terraform -chdir=terraform apply
}