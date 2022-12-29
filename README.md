
# Introduction

This repository is a fork of https://github.com/isqo/deploy_puppet5_env_on_AWS_with_terraform to test it and maintain it.

# Utility functions guide

## Pre-requisites
 
- You should have created the infrastructure with the IaC Terraform code of this repository.
- You should have set the required environment variables in either .local.env.

## Usage

### Creation/Update infra with Terraform

. ./utils.sh && update_infra

### SSH To puppet master

. ./utils.sh && ssh_to_puppet_master

### SSH To puppet slave

. ./utils.sh && ssh_to_puppet_slave

### Sync r10k and run puppet agent on slave

. ./utils.sh && sync_r10k_and_run_puppet_on_slave

### Sync r10k and run puppet agent on master

. ./utils.sh && sync_r10k_and_run_puppet_on_master
