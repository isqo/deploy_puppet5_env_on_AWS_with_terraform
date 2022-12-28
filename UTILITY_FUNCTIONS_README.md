
# Utility functions guide

## SSH To puppet master
- export $(cat .env | xargs) && . ./utility_functions.sh && ssh_to_puppet_master