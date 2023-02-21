#!/bin/bash

#Author: Gerald Lim Wee Koon (github:mathscantor)

set -o errexit
set -o nounset
set -o pipefail

#----------------SET YOUR VALUES HERE PROPERLY----------------#
user="root" # Preferably root									  
readonly SOURCE_DIR="123.123.123.123:/path/to/original/storage"
readonly BACKUP_DIR="/path/to/backups/folder"	
readonly LOG_DIR="/path/to/rsync_logs/folder"
readonly INCLUDELIST_PATH="/path/to/include-list.txt"
readonly EXCLUDELIST_PATH="/path/to/exclude-list.txt"
readonly DATETIME="$(date '+%Y-%m-%d_%H:%M:%S')"		  
readonly BACKUP_PATH="${BACKUP_DIR}/${DATETIME}"			  
readonly LATEST_LINK="${BACKUP_DIR}/latest"	
readonly LOG_PATH="${LOG_DIR}/${DATETIME}.log"
				  
mkdir -p "${BACKUP_DIR}"							  
mkdir -p "${LATEST_LINK}"
mkdir -p "${LOG_DIR}"	
    										  
#Set the retention value, a.k.a number of backups to retain
#Remember to +1 because of latest directory.	  
retention=31									  
#-------------------------------------------------------------#


#----------------COLOURS----------------#
RED="\033[0;91m"
GREEN="\033[0;92m"
YELLOW="\033[0;93m"
BLUE="\033[0;94m"
PURPLE="\033[0;95m"
CYAN="\033[0;96m"
ENDC="\033[0m"
#---------------------------------------#

eventInterrupt(){
	trap SIGINT
	echo -e "${RED}[ERROR] Interrupt Signal was given${ENDC}"
	echo -e "${YELLOW}[DEBUG] Removing ${BACKUP_PATH}...Please Wait${ENDC}"
	echo -e "${RED}[ERROR] Interrupt Signal was given${ENDC}" >> ${LOG_PATH}
	echo -e "${YELLOW}[DEBUG] Removing ${BACKUP_PATH}...Please Wait${ENDC}" >> ${LOG_PATH}
	rm -rd ${BACKUP_PATH}
	exit 3
}

main() {
	
	trap "eventInterrupt" INT
	
	echo -e "${GREEN}[INFO] Starting Rsync...${ENDC}"
	echo -e "${GREEN}[INFO] Starting Rsync...${ENDC}" >> ${LOG_PATH}
	#Start the backup process
	rsync -avP --info=progress2 --delete \
	"${user}@${SOURCE_DIR}/" \
	--link-dest "${LATEST_LINK}" \
	--include-from="${INCLUDELIST_PATH}" \
	--exclude-from="${EXCLUDELIST_PATH}" \
	"${BACKUP_PATH}" >> ${LOG_PATH}
	
	if [[ $? -ne 0 ]]; then
		echo -e "${RED}[ERROR] RSYNC cannot be completed...${ENDC}"
		echo -e "${YELLOW}[DEBUG] Removing ${BACKUP_PATH}...Please Wait${ENDC}"
		echo -e "${RED}[ERROR] RSYNC cannot be completed...${ENDC}" >> ${LOG_PATH}
		echo -e "${YELLOW}[DEBUG] Removing ${BACKUP_PATH}...Please Wait${ENDC}" >> ${LOG_PATH}
		rm -rd ${BACKUP_PATH}
		echo "Backup Server failed rsync @ ${DATETIME}. Please resolve this issue!" >> ${LOG_PATH}
		exit 2
	else
		echo -e "${GREEN}[INFO] RSYNC successful${ENDC}"
		echo -e "${GREEN}[INFO] Symbolic Re-link: ${LATEST_LINK} --> ${BACKUP_PATH}${ENDC}"
		echo -e "${GREEN}[INFO] RSYNC successful${ENDC}" >> ${LOG_PATH}
		echo -e "${GREEN}[INFO] Symbolic Re-link: ${LATEST_LINK} --> ${BACKUP_PATH}${ENDC}" >> ${LOG_PATH}
	fi
	
	if [ -L "${LATEST_LINK}" ]
	then 
		rm "${LATEST_LINK}"
	else 
		rm -d "${LATEST_LINK}"
	fi
	echo -e "${YELLOW}[DEBUG] Old symbolic link removed!${ENDC}"
	echo -e "${YELLOW}[DEBUG] Old symbolic link removed!${ENDC}" >> ${LOG_PATH}

	ln -s "${BACKUP_PATH}" "${LATEST_LINK}"
	echo -e "${YELLOW}[DEBUG] New symbolic link created!${ENDC}"
	echo -e "${YELLOW}[DEBUG] New symbolic link created!${ENDC}" >> ${LOG_PATH}

	#clean up incremental archives older than the specified retention period
	while [ $(ls ${BACKUP_DIR} | wc -l ) -gt ${retention} ]
	do 	
		fileToBeRemoved="${BACKUP_DIR}/$(ls ${BACKUP_DIR} | tail -n 10000 | head -n 1)"
		echo -e "${GREEN}[INFO] Removing ${fileToBeRemoved}${ENDC}"
		echo -e "${GREEN}[INFO] Removing ${fileToBeRemoved}${ENDC}" >> ${LOG_PATH}
		rm -rd ${fileToBeRemoved}
	done
	echo -e "${CYAN}Please check under ${LATEST_LINK} OR ${BACKUP_PATH} for new backup files!${ENDC}"
	echo -e "${CYAN}Please check under ${LATEST_LINK} OR ${BACKUP_PATH} for new backup files!${ENDC}" >> ${LOG_PATH}
	echo "Backup Server successfully performed rsync @ ${DATETIME}" >> ${LOG_PATH}
	trap SIGINT
	exit 0
}

#Entry Point
main

