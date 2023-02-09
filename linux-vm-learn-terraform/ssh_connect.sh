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
MAIN() 
{
	local to_do

	if [ -n "${*}" ]; then
		SET_OPTIONS "$@"
		LOG "${FUNCNAME[0]}" "For script $0 was provided options: ${*}"
		CHECK_USERNAME 
		CHECK_VM_IP
		CHECK_SSH_KEY
		LOG "${FUNCNAME[0]}" "Following paramiters will be used:"
		LOG "${FUNCNAME[0]}" "username: $vm_user" 
		LOG "${FUNCNAME[0]}" "ip_address: $vm_IP"
		LOG "${FUNCNAME[0]}" "ssh_key_file: $vm_ssh_key"
		to_do="$ssh_connect"
		if [ "$to_do" ]; then
			echo "SSH connect"
			# eval ssh -i $ss_key $vm_user@$vm_IP
		fi
	else
		HELP "--less" "Don't know what to do. No OPTION was passed"
	fi
}	# ----------  end of function MAIN  ----------

##################################################
# FUNCTIONS
##################################################

SET_OPTIONS() 
{
	while [ "$#" -gt 0 ]; do
		case "$1" in
			"-c" | "--connect")
				ssh_connect='True'
				shift
				;;
			"-f" | "--ssh-f")
				ssh_key_file="$2"
				shift 2
				;;
			"-h" | "--help")
				HELP
				;;
			"-l" | "--log")
				print_log='True'
				log_level='info-level'
				shift
				;;
			"-u" | "--user")
				username="$2"
				shift 2
				;;
			"-vvv")
				print_log='True'
				log_level='verbose-level'
				shift
				;;
			*)
				ERROR "Don't know what to do. '$1' is an unknown OPTION."
				;;
		esac
	done
}	# ----------  end of function SET_OPTIONS  ----------

ERROR() 
{
	local message="${*}"
	echo "Error occured."
	HELP "--less" "${message}"
}	# ----------  end of function ERROR  ----------

HELP() 
{
	local message
	# --less statement: used for Error messages
	if [ "$1" = "--less" ]; then
		message=$(echo "${@}" | cut -d ' ' -f2-)
		echo "See '$0 -h/--help' for DESCRIPTION and USAGE.."
		EXIT "--abnormal" "$message"
	else
		echo "$0 HELP statement"
		echo
		echo "DESCRIPTION:"
		echo "    __will be implemented__"
		echo
		echo
		echo "USAGE: $0 [OPTIONS].."
		echo
		echo "OPTIONS:"
		echo "    -c, --connect            Perform action - ssh connection."
		echo "    -f, --ssh-f FILENAME     Provide a FILENAME for storing ssh key"
		echo "                              otherwise 'file.ssh_key' will be used."
		echo "    -h, --help               Display this statement and exit."
		echo "    -l, --log                Enable logs during execution. Used for"
		echo "                              this script development."
		echo "    -u, --user USERNAME      Give USERNAME to connect to Azure VM "
		echo "                              otherwise 'azureuser' will be used."
		echo
	fi
	EXIT "--normal" " "
}	# ----------  end of function HELP  ----------

EXIT() 
{
	local message
	message=$(echo "${@}" | cut -d ' ' -f2-)

	case "$1" in # "$mode" in
		--abnormal)
			echo "ABNORMAL Exit. Reason:"
			echo "$message"
			exit 1
			;;
		--normal)
			LOG "verbose" "CLEAN Exit."
			exit 0
			;;
		*)
			echo "ABNORMAL Exit. Reason: Unrecognized exit mode."
			echo "'\$mode'=$1"
			exit 1
			;;
	esac
}	# ----------  end of function EXIT  ----------

CHECK_USERNAME() 
{
	local user="$username"
	if [ -z "${vm_user}" ]; then
		user='azureuser'
	fi
	vm_user="$user"
}	# ----------  end of function CHECK_USERNAME  ----------

CHECK_VM_IP() 
{
	# get ip_address from terraform output
	local ip_address
	ip_address=$(terraform output public_ip_address | tr -d '"')
	LOG "verbose" "${FUNCNAME[0]}:" "$ip_address" "- ip_address"
	
	# validating
	if [[ $ip_address =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
		## save output as array to $ip - IFS delimiter.
		local ip
		IFS="." read -r -a ip <<< "$ip_address"
		[[ "${ip[0]}" -le 255 && "${ip[1]}" -le 255 && "${ip[2]}" -le 255 \
			&& "${ip[3]}" -le 255 ]]
		local stat=$?
	fi
	
	LOG "verbose" "${FUNCNAME[0]}:" "$stat" "- status of ip validation"
	if [ "$stat" -eq 0 ]; then
		# ip_address is valid -> return it value
		vm_IP="$ip_address"
	fi
}	# ----------  end of function CHECK_VM_IP  ----------

CHECK_SSH_KEY ()
{
	local k_file 
	local ssh_key_content
	local valid
	local file_perm # permisions

	k_file="$ssh_key_file"

	# check if file_name_of_ssh_key was provided 
	if [ -z "$k_file" ]; then
		k_file='file.ssh_key'
	fi
	
	# check content of ssh_key
	ssh_key_content=$(terraform output -raw tls_private_key)
	## save output as array to $valid - IFS delimiter.
	IFS=" " read -r -a valid <<< "$(echo "$ssh_key_content" | \
				grep -E "(-{5}(BEGIN|END) RSA PRIVATE KEY-{5})" | \
				wc -l -m)"

	file_perm=$(stat -c "%a" "$k_file")
	if [[ "$file_perm" -gt 600 ]]; then
		eval 'chmod 600 "$k_file"'
	fi

	fingerprint=$(ssh-keygen -l -f "$k_file")
	valid+=( "$(echo "$fingerprint" | \
		grep -qE "(^4096\s+SHA256.*\(RSA\)$)"; \
		echo $?)" )

	LOG "verbose" "${FUNCNAME[0]}:" "Result of 1th validation step: ${valid[*]}"
	
	if [[ "${valid[0]}" = 2 ]] && [[ "${valid[1]}" = 62 ]] && [ "${valid[2]}" ]; then
		eval 'echo "$ssh_key_content" > "$k_file"'
	else
		LOG "verbose" "File ssh Error"
		ERROR "The key does not passed validation step." "$(printf "\nSSH_KEY_Content: \n \n \n")" "$ssh_key_content"
	fi

	vm_ssh_key="$k_file"
}	# ----------  end of function CHECK_SSH_KEY  ----------

LOG()
{
	local to_print="$print_log"
	local lg_lv="$log_level"
	local message
	# set message
	if [ "$lg_lv" = "verbose-level" ] && [ "$1" = "verbose" ]; then
		message=$(echo "${@}" | cut -d ' ' -f2-)
	elif [ "$lg_lv" = "info-level" ] && [ "$1" = "verbose" ]; then
		return 2
	else
		message="${*}"
	fi

	if [ "$to_print" = "True" ] && [ -n "$message" ]; then
		echo "$message"
	fi
}	# ----------  end of function LOG  ----------

### call MAIN
MAIN "$@"


### end.SCRIPT
