#!/bin/bash

. /usr/share/openmediavault/scripts/helper-functions
. /etc/default/openmediavault

# Time interval (in seconds) between checks
CHECK_INTERVAL=3600  # 3600 seconds = 1 hour

if [[ $(id -u) -ne 0 ]]; then
  echo "This script must be executed as root or using sudo."
  exit 99
fi

# Automatically set the Let's Encrypt certificate paths
cert="/path/to/fullchain.pem"
key="/path/to/privkey.pem"

# Check if the certificate and key files exist
if [ ! -f "${cert}" ]; then
  echo "Cert file not found: ${cert}"
  exit 2
fi

if [ ! -f "${key}" ]; then
  echo "Key file not found: ${key}"
  exit 3
fi

# Automatically get the UUID of the existing certificate
uuid=$(ls /etc/ssl/certs/openmediavault-* | sed -e 's@/etc/ssl/certs/openmediavault-@@' -e 's@.crt@@')

# Check if the UUID was found
if [[ -z "$uuid" ]]; then
  echo "UUID not found"
  exit 1
fi

# Path to the UUID in the configuration system
xpath="/config/system/certificates/sslcertificate[uuid='${uuid}']"

# Temporary backup directory (deleted and replaced every time)
backup_dir="/path/to/backup"  # Modify with your backup destination path
mkdir -p "${backup_dir}"

# Function to check if the files have changed
check_files_changed() {
  current_cert_content=$(cat "${cert}")
  current_key_content=$(cat "${key}")

  # Read the certificates and private key already stored in the database
  stored_cert_content=$(omv_config_get "${xpath}/certificate")
  stored_key_content=$(omv_config_get "${xpath}/privatekey")

  if [[ "$current_cert_content" != "$stored_cert_content" || "$current_key_content" != "$stored_key_content" ]]; then
    return 0  # Files have changed
  else
    return 1  # Files have not changed
  fi
}

# Function to perform the certificate update
update_certificates() {
  echo "Certificate or private key has changed, updating..."

  # Backup the previous certificate (deleted and replaced every time)
  echo "Deleting old certificate backup..."
  rm -f "${backup_dir}/openmediavault-${uuid}-old.crt"
  rm -f "${backup_dir}/openmediavault-${uuid}-old.key"

  # Save the new certificates as a backup
  echo "Backing up new certificate and private key..."
  cp "${cert}" "${backup_dir}/openmediavault-${uuid}-old.crt"
  cp "${key}" "${backup_dir}/openmediavault-${uuid}-old.key"

  # Update the certificate in the database
  omv_config_update "${xpath}/certificate" "$(cat ${cert})"

  # Update the private key in the database
  omv_config_update "${xpath}/privatekey" "$(cat ${key})"

  # If a fourth parameter (comment) is passed, update the comment as well
  if [ -n "${4}" ]; then
    omv_config_update "${xpath}/comment" "${4}"
  fi

  # Update the certificates and nginx
  omv-salt deploy run certificates nginx

  # Restart the nginx service
  systemctl restart nginx

  echo "Process completed successfully."
}

# Main loop to monitor changes every CHECK_INTERVAL seconds
while true; do
  if check_files_changed; then
    update_certificates
  else
    echo "No changes detected. Waiting for next check..."
  fi
  sleep "$CHECK_INTERVAL"
done
