#!/bin/bash
set -euo pipefail

# ==================================================
# LUKS2 + TPM2 Auto-Unlock
# ==================================================
LUKS_DEVICE="/dev/nvme0n1p7"

echo "==> Re-enrolling TPM2 for LUKS auto-unlock..."

# Wipe existing tpm2 slot if present (ignore failure on first run)
sudo systemd-cryptenroll --wipe-slot=tpm2 "$LUKS_DEVICE" || true

# Enroll fresh TPM2 key
sudo systemd-cryptenroll \
	--tpm2-device=auto \
	--tpm2-pcrs=7 "$LUKS_DEVICE"

# ==================================================
# NVIDIA + Secure Boot / MOK
# ==================================================
GRAPHICS_CARD="NVIDIA GeForce RTX 4060"
GRAPHICS_MODULE="nvidia"

echo "==> Rebuilding NVIDIA kernel modules..."

sudo rm -rf /var/cache/akmods/nvidia/*
sudo akmods --force --rebuild

# --------------------------------------------------
# Secure Boot / MOK
# --------------------------------------------------

if mokutil --sb-state 2>/dev/null | grep -q "SecureBoot enabled"; then
	echo "==> Secure Boot enabled; checking AKMOD signing certificate..."

	MOK_CERT="/etc/pki/akmods/certs/public_key.der"

	if [ ! -f "$MOK_CERT" ]; then
		echo "  - AKMOD signing certificate not found."
		echo "  - Attempting to locate certificate..."

		MOK_CERT=$(find /etc/pki/akmods \
			-type f \
			-name "*.der" \
			-print -quit)

		if [ -z "$MOK_CERT" ]; then
			echo "ERROR: Could not locate AKMOD signing certificate."
			exit 1
		fi
	fi

	echo "  - Using certificate: $MOK_CERT"

	# Check whether the certificate is already enrolled.
	# If not, queue it for enrollment on next reboot.
	if ! mokutil --list-enrolled 2>/dev/null | \
		grep -q "$(openssl x509 \
			-inform DER \
			-in "$MOK_CERT" \
			-noout \
			-subject 2>/dev/null | \
			sed 's/^subject=//')"
	then
		echo "  - AKMOD certificate is not enrolled."
		echo "  - Importing certificate into MOK database..."

		sudo mokutil --import "$MOK_CERT"

		echo
		echo "=================================================="
		echo " MOK enrollment has been queued."
		echo " Reboot and enroll the certificate in MOK Manager."
		echo "=================================================="
		echo
	else
		echo "  - AKMOD certificate already enrolled."
	fi
fi

# ==================================================
# Time Sync
# ==================================================
echo "==> Verifying time sync configuration..."

TIMEDATE_STATUS=$(timedatectl status)

if echo "$TIMEDATE_STATUS" | grep -q "RTC in local TZ: yes"; then
	echo "  - RTC was set to local TZ, correcting to UTC"
	sudo timedatectl set-local-rtc 0 --adjust-system-clock
fi

if ! echo "$TIMEDATE_STATUS" | grep -q "NTP service: active"; then
	echo "  - NTP not active, enabling"
	sudo timedatectl set-ntp true
fi

# ==================================================
# Rebuild INITRAMFS (covers LUKS + NVIDIA changes above)
# ==================================================
echo "==> Regenerating initramfs..."
sudo dracut --force --regenerate-all

echo "==> Done."

