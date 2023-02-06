#!/bin/bash -
#===============================================================================
#
#          FILE: ssh_c.sh
#
#         USAGE: ./ssh_c.sh
#
#   DESCRIPTION: Execute this script to connect to VM after `terraform apply`
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: Iurie Topor (IT), iurie.topor@outlook.com
#  ORGANIZATION: 
#       CREATED: 02/06/23 21:43:39
#      REVISION:  ---
#===============================================================================

##################################################
# MAIN
##################################################

# code

##################################################
# FUNCTIONS
##################################################

## HELP
##################################################
HELP() {
	# --less statement: used for Error messages
	if [ "$1" = "--less" ]; then
		echo
		# code here
	fi

