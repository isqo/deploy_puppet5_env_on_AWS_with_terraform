#!/bin/bash -ex


function get_puppet_node_dns() {

  NAME=$1

  if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]] || [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "ERROR: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set!"
  fi

  PUPPET_MASTER_IP=$(aws ec2 describe-instances  --filters "Name=tag:Name,Values=$NAME" --query "Reservations[*].Instances[*].PublicDnsName" --output=text)

  if [[ -z "${PUPPET_MASTER_IP}" ]]; then
    echo "ERROR: Unable to fetch IP of Puppet Master Server!"
  fi

  echo "$PUPPET_MASTER_IP"
}

function ssh_to_puppet_master() {
  LOCAL_ENV_FILE=${${1}:-.local.env}
  CMD=${${2}:-}

  # shellcheck disable=SC2046
  export $(cat $LOCAL_ENV_FILE | xargs)

  DNS=$(get_puppet_node_dns "Puppet Master Server")

  if [[ -z "${SSH_PRIVATE_KEY_PATH}" ]]; then
    echo "ERROR: SSH_PRIVATE_KEY_PATH must be set!"
  fi

  ssh -i ${SSH_PRIVATE_KEY_PATH} ec2-user@${DNS} "$CMD"
}

function ssh_to_puppet_slave() {
  LOCAL_ENV_FILE=${${1}:-.local.env}
  CMD=${${2}:-}
  # shellcheck disable=SC2046
  export $(cat $LOCAL_ENV_FILE | xargs)

  DNS=$(get_puppet_node_dns "Puppet Agent Node")

  if [[ -z "${SSH_PRIVATE_KEY_PATH}" ]]; then
    echo "ERROR: SSH_PRIVATE_KEY_PATH must be set!"
  fi

  ssh -i ${SSH_PRIVATE_KEY_PATH} ec2-user@${DNS} "$CMD"
}

function update_infra() {
  LOCAL_ENV_FILE=${${1}:-.local.env}

  # shellcheck disable=SC2046
  export $(cat $LOCAL_ENV_FILE | xargs)

  if [[ -z "${AWS_ACCESS_KEY_ID}" ]] || [[ -z "${AWS_SECRET_ACCESS_KEY}" ]] || [[ -z "${AWS_DEFAULT_REGION}" ]]; then
    echo "ERROR: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION must be set!"
  fi

   terraform -chdir=terraform plan && terraform -chdir=terraform apply
}

function run_puppet_on_slave(){
  LOCAL_ENV_FILE=${${1}:-.local.env}

  ssh_to_puppet_slave $LOCAL_ENV_FILE "sudo su - root -c 'puppet agent -t'"
}

function run_puppet_on_master(){
  LOCAL_ENV_FILE=${${1}:-.local.env}

  ssh_to_puppet_master $LOCAL_ENV_FILE "sudo su - root -c 'puppet agent -t'"
}


function sync_r10k_and_run_puppet_on_slave(){
  LOCAL_ENV_FILE=${${1}:-.local.env}

  ssh_to_puppet_master $LOCAL_ENV_FILE "sudo su - root -c 'r10k deploy environment -m --incremental -v'"

  run_puppet_on_slave $LOCAL_ENV_FILE
}

function sync_r10k_and_run_puppet_on_master(){
  LOCAL_ENV_FILE=${${1}:-.local.env}

  ssh_to_puppet_master $LOCAL_ENV_FILE "sudo su - root -c 'r10k deploy environment -m --incremental -v'"

  run_puppet_on_master $LOCAL_ENV_FILE
}