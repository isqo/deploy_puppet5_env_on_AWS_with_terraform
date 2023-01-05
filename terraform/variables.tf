##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {
  type        = string
  description = "Access key of the aws user."
}

variable "aws_secret_key" {
  type        = string
  description = "Secret access key of the aws user."
}

variable "aws_secret_region" {
  type        = string
  description = "The region in which resources will be created."
  default = "us-east-2"
}

variable "puppet_repository" {
  type        = string
  default     = "https://yum.puppet.com/puppet5/puppet5-release-el-7.noarch.rpm"
  description = "The puppet repository of open source Puppet 5-compatible software packages."
}

variable "vpc_id" {
  type        = string
  description = "Create puppet nodes in this AWS VPC."
}

variable "vpc_region" {
  type        = string
  description = "Create puppet nodes in this AWS REGION."
}

variable "vpc_subnet_id" {
  type        = string
  description = "Puppet nodes will be placed into this subnet."
}

variable "ec2_keypair" {
  type        = string
  description = "Access puppet nodes via SSH with this AWS EC2 keypair name."
}

variable "instance_type" {
  type        = string
  default     = "t2.medium"
  description = "The instance type of the puppet node instance."
}

variable "aws_route53_zone_name" {
  type        = string
  default     = "private"
  description = "Name of the route53 zone."
}

variable "puppet_master_name" {
  type        = string
  default     = "puppet.master"
  description = "Name of the route53 zone."
}

variable "node_count" {
  type        = string
  default     = "1"
  description = "The number of puppet nodes you want to launch."
}

variable "asg_min" {
  type        = string
  default     = "1"
  description = "Minimum number of nodes in the Auto-Scaling Group"
}

variable "asg_max" {
  type        = string
  default     = "1"
  description = "Minimum number of nodes in the Auto-Scaling Group"
}

variable "control_repo_remote" {
  type        = string
  description = "URL of the r10k control GIT repository remote"
}

variable "control_repo_remote_domain_for_ssh_key_fingerprint" {
  type        = string
  description = "Domain of the r10k control repository for the SSH key fingerprint."
}

variable "control_repo_ssh_key" {
  type        = string
  description = "The private SSH key to auth against the r10k git remote."
}

variable "control_repo_ssh_key_path" {
  type        = string
  description = "The path to which the r10k private SSH key will be deployed."
}

variable "eyaml_secrets_remote" {
  type        = string
  description = "URL of the eyaml secrets Git repository remote"
}

variable "eyaml_secrets_remote_domain_for_ssh_key_fingerprint" {
  type        = string
  description = "Domain of the eyaml secrets repository for the SSH key fingerprint."
}

variable "eyaml_secrets_ssh_key" {
  type        = string
  description = "The private SSH key to auth against the eyaml secrets git remote."
}

variable "eyaml_secrets_ssh_key_path" {
  type        = string
  description = "The path to which the eyaml secrets private SSH key will be deployed."
}