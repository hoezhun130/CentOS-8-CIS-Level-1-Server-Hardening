#!/bin/bash

clear
> cis_compliance_check.txt
echo Generating Result...
echo "================================================================================" >> cis_compliance_check.txt
# 1.10
echo "1.10" >> cis_compliance_check.txt
echo "Ensure updates, patches, and additional security software are installed" >> cis_compliance_check.txt

# Run dnf check-update command
dnf_check=$(dnf check-update)
echo "Output of 'dnf check-update':" >> cis_compliance_check.txt
echo "$dnf_check" >> cis_compliance_check.txt

# Check if there are updates available
if [ -z "$dnf_check" ]; then
    echo "Result: Compliant" >> cis_compliance_check.txt
else
    echo "Result: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.9
echo "" >> cis_compliance_check.txt
echo "1.1.9" >> cis_compliance_check.txt
echo "Disable Automounting" >> cis_compliance_check.txt

# Check if autofs is installed
if ! rpm -q autofs &> /dev/null; then
    echo "autofs is not installed" >> cis_compliance_check.txt
else
    # Check if autofs is enabled
    is_enabled=$(systemctl is-enabled autofs 2>&1)
    echo "Output: $is_enabled" >> cis_compliance_check.txt
    if [[ "$is_enabled" == *"disabled"* ]]; then
        echo "Result: Compliant" >> cis_compliance_check.txt
    else
        echo "Result: Non-Compliant" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.10
echo "" >> cis_compliance_check.txt
echo "1.1.10" >> cis_compliance_check.txt
echo "Disable USB Storage" >> cis_compliance_check.txt

# Run the command to check the output of modprobe -n -v usb-storage
modprobe_output=$(modprobe -n -v usb-storage)
echo "Output: $modprobe_output" >> cis_compliance_check.txt

# Verify if the output matches the expected result
if [[ "$modprobe_output" == *"install /bin/true"* ]]; then
    echo "Result: Compliant" >> cis_compliance_check.txt
else
    echo "Result: Non-compliant" >> cis_compliance_check.txt
fi

# Run the command to check if usb-storage module is loaded
lsmod_output=$(lsmod | grep usb-storage)
echo "Output: $lsmod_output" >> cis_compliance_check.txt

# Verify if there is no output for usb-storage module
if [ -z "$lsmod_output" ]; then
    echo "No usb-storage module loaded" >> cis_compliance_check.txt
else
    echo "usb-storage module loaded" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.1.1
echo "" >> cis_compliance_check.txt
echo "1.1.1.1" >> cis_compliance_check.txt
echo "Ensure mounting of cramfs filesystems is disabled" >> cis_compliance_check.txt

# Run the command to check the output of modprobe -n -v cramfs | grep "^install"
modprobe_output=$(modprobe -n -v cramfs | grep "^install")
echo "Output of 'modprobe -n -v cramfs | grep \"^install\"': $modprobe_output" >> cis_compliance_check.txt

# Verify if the output matches the expected result
if [[ "$modprobe_output" == *"install /bin/false"* ]]; then
    echo "Output of 'modprobe -n -v cramfs' is compliant" >> cis_compliance_check.txt
else
    echo "Output of 'modprobe -n -v cramfs' is non-compliant" >> cis_compliance_check.txt
fi

# Run the command to check if cramfs module is loaded
lsmod_output=$(lsmod | grep cramfs)
echo "Output of 'lsmod | grep cramfs': $lsmod_output" >> cis_compliance_check.txt

# Verify if there is no output for cramfs module
if [ -z "$lsmod_output" ]; then
    echo "No cramfs module loaded" >> cis_compliance_check.txt
else
    echo "cramfs module loaded" >> cis_compliance_check.txt
fi

# Run the command to check if cramfs module is blacklisted
blacklist_output=$(grep -E "^blacklist\s+cramfs" /etc/modprobe.d/*)
echo "Output of 'grep -E \"^blacklist\s+cramfs\" /etc/modprobe.d/*': $blacklist_output" >> cis_compliance_check.txt

# Verify if the module is blacklisted
if [ -n "$blacklist_output" ]; then
    echo "cramfs module is blacklisted" >> cis_compliance_check.txt
else
    echo "cramfs module is not blacklisted" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.2.1
echo "" >> cis_compliance_check.txt
echo "1.1.2.1" >> cis_compliance_check.txt
echo "Ensure /tmp is a separate partition" >> cis_compliance_check.txt

# Run the command to check if /tmp is mounted
findmnt_output=$(findmnt --kernel /tmp)
echo "Output of 'findmnt --kernel /tmp':" >> cis_compliance_check.txt
echo "$findmnt_output" >> cis_compliance_check.txt

# Verify if /tmp is mounted
if echo "$findmnt_output" | grep -q "/tmp"; then
    echo "/tmp is mounted: Compliant" >> cis_compliance_check.txt
else
    echo "/tmp is not mounted: Non-Compliant" >> cis_compliance_check.txt
fi

# Run the command to check if /tmp partition is set to be mounted at boot time
systemctl_output=$(systemctl is-enabled tmp.mount)
echo "Output of 'systemctl is-enabled tmp.mount': $systemctl_output" >> cis_compliance_check.txt

# Verify if /tmp partition is set to be mounted at boot time
if [[ "$systemctl_output" == "static" || "$systemctl_output" == "generated" ]]; then
    echo "/tmp partition is set to be mounted at boot time" >> cis_compliance_check.txt
else
    echo "/tmp partition is not set to be mounted at boot time" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.2.2
echo "" >> cis_compliance_check.txt
echo "1.1.2.2" >> cis_compliance_check.txt
echo "Ensure nodev option set on /tmp partition" >> cis_compliance_check.txt

# Run the command to check if the nodev option is set for /tmp partition
nodev_output=$(findmnt --kernel /tmp | grep nodev)
echo "Output of 'findmnt --kernel /tmp | grep nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if the nodev option is set for /tmp partition
if echo "$nodev_output" | grep -q "nodev"; then
    echo "nodev option is set for /tmp partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /tmp partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.2.3
echo "" >> cis_compliance_check.txt
echo "1.1.2.3" >> cis_compliance_check.txt
echo "Ensure noexec option set on /tmp partition" >> cis_compliance_check.txt

# Run the command to check if the noexec option is set for /tmp partition
noexec_output=$(findmnt --kernel /tmp | grep noexec)
echo "Output of 'findmnt --kernel /tmp | grep noexec':" >> cis_compliance_check.txt
echo "$noexec_output" >> cis_compliance_check.txt

# Verify if the noexec option is set for /tmp partition
if echo "$noexec_output" | grep -q "noexec"; then
    echo "noexec option is set for /tmp partition: Compliant" >> cis_compliance_check.txt
else
    echo "noexec option is not set for /tmp partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.2.4
echo "" >> cis_compliance_check.txt
echo "1.1.2.4" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /tmp partition" >> cis_compliance_check.txt

# Run the command to check if the nosuid option is set for /tmp partition
nosuid_output=$(findmnt --kernel /tmp | grep nosuid)
echo "Output of 'findmnt --kernel /tmp | grep nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if the nosuid option is set for /tmp partition
if echo "$nosuid_output" | grep -q "nosuid"; then
    echo "nosuid option is set for /tmp partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /tmp partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.3.2
echo "" >> cis_compliance_check.txt
echo "1.1.3.2" >> cis_compliance_check.txt
echo "Ensure nodev option set on /var partition" >> cis_compliance_check.txt

# Run the command to check if the nodev option is set for /var partition
nodev_output=$(findmnt --kernel /var | grep nodev)
echo "Output of 'findmnt --kernel /var | grep nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if the nodev option is set for /var partition
if echo "$nodev_output" | grep -q "nodev"; then
    echo "nodev option is set for /var partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /var partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.3.3
echo "" >> cis_compliance_check.txt
echo "1.1.3.3" >> cis_compliance_check.txt
echo "Ensure noexec option set on /var partition" >> cis_compliance_check.txt

# Run the command to check if the noexec option is set for /var partition
noexec_output=$(findmnt --kernel /var | grep noexec)
echo "Output of 'findmnt --kernel /var | grep noexec':" >> cis_compliance_check.txt
echo "$noexec_output" >> cis_compliance_check.txt

# Verify if the noexec option is set for /var partition
if echo "$noexec_output" | grep -q "noexec"; then
    echo "noexec option is set for /var partition: Compliant" >> cis_compliance_check.txt
else
    echo "noexec option is not set for /var partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.3.4
echo "" >> cis_compliance_check.txt
echo "1.1.3.4" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /var partition" >> cis_compliance_check.txt

# Run the command to check if the nosuid option is set for /var partition
nosuid_output=$(findmnt --kernel /var | grep nosuid)
echo "Output of 'findmnt --kernel /var | grep nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if the nosuid option is set for /var partition
if echo "$nosuid_output" | grep -q "nosuid"; then
    echo "nosuid option is set for /var partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /var partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.4.2
echo "" >> cis_compliance_check.txt
echo "1.1.4.2" >> cis_compliance_check.txt
echo "Ensure noexec option set on /var/tmp partition" >> cis_compliance_check.txt

# Run the command to check if the noexec option is set for /var/tmp partition
noexec_output=$(findmnt --kernel /var/tmp | grep noexec)
echo "Output of 'findmnt --kernel /var/tmp | grep noexec':" >> cis_compliance_check.txt
echo "$noexec_output" >> cis_compliance_check.txt

# Verify if the noexec option is set for /var/tmp partition
if echo "$noexec_output" | grep -q "noexec"; then
    echo "noexec option is set for /var/tmp partition: Compliant" >> cis_compliance_check.txt
else
    echo "noexec option is not set for /var/tmp partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.4.3
echo "" >> cis_compliance_check.txt
echo "1.1.4.3" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /var/tmp partition" >> cis_compliance_check.txt

# Run the command to check if the nosuid option is set for /var/tmp partition
nosuid_output=$(findmnt --kernel /var/tmp | grep nosuid)
echo "Output of 'findmnt --kernel /var/tmp | grep nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if the nosuid option is set for /var/tmp partition
if echo "$nosuid_output" | grep -q "nosuid"; then
    echo "nosuid option is set for /var/tmp partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /var/tmp partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.4.4
echo "" >> cis_compliance_check.txt
echo "1.1.4.4" >> cis_compliance_check.txt
echo "Ensure nodev option set on /var/tmp partition" >> cis_compliance_check.txt

# Run the command to check if the nodev option is set for /var/tmp partition
nodev_output=$(findmnt --kernel /var/tmp | grep nodev)
echo "Output of 'findmnt --kernel /var/tmp | grep nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if the nodev option is set for /var/tmp partition
if echo "$nodev_output" | grep -q "nodev"; then
    echo "nodev option is set for /var/tmp partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /var/tmp partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.5.2
echo "" >> cis_compliance_check.txt
echo "1.1.5.2" >> cis_compliance_check.txt
echo "Ensure nodev option set on /var/log partition" >> cis_compliance_check.txt

# Run the command to check if the nodev option is set for /var/log partition
nodev_output=$(findmnt --kernel /var/log | grep nodev)
echo "Output of 'findmnt --kernel /var/log | grep nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if the nodev option is set for /var/log partition
if echo "$nodev_output" | grep -q "nodev"; then
    echo "nodev option is set for /var/log partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /var/log partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.5.3
echo "" >> cis_compliance_check.txt
echo "1.1.5.3" >> cis_compliance_check.txt
echo "Ensure noexec option set on /var/log partition" >> cis_compliance_check.txt

# Run the command to check if the noexec option is set for /var/log partition
noexec_output=$(findmnt --kernel /var/log | grep noexec)
echo "Output of 'findmnt --kernel /var/log | grep noexec':" >> cis_compliance_check.txt
echo "$noexec_output" >> cis_compliance_check.txt

# Verify if the noexec option is set for /var/log partition
if echo "$noexec_output" | grep -q "noexec"; then
    echo "noexec option is set for /var/log partition: Compliant" >> cis_compliance_check.txt
else
    echo "noexec option is not set for /var/log partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.5.4
echo "" >> cis_compliance_check.txt
echo "1.1.5.4" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /var/log partition" >> cis_compliance_check.txt

# Run the command to check if the nosuid option is set for /var/log partition
nosuid_output=$(findmnt --kernel /var/log | grep nosuid)
echo "Output of 'findmnt --kernel /var/log | grep nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if the nosuid option is set for /var/log partition
if echo "$nosuid_output" | grep -q "nosuid"; then
    echo "nosuid option is set for /var/log partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /var/log partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.6.2
echo "" >> cis_compliance_check.txt
echo "1.1.6.2" >> cis_compliance_check.txt
echo "Ensure noexec option set on /var/log/audit partition" >> cis_compliance_check.txt

# Run the command to check if the noexec option is set for /var/log/audit partition
noexec_output=$(findmnt --kernel /var/log/audit | grep noexec)
echo "Output of 'findmnt --kernel /var/log/audit | grep noexec':" >> cis_compliance_check.txt
echo "$noexec_output" >> cis_compliance_check.txt

# Verify if the noexec option is set for /var/log/audit partition
if echo "$noexec_output" | grep -q "noexec"; then
    echo "noexec option is set for /var/log/audit partition: Compliant" >> cis_compliance_check.txt
else
    echo "noexec option is not set for /var/log/audit partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.6.3
echo "" >> cis_compliance_check.txt
echo "1.1.6.3" >> cis_compliance_check.txt
echo "Ensure nodev option set on /var/log/audit partition" >> cis_compliance_check.txt

# Run the command to check if the nodev option is set for /var/log/audit partition
nodev_output=$(findmnt --kernel /var/log/audit | grep nodev)
echo "Output of 'findmnt --kernel /var/log/audit | grep nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if the nodev option is set for /var/log/audit partition
if echo "$nodev_output" | grep -q "nodev"; then
    echo "nodev option is set for /var/log/audit partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /var/log/audit partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.6.4
echo "" >> cis_compliance_check.txt
echo "1.1.6.4" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /var/log/audit partition" >> cis_compliance_check.txt

# Run the command to check if the nosuid option is set for /var/log/audit partition
nosuid_output=$(findmnt --kernel /var/log/audit | grep nosuid)
echo "Output of 'findmnt --kernel /var/log/audit | grep nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if the nosuid option is set for /var/log/audit partition
if echo "$nosuid_output" | grep -q "nosuid"; then
    echo "nosuid option is set for /var/log/audit partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /var/log/audit partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.7.2
echo "" >> cis_compliance_check.txt
echo "1.1.7.2" >> cis_compliance_check.txt
echo "Ensure nodev option set on /home partition" >> cis_compliance_check.txt

# Run the command to check if the nodev option is set for /home partition
nodev_output=$(findmnt --kernel /home | grep nodev)
echo "Output of 'findmnt --kernel /home | grep nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if the nodev option is set for /home partition
if echo "$nodev_output" | grep -q "nodev"; then
    echo "nodev option is set for /home partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /home partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.7.3
echo "" >> cis_compliance_check.txt
echo "1.1.7.3" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /home partition" >> cis_compliance_check.txt

# Run the command to check if the nosuid option is set for /home partition
nosuid_output=$(findmnt --kernel /home | grep nosuid)
echo "Output of 'findmnt --kernel /home | grep nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if the nosuid option is set for /home partition
if echo "$nosuid_output" | grep -q "nosuid"; then
    echo "nosuid option is set for /home partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /home partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.7.4
echo "" >> cis_compliance_check.txt
echo "1.1.7.4" >> cis_compliance_check.txt
echo "Ensure usrquota option set on /home partition" >> cis_compliance_check.txt

# Run the command to check if the usrquota option is set for /home partition
usrquota_output=$(findmnt --kernel /home | grep usrquota)
echo "Output of 'findmnt --kernel /home | grep usrquota':" >> cis_compliance_check.txt
echo "$usrquota_output" >> cis_compliance_check.txt

# Verify if the usrquota option is set for /home partition
if echo "$usrquota_output" | grep -q "usrquota"; then
    echo "usrquota option is set for /home partition: Compliant" >> cis_compliance_check.txt
else
    echo "usrquota option is not set for /home partition: Non-Compliant" >> cis_compliance_check.txt
fi

# Check if user quotas are enabled
quota_status=$(quotaon -p /home 2>/dev/null | grep user)
echo "Output of 'quotaon -p /home | grep user':" >> cis_compliance_check.txt
echo "$quota_status" >> cis_compliance_check.txt

# Verify if user quotas are enabled
if echo "$quota_status" | grep -q "user quota on"; then
    echo "User quotas are enabled for /home partition: Compliant" >> cis_compliance_check.txt
else
    echo "User quotas are not enabled for /home partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.7.5
echo "" >> cis_compliance_check.txt
echo "1.1.7.5" >> cis_compliance_check.txt
echo "Ensure grpquota option set on /home partition" >> cis_compliance_check.txt

# Run the command to check if the grpquota option is set for /home partition
grpquota_output=$(findmnt --kernel /home | grep grpquota)
echo "Output of 'findmnt --kernel /home | grep grpquota':" >> cis_compliance_check.txt
echo "$grpquota_output" >> cis_compliance_check.txt

# Verify if the grpquota option is set for /home partition
if echo "$grpquota_output" | grep -q "grpquota"; then
    echo "grpquota option is set for /home partition: Compliant" >> cis_compliance_check.txt
else
    echo "grpquota option is not set for /home partition: Non-Compliant" >> cis_compliance_check.txt
fi

# Check if group quotas are enabled
quota_status=$(quotaon -p /home 2>/dev/null | grep group)
echo "Output of 'quotaon -p /home | grep group':" >> cis_compliance_check.txt
echo "$quota_status" >> cis_compliance_check.txt

# Verify if group quotas are enabled
if echo quotaon -p /home | grep group | grep -q "group quota on"; then
    echo "Group quotas are enabled for /home partition: Compliant" >> cis_compliance_check.txt
else
    echo "Group quotas are not enabled for /home partition: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.1.8.1
echo "" >> cis_compliance_check.txt
echo "1.1.8.1" >> cis_compliance_check.txt
echo "Ensure nodev option set on /dev/shm partition" >> cis_compliance_check.txt

# Run the command to check if /dev/shm partition exists and if nodev option is set
nodev_output=$(mount | grep -E '\s/dev/shm\s' | grep -v nodev)
echo "Output of 'mount | grep -E '\s/dev/shm\s' | grep -v nodev':" >> cis_compliance_check.txt
echo "$nodev_output" >> cis_compliance_check.txt

# Verify if nodev option is set for /dev/shm partition
if [ -z "$nodev_output" ]; then
    echo "nodev option is set for /dev/shm partition: Compliant" >> cis_compliance_check.txt
else
    echo "nodev option is not set for /dev/shm partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.8.2
echo "" >> cis_compliance_check.txt
echo "1.1.8.2" >> cis_compliance_check.txt
echo "Ensure noexec option set on /dev/shm partition" >> cis_compliance_check.txt

# Run the command to check if the noexec option is set for /dev/shm partition
noexec_output=$(findmnt --kernel /dev/shm | grep noexec)
echo "Output of 'findmnt --kernel /dev/shm | grep noexec':" >> cis_compliance_check.txt
echo "$noexec_output" >> cis_compliance_check.txt

# Verify if the noexec option is set for /dev/shm partition
if echo "$noexec_output" | grep -q "noexec"; then
    echo "noexec option is set for /dev/shm partition: Compliant" >> cis_compliance_check.txt
else
    echo "noexec option is not set for /dev/shm partition: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.1.8.3
echo "" >> cis_compliance_check.txt
echo "1.1.8.3" >> cis_compliance_check.txt
echo "Ensure nosuid option set on /dev/shm partition" >> cis_compliance_check.txt

# Run the command to check if /dev/shm partition exists and if nosuid option is set
nosuid_output=$(mount | grep -E '\s/dev/shm\s' | grep -v nosuid)
echo "Output of 'mount | grep -E '\s/dev/shm\s' | grep -v nosuid':" >> cis_compliance_check.txt
echo "$nosuid_output" >> cis_compliance_check.txt

# Verify if nosuid option is set for /dev/shm partition
if [ -z "$nosuid_output" ]; then
    echo "nosuid option is set for /dev/shm partition: Compliant" >> cis_compliance_check.txt
else
    echo "nosuid option is not set for /dev/shm partition: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.2.2
echo "" >> cis_compliance_check.txt
echo "1.2.2" >> cis_compliance_check.txt
echo "Ensure gpgcheck is globally activated" >> cis_compliance_check.txt

# Check global configuration in /etc/dnf/dnf.conf
global_gpgcheck=$(grep ^gpgcheck /etc/dnf/dnf.conf)
echo "Global configuration (in /etc/dnf/dnf.conf):" >> cis_compliance_check.txt
echo "$global_gpgcheck" >> cis_compliance_check.txt

# Verify if gpgcheck is set to 1 in /etc/dnf/dnf.conf
if echo "$global_gpgcheck" | grep -q "^gpgcheck=1$"; then
    echo "gpgcheck is set to 1 in /etc/dnf/dnf.conf: Compliant" >> cis_compliance_check.txt
else
    echo "gpgcheck is not set to 1 in /etc/dnf/dnf.conf: Non-Compliant" >> cis_compliance_check.txt
fi

# Check configurations in /etc/yum.repos.d/
repo_gpgcheck=$(grep -P "^gpgcheck\h*=\h*[^1].*\h*$" /etc/yum.repos.d/*)
echo "Configuration in /etc/yum.repos.d/:" >> cis_compliance_check.txt
echo "$repo_gpgcheck" >> cis_compliance_check.txt

# Verify if there are no instances of entries starting with gpgcheck set to 0 or invalid values
if [ -z "$repo_gpgcheck" ]; then
    echo "No instances of entries with gpgcheck set to 0 or invalid values in /etc/yum.repos.d/: Compliant" >> cis_compliance_check.txt
else
    echo "There are instances of entries with gpgcheck set to 0 or invalid values in /etc/yum.repos.d/: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.3.1
echo "" >> cis_compliance_check.txt
echo "1.3.1" >> cis_compliance_check.txt
echo "Ensure AIDE is installed" >> cis_compliance_check.txt

# Check if AIDE is installed
aide_installed=$(rpm -q aide)
echo "Output of 'rpm -q aide':" >> cis_compliance_check.txt
echo "$aide_installed" >> cis_compliance_check.txt

# Verify if AIDE is installed
if [ "$aide_installed" = "package aide is not installed" ]; then
    echo "AIDE is not installed: Non-Compliant" >> cis_compliance_check.txt
else
    echo "AIDE is installed: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.3.2
echo "" >> cis_compliance_check.txt
echo "1.3.2" >> cis_compliance_check.txt
echo "Ensure filesystem integrity is regularly checked" >> cis_compliance_check.txt

# Check for cron job
cron_job_output=$(grep -Ers '^([^#]+\s+)?(\/usr\/s?bin\/|^\s*)aide(\.wrapper)?\s(--?\S+\s)*(--(check|update)|\$AIDEARGS)\b' /etc/cron.* /etc/crontab /var/spool/cron/)
echo "Output of 'grep -Ers '^([^#]+\s+)?(\/usr\/s?bin\/|^\s*)aide(\.wrapper)?\s(--?\S+\s)*(--(check|update)|\$AIDEARGS)\b' /etc/cron.* /etc/crontab /var/spool/cron/':" >> cis_compliance_check.txt
echo "$cron_job_output" >> cis_compliance_check.txt

# Verify if a cron job in compliance with site policy is returned
if [ -n "$cron_job_output" ]; then
    echo "A cron job in compliance with site policy is configured: Compliant" >> cis_compliance_check.txt
else
    echo "No cron job configured or not compliant with site policy: Non-Compliant" >> cis_compliance_check.txt
fi

# Check systemd services and timer
systemctl_status_service=$(systemctl is-enabled aidecheck.service 2>/dev/null)
systemctl_status_timer=$(systemctl is-enabled aidecheck.timer 2>/dev/null)
timer_status=$(systemctl status aidecheck.timer 2>/dev/null| grep "Active:")

echo "Output of 'systemctl is-enabled aidecheck.service':" >> cis_compliance_check.txt
echo "$systemctl_status_service" >> cis_compliance_check.txt
echo "Output of 'systemctl is-enabled aidecheck.timer':" >> cis_compliance_check.txt
echo "$systemctl_status_timer" >> cis_compliance_check.txt
echo "Output of 'systemctl status aidecheck.timer | grep 'Active':''" >> cis_compliance_check.txt
echo "$timer_status" >> cis_compliance_check.txt

# Verify if aidcheck.service and aidcheck.timer are enabled and aidcheck.timer is running
if [ "$systemctl_status_service" = "enabled" ] && [ "$systemctl_status_timer" = "enabled" ] && [[ "$timer_status" == *"active (waiting)"* ]]; then
    echo "aidcheck.service and aidcheck.timer are enabled, and aidcheck.timer is running: Compliant" >> cis_compliance_check.txt
else
    echo "aidcheck.service and/or aidcheck.timer are not properly configured: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.4.1
echo "" >> cis_compliance_check.txt
echo "1.4.1" >> cis_compliance_check.txt
echo "Ensure bootloader password is set" >> cis_compliance_check.txt

# Run the script to verify bootloader password
{
  tst1="" 
  tst2="" 
  output=""
  grubdir=$(dirname "$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -El '^\s*(kernelopts=|linux|kernel)' {} \;)")
  
  if [ -f "$grubdir/user.cfg" ]; then
    grep -Pq '^\h*GRUB2_PASSWORD\h*=\h*.+$' "$grubdir/user.cfg" && output="bootloader password set in \"$grubdir/user.cfg\""
  fi
  
  if [ -z "$output" ]; then
    grep -Piq '^\h*set\h+superusers\h*=\h*"?[^"\n\r]+"?(\h+.*)?$' "$grubdir/grub.cfg" && tst1=pass
    grep -Piq '^\h*password(_pbkdf2)?\h+\H+\h+.+$' "$grubdir/grub.cfg" && tst2=pass
    [ "$tst1" = pass ] && [ "$tst2" = pass ] && output="bootloader password set in \"$grubdir/grub.cfg\""
  fi
  
  if [ -n "$output" ]; then
    echo -e "PASSED! $output\n" >> cis_compliance_check.txt
    echo "Bootloader password is set: Compliant" >> cis_compliance_check.txt
  else
    echo -e "FAILED! Bootloader password is not set or properly configured."
    echo "Bootloader password is not set or properly configured: Non-Compliant" >> cis_compliance_check.txt
  fi
} | tee -a cis_compliance_check.txt



echo "================================================================================" >> cis_compliance_check.txt
#1.4.2
# Ensure permissions on bootloader config are configured
echo "" >> cis_compliance_check.txt
echo "1.4.2" >> cis_compliance_check.txt
echo "Ensure permissions on bootloader config are configured" >> cis_compliance_check.txt

# Run the script to verify permissions
{
  output="" 
  output2="" 
  output3="" 
  output4=""
  
  grubdir=$(dirname "$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl '^\s*(kernelopts=|linux|kernel)' {} \;)")
  
  for grubfile in $grubdir/user.cfg $grubdir/grubenv $grubdir/grub.cfg; do
    if [ -f "$grubfile" ]; then
      if stat -c "%a" "$grubfile" | grep -Pq '^\s*[0-7]00$'; then
        output="$output\npermissions on \"$grubfile\" are \"$(stat -c "%a" "$grubfile")\""
      else
        output3="$output3\npermissions on \"$grubfile\" are \"$(stat -c "%a" "$grubfile")\""
      fi
      if stat -c "%u:%g" "$grubfile" | grep -Pq '^\s*0:0$'; then
        output2="$output2\n\"$grubfile\" is owned by \"$(stat -c "%U" "$grubfile")\" and belongs to group \"$(stat -c "%G" "$grubfile")\""
      else
        output4="$output4\n\"$grubfile\" is owned by \"$(stat -c "%U" "$grubfile")\" and belongs to group \"$(stat -c "%G" "$grubfile")\""
      fi
    fi
  done
  
  if [[ -n "$output" && -n "$output2" && -z "$output3" && -z "$output4" ]]; then
    echo -e "\nPASSED:" >> cis_compliance_check.txt
    [ -n "$output" ] && echo -e "$output" >> cis_compliance_check.txt
    [ -n "$output2" ] && echo -e "$output2" >> cis_compliance_check.txt
  else
    echo -e "\nFAILED:" >> cis_compliance_check.txt
    [ -n "$output3" ] && echo -e "$output3" >> cis_compliance_check.txt
    [ -n "$output4" ] && echo -e "$output4" >> cis_compliance_check.txt
  fi
} | tee -a cis_compliance_check.txt


echo "================================================================================" >> cis_compliance_check.txt
#1.4.3
# Ensure authentication is required when booting into rescue mode
echo "" >> cis_compliance_check.txt
echo "1.4.3" >> cis_compliance_check.txt
echo "Ensure authentication is required when booting into rescue mode" >> cis_compliance_check.txt

# Run the command to verify rescue mode configuration and capture the output
rescue_mode_config=$(grep -r '/usr/lib/systemd/systemd-sulogin-shell rescue' /usr/lib/systemd/system/rescue.service /etc/systemd/system/rescue.service.d 2>/dev/null)

echo "Output of rescue mode configuration command:" >> cis_compliance_check.txt
echo "$rescue_mode_config" >> cis_compliance_check.txt

# Check if the configuration is as expected
if [[ "$rescue_mode_config" == *"ExecStart=-/usr/lib/systemd/systemd-sulogin-shell rescue"* ]]; then
    echo "systemd-sulogin-shell is used: Compliant" >> cis_compliance_check.txt
else
    echo "systemd-sulogin-shell is not used: Non-compliant" >> cis_compliance_check.txt
fi


echo "================================================================================" >> cis_compliance_check.txt
#1.5.1
# Ensure core dump storage is disabled
echo "" >> cis_compliance_check.txt
echo "1.5.1" >> cis_compliance_check.txt
echo "Ensure core dump storage is disabled" >> cis_compliance_check.txt

# Run the command to verify core dump storage configuration and capture the output
coredump_config=$(grep -i '^\s*storage\s*=\s*none' /etc/systemd/coredump.conf)

echo "Output of core dump storage configuration command:" >> cis_compliance_check.txt
echo "$coredump_config" >> cis_compliance_check.txt

# Check if the configuration is as expected
if [[ "$coredump_config" == "Storage=none" ]]; then
    echo "Core dump storage is disabled: Storage=none. Compliant" | tee -a cis_compliance_check.txt
else
    echo "Core dump storage is not disabled: Storage configuration differs. Non-Compliant" >> cis_compliance_check.txt
fi


echo "================================================================================" >> cis_compliance_check.txt
#1.5.2
# Ensure core dump backtraces are disabled
echo "" >> cis_compliance_check.txt
echo "1.5.2" >> cis_compliance_check.txt
echo "Ensure core dump backtraces are disabled" >> cis_compliance_check.txt

# Run the command to verify core dump backtraces configuration and capture the output
backtraces_config=$(grep -i '^\s*ProcessSizeMax\s*=\s*0' /etc/systemd/coredump.conf)

echo "Output of core dump backtraces configuration command:" >> cis_compliance_check.txt
echo "$backtraces_config" >> cis_compliance_check.txt

# Check if the configuration is as expected
if [[ "$backtraces_config" == "ProcessSizeMax=0" ]]; then
    echo "Compliant: Core dump backtraces are disabled: ProcessSizeMax=0" | tee -a cis_compliance_check.txt
else
    echo "Non-Compliant: Core dump backtraces are not disabled: ProcessSizeMax configuration differs" >> cis_compliance_check.txt
fi


echo "================================================================================" >> cis_compliance_check.txt
#1.5.3
echo "" >> cis_compliance_check.txt
echo "1.5.3" >> cis_compliance_check.txt
echo "Ensure address space layout randomization (ASLR) is enabled" >> cis_compliance_check.txt

# Run the script to verify ASLR configuration and capture the output
{
krp="" pafile="" fafile=""
kpname="kernel.randomize_va_space" 
kpvalue="2"
searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
    echo -e "Output of ASLR configuration command:" >> cis_compliance_check.txt
    echo -e "\nPASS: \"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\"" >> cis_compliance_check.txt
else
    echo -e "Output of ASLR configuration command:" >> cis_compliance_check.txt
    echo -e "\nFAIL: " >> cis_compliance_check.txt
    [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration\n" >> cis_compliance_check.txt
    [ -n "$fafile" ] && echo -e "\n\"$kpname\" is set incorrectly in \"$fafile\"" >> cis_compliance_check.txt
    [ -z "$pafile" ] && echo -e "\n\"$kpname = $kpvalue\" is not set in a kernel parameter configuration file\n" >> cis_compliance_check.txt
fi
}

echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.1
echo "" >> cis_compliance_check.txt
echo "1.6.1.1" >> cis_compliance_check.txt
echo "Ensure SELinux is installed" >> cis_compliance_check.txt

# Run the command to verify SELinux installation and capture the output
selinux_installed=$(rpm -q libselinux)

echo "Output of SELinux installation check command:" >> cis_compliance_check.txt
echo "$selinux_installed" >> cis_compliance_check.txt

# Check if SELinux is installed
if [[ "$selinux_installed" == "libselinux-"* ]]; then
    echo "SELinux is installed: Compliant" >> cis_compliance_check.txt
else
    echo "SELinux is not installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.2
echo "" >> cis_compliance_check.txt
echo "1.6.1.2" >> cis_compliance_check.txt
echo "Ensure SELinux is not disabled in bootloader configuration" >> cis_compliance_check.txt

# Run the command to verify SELinux configuration in bootloader and capture the output
selinux_disabled=$(grep -P -- '^\h*(kernelopts=|linux|kernel)' $(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;) | grep -E -- '(selinux=0|enforcing=0)')

echo "Output of SELinux bootloader configuration check command:" >> cis_compliance_check.txt
echo "$selinux_disabled" >> cis_compliance_check.txt

# Check if SELinux is disabled in bootloader configuration
if [[ -z "$selinux_disabled" ]]; then
    echo "SELinux is not disabled in bootloader configuration: Compliant" >> cis_compliance_check.txt
else
    echo "SELinux is disabled in bootloader configuration: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.3
echo "" >> cis_compliance_check.txt
echo "1.6.1.3" >> cis_compliance_check.txt
echo "Ensure SELinux policy is configured" >> cis_compliance_check.txt

# Run the command to verify SELinux policy configuration in /etc/selinux/config
selinux_policy_config=$(grep -E '^\s*SELINUXTYPE=(targeted|mls)\b' /etc/selinux/config)

echo "Output of SELinux policy configuration command in /etc/selinux/config:" >> cis_compliance_check.txt
echo "$selinux_policy_config" >> cis_compliance_check.txt

# Check if SELinux policy is configured in /etc/selinux/config
if [[ "$selinux_policy_config" =~ (targeted|mls) ]]; then
    echo "SELinux policy is configured in /etc/selinux/config: Compliant" >> cis_compliance_check.txt
else
    echo "SELinux policy is not configured in /etc/selinux/config: Non-Compliant" >> cis_compliance_check.txt
fi

# Run the command to verify SELinux policy configuration with sestatus
selinux_policy_loaded=$(sestatus | grep "Loaded policy name")

echo "Output of SELinux policy configuration command with sestatus:" >> cis_compliance_check.txt
echo "$selinux_policy_loaded" >> cis_compliance_check.txt

# Check if SELinux policy is configured with sestatus
if [[ "$selinux_policy_loaded" =~ targeted ]]; then
    echo "SELinux policy is configured with sestatus: Compliant" >> cis_compliance_check.txt
else
    echo "SELinux policy is not configured with sestatus: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.4
echo "" >> cis_compliance_check.txt
echo "1.6.1.4" >> cis_compliance_check.txt
echo "Ensure the SELinux mode is not disabled" >> cis_compliance_check.txt

# Run the command to verify SELinux's current mode
selinux_current_mode=$(getenforce)

echo "Current SELinux mode:" >> cis_compliance_check.txt
echo "$selinux_current_mode" >> cis_compliance_check.txt

# Check if SELinux's current mode is either Enforcing or Permissive
if [[ "$selinux_current_mode" =~ (Enforcing|Permissive) ]]; then
    echo "SELinux mode is not disabled: Compliant" >> cis_compliance_check.txt
else
    echo "SELinux mode is disabled: Non-Compliant" >> cis_compliance_check.txt
fi

# Run the command to verify SELinux's configured mode in /etc/selinux/config
selinux_configured_mode=$(grep -Ei '^\s*SELINUX=(enforcing|permissive)' /etc/selinux/config)

echo "SELinux configured mode in /etc/selinux/config:" >> cis_compliance_check.txt
echo "$selinux_configured_mode" >> cis_compliance_check.txt

# Check if SELinux's configured mode in /etc/selinux/config is either Enforcing or Permissive
if [[ "$selinux_configured_mode" =~ (SELINUX=enforcing|SELINUX=permissive) ]]; then
    echo "SELinux configured mode is not disabled in /etc/selinux/config: Compliant" >> cis_compliance_check.txt
else
    echo "SELinux configured mode is disabled in /etc/selinux/config: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.6
echo "" >> cis_compliance_check.txt
echo "1.6.1.6" >> cis_compliance_check.txt
echo "Ensure no unconfined services exist" >> cis_compliance_check.txt

# Run the command to check for unconfined services
unconfined_services=$(ps -eZ | grep unconfined_service_t)

echo "Unconfined services:" >> cis_compliance_check.txt
echo "$unconfined_services" >> cis_compliance_check.txt

# Check if any unconfined services are found
if [ -z "$unconfined_services" ]; then
    echo "No unconfined services exist: Compliant" >> cis_compliance_check.txt
else
    echo "Unconfined services exist: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.7
echo "" >> cis_compliance_check.txt
echo "1.6.1.7" >> cis_compliance_check.txt
echo "Ensure SETroubleshoot is not installed" >> cis_compliance_check.txt

# Run the command to check if SETroubleshoot is installed
setroubleshoot_installed=$(rpm -q setroubleshoot)

echo "SETroubleshoot status:" >> cis_compliance_check.txt
echo "$setroubleshoot_installed" >> cis_compliance_check.txt

# Check if SETroubleshoot is not installed
if [ "$setroubleshoot_installed" == "package setroubleshoot is not installed" ]; then
    echo "SETroubleshoot is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "SETroubleshoot is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.6.1.8
echo "" >> cis_compliance_check.txt
echo "1.6.1.8" >> cis_compliance_check.txt
echo "Ensure the MCS Translation Service (mcstrans) is not installed" >> cis_compliance_check.txt

# Run the command to check if mcstrans is installed
mcstrans_installed=$(rpm -q mcstrans)

echo "MCS Translation Service (mcstrans) status:" >> cis_compliance_check.txt
echo "$mcstrans_installed" >> cis_compliance_check.txt

# Check if mcstrans is not installed
if [ "$mcstrans_installed" == "package mcstrans is not installed" ]; then
    echo "MCS Translation Service (mcstrans) is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "MCS Translation Service (mcstrans) is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.7.1
echo "" >> cis_compliance_check.txt
echo "1.7.1" >> cis_compliance_check.txt
echo "Ensure message of the day is configured properly" >> cis_compliance_check.txt

# Retrieve operating system name
os_name=$(grep '^ID=' /etc/os-release | cut -d= -f2 | sed -e 's/"//g')

# Check motd contents and log any errors
motd_contents=$(cat /etc/motd 2>&1) || {
    echo "Error: Failed to read /etc/motd" >> cis_compliance_check.txt
    exit 1
}

# Log current motd contents
echo "Message of the Day (motd) contents:" >> cis_compliance_check.txt
echo "$motd_contents" >> cis_compliance_check.txt

# Check compliance and log details
if grep -E -qi "(\v|\r|\m|\s|$os_name)" /etc/motd; then
    echo "Message of the day (motd) is not configured properly: Non-Compliant" >> cis_compliance_check.txt
else
    echo "Message of the day (motd) is configured properly: Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.7.2
echo "" >> cis_compliance_check.txt
echo "1.7.2" >> cis_compliance_check.txt
echo "Ensure local login warning banner is configured properly" >> cis_compliance_check.txt

# Check /etc/issue contents
issue_contents=$(cat /etc/issue)

echo "Contents of /etc/issue:" >> cis_compliance_check.txt
echo "$issue_contents" >> cis_compliance_check.txt

# Check if /etc/issue contents match site policy
if grep -E -qi "(\v|\r|\m|\s|$os_name)" /etc/issue; then
    echo "Local login warning banner (/etc/issue) is not configured properly: Non-Compliant" >> cis_compliance_check.txt
else
    echo "Local login warning banner (/etc/issue) is configured properly: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.7.3
echo "" >> cis_compliance_check.txt
echo "1.7.3" >> cis_compliance_check.txt
echo "Ensure remote login warning banner is configured properly" >> cis_compliance_check.txt

# Check /etc/issue.net contents
issue_net_contents=$(cat /etc/issue.net)

echo "Contents of /etc/issue.net:" >> cis_compliance_check.txt
echo "$issue_net_contents" >> cis_compliance_check.txt

# Check if /etc/issue.net contents match site policy
if grep -E -qi "(\v|\r|\m|\s|$os_name)" /etc/issue.net; then
    echo "VRemote login warning banner (/etc/issue.net) is not configured properly: Non-Compliant" >> cis_compliance_check.txt
else
    echo "Remote login warning banner (/etc/issue.net) is configured properly: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.7.4
echo "" >> cis_compliance_check.txt
echo "1.7.4" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/motd are configured" >> cis_compliance_check.txt

# Run the command to verify permissions on /etc/motd and capture the output
motd_permissions=$(stat -c "%A Uid: (%U/%G) Gid: (%G/%G)" /etc/motd 2>&1)

# Display the output of the permission check
echo "Permissions on /etc/motd:" >> cis_compliance_check.txt
echo "$motd_permissions" >> cis_compliance_check.txt

# Check if the permissions are as expected
if [[ "$motd_permissions" == "Access: (0644/-rw-r--r--) Uid: (0/root) Gid: (0/root)" ]]; then
    echo "Permissions on /etc/motd are configured correctly: Compliant" | tee -a cis_compliance_check.txt
else
    echo "Permissions on /etc/motd are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi


echo "================================================================================" >> cis_compliance_check.txt
#1.7.5
echo "" >> cis_compliance_check.txt
echo "1.7.5" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/issue are configured" >> cis_compliance_check.txt

# Run the command to verify permissions on /etc/issue
issue_permissions=$(stat -c "%A Uid: (%U/%G) Gid: (%G/%G)" /etc/issue)

# Display the output of the permission check
echo "Permissions on /etc/issue:" >> cis_compliance_check.txt
echo "$issue_permissions" >> cis_compliance_check.txt

# Check if the permissions are as expected
if [[ "$issue_permissions" == "Access: (0644/-rw-r--r--) Uid: (0/root) Gid: (0/root)" ]]; then
    echo "Permissions on /etc/issue are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "Permissions on /etc/issue are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.7.6
echo "" >> cis_compliance_check.txt
echo "1.7.6" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/issue.net are configured" >> cis_compliance_check.txt

# Run the command to verify permissions on /etc/issue.net
issue_net_permissions=$(stat -c "%A Uid: (%U/%G) Gid: (%G/%G)" /etc/issue.net)

# Display the output of the permission check
echo "Permissions on /etc/issue.net:" >> cis_compliance_check.txt
echo "$issue_net_permissions" >> cis_compliance_check.txt

# Check if the permissions are as expected
if [[ "$issue_net_permissions" == "Access: (0644/-rw-r--r--) Uid: (0/root) Gid: (0/root)" ]]; then
    echo "Permissions on /etc/issue.net are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "Permissions on /etc/issue.net are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#1.8.2
echo "" >> cis_compliance_check.txt
echo "1.8.2" >> cis_compliance_check.txt
echo "Ensure GDM login banner is configured" >> cis_compliance_check.txt

# Verify /etc/dconf/profile/gdm
gdm_profile="/etc/dconf/profile/gdm"
if [ -f "$gdm_profile" ]; then
    if grep -q "user-db:user" "$gdm_profile" && grep -q "system-db:gdm" "$gdm_profile" && grep -q "file-db:/usr/share/gdm/greeter-dconf-defaults" "$gdm_profile"; then
        echo "Configuration in $gdm_profile is correct: Compliant" >> cis_compliance_check.txt
    else
        echo "Configuration in $gdm_profile is incorrect: Non-Compliant" >> cis_compliance_check.txt
    fi
else
    echo "$gdm_profile does not exist: Non-Compliant" >> cis_compliance_check.txt
fi
echo "Output of $gdm_profile:" >> cis_compliance_check.txt
cat "$gdm_profile" 2>/dev/null >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify /etc/dconf/db/gdm.d/01-banner-message
gdm_banner_config="/etc/dconf/db/gdm.d/01-banner-message"
if [ -f "$gdm_banner_config" ]; then
    if grep -q "\[org/gnome/login-screen\]" "$gdm_banner_config" && grep -q "banner-message-enable=true" "$gdm_banner_config" && grep -q "banner-message-text='<banner message>'" "$gdm_banner_config"; then
        echo "Configuration in $gdm_banner_config is correct: Compliant" >> cis_compliance_check.txt
    else
        echo "Configuration in $gdm_banner_config is incorrect: Non-Compliant" >> cis_compliance_check.txt
    fi
else
    echo "$gdm_banner_config does not exist: Non-Compliant" >> cis_compliance_check.txt
fi
echo "Output of $gdm_banner_config:" >> cis_compliance_check.txt
cat "$gdm_banner_config" 2>/dev/null >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#1.8.3
echo "" >> cis_compliance_check.txt
echo "1.8.3" >> cis_compliance_check.txt
echo "Ensure last logged in user display is disabled" >> cis_compliance_check.txt

# Verify /etc/dconf/profile/gdm
gdm_profile="/etc/dconf/profile/gdm"
if [ -f "$gdm_profile" ]; then
    if grep -q "user-db:user" "$gdm_profile" && grep -q "system-db:gdm" "$gdm_profile" && grep -q "file-db:/usr/share/gdm/greeter-dconf-defaults" "$gdm_profile"; then
        echo "Configuration in $gdm_profile is correct: Compliant" >> cis_compliance_check.txt
    else
        echo "Configuration in $gdm_profile is incorrect: Non-Compliant" >> cis_compliance_check.txt
    fi
else
    echo "$gdm_profile does not exist: Non-Compliant" >> cis_compliance_check.txt
fi
echo "Output of $gdm_profile:" >> cis_compliance_check.txt
cat "$gdm_profile" 2>/dev/null >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify /etc/dconf/db/gdm.d/00-login-screen
gdm_login_screen_config="/etc/dconf/db/gdm.d/00-login-screen"
if [ -f "$gdm_login_screen_config" ]; then
    if grep -q "\[org/gnome/login-screen\]" "$gdm_login_screen_config" && grep -q "disable-user-list=true" "$gdm_login_screen_config"; then
        echo "Configuration in $gdm_login_screen_config is correct: Compliant" >> cis_compliance_check.txt
    else
        echo "Configuration in $gdm_login_screen_config is incorrect: Non-Compliant" >> cis_compliance_check.txt
    fi
else
    echo "$gdm_login_screen_config does not exist: Non-Compliant" >> cis_compliance_check.txt
fi
echo "Output of $gdm_login_screen_config:" >> cis_compliance_check.txt
cat "$gdm_login_screen_config" 2>/dev/null >> cis_compliance_check.txt
echo "================================================================================" >> cis_compliance_check.txt
#1.8.4
echo "" >> cis_compliance_check.txt
echo "1.8.4" >> cis_compliance_check.txt
echo "Ensure XDMCP is not enabled" >> cis_compliance_check.txt

# Run the command to check if XDMCP is enabled
xdmcp_enabled=$(grep -Eis '^\s*Enable\s*=\s*true' /etc/gdm/custom.conf)

# Add command output to the file
echo "Output of 'grep -Eis '^\s*Enable\s*=\s*true' /etc/gdm/custom.conf':" >> cis_compliance_check.txt
echo "$xdmcp_enabled" >> cis_compliance_check.txt

# Check the output
if [ -z "$xdmcp_enabled" ]; then
    echo "XDMCP is not enabled: Compliant" >> cis_compliance_check.txt
else
    echo "XDMCP is enabled: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#1.8.5
echo "" >> cis_compliance_check.txt
echo "1.8.5" >> cis_compliance_check.txt
echo "Ensure automatic mounting of removable media is disabled" >> cis_compliance_check.txt

# Run the command to check if automatic mounting is disabled
automount_disabled=$(gsettings get org.gnome.desktop.media-handling automount)

# Check the output
if [ "$automount_disabled" == "false" ]; then
    echo "Automatic mounting of removable media is disabled: Compliant" >> cis_compliance_check.txt
else
    echo "Automatic mounting of removable media is enabled: Non-Compliant" >> cis_compliance_check.txt
fi

# Add command output to the file
echo "Output of 'gsettings get org.gnome.desktop.media-handling automount':" >> cis_compliance_check.txt
echo "$automount_disabled" >> cis_compliance_check.txt
echo "================================================================================" >> cis_compliance_check.txt
#2.1.1
echo "" >> cis_compliance_check.txt
echo "2.1.1" >> cis_compliance_check.txt
echo "Ensure time synchronization is in use" >> cis_compliance_check.txt

# Run the command to check if chrony is installed
chrony_installed=$(rpm -q chrony)

# Check the output
if [ "$chrony_installed" != "package chrony is not installed" ]; then
    echo "Chrony is installed: Compliant" >> cis_compliance_check.txt
else
    echo "Chrony is not installed: Non-Compliant" >> cis_compliance_check.txt
fi

# Add command output to the file
echo "Output of 'rpm -q chrony':" >> cis_compliance_check.txt
echo "$chrony_installed" >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#2.1.2
echo "" >> cis_compliance_check.txt
echo "2.1.2" >> cis_compliance_check.txt
echo "Ensure chrony is configured" >> cis_compliance_check.txt

# Check remote server configuration
echo "Remote server configuration:" >> cis_compliance_check.txt
grep -E "^(server|pool)" /etc/chrony.conf >> cis_compliance_check.txt

# Check OPTIONS in chronyd configuration
echo "OPTIONS in /etc/sysconfig/chronyd:" >> cis_compliance_check.txt
grep ^OPTIONS /etc/sysconfig/chronyd >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#2.2.1
echo "" >> cis_compliance_check.txt
echo "2.2.1" >> cis_compliance_check.txt
echo "Ensure xinetd is not installed" >> cis_compliance_check.txt

# Check if xinetd is installed
xinetd_installed=$(rpm -q xinetd)

if [[ "$xinetd_installed" == "package xinetd is not installed" ]]; then
    echo "xinetd is not installed: Compliant" >> cis_compliance_check.txt
    echo "Output of 'rpm -q xinetd':" >> cis_compliance_check.txt
    echo "$xinetd_installed" >> cis_compliance_check.txt
else
    echo "xinetd is installed: Non-Compliant" >> cis_compliance_check.txt
    echo "Output of 'rpm -q xinetd':" >> cis_compliance_check.txt
    echo "$xinetd_installed" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.2
echo "" >> cis_compliance_check.txt
echo "2.2.2" >> cis_compliance_check.txt
echo "Ensure xorg-x11-server-common is not installed" >> cis_compliance_check.txt

# Check if xorg-x11-server-common is installed
xorg_installed=$(rpm -q xorg-x11-server-common)

if [[ "$xorg_installed" == "package xorg-x11-server-common is not installed" ]]; then
    echo "xorg-x11-server-common is not installed: Compliant" >> cis_compliance_check.txt
    echo "Output of 'rpm -q xorg-x11-server-common':" >> cis_compliance_check.txt
    echo "$xorg_installed" >> cis_compliance_check.txt
else
    echo "xorg-x11-server-common is installed: Non-Compliant" >> cis_compliance_check.txt
    echo "Output of 'rpm -q xorg-x11-server-common':" >> cis_compliance_check.txt
    echo "$xorg_installed" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.3
echo "" >> cis_compliance_check.txt
echo "2.2.3" >> cis_compliance_check.txt
echo "Ensure Avahi Server is not installed" >> cis_compliance_check.txt

# Check if Avahi Server components are installed
avahi_autoipd_installed=$(rpm -q avahi-autoipd)
avahi_installed=$(rpm -q avahi)

if [[ "$avahi_autoipd_installed" == "package avahi-autoipd is not installed" && "$avahi_installed" == "package avahi is not installed" ]]; then
    echo "Avahi Server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "Avahi Server is installed: Non-Compliant" >> cis_compliance_check.txt
    echo "Output of 'rpm -q avahi-autoipd avahi':" >> cis_compliance_check.txt
    echo "$avahi_autoipd_installed" >> cis_compliance_check.txt
    echo "$avahi_installed" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.4
echo "" >> cis_compliance_check.txt
echo "2.2.4" >> cis_compliance_check.txt
echo "Ensure CUPS is not installed" >> cis_compliance_check.txt

# Run the command to verify CUPS is not installed and capture the output
cups_status=$(rpm -q cups)
echo "Output of 'rpm -q cups':" >> cis_compliance_check.txt
echo "$cups_status" >> cis_compliance_check.txt

# Check if CUPS is installed
if [[ "$cups_status" == *"not installed"* ]]; then
    echo "CUPS is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "CUPS is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.5
echo "" >> cis_compliance_check.txt
echo "2.2.5" >> cis_compliance_check.txt
echo "Ensure DHCP Server is not installed" >> cis_compliance_check.txt

# Run the command to verify DHCP Server is not installed and capture the output
dhcp_status=$(rpm -q dhcp-server)
echo "Output of 'rpm -q dhcp-server':" >> cis_compliance_check.txt
echo "$dhcp_status" >> cis_compliance_check.txt

# Check if DHCP Server is installed
if [[ "$dhcp_status" == *"not installed"* ]]; then
    echo "DHCP Server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "DHCP Server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.6
echo "" >> cis_compliance_check.txt
echo "2.2.6" >> cis_compliance_check.txt
echo "Ensure DNS Server is not installed" >> cis_compliance_check.txt

# Run the command to verify DNS Server is not installed and capture the output
dns_status=$(rpm -q bind)
echo "Output of 'rpm -q bind':" >> cis_compliance_check.txt
echo "$dns_status" >> cis_compliance_check.txt

# Check if DNS Server is installed
if [[ "$dns_status" == *"not installed"* ]]; then
    echo "DNS Server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "DNS Server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.7
echo "" >> cis_compliance_check.txt
echo "2.2.7" >> cis_compliance_check.txt
echo "Ensure FTP Server is not installed" >> cis_compliance_check.txt

# Run the command to verify FTP Server is not installed and capture the output
ftp_status=$(rpm -q ftp)
echo "Output of 'rpm -q ftp':" >> cis_compliance_check.txt
echo "$ftp_status" >> cis_compliance_check.txt

# Check if FTP Server is installed
if [[ "$ftp_status" == *"not installed"* ]]; then
    echo "FTP Server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "FTP Server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.8
echo "" >> cis_compliance_check.txt
echo "2.2.8" >> cis_compliance_check.txt
echo "Ensure VSFTP Server is not installed" >> cis_compliance_check.txt

# Run the command to verify VSFTP Server is not installed and capture the output
vsftpd_status=$(rpm -q vsftpd)
echo "Output of 'rpm -q vsftpd':" >> cis_compliance_check.txt
echo "$vsftpd_status" >> cis_compliance_check.txt

# Check if VSFTP Server is installed
if [[ "$vsftpd_status" == *"not installed"* ]]; then
    echo "VSFTP Server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "VSFTP Server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.9
echo "" >> cis_compliance_check.txt
echo "2.2.9" >> cis_compliance_check.txt
echo "Ensure TFTP Server is not installed" >> cis_compliance_check.txt

# Run the command to verify TFTP Server is not installed and capture the output
tftp_server_status=$(rpm -q tftp-server)
echo "Output of 'rpm -q tftp-server':" >> cis_compliance_check.txt
echo "$tftp_server_status" >> cis_compliance_check.txt

# Check if TFTP Server is installed
if [[ "$tftp_server_status" == *"not installed"* ]]; then
    echo "TFTP Server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "TFTP Server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "2.2.10" >> cis_compliance_check.txt
echo "Ensure a web server is not installed" >> cis_compliance_check.txt

# Run the command to verify if httpd and nginx are installed and capture the output
httpd_status=$(rpm -q httpd)
nginx_status=$(rpm -q nginx)

echo "Output of 'rpm -q httpd nginx':" >> cis_compliance_check.txt
echo "$httpd_status" >> cis_compliance_check.txt
echo "$nginx_status" >> cis_compliance_check.txt

# Check if either httpd or nginx are installed
if [[ "$httpd_status" == *"not installed"* && "$nginx_status" == *"not installed"* ]]; then
    echo "No web server is installed: Compliant" >> cis_compliance_check.txt
else
    echo "A web server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.11
echo "" >> cis_compliance_check.txt
echo "2.2.11" >> cis_compliance_check.txt
echo "Ensure IMAP and POP3 server is not installed" >> cis_compliance_check.txt

# Run the command to verify if dovecot and cyrus-imapd are installed and capture the output
dovecot_status=$(rpm -q dovecot)
cyrus_imapd_status=$(rpm -q cyrus-imapd)

echo "Output of 'rpm -q dovecot cyrus-imapd':" >> cis_compliance_check.txt
echo "$dovecot_status" >> cis_compliance_check.txt
echo "$cyrus_imapd_status" >> cis_compliance_check.txt

# Check if either dovecot or cyrus-imapd are installed
if [[ "$dovecot_status" == *"not installed"* && "$cyrus_imapd_status" == *"not installed"* ]]; then
    echo "No IMAP or POP3 server is installed: Compliant" >> cis_compliance_check.txt
else
    echo "An IMAP or POP3 server is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.12
echo "" >> cis_compliance_check.txt
echo "2.2.12" >> cis_compliance_check.txt
echo "Ensure Samba is not installed" >> cis_compliance_check.txt

# Run the command to verify if Samba is installed and capture the output
samba_status=$(rpm -q samba)

echo "Output of 'rpm -q samba':" >> cis_compliance_check.txt
echo "$samba_status" >> cis_compliance_check.txt

# Check if Samba is not installed
if [[ "$samba_status" == *"not installed"* ]]; then
    echo "Samba is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "Samba is installed: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.2.13
echo "" >> cis_compliance_check.txt
echo "2.2.13" >> cis_compliance_check.txt
echo "Ensure HTTP Proxy Server (Squid) is not installed" >> cis_compliance_check.txt

# Run the command to verify if Squid is installed and capture the output
squid_status=$(rpm -q squid)

echo "Output of 'rpm -q squid':" >> cis_compliance_check.txt
echo "$squid_status" >> cis_compliance_check.txt

# Check if Squid is not installed
if [[ "$squid_status" == *"not installed"* ]]; then
    echo "Squid is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "Squid is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.14
echo "" >> cis_compliance_check.txt
echo "2.2.14" >> cis_compliance_check.txt
echo "Ensure net-snmp is not installed" >> cis_compliance_check.txt

# Run the command to verify if net-snmp is installed and capture the output
net_snmp_status=$(rpm -q net-snmp)

echo "Output of 'rpm -q net-snmp':" >> cis_compliance_check.txt
echo "$net_snmp_status" >> cis_compliance_check.txt

# Check if net-snmp is not installed
if [[ "$net_snmp_status" == *"not installed"* ]]; then
    echo "net-snmp is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "net-snmp is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.2.15
echo "" >> cis_compliance_check.txt
echo "2.2.15" >> cis_compliance_check.txt
echo "Ensure NIS server is not installed" >> cis_compliance_check.txt

# Run the command to verify if ypserv is installed and capture the output
ypserv_status=$(rpm -q ypserv)

echo "Output of 'rpm -q ypserv':" >> cis_compliance_check.txt
echo "$ypserv_status" >> cis_compliance_check.txt

# Check if ypserv is not installed
if [[ "$ypserv_status" == *"not installed"* ]]; then
    echo "ypserv is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "ypserv is installed: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.2.16
echo "" >> cis_compliance_check.txt
echo "2.2.16" >> cis_compliance_check.txt
echo "Ensure telnet-server is not installed" >> cis_compliance_check.txt

# Run the command to verify if telnet-server is installed and capture the output
telnet_server_status=$(rpm -q telnet-server)

echo "Output of 'rpm -q telnet-server':" >> cis_compliance_check.txt
echo "$telnet_server_status" >> cis_compliance_check.txt

# Check if telnet-server is not installed
if [[ "$telnet_server_status" == *"not installed"* ]]; then
    echo "telnet-server is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "telnet-server is installed: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.2.17
echo "" >> cis_compliance_check.txt
echo "2.2.17" >> cis_compliance_check.txt
echo "Ensure mail transfer agent is configured for local-only mode" >> cis_compliance_check.txt

# Run the command to verify if the MTA is listening on non-loopback addresses for port 25 and capture the output
mta_config=$(ss -lntu | grep -E ':25\s' | grep -E -v '\s(127.0.0.1|\[?::1\]?):25\s')

echo "Output of 'ss -lntu | grep -E ':25\s' | grep -E -v '\s(127.0.0.1|\[?::1\]?):25\s':" >> cis_compliance_check.txt
echo "$mta_config" >> cis_compliance_check.txt

# Check if the MTA is configured for local-only mode
if [ -z "$mta_config" ]; then
    echo "MTA is configured for local-only mode: Compliant" >> cis_compliance_check.txt
else
    echo "MTA is not configured for local-only mode: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.2.18
echo "" >> cis_compliance_check.txt
echo "2.2.18" >> cis_compliance_check.txt
echo "Ensure nfs-utils is not installed or the nfs-server service is masked" >> cis_compliance_check.txt

# Check if nfs-utils package is installed
nfs_utils_status=$(rpm -q nfs-utils)

echo "Output of 'rpm -q nfs-utils':" >> cis_compliance_check.txt
echo "$nfs_utils_status" >> cis_compliance_check.txt

# Check if nfs-utils is not installed
if [ "$nfs_utils_status" == "package nfs-utils is not installed" ]; then
    echo "nfs-utils is not installed: Compliant" >> cis_compliance_check.txt
else
    # Check if the nfs-server service is masked
    nfs_server_status=$(systemctl is-enabled nfs-server)

    echo "Output of 'systemctl is-enabled nfs-server':" >> cis_compliance_check.txt
    echo "$nfs_server_status" >> cis_compliance_check.txt

    # Check if the nfs-server service is masked
    if [ "$nfs_server_status" == "masked" ]; then
        echo "nfs-server service is masked: Compliant" >> cis_compliance_check.txt
    else
        echo "nfs-server service is not masked: Non-Compliant" >> cis_compliance_check.txt
    fi
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.2.19
echo "" >> cis_compliance_check.txt
echo "2.2.19" >> cis_compliance_check.txt
echo "Ensure rpcbind is not installed or the rpcbind services are masked" >> cis_compliance_check.txt

# Check if rpcbind package is installed
rpcbind_status=$(rpm -q rpcbind)

echo "Output of 'rpm -q rpcbind':" >> cis_compliance_check.txt
echo "$rpcbind_status" >> cis_compliance_check.txt

# Check if rpcbind is not installed
if [ "$rpcbind_status" == "package rpcbind is not installed" ]; then
    echo "rpcbind is not installed: Compliant" >> cis_compliance_check.txt
else
    # Check if the rpcbind service is masked
    rpcbind_service_status=$(systemctl is-enabled rpcbind)

    echo "Output of 'systemctl is-enabled rpcbind':" >> cis_compliance_check.txt
    echo "$rpcbind_service_status" >> cis_compliance_check.txt

    # Check if the rpcbind service is masked
    if [ "$rpcbind_service_status" == "masked" ]; then
        echo "rpcbind service is masked: Compliant" >> cis_compliance_check.txt
    else
        echo "rpcbind service is not masked: Non-Compliant" >> cis_compliance_check.txt
    fi

    # Check if the rpcbind.socket service is masked
    rpcbind_socket_status=$(systemctl is-enabled rpcbind.socket)

    echo "Output of 'systemctl is-enabled rpcbind.socket':" >> cis_compliance_check.txt
    echo "$rpcbind_socket_status" >> cis_compliance_check.txt

    # Check if the rpcbind.socket service is masked
    if [ "$rpcbind_socket_status" == "masked" ]; then
        echo "rpcbind.socket service is masked: Compliant" >> cis_compliance_check.txt
    else
        echo "rpcbind.socket service is not masked: Non-Compliant" >> cis_compliance_check.txt
    fi
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.2.20
echo "" >> cis_compliance_check.txt
echo "2.2.20" >> cis_compliance_check.txt
echo "Ensure rsync is not installed or the rsyncd service is masked" >> cis_compliance_check.txt

# Check if rsync package is installed
rsync_status=$(rpm -q rsync)

echo "Output of 'rpm -q rsync':" >> cis_compliance_check.txt
echo "$rsync_status" >> cis_compliance_check.txt

# Check if rsync is not installed
if [ "$rsync_status" == "package rsync is not installed" ]; then
    echo "rsync is not installed: Compliant" >> cis_compliance_check.txt
else
    # Check if the rsyncd service is masked
    rsyncd_service_status=$(systemctl is-enabled rsyncd 2>/dev/null)

    echo "Output of 'systemctl is-enabled rsyncd':" >> cis_compliance_check.txt
    echo "$rsyncd_service_status" >> cis_compliance_check.txt

    # Check if the rsyncd service is masked
    if [ "$rsyncd_service_status" == "masked" ]; then
        echo "rsyncd service is masked: Compliant" >> cis_compliance_check.txt
    else
        echo "rsyncd service is not masked: Non-Compliant" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.3.1
echo "" >> cis_compliance_check.txt
echo "2.3.1" >> cis_compliance_check.txt
echo "Ensure NIS Client is not installed" >> cis_compliance_check.txt

# Check if ypbind package is installed
ypbind_status=$(rpm -q ypbind)

echo "Output of 'rpm -q ypbind':" >> cis_compliance_check.txt
echo "$ypbind_status" >> cis_compliance_check.txt

# Check if ypbind is not installed
if [ "$ypbind_status" == "package ypbind is not installed" ]; then
    echo "ypbind is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "ypbind is installed: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.3.2
echo "" >> cis_compliance_check.txt
echo "2.3.2" >> cis_compliance_check.txt
echo "Ensure rsh client is not installed" >> cis_compliance_check.txt

# Check if rsh package is installed
rsh_status=$(rpm -q rsh)

echo "Output of 'rpm -q rsh':" >> cis_compliance_check.txt
echo "$rsh_status" >> cis_compliance_check.txt

# Check if rsh is not installed
if [ "$rsh_status" == "package rsh is not installed" ]; then
    echo "rsh is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "rsh is installed: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.3.3
echo "" >> cis_compliance_check.txt
echo "2.3.3" >> cis_compliance_check.txt
echo "Ensure talk client is not installed" >> cis_compliance_check.txt

# Check if talk package is installed
talk_status=$(rpm -q talk)

echo "Output of 'rpm -q talk':" >> cis_compliance_check.txt
echo "$talk_status" >> cis_compliance_check.txt

# Check if talk is not installed
if [ "$talk_status" == "package talk is not installed" ]; then
    echo "talk is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "talk is installed: Non-Compliant" >> cis_compliance_check.txt
fi
echo "================================================================================" >> cis_compliance_check.txt
#2.3.4
echo "" >> cis_compliance_check.txt
echo "2.3.4" >> cis_compliance_check.txt
echo "Ensure telnet client is not installed" >> cis_compliance_check.txt

# Check if telnet package is installed
telnet_status=$(rpm -q telnet)

echo "Output of 'rpm -q telnet':" >> cis_compliance_check.txt
echo "$telnet_status" >> cis_compliance_check.txt

# Check if telnet is not installed
if [ "$telnet_status" == "package telnet is not installed" ]; then
    echo "telnet is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "telnet is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.3.5
echo "" >> cis_compliance_check.txt
echo "2.3.5" >> cis_compliance_check.txt
echo "Ensure LDAP client is not installed" >> cis_compliance_check.txt

# Check if openldap-clients package is installed
ldap_clients_status=$(rpm -q openldap-clients)

echo "Output of 'rpm -q openldap-clients':" >> cis_compliance_check.txt
echo "$ldap_clients_status" >> cis_compliance_check.txt

# Check if openldap-clients is not installed
if [ "$ldap_clients_status" == "package openldap-clients is not installed" ]; then
    echo "openldap-clients is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "openldap-clients is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#2.3.6
echo "" >> cis_compliance_check.txt
echo "2.3.6" >> cis_compliance_check.txt
echo "Ensure TFTP client is not installed" >> cis_compliance_check.txt

# Check if tftp package is installed
tftp_status=$(rpm -q tftp)

echo "Output of 'rpm -q tftp':" >> cis_compliance_check.txt
echo "$tftp_status" >> cis_compliance_check.txt

# Check if tftp is not installed
if [ "$tftp_status" == "package tftp is not installed" ]; then
    echo "tftp is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "tftp is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.1.4
echo "" >> cis_compliance_check.txt
echo "3.1.4" >> cis_compliance_check.txt
echo "Ensure wireless interfaces are disabled" >> cis_compliance_check.txt

# Run the script to check for active wireless interfaces
{
    if command -v nmcli >/dev/null 2>&1; then
        echo "Output of 'nmcli radio all':" >> cis_compliance_check.txt
        nmcli radio all >> cis_compliance_check.txt
        if nmcli radio all | grep -Eq '\s*\S+\s+disabled\s+\S+\s+disabled\b'; then
            echo "Wireless is not enabled: Compliant" >> cis_compliance_check.txt
        else
            echo "Wireless is enabled: Non-Compliant" >> cis_compliance_check.txt
        fi
    elif [ -n "$(find /sys/class/net/*/ -type d -name wireless)" ]; then
        t=0
        mname=$(for driverdir in $(find /sys/class/net/*/ -type d -name wireless | xargs -0 dirname); do basename "$(readlink -f "$driverdir"/device/driver/module)"; done | sort -u)
        for dm in $mname; do
            if grep -Eq "^\s*install\s+$dm\s+/bin/(true|false)" /etc/modprobe.d/*.conf; then
                /bin/true
            else
                echo "$dm is not disabled"
                t=1
            fi
        done
        if [ "$t" -eq 0 ]; then
            echo "Wireless is not enabled: Compliant" >> cis_compliance_check.txt
        else
            echo "Wireless is enabled: Non-Compliant" >> cis_compliance_check.txt
        fi
    else
        echo "Wireless is not enabled: Compliant" >> cis_compliance_check.txt
    fi
} >> cis_compliance_check.txt
echo "================================================================================" >> cis_compliance_check.txt
#3.2.1
echo "" >> cis_compliance_check.txt
echo "3.2.1" >> cis_compliance_check.txt
echo "Ensure IP forwarding is disabled" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "For IPv4 forwarding:" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.ip_forward" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\": Compliant"
    else
        echo -e "\"$kpname\" is not configured properly: Non-compliant"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt
echo "For IPv6 forwarding:" >> cis_compliance_check.txt

{
    krp="" pafile="" fafile=""
    kpname="net.ipv6.conf.all.forwarding" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\": Compliant"
    else
        echo -e "\"$kpname\" is not configured properly: Non-compliant"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.2.2
echo "" >> cis_compliance_check.txt
echo "3.2.2" >> cis_compliance_check.txt
echo "Ensure packet redirect sending is disabled" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "For net.ipv4.conf.all.send_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.all.send_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt
echo "For net.ipv4.conf.default.send_redirects" >> cis_compliance_check.txt

{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.default.send_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.1
echo "" >> cis_compliance_check.txt
echo "3.3.1" >> cis_compliance_check.txt
echo "Ensure source routed packets are not accepted" >> cis_compliance_check.txt

echo "For net.ipv4.conf.all.send_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.all.send_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\"" 
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file" &&
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

echo "For net.ipv4.conf.default.send_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.default.send_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\"" 
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file" 
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.2
echo "" >> cis_compliance_check.txt
echo "3.3.2" >> cis_compliance_check.txt
echo "Ensure ICMP redirects are not accepted" >> cis_compliance_check.txt

echo "For net.ipv4.conf.all.accept_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.all.accept_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Audit for net.ipv4.conf.default.accept_redirects
echo "For net.ipv4.conf.default.accept_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.default.accept_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Audit for net.ipv6.conf.all.accept_redirects
echo "For net.ipv6.conf.all.accept_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv6.conf.all.accept_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Audit for net.ipv6.conf.default.accept_redirects
echo "For net.ipv6.conf.default.accept_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv6.conf.default.accept_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.3
echo "" >> cis_compliance_check.txt
echo "3.3.3" >> cis_compliance_check.txt
echo "Ensure secure ICMP redirects are not accepted" >> cis_compliance_check.txt

echo "For net.ipv4.conf.all.secure_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.all.secure_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Audit for net.ipv4.conf.default.secure_redirects
echo "For net.ipv4.conf.default.secure_redirects" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.default.secure_redirects" 
    kpvalue="0"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.4
echo "" >> cis_compliance_check.txt
echo "3.3.4" >> cis_compliance_check.txt
echo "Ensure suspicious packets are logged" >> cis_compliance_check.txt

echo "For net.ipv4.conf.all.log_martians" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.all.log_martians" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly" 
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

echo "For net.ipv4.conf.default.log_martians" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.default.log_martians" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\"" 
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly" 
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration" 
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\"" >> cis_compliance_check.txt
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file" 
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.5
echo "" >> cis_compliance_check.txt
echo "3.3.5" >> cis_compliance_check.txt
echo "Ensure broadcast ICMP requests are ignored" >> cis_compliance_check.txt

echo "For net.ipv4.icmp_echo_ignore_broadcasts" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.icmp_echo_ignore_broadcasts" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\"" 
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\"" >> cis_compliance_check.txt
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.6
echo "" >> cis_compliance_check.txt
echo "3.3.6" >> cis_compliance_check.txt
echo "Ensure bogus ICMP responses are ignored" >> cis_compliance_check.txt

echo "For net.ipv4.icmp_ignore_bogus_error_responses" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.icmp_ignore_bogus_error_responses" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
        echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
        echo "Non-Compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.7
echo "" >> cis_compliance_check.txt
echo "3.3.7" >> cis_compliance_check.txt
echo "Ensure Reverse Path Filtering is enabled" >> cis_compliance_check.txt

echo "For net.ipv4.conf.all.rp_filter" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.all.rp_filter" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
	echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
	echo "Non-compliant"
    fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

echo "For net.ipv4.conf.default.rp_filter" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.conf.default.rp_filter" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
	echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
	echo "Non-compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.8
echo "" >> cis_compliance_check.txt
echo "3.3.8" >> cis_compliance_check.txt
echo "Ensure TCP SYN Cookies is enabled" >> cis_compliance_check.txt

echo "For net.ipv4.tcp_syncookies" >> cis_compliance_check.txt
{
    krp="" pafile="" fafile=""
    kpname="net.ipv4.tcp_syncookies" 
    kpvalue="1"
    searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
    krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
    pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
    fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
    if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
        echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
	echo "Compliant"
    else
        echo -e "FAIL:\n\"$kpname\" is not configured properly"
        [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
        [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
        [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in any kernel parameter configuration file"
	echo "Non-compliant"
    fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.3.9
echo "" >> cis_compliance_check.txt
echo "3.3.9" >> cis_compliance_check.txt
echo "Ensure IPv6 router advertisements are not accepted" >> cis_compliance_check.txt

echo "For verifying net.ipv6.conf.all.accept_ra is set to 0" >> cis_compliance_check.txt
{
 krp="" pafile="" fafile=""
 kpname="net.ipv6.conf.all.accept_ra" 
 kpvalue="0"
 searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
 krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
 pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
 fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
 if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
     echo -e "PASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
	echo "Compliant"
 else
     echo -e "FAIL: "
     [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
     [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
     [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in a kernel parameter configuration file"
	echo "Non-compliant"
 fi
} >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

echo "For verifying net.ipv6.conf.default.accept_ra is set to 0" >> cis_compliance_check.txt
{
 krp="" pafile="" fafile=""
 kpname="net.ipv6.conf.default.accept_ra" 
 kpvalue="0"
 searchloc="/run/sysctl.d/*.conf /etc/sysctl.d/*.conf /usr/local/lib/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /lib/sysctl.d/*.conf /etc/sysctl.conf"
 krp="$(sysctl "$kpname" | awk -F= '{print $2}' | xargs)"
 pafile="$(grep -Psl -- "^\h*$kpname\h*=\h*$kpvalue\b\h*(#.*)?$" $searchloc)"
 fafile="$(grep -s -- "^\s*$kpname" $searchloc | grep -Pv -- "\h*=\h*$kpvalue\b\h*" | awk -F: '{print $1}')"
 if [ "$krp" = "$kpvalue" ] && [ -n "$pafile" ] && [ -z "$fafile" ]; then
     echo -e "\nPASS:\n\"$kpname\" is set to \"$kpvalue\" in the running configuration and in \"$pafile\""
	echo "Compliant"
 else
     echo -e "FAIL: "
     [ "$krp" != "$kpvalue" ] && echo -e "\"$kpname\" is set to \"$krp\" in the running configuration"
     [ -n "$fafile" ] && echo -e "\"$kpname\" is set incorrectly in \"$fafile\""
     [ -z "$pafile" ] && echo -e "\"$kpname = $kpvalue\" is not set in a kernel parameter configuration file"
	echo "Non-compliant"
 fi
} >> cis_compliance_check.txt

echo "================================================================================" >> cis_compliance_check.txt
#3.4.1.1
echo "" >> cis_compliance_check.txt
echo "3.4.1.1" >> cis_compliance_check.txt
echo "Ensure firewalld is installed" >> cis_compliance_check.txt

# Check if firewalld package is installed
firewalld_status=$(rpm -q firewalld)

# Write output of 'rpm -q firewalld' to compliance check file
echo "Output of 'rpm -q firewalld':" >> cis_compliance_check.txt
echo "$firewalld_status" >> cis_compliance_check.txt

# Check if firewalld is installed
if [ "$firewalld_status" == "package firewalld is not installed" ]; then
    echo "FirewallD is not installed: Non-Compliant" >> cis_compliance_check.txt
else
    echo "FirewallD is installed: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.1.2
echo "" >> cis_compliance_check.txt
echo "3.4.1.2" >> cis_compliance_check.txt
echo "Ensure iptables-services not installed with firewalld" >> cis_compliance_check.txt

# Check if iptables-services package is installed
iptables_services_status=$(rpm -q iptables-services)

# Write output of 'rpm -q iptables-services' to compliance check file
echo "Output of 'rpm -q iptables-services':" >> cis_compliance_check.txt
echo "$iptables_services_status" >> cis_compliance_check.txt

# Check if iptables-services is not installed
if [ "$iptables_services_status" == "package iptables-services is not installed" ]; then
    echo "iptables-services is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "iptables-services is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.1.3
echo "" >> cis_compliance_check.txt
echo "3.4.1.3" >> cis_compliance_check.txt
echo "Ensure nftables either not installed or masked with firewalld" >> cis_compliance_check.txt

# Check if nftables package is installed
nftables_status=$(rpm -q nftables)

# Write output of 'rpm -q nftables' to compliance check file
echo "Output of 'rpm -q nftables':" >> cis_compliance_check.txt
echo "$nftables_status" >> cis_compliance_check.txt

# Check if nftables is not installed
if [ "$nftables_status" == "package nftables is not installed" ]; then
    echo "nftables is not installed: Compliant" >> cis_compliance_check.txt
else
    # Check if nftables is inactive
    nftables_active=$(systemctl is-active nftables)
    # Write output of 'systemctl is-active nftables' to compliance check file
    echo "Output of 'systemctl is-active nftables':" >> cis_compliance_check.txt
    echo "$nftables_active" >> cis_compliance_check.txt

    # Check if nftables is masked
    nftables_masked=$(systemctl is-enabled nftables)
    # Write output of 'systemctl is-enabled nftables' to compliance check file
    echo "Output of 'systemctl is-enabled nftables':" >> cis_compliance_check.txt
    echo "$nftables_masked" >> cis_compliance_check.txt

    if [ "$nftables_active" == "inactive" ] && [ "$nftables_masked" == "masked" ]; then
        echo "nftables is inactive and masked: Compliant" >> cis_compliance_check.txt
    else
        echo "nftables is either active or not masked: Non-Compliant" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.1.4
echo "" >> cis_compliance_check.txt
echo "3.4.1.4" >> cis_compliance_check.txt
echo "Ensure firewalld service enabled and running" >> cis_compliance_check.txt

# Check if firewalld service is enabled
firewalld_enabled=$(systemctl is-enabled firewalld)

# Write output of 'systemctl is-enabled firewalld' to compliance check file
echo "Output of 'systemctl is-enabled firewalld':" >> cis_compliance_check.txt
echo "$firewalld_enabled" >> cis_compliance_check.txt

if [ "$firewalld_enabled" == "enabled" ]; then
    # Check if firewalld service is running
    firewalld_state=$(firewall-cmd --state)
    # Write output of 'firewall-cmd --state' to compliance check file
    echo "Output of 'firewall-cmd --state':" >> cis_compliance_check.txt
    echo "$firewalld_state" >> cis_compliance_check.txt

    if [ "$firewalld_state" == "running" ]; then
        echo "firewalld service is enabled and running: Compliant" >> cis_compliance_check.txt
    else
        echo "firewalld service is enabled but not running: Non-Compliant" >> cis_compliance_check.txt
    fi
else
    echo "firewalld service is not enabled: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.1.5
echo "" >> cis_compliance_check.txt
echo "3.4.1.5" >> cis_compliance_check.txt
echo "Ensure firewalld default zone is set" >> cis_compliance_check.txt

# Get the default zone from firewalld
default_zone=$(firewall-cmd --get-default-zone)

# Write output of 'firewall-cmd --get-default-zone' to compliance check file
echo "Output of 'firewall-cmd --get-default-zone':" >> cis_compliance_check.txt
echo "$default_zone" >> cis_compliance_check.txt

# Compare the default zone with company policy (replace "company_policy_zone" with the desired default zone)
company_policy_zone="public"

if [ "$default_zone" == "$company_policy_zone" ]; then
    echo "Default zone is set to company policy: Compliant" >> cis_compliance_check.txt
else
    echo "Default zone is not set to company policy: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.1
echo "" >> cis_compliance_check.txt
echo "3.4.2.1" >> cis_compliance_check.txt
echo "Ensure nftables is installed" >> cis_compliance_check.txt

# Check if nftables package is installed
nftables_status=$(rpm -q nftables)

# Write output of 'rpm -q nftables' to compliance check file
echo "Output of 'rpm -q nftables':" >> cis_compliance_check.txt
echo "$nftables_status" >> cis_compliance_check.txt

# Check if nftables is installed
if [[ "$nftables_status" == *"nftables"* ]]; then
    echo "nftables is installed: Compliant" >> cis_compliance_check.txt
else
    echo "nftables is not installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.2
echo "" >> cis_compliance_check.txt
echo "3.4.2.2" >> cis_compliance_check.txt
echo "Ensure firewalld is either not installed or masked with nftables" >> cis_compliance_check.txt

# Check if firewalld is masked
firewalld_masked=$(systemctl is-enabled firewalld)

# Write output of 'systemctl is-enabled firewalld' to compliance check file
echo "Output of 'systemctl is-enabled firewalld':" >> cis_compliance_check.txt
echo "$firewalld_masked" >> cis_compliance_check.txt

# Check if firewalld is masked
if [[ "$firewalld_masked" == *"masked"* ]]; then
    echo "firewalld is masked: Compliant" >> cis_compliance_check.txt
else
    echo "firewalld is not masked: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.3
echo "" >> cis_compliance_check.txt
echo "3.4.2.3" >> cis_compliance_check.txt
echo "Ensure iptables-services not installed with nftables" >> cis_compliance_check.txt

# Check if iptables-services package is installed
iptables_services_status=$(rpm -q iptables-services)

# Write output of 'rpm -q iptables-services' to compliance check file
echo "Output of 'rpm -q iptables-services':" >> cis_compliance_check.txt
echo "$iptables_services_status" >> cis_compliance_check.txt

# Check if iptables-services is not installed
if [[ "$iptables_services_status" == *"iptables-services"* ]]; then
    echo "iptables-services is installed: Non-Compliant" >> cis_compliance_check.txt
else
    echo "iptables-services is not installed: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.5
echo "" >> cis_compliance_check.txt
echo "3.4.2.5" >> cis_compliance_check.txt
echo "Ensure an nftables table exists" >> cis_compliance_check.txt

# Run the command to list nftables tables
nft_tables_output=$(nft list tables)

# Write output of 'nft list tables' to compliance check file
echo "Output of 'nft list tables':" >> cis_compliance_check.txt
echo "$nft_tables_output" >> cis_compliance_check.txt

# Check if nftables tables are present
if [[ "$nft_tables_output" == *"table"* ]]; then
    echo "nftables table(s) exist(s): Compliant" >> cis_compliance_check.txt
else
    echo "nftables table(s) do(es) not exist: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.6
echo "" >> cis_compliance_check.txt
echo "3.4.2.6" >> cis_compliance_check.txt
echo "Ensure nftables base chains exist" >> cis_compliance_check.txt

# Run the commands to check for base chains
input_chain=$(nft list ruleset | grep 'hook input')
forward_chain=$(nft list ruleset | grep 'hook forward')
output_chain=$(nft list ruleset | grep 'hook output')

# Write output of commands to compliance check file
echo "Output of 'nft list ruleset | grep 'hook input'':" >> cis_compliance_check.txt
echo "$input_chain" >> cis_compliance_check.txt
echo "Output of 'nft list ruleset | grep 'hook forward'':" >> cis_compliance_check.txt
echo "$forward_chain" >> cis_compliance_check.txt
echo "Output of 'nft list ruleset | grep 'hook output'':" >> cis_compliance_check.txt
echo "$output_chain" >> cis_compliance_check.txt

# Check if base chains exist
if [[ -n "$input_chain" && -n "$forward_chain" && -n "$output_chain" ]]; then
    echo "Base chains for INPUT, FORWARD, and OUTPUT exist: Compliant" >> cis_compliance_check.txt
else
    echo "Base chains for INPUT, FORWARD, or OUTPUT do not exist: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.7
echo "" >> cis_compliance_check.txt
echo "3.4.2.7" >> cis_compliance_check.txt
echo "Ensure nftables loopback traffic is configured" >> cis_compliance_check.txt

# Check loopback traffic configuration for IPv4
ipv4_lo_accept=$(nft list ruleset | awk '/hook input/,/}/' | grep 'iif "lo" accept')
ipv4_lo_drop=$(nft list ruleset | awk '/hook input/,/}/' | grep 'ip saddr 127.0.0.0/8 counter packets 0 bytes 0 drop')

# Write output of commands to compliance check file
echo "Output of 'nft list ruleset | awk '/hook input/,/}/' | grep 'iif \"lo\" accept'':" >> cis_compliance_check.txt
echo "$ipv4_lo_accept" >> cis_compliance_check.txt
echo "Output of 'nft list ruleset | awk '/hook input/,/}/' | grep 'ip saddr 127.0.0.0/8 counter packets 0 bytes 0 drop'':" >> cis_compliance_check.txt
echo "$ipv4_lo_drop" >> cis_compliance_check.txt

# Check compliance for IPv4 loopback traffic
if [[ -n "$ipv4_lo_accept" && -n "$ipv4_lo_drop" ]]; then
    echo "IPv4 loopback traffic is configured: Compliant" >> cis_compliance_check.txt
else
    echo "IPv4 loopback traffic is not configured: Non-Compliant" >> cis_compliance_check.txt
fi

# Function to check if IPv6 is disabled
ipv6_chk() {
    passing=""
    grubfile="$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)"
    ! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
    
    # Check if sysctl configuration files exist before running grep
    sysctl_files=("/etc/sysctl.conf" "/etc/sysctl.d/*.conf" "/usr/lib/sysctl.d/*.conf" "/run/sysctl.d/*.conf")
    for file in "${sysctl_files[@]}"; do
        if compgen -G "$file" > /dev/null; then
            grep -Pq -- "^\s*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" $file && \
            grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" $file && passing="true"
        fi
    done

    sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
    sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" && passing="true"
    
    if [ "$passing" = true ] ; then
        echo -e "\nIPv6 is disabled on the system\n" >> cis_compliance_check.txt
    else
        echo -e "\nIPv6 is enabled on the system\n" >> cis_compliance_check.txt
    fi
    [ "$passing" = true ]
}

# Check loopback traffic configuration for IPv6 if IPv6 is enabled
if ipv6_chk; then
    echo "IPv6 is disabled on the system: Compliant" >> cis_compliance_check.txt
else
    ipv6_lo_drop=$(nft list ruleset | awk '/hook input/,/}/' | grep 'ip6 saddr ::1 counter packets 0 bytes 0 drop')
    echo "Output of 'nft list ruleset | awk '/hook input/,/}/' | grep 'ip6 saddr ::1 counter packets 0 bytes 0 drop'':" >> cis_compliance_check.txt
    echo "$ipv6_lo_drop" >> cis_compliance_check.txt
    
    # Check compliance for IPv6 loopback traffic
    if [[ -n "$ipv6_lo_drop" ]]; then
        echo "IPv6 loopback traffic is configured: Compliant" >> cis_compliance_check.txt
    else
        echo "IPv6 loopback traffic is not configured: Non-Compliant" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.9
echo "" >> cis_compliance_check.txt
echo "3.4.2.9" >> cis_compliance_check.txt
echo "Ensure nftables default deny firewall policy" >> cis_compliance_check.txt

# Check nftables default deny policy for input chain
input_policy=$(nft list ruleset | grep 'hook input' | grep 'policy drop')
echo "Output of 'nft list ruleset | grep \"hook input\"':" >> cis_compliance_check.txt
echo "$input_policy" >> cis_compliance_check.txt

# Check nftables default deny policy for forward chain
forward_policy=$(nft list ruleset | grep 'hook forward' | grep 'policy drop')
echo "Output of 'nft list ruleset | grep \"hook forward\"':" >> cis_compliance_check.txt
echo "$forward_policy" >> cis_compliance_check.txt

# Check nftables default deny policy for output chain
output_policy=$(nft list ruleset | grep 'hook output' | grep 'policy drop')
echo "Output of 'nft list ruleset | grep \"hook output\"':" >> cis_compliance_check.txt
echo "$output_policy" >> cis_compliance_check.txt

# Check compliance for input policy
if [[ -n "$input_policy" ]]; then
    echo "nftables input policy is set to drop: Compliant" >> cis_compliance_check.txt
else
    echo "nftables input policy is not set to drop: Non-Compliant" >> cis_compliance_check.txt
fi

# Check compliance for forward policy
if [[ -n "$forward_policy" ]]; then
    echo "nftables forward policy is set to drop: Compliant" >> cis_compliance_check.txt
else
    echo "nftables forward policy is not set to drop: Non-Compliant" >> cis_compliance_check.txt
fi

# Check compliance for output policy
if [[ -n "$output_policy" ]]; then
    echo "nftables output policy is set to drop: Compliant" >> cis_compliance_check.txt
else
    echo "nftables output policy is not set to drop: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.2.10
echo "" >> cis_compliance_check.txt
echo "3.4.2.10" >> cis_compliance_check.txt
echo "Ensure nftables service is enabled" >> cis_compliance_check.txt

# Check if nftables service is enabled
nftables_status=$(systemctl is-enabled nftables 2>/dev/null)

echo "Output of 'systemctl is-enabled nftables':" >> cis_compliance_check.txt
echo "$nftables_status" >> cis_compliance_check.txt

# Check compliance
if [ "$nftables_status" == "enabled" ]; then
    echo "nftables service is enabled: Compliant" >> cis_compliance_check.txt
else
    echo "nftables service is not enabled: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.1.1
echo "" >> cis_compliance_check.txt
echo "3.4.3.1.1" >> cis_compliance_check.txt
echo "Ensure nftables service is enabled" >> cis_compliance_check.txt

# Check if iptables and iptables-services packages are installed
iptables_status=$(rpm -q iptables)
iptables_services_status=$(rpm -q iptables-services)

echo "Output of 'rpm -q iptables iptables-services':" >> cis_compliance_check.txt
echo "$iptables_status" >> cis_compliance_check.txt
echo "$iptables_services_status" >> cis_compliance_check.txt

# Check if iptables package is installed
if [ "$iptables_status" == "package iptables is not installed" ]; then
    echo "iptables package is not installed: Non-Compliant" >> cis_compliance_check.txt
else
    echo "iptables package is installed: Compliant" >> cis_compliance_check.txt
fi

# Check if iptables-services package is installed
if [ "$iptables_services_status" == "package iptables-services is not installed" ]; then
    echo "iptables-services package is not installed: Non-Compliant" >> cis_compliance_check.txt
else
    echo "iptables-services package is installed: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.1.2
echo "" >> cis_compliance_check.txt
echo "3.4.3.1.2" >> cis_compliance_check.txt
echo "Ensure nftables is not installed with iptables" >> cis_compliance_check.txt

# Check if nftables package is installed
nftables_status=$(rpm -q nftables)

echo "Output of 'rpm -q nftables':" >> cis_compliance_check.txt
echo "$nftables_status" >> cis_compliance_check.txt

# Check if nftables package is not installed
if [ "$nftables_status" == "package nftables is not installed" ]; then
    echo "nftables package is not installed: Compliant" >> cis_compliance_check.txt
else
    echo "nftables package is installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.1.3
echo "" >> cis_compliance_check.txt
echo "3.4.3.1.3" >> cis_compliance_check.txt
echo "Ensure firewalld is either not installed or masked with iptables" >> cis_compliance_check.txt

# Check if firewalld package is installed
firewalld_status=$(rpm -q firewalld)

echo "Output of 'rpm -q firewalld':" >> cis_compliance_check.txt
echo "$firewalld_status" >> cis_compliance_check.txt

# Check if firewalld package is not installed
if [ "$firewalld_status" == "package firewalld is not installed" ]; then
    echo "firewalld package is not installed: Compliant" >> cis_compliance_check.txt
else
    # Check if firewalld service is stopped and masked
    firewalld_status=$(systemctl status firewalld | grep "Active:" | grep -v "active (running)")
    is_masked=$(systemctl is-enabled firewalld)

    echo "Output of 'systemctl status firewalld':" >> cis_compliance_check.txt
    echo "$firewalld_status" >> cis_compliance_check.txt
    echo "Output of 'systemctl is-enabled firewalld':" >> cis_compliance_check.txt
    echo "$is_masked" >> cis_compliance_check.txt

    if [ -z "$firewalld_status" ] && [ "$is_masked" == "masked" ]; then
        echo "firewalld service is either stopped and masked: Compliant" >> cis_compliance_check.txt
    else
        echo "firewalld service is not stopped and masked: Non-Compliant" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.2.1
echo "" >> cis_compliance_check.txt
echo "3.4.3.2.1" >> cis_compliance_check.txt
echo "Ensure iptables loopback traffic is configured" >> cis_compliance_check.txt

# Check INPUT chain
echo "Output of 'iptables -L INPUT -v -n':" >> cis_compliance_check.txt
iptables_input=$(iptables -L INPUT -v -n)
echo "$iptables_input" >> cis_compliance_check.txt

# Required rules for INPUT chain
input_rule1="ACCEPT     all  --  lo   *     0.0.0.0/0            0.0.0.0/0"
input_rule2="DROP       all  --  *    *     127.0.0.0/8          0.0.0.0/0"

if [[ "$iptables_input" == *"$input_rule1"* && "$iptables_input" == *"$input_rule2"* ]]; then
    echo "Loopback traffic is configured in INPUT chain: Compliant" >> cis_compliance_check.txt
else
    echo "Loopback traffic is not configured in INPUT chain: Non-Compliant" >> cis_compliance_check.txt
fi

# Check OUTPUT chain
echo "" >> cis_compliance_check.txt
echo "Output of 'iptables -L OUTPUT -v -n':" >> cis_compliance_check.txt
iptables_output=$(iptables -L OUTPUT -v -n)
echo "$iptables_output" >> cis_compliance_check.txt

# Required rules for OUTPUT chain
output_rule="ACCEPT     all  --  *    lo    0.0.0.0/0            0.0.0.0/0"

if [[ "$iptables_output" == *"$output_rule"* ]]; then
    echo "Loopback traffic is configured in OUTPUT chain: Compliant" >> cis_compliance_check.txt
else
    echo "Loopback traffic is not configured in OUTPUT chain: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.2.3
echo "" >> cis_compliance_check.txt
echo "3.4.3.2.3" >> cis_compliance_check.txt
echo "Ensure iptables rules exist for all open ports" >> cis_compliance_check.txt

# Capture the list of open ports
open_ports=$(ss -4tuln | awk 'NR>1 {print $1, $5}' | grep -v '127.0.0.1' | grep -v '::1')

echo "Open ports:" >> cis_compliance_check.txt
echo "$open_ports" >> cis_compliance_check.txt

# Capture the iptables rules
iptables_rules=$(iptables -L INPUT -v -n)

echo "" >> cis_compliance_check.txt
echo "Output of 'iptables -L INPUT -v -n':" >> cis_compliance_check.txt
echo "$iptables_rules" >> cis_compliance_check.txt

# Check if each open port has a corresponding iptables rule
compliant=true

while IFS= read -r line; do
    proto=$(echo $line | awk '{print $1}')
    port=$(echo $line | awk -F: '{print $2}')
    
    if ! echo "$iptables_rules" | grep -q "$proto .* dpt:$port"; then
        echo "No iptables rule for $proto port $port: Non-Compliant" >> cis_compliance_check.txt
        compliant=false
    fi
done <<< "$open_ports"

if $compliant; then
    echo "All open ports have corresponding iptables rules: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.2.4
echo "" >> cis_compliance_check.txt
echo "3.4.3.2.4" >> cis_compliance_check.txt
echo "Ensure iptables default deny firewall policy" >> cis_compliance_check.txt

# Capture the iptables policy output
iptables_policies=$(iptables -L -v -n)

echo "Output of 'iptables -L -v -n':" >> cis_compliance_check.txt
echo "$iptables_policies" >> cis_compliance_check.txt

# Check if the policies for INPUT, FORWARD, and OUTPUT chains are DROP or REJECT
input_policy=$(echo "$iptables_policies" | grep '^Chain INPUT' | awk '{print $4}')
forward_policy=$(echo "$iptables_policies" | grep '^Chain FORWARD' | awk '{print $4}')
output_policy=$(echo "$iptables_policies" | grep '^Chain OUTPUT' | awk '{print $4}')

compliant=true

if [[ "$input_policy" != "DROP" && "$input_policy" != "REJECT" ]]; then
    echo "INPUT chain policy is not set to DROP or REJECT: Non-Compliant" >> cis_compliance_check.txt
    compliant=false
else
    echo "INPUT chain policy is set to $input_policy: Compliant" >> cis_compliance_check.txt
fi

if [[ "$forward_policy" != "DROP" && "$forward_policy" != "REJECT" ]]; then
    echo "FORWARD chain policy is not set to DROP or REJECT: Non-Compliant" >> cis_compliance_check.txt
    compliant=false
else
    echo "FORWARD chain policy is set to $forward_policy: Compliant" >> cis_compliance_check.txt
fi

if [[ "$output_policy" != "DROP" && "$output_policy" != "REJECT" ]]; then
    echo "OUTPUT chain policy is not set to DROP or REJECT: Non-Compliant" >> cis_compliance_check.txt
    compliant=false
else
    echo "OUTPUT chain policy is set to $output_policy: Compliant" >> cis_compliance_check.txt
fi

if $compliant; then
    echo "All chains have default deny policies: Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.2.5
echo "" >> cis_compliance_check.txt
echo "3.4.3.2.5" >> cis_compliance_check.txt
echo "Ensure iptables rules are saved" >> cis_compliance_check.txt

# Check if the iptables rules file exists
if [ -f /etc/sysconfig/iptables ]; then
    echo "File /etc/sysconfig/iptables exists" >> cis_compliance_check.txt

    # Output the contents of the iptables rules file
    iptables_rules=$(cat /etc/sysconfig/iptables)
    echo "Contents of /etc/sysconfig/iptables:" >> cis_compliance_check.txt
    echo "$iptables_rules" >> cis_compliance_check.txt

    # Check if the iptables rules file contains the necessary rules
    if grep -qE "^:INPUT DROP" /etc/sysconfig/iptables &&
       grep -qE "^:FORWARD DROP" /etc/sysconfig/iptables &&
       grep -qE "^:OUTPUT DROP" /etc/sysconfig/iptables &&
       grep -qE "^-A INPUT -i lo -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A INPUT -s 127.0.0.0/8 -j DROP" /etc/sysconfig/iptables &&
       grep -qE "^-A INPUT -p tcp -m state --state ESTABLISHED -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A INPUT -p udp -m state --state ESTABLISHED -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A INPUT -p icmp -m state --state ESTABLISHED -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A INPUT -p tcp -m tcp --dport 22 -m state --state NEW -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A OUTPUT -o lo -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A OUTPUT -p tcp -m state --state NEW,ESTABLISHED -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A OUTPUT -p udp -m state --state NEW,ESTABLISHED -j ACCEPT" /etc/sysconfig/iptables &&
       grep -qE "^-A OUTPUT -p icmp -m state --state NEW,ESTABLISHED -j ACCEPT" /etc/sysconfig/iptables; then
        echo "iptables rules are correctly saved: Compliant" >> cis_compliance_check.txt
    else
        echo "iptables rules are not correctly saved: Non-Compliant" >> cis_compliance_check.txt
    fi
else
    echo "File /etc/sysconfig/iptables does not exist: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.2.6
echo "" >> cis_compliance_check.txt
echo "3.4.3.2.6" >> cis_compliance_check.txt
echo "Ensure iptables is enabled and active" >> cis_compliance_check.txt

# Check if iptables is enabled
iptables_enabled=$(systemctl is-enabled iptables 2>/dev/null)
echo "Output of 'systemctl is-enabled iptables':" >> cis_compliance_check.txt
echo "$iptables_enabled" >> cis_compliance_check.txt

# Check if iptables is active
iptables_active=$(systemctl is-active iptables 2>/dev/null)
echo "Output of 'systemctl is-active iptables':" >> cis_compliance_check.txt
echo "$iptables_active" >> cis_compliance_check.txt

# Verify compliance
if [ "$iptables_enabled" == "enabled" ] && [ "$iptables_active" == "active" ]; then
    echo "iptables is enabled and active: Compliant" >> cis_compliance_check.txt
else
    echo "iptables is not enabled or not active: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.3.1
echo "" >> cis_compliance_check.txt
echo "3.4.3.3.1" >> cis_compliance_check.txt
echo "Ensure ip6tables loopback traffic is configured" >> cis_compliance_check.txt

# Check ip6tables INPUT chain for loopback traffic configuration
input_chain_status=$(ip6tables -L INPUT -v -n 2>/dev/null | grep -E 'ACCEPT.*lo.*::/0|DROP.*::1.*::/0')
echo "Output of 'ip6tables -L INPUT -v -n':" >> cis_compliance_check.txt
ip6tables -L INPUT -v -n >> cis_compliance_check.txt

# Check ip6tables OUTPUT chain for loopback traffic configuration
output_chain_status=$(ip6tables -L OUTPUT -v -n 2>/dev/null | grep 'ACCEPT.*lo.*::/0')
echo "Output of 'ip6tables -L OUTPUT -v -n':" >> cis_compliance_check.txt
ip6tables -L OUTPUT -v -n >> cis_compliance_check.txt

# Verify if IPv6 is disabled
ipv6_chk() {
 passing=""
 grubfile="$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)"
 ! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
 grep -Pq -- "^\s*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && \
 grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf && \
 sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
 sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" && passing="true"
 if [ "$passing" = true ]; then
   echo -e "\nIPv6 is disabled on the system\n" >> cis_compliance_check.txt
 else
   echo -e "\nIPv6 is enabled on the system\n" >> cis_compliance_check.txt
 fi
}

# Append results to compliance check file
if [[ $input_chain_status && $output_chain_status ]]; then
    echo "ip6tables loopback traffic is configured: Compliant" >> cis_compliance_check.txt
else
    echo "ip6tables loopback traffic is not configured: Non-Compliant" >> cis_compliance_check.txt
    ipv6_chk
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.3.3
echo "" >> cis_compliance_check.txt
echo "3.4.3.3.3" >> cis_compliance_check.txt
echo "Ensure ip6tables firewall rules exist for all open ports" >> cis_compliance_check.txt

# Check ip6tables INPUT chain for loopback traffic configuration
input_chain_status=$(ip6tables -L INPUT -v -n 2>/dev/null | grep -E 'ACCEPT.*lo.*::/0|DROP.*::1.*::/0')
echo "Output of 'ip6tables -L INPUT -v -n':" >> cis_compliance_check.txt
ip6tables -L INPUT -v -n >> cis_compliance_check.txt

# Check ip6tables OUTPUT chain for loopback traffic configuration
output_chain_status=$(ip6tables -L OUTPUT -v -n 2>/dev/null | grep 'ACCEPT.*lo.*::/0')
echo "Output of 'ip6tables -L OUTPUT -v -n':" >> cis_compliance_check.txt
ip6tables -L OUTPUT -v -n >> cis_compliance_check.txt

# Verify if IPv6 is disabled
passing=""
grubfile="$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)"
! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
grep -Pq -- "^\s*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" && passing="true"
if [ "$passing" = true ]; then
  echo -e "\nIPv6 is disabled on the system\n" >> cis_compliance_check.txt
else
  echo -e "\nIPv6 is enabled on the system\n" >> cis_compliance_check.txt
fi

# Append results to compliance check file
if [[ $input_chain_status && $output_chain_status ]]; then
    echo "ip6tables loopback traffic is configured: Compliant" >> cis_compliance_check.txt
else
    echo "ip6tables loopback traffic is not configured: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.3.4
echo "" >> cis_compliance_check.txt
echo "3.4.3.3.4" >> cis_compliance_check.txt
echo "Ensure ip6tables default deny firewall policy" >> cis_compliance_check.txt

# Check ip6tables default policies
echo "Output of 'ip6tables -L':" >> cis_compliance_check.txt
ip6tables -L >> cis_compliance_check.txt

# Verify if IPv6 is disabled
passing=""
grubfile="$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)"
! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
grep -Pq -- "^\s*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" && passing="true"
if [ "$passing" = true ]; then
  echo -e "\nIPv6 is disabled on the system\n" >> cis_compliance_check.txt
else
  echo -e "\nIPv6 is enabled on the system\n" >> cis_compliance_check.txt
fi

# Check if default policies are set to DROP or REJECT
if ip6tables -L INPUT | grep -q "policy DROP" && ip6tables -L OUTPUT | grep -q "policy DROP" && ip6tables -L FORWARD | grep -q "policy DROP"; then
    echo "ip6tables default deny firewall policy: Compliant" >> cis_compliance_check.txt
else
    echo "ip6tables default deny firewall policy: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.3.5
echo "" >> cis_compliance_check.txt
echo "3.4.3.3.5" >> cis_compliance_check.txt
echo "Ensure ip6tables rules are saved" >> cis_compliance_check.txt

# Check if /etc/sysconfig/ip6tables contains the correct rule-set
echo "Contents of '/etc/sysconfig/ip6tables':" >> cis_compliance_check.txt
cat /etc/sysconfig/ip6tables >> cis_compliance_check.txt

# Verify if IPv6 is disabled
passing=""
grubfile="$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)"
! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
grep -Pq -- "^\s*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" && passing="true"
if [ "$passing" = true ]; then
  echo -e "\nIPv6 is disabled on the system\n" >> cis_compliance_check.txt
  echo "ip6tables rules are saved: Compliant" >> cis_compliance_check.txt
else
  echo -e "\nIPv6 is enabled on the system\n" >> cis_compliance_check.txt
  echo "ip6tables rules are saved: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#3.4.3.3.6
echo "" >> cis_compliance_check.txt
echo "3.4.3.3.6" >> cis_compliance_check.txt
echo "Ensure ip6tables is enabled and active" >> cis_compliance_check.txt

# Check if ip6tables is enabled
ip6tables_enabled=$(systemctl is-enabled ip6tables)
echo "Output of 'systemctl is-enabled ip6tables':" >> cis_compliance_check.txt
echo "$ip6tables_enabled" >> cis_compliance_check.txt

# Check if ip6tables is active
ip6tables_active=$(systemctl is-active ip6tables)
echo "Output of 'systemctl is-active ip6tables':" >> cis_compliance_check.txt
echo "$ip6tables_active" >> cis_compliance_check.txt

# Verify if IPv6 is disabled
passing=""
grubfile="$(find /boot -type f \( -name 'grubenv' -o -name 'grub.conf' -o -name 'grub.cfg' \) -exec grep -Pl -- '^\h*(kernelopts=|linux|kernel)' {} \;)"
! grep -P -- "^\h*(kernelopts=|linux|kernel)" "$grubfile" | grep -vq -- ipv6.disable=1 && passing="true"
grep -Pq -- "^\s*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" /etc/sysctl.conf /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf /run/sysctl.d/*.conf 2>/dev/null && \
sysctl net.ipv6.conf.all.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.all\.disable_ipv6\h*=\h*1\h*(#.*)?$" && \
sysctl net.ipv6.conf.default.disable_ipv6 | grep -Pq -- "^\h*net\.ipv6\.conf\.default\.disable_ipv6\h*=\h*1\h*(#.*)?$" && passing="true"
if [ "$passing" = true ]; then
  echo -e "\nIPv6 is disabled on the system\n" >> cis_compliance_check.txt
  echo "ip6tables is enabled and active: Compliant" >> cis_compliance_check.txt
else
  echo -e "\nIPv6 is enabled on the system\n" >> cis_compliance_check.txt
  echo "ip6tables is enabled and active: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.3
echo "" >> cis_compliance_check.txt
echo "4.2.3" >> cis_compliance_check.txt
echo "Ensure permissions on all logfiles are configured" >> cis_compliance_check.txt

# Check permissions on log files
log_permissions=$(find /var/log/ -type f -perm /g+wx,o+rwx -exec ls -l {} + 2>/dev/null)
if [ -z "$log_permissions" ]; then
  echo "No log files have incorrect permissions." >> cis_compliance_check.txt
  echo "Permissions on all logfiles are configured: Compliant" >> cis_compliance_check.txt
else
  echo "The following log files have incorrect permissions:" >> cis_compliance_check.txt
  echo "$log_permissions" >> cis_compliance_check.txt
  echo "Permissions on all logfiles are not configured: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.1.1
echo "" >> cis_compliance_check.txt
echo "4.2.1.1" >> cis_compliance_check.txt
echo "Ensure rsyslog is installed" >> cis_compliance_check.txt

# Check if rsyslog is installed
rsyslog_installed=$(rpm -q rsyslog)
if [ $? -eq 0 ]; then
  echo "rsyslog is installed: $rsyslog_installed" >> cis_compliance_check.txt
  echo "rsyslog is installed: Compliant" >> cis_compliance_check.txt
else
  echo "rsyslog is not installed" >> cis_compliance_check.txt
  echo "rsyslog is not installed: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.1.2
echo "" >> cis_compliance_check.txt
echo "4.2.1.2" >> cis_compliance_check.txt
echo "Ensure rsyslog service is enabled" >> cis_compliance_check.txt

# Check if rsyslog service is enabled
rsyslog_enabled=$(systemctl is-enabled rsyslog)
if [ "$rsyslog_enabled" = "enabled" ]; then
  echo "rsyslog service is enabled: $rsyslog_enabled" >> cis_compliance_check.txt
  echo "rsyslog service is enabled: Compliant" >> cis_compliance_check.txt
else
  echo "rsyslog service is not enabled" >> cis_compliance_check.txt
  echo "rsyslog service is not enabled: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.1.4
echo "" >> cis_compliance_check.txt
echo "4.2.1.4" >> cis_compliance_check.txt
echo "Ensure rsyslog default file permissions are configured" >> cis_compliance_check.txt

# Check rsyslog default file permissions
file_create_mode=$(grep "^\\\$FileCreateMode" /etc/rsyslog.conf /etc/rsyslog.d/*.conf | awk '{print $2}')
if [ "$file_create_mode" = "0640" ]; then
  echo "rsyslog default file permissions are configured: $file_create_mode" >> cis_compliance_check.txt
  echo "rsyslog default file permissions are configured: Compliant" >> cis_compliance_check.txt
else
  echo "rsyslog default file permissions are not configured as 0640" >> cis_compliance_check.txt
  echo "rsyslog default file permissions are not configured as 0640: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.1.7
echo "" >> cis_compliance_check.txt
echo "4.2.1.7" >> cis_compliance_check.txt
echo "Ensure rsyslog is not configured to recieve logs from a remote client" >> cis_compliance_check.txt

# Check if rsyslog is configured to receive logs from a remote client (old format)
old_format_output=$(grep -s '$ModLoad imtcp' /etc/rsyslog.conf /etc/rsyslog.d/*.conf)
old_format_status=""
if [ -z "$old_format_output" ]; then
    old_format_status="Compliant"
else
    old_format_status="Non-Compliant"
fi
echo "$old_format_output" >> cis_compliance_check.txt

# Check if rsyslog is configured to receive logs from a remote client (new format)
new_format_output=$(grep -s -P '^\h*module\(load=""imtcp""\)' /etc/rsyslog.conf /etc/rsyslog.d/*.conf)
new_format_status=""
if [ -z "$new_format_output" ]; then
    new_format_status="Compliant"
else
    new_format_status="Non-Compliant"
fi
echo "$new_format_output" >> cis_compliance_check.txt

# Append compliance status
if [ "$old_format_status" == "Compliant" ] && [ "$new_format_status" == "Compliant" ]; then
    echo "Rsyslog is not configured to receive logs from a remote client: Compliant" >> cis_compliance_check.txt
else
    echo "Rsyslog is configured to receive logs from a remote client: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.2.2
echo "" >> cis_compliance_check.txt
echo "4.2.2.2" >> cis_compliance_check.txt
echo "Ensure journald service is enabled" >> cis_compliance_check.txt

# Check if journald service is enabled
journald_status=$(systemctl is-enabled systemd-journald.service)
echo "Output of 'systemctl is-enabled systemd-journald.service':" >> cis_compliance_check.txt
echo "$journald_status" >> cis_compliance_check.txt

# Append compliance status
if [ "$journald_status" == "static" ]; then
    echo "Journald service is enabled: Compliant" >> cis_compliance_check.txt
else
    echo "Journald service is not enabled: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
#4.2.2.3
echo "" >> cis_compliance_check.txt
echo "4.2.2.3" >> cis_compliance_check.txt
echo "Ensure journald is configured to compress large log files" >> cis_compliance_check.txt

# Check if journald is configured to compress large log files
compress_status=$(grep '^\s*Compress' /etc/systemd/journald.conf | awk '{print $2}')
echo "Output of 'grep ^\s*Compress /etc/systemd/journald.conf':" >> cis_compliance_check.txt
echo "$compress_status" >> cis_compliance_check.txt

# Append compliance status
if [ "$compress_status" == "yes" ]; then
    echo "Journald is configured to compress large log files: Compliant" >> cis_compliance_check.txt
else
    echo "Journald is not configured to compress large log files: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 4.2.2.3
echo "" >> cis_compliance_check.txt
echo "4.2.2.3" >> cis_compliance_check.txt
echo "Ensure journald is configured to compress large log files" >> cis_compliance_check.txt

# Check if journald is configured to compress large log files
compress_status=$(grep '^\s*Compress' /etc/systemd/journald.conf | awk '{print $2}')
echo "Output of 'grep ^\s*Compress /etc/systemd/journald.conf':" >> cis_compliance_check.txt
echo "$compress_status" >> cis_compliance_check.txt

# Append compliance status
if [ "$compress_status" == "yes" ]; then
    echo "Journald is configured to compress large log files: Compliant" >> cis_compliance_check.txt
else
    echo "Journald is not configured to compress large log files: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 4.2.2.4
echo "" >> cis_compliance_check.txt
echo "4.2.2.4" >> cis_compliance_check.txt
echo "Ensure journald is configured to write logfiles to persistent disk" >> cis_compliance_check.txt

# Check if journald is configured to write log files to persistent disk
storage_status=$(grep '^\s*Storage' /etc/systemd/journald.conf | awk '{print $2}')
echo "Output of 'grep ^\s*Storage /etc/systemd/journald.conf':" >> cis_compliance_check.txt
echo "$storage_status" >> cis_compliance_check.txt

# Append compliance status
if [ "$storage_status" == "persistent" ]; then
    echo "Journald is configured to write log files to persistent disk: Compliant" >> cis_compliance_check.txt
else
    echo "Journald is not configured to write log files to persistent disk: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 4.2.2.1.4
echo "" >> cis_compliance_check.txt
echo "4.2.2.1.4" >> cis_compliance_check.txt
echo "Ensure journald is not configured to receive logs from a remote client" >> cis_compliance_check.txt

# Check if systemd-journal-remote.socket is enabled
remote_socket_status=$(systemctl is-enabled systemd-journal-remote.socket)
echo "Output of 'systemctl is-enabled systemd-journal-remote.socket':" >> cis_compliance_check.txt
echo "$remote_socket_status" >> cis_compliance_check.txt

# Append compliance status
if [ "$remote_socket_status" == "masked" ]; then
    echo "Journald is not configured to receive logs from a remote client: Compliant" >> cis_compliance_check.txt
else
    echo "Journald is configured to receive logs from a remote client: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.1
echo "" >> cis_compliance_check.txt
echo "5.1.1" >> cis_compliance_check.txt
echo "Ensure cron daemon is enabled" >> cis_compliance_check.txt

# Check if cron daemon (crond) is enabled
cron_status=$(systemctl is-enabled crond)
echo "Output of 'systemctl is-enabled crond':" >> cis_compliance_check.txt
echo "$cron_status" >> cis_compliance_check.txt

# Append compliance status
if [ "$cron_status" == "enabled" ]; then
    echo "Cron daemon (crond) is enabled: Compliant" >> cis_compliance_check.txt
else
    echo "Cron daemon (crond) is not enabled: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.2
echo "" >> cis_compliance_check.txt
echo "5.1.2" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/crontab are configured" >> cis_compliance_check.txt

# Check permissions on /etc/crontab
crontab_permissions=$(stat -c "%A %U %G" /etc/crontab)
echo "Output of 'stat /etc/crontab':" >> cis_compliance_check.txt
echo "Access: $crontab_permissions" >> cis_compliance_check.txt

# Append compliance status
if [[ "$crontab_permissions" == "0600 root root" ]]; then
    echo "/etc/crontab permissions are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "/etc/crontab permissions are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.3
echo "" >> cis_compliance_check.txt
echo "5.1.3" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/cron.hourly are configured" >> cis_compliance_check.txt

# Check permissions on /etc/cron.hourly
cron_hourly_permissions=$(stat -c "%A %U %G" /etc/cron.hourly)
echo "Output of 'stat /etc/cron.hourly':" >> cis_compliance_check.txt
echo "Access: $cron_hourly_permissions" >> cis_compliance_check.txt

# Append compliance status
if [[ "$cron_hourly_permissions" == "0700 root root" ]]; then
    echo "/etc/cron.hourly permissions are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "/etc/cron.hourly permissions are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.4
echo "" >> cis_compliance_check.txt
echo "5.1.4" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/cron.daily are configured" >> cis_compliance_check.txt

# Check permissions on /etc/cron.daily
cron_daily_permissions=$(stat -c "%A %U %G" /etc/cron.daily)
echo "Output of 'stat /etc/cron.daily':" >> cis_compliance_check.txt
echo "Access: $cron_daily_permissions" >> cis_compliance_check.txt

# Append compliance status
if [[ "$cron_daily_permissions" == "0700 root root" ]]; then
    echo "/etc/cron.daily permissions are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "/etc/cron.daily permissions are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.5
echo "" >> cis_compliance_check.txt
echo "5.1.5" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/cron.weekly are configured" >> cis_compliance_check.txt

# Check permissions on /etc/cron.weekly
cron_weekly_permissions=$(stat -c "%A %U %G" /etc/cron.weekly)
echo "Output of 'stat /etc/cron.weekly':" >> cis_compliance_check.txt
echo "Access: $cron_weekly_permissions" >> cis_compliance_check.txt

# Append compliance status
if [[ "$cron_weekly_permissions" == "0700 root root" ]]; then
    echo "/etc/cron.weekly permissions are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "/etc/cron.weekly permissions are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.6
echo "" >> cis_compliance_check.txt
echo "5.1.6" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/cron.monthly are configured" >> cis_compliance_check.txt

# Check permissions on /etc/cron.monthly
cron_monthly_permissions=$(stat -c "%A %U %G" /etc/cron.monthly)
echo "Output of 'stat /etc/cron.monthly':" >> cis_compliance_check.txt
echo "Access: $cron_monthly_permissions" >> cis_compliance_check.txt

# Append compliance status
if [[ "$cron_monthly_permissions" == "0700 root root" ]]; then
    echo "/etc/cron.monthly permissions are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "/etc/cron.monthly permissions are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
# 5.1.7
echo "" >> cis_compliance_check.txt
echo "5.1.7" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/cron.d are configured" >> cis_compliance_check.txt

# Check permissions on /etc/cron.d
cron_d_permissions=$(stat -c "%A %U %G" /etc/cron.d)
echo "Output of 'stat /etc/cron.d':" >> cis_compliance_check.txt
echo "Access: $cron_d_permissions" >> cis_compliance_check.txt

# Append compliance status
if [[ "$cron_d_permissions" == "0700 root root" ]]; then
    echo "/etc/cron.d permissions are configured correctly: Compliant" >> cis_compliance_check.txt
else
    echo "/etc/cron.d permissions are not configured correctly: Non-Compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.1.9" >> cis_compliance_check.txt
echo "Ensure at is restricted to authorized users" >> cis_compliance_check.txt

if rpm -q at >/dev/null; then
    if [ -e /etc/at.deny ]; then
        echo "Non-Compliant: at.deny exists" >> cis_compliance_check.txt
    fi
    
    if [ ! -e /etc/at.allow ]; then 
        echo "Non-Compliant: at.allow doesn't exist" >> cis_compliance_check.txt
    else
        at_allow_permissions=$(stat -Lc "%a" /etc/at.allow)
        at_allow_owner_group=$(stat -Lc "%u:%g" /etc/at.allow)
        
        if ! echo "$at_allow_permissions" | grep -Eq "[0,2,4,6]00"; then
            echo "Non-Compliant: at.allow mode too permissive" >> cis_compliance_check.txt
            echo "Permissions of /etc/at.allow: $at_allow_permissions" >> cis_compliance_check.txt
        else
            echo "Permissions of /etc/at.allow: $at_allow_permissions" >> cis_compliance_check.txt
        fi
        
        if ! echo "$at_allow_owner_group" | grep -Eq "^0:0$"; then
            echo "Non-Compliant: at.allow owner and/or group not root" >> cis_compliance_check.txt
            echo "Owner and group of /etc/at.allow: $at_allow_owner_group" >> cis_compliance_check.txt
        else
            echo "Owner and group of /etc/at.allow: $at_allow_owner_group" >> cis_compliance_check.txt
        fi
    fi
    
    if [ ! -e /etc/at.deny ] && [ -e /etc/at.allow ] && echo "$at_allow_permissions" | grep -Eq "[0,2,4,6]00" && echo "$at_allow_owner_group" | grep -Eq "^0:0$"; then
        echo "Compliant: at.allow configured correctly" >> cis_compliance_check.txt
    fi
else
    echo "Compliant: at is not installed on the system" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.1" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/ssh/sshd_config are configured" >> cis_compliance_check.txt

sshd_config_permissions=$(stat -c "%A" /etc/ssh/sshd_config)
sshd_config_owner=$(stat -c "%U" /etc/ssh/sshd_config)
sshd_config_group=$(stat -c "%G" /etc/ssh/sshd_config)

if [ "$sshd_config_permissions" = "-rw-------" ] && [ "$sshd_config_owner" = "root" ] && [ "$sshd_config_group" = "root" ]; then
    echo "Compliant: Permissions on /etc/ssh/sshd_config are configured correctly" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Permissions on /etc/ssh/sshd_config are not configured correctly" >> cis_compliance_check.txt
    echo "Actual permissions: $sshd_config_permissions, Owner: $sshd_config_owner, Group: $sshd_config_group" >> cis_compliance_check.txt
fi

#!/usr/bin/env bash

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.2" >> cis_compliance_check.txt
echo "Ensure permissions on SSH private host key files are configured" >> cis_compliance_check.txt

ssh_host_keys=$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key')

for key_file in $ssh_host_keys; do
    key_permissions=$(stat -c "%a" "$key_file")
    key_owner=$(stat -c "%U" "$key_file")
    key_group=$(stat -c "%G" "$key_file")
    
    if [ "$key_owner" = "root" ] && [ "$key_permissions" -ge "600" ]; then
        if [ "$key_group" = "ssh_keys" ] || [ "$key_group" = "root" ]; then
            echo "Compliant: Permissions on $key_file are configured correctly" >> cis_compliance_check.txt
        else
            echo "Non-Compliant: Group of $key_file is not configured correctly" >> cis_compliance_check.txt
            echo "Actual group: $key_group" >> cis_compliance_check.txt
        fi
    else
        echo "Non-Compliant: Permissions on $key_file are not configured correctly" >> cis_compliance_check.txt
        echo "Actual permissions: $key_permissions, Owner: $key_owner" >> cis_compliance_check.txt
    fi
done

#!/usr/bin/env bash

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.3" >> cis_compliance_check.txt
echo "Ensure permissions on SSH public host key files are configured" >> cis_compliance_check.txt

ssh_host_pub_keys=$(find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub')

for key_file in $ssh_host_pub_keys; do
    key_permissions=$(stat -c "%a" "$key_file")
    key_owner=$(stat -c "%U" "$key_file")
    key_group=$(stat -c "%G" "$key_file")
    
    if [ "$key_permissions" -eq "644" ]; then
        if [ "$key_owner" = "root" ] && [ "$key_group" = "root" ]; then
            echo "Compliant: Permissions on $key_file are configured correctly" >> cis_compliance_check.txt
        else
            echo "Non-Compliant: Owner or group of $key_file is not configured correctly" >> cis_compliance_check.txt
            echo "Actual owner: $key_owner, Actual group: $key_group" >> cis_compliance_check.txt
        fi
    else
        echo "Non-Compliant: Permissions on $key_file are not configured correctly" >> cis_compliance_check.txt
        echo "Actual permissions: $key_permissions" >> cis_compliance_check.txt
    fi
done

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.4" >> cis_compliance_check.txt
echo "Ensure SSH access is limited" >> cis_compliance_check.txt

sshd_config_output=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -Pi '^\h*(allow|deny)(users|groups)\h+\H+(\h+.*)?$')
sshd_config_file=$(grep -Pi '^\h*(allow|deny)(users|groups)\h+\H+(\h+.*)?$' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_config_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_file" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

if [ -n "$sshd_config_output" ] || [ -n "$sshd_config_file" ]; then
    echo "Compliant: SSH access is limited" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH access is not limited" >> cis_compliance_check.txt
fi

#!/usr/bin/env bash

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.5" >> cis_compliance_check.txt
echo "Ensure SSH LogLevel is appropriate" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_loglevel=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep loglevel)

# Run the second command and capture the output
sshd_config_loglevel=$(grep -i 'loglevel' /etc/ssh/sshd_config | grep -Evi '(VERBOSE|INFO)')

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_loglevel" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_loglevel" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the loglevel is appropriate
if [ -n "$sshd_loglevel" ] || [ -n "$sshd_config_loglevel" ]; then
    echo "Non-Compliant: SSH LogLevel is not appropriate" >> cis_compliance_check.txt
else
    echo "Compliant: SSH LogLevel is appropriate" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.6" >> cis_compliance_check.txt
echo "Ensure SSH PAM is enabled" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_usepam=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i usepam)

# Run the second command and capture the output
sshd_config_usepam=$(grep -Ei '^\s*UsePAM\s+no' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_usepam" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_usepam" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if PAM is enabled
if [ -n "$sshd_usepam" ] || [ -n "$sshd_config_usepam" ]; then
    echo "Non-Compliant: SSH PAM is not enabled" >> cis_compliance_check.txt
else
    echo "Compliant: SSH PAM is enabled" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.7" >> cis_compliance_check.txt
echo "Ensure SSH root login is disabled" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_root_login=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permitrootlogin)

# Run the second command and capture the output
sshd_config_root_login=$(grep -Ei '^\s*PermitRootLogin\s+yes' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_root_login" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_root_login" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if root login is disabled
if [ -n "$sshd_root_login" ] || [ -n "$sshd_config_root_login" ]; then
    echo "Non-Compliant: SSH root login is not disabled" >> cis_compliance_check.txt
else
    echo "Compliant: SSH root login is disabled" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.8" >> cis_compliance_check.txt
echo "Ensure SSH HostbasedAuthentication is disabled" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_hostbasedauth=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep hostbasedauthentication)

# Run the second command and capture the output
sshd_config_hostbasedauth=$(grep -Ei '^\s*HostbasedAuthentication\s+yes' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_hostbasedauth" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_hostbasedauth" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if HostbasedAuthentication is disabled
if [ -n "$sshd_hostbasedauth" ] || [ -n "$sshd_config_hostbasedauth" ]; then
    echo "Non-Compliant: SSH HostbasedAuthentication is not disabled" >> cis_compliance_check.txt
else
    echo "Compliant: SSH HostbasedAuthentication is disabled" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.9" >> cis_compliance_check.txt
echo "Ensure SSH PermitEmptyPasswords is disabled" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_permitemptypasswords=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permitemptypasswords)

# Run the second command and capture the output
sshd_config_permitemptypasswords=$(grep -Ei '^\s*PermitEmptyPasswords\s+yes' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_permitemptypasswords" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_permitemptypasswords" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if PermitEmptyPasswords is disabled
if [ -n "$sshd_permitemptypasswords" ] || [ -n "$sshd_config_permitemptypasswords" ]; then
    echo "Non-Compliant: SSH PermitEmptyPasswords is not disabled" >> cis_compliance_check.txt
else
    echo "Compliant: SSH PermitEmptyPasswords is disabled" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.10" >> cis_compliance_check.txt
echo "Ensure SSH PermitUserEnvironment is disabled" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_permituserenvironment=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep permituserenvironment)

# Run the second command and capture the output
sshd_config_permituserenvironment=$(grep -Ei '^\s*PermitUserEnvironment\s+yes' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_permituserenvironment" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_permituserenvironment" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if PermitUserEnvironment is disabled
if [ -n "$sshd_permituserenvironment" ] || [ -n "$sshd_config_permituserenvironment" ]; then
    echo "Non-Compliant: SSH PermitUserEnvironment is not disabled" >> cis_compliance_check.txt
else
    echo "Compliant: SSH PermitUserEnvironment is disabled" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.11" >> cis_compliance_check.txt
echo "Ensure SSH IgnoreRhosts is enabled" >> cis_compliance_check.txt

# Run the first command and capture the output
sshd_ignorerhosts=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep ignorerhosts)

# Run the second command and capture the output
sshd_config_ignorerhosts=$(grep -Ei '^\s*ignorerhosts\s+no\b' /etc/ssh/sshd_config)

echo "Output of 'sshd -T' command:" >> cis_compliance_check.txt
echo "$sshd_ignorerhosts" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

echo "Content of /etc/ssh/sshd_config:" >> cis_compliance_check.txt
echo "$sshd_config_ignorerhosts" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if IgnoreRhosts is enabled
if [ -n "$sshd_ignorerhosts" ] || [ -n "$sshd_config_ignorerhosts" ]; then
    echo "Non-Compliant: SSH IgnoreRhosts is not enabled" >> cis_compliance_check.txt
else
    echo "Compliant: SSH IgnoreRhosts is enabled" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.14" >> cis_compliance_check.txt
echo "Ensure system-wide crypto policy is not over-ridden" >> cis_compliance_check.txt

# Run the command and capture the output
crypto_policy=$(grep -i '^\s*CRYPTO_POLICY=' /etc/sysconfig/sshd)

echo "Output of 'grep' command:" >> cis_compliance_check.txt
echo "$crypto_policy" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if any output is returned
if [ -n "$crypto_policy" ]; then
    echo "Non-Compliant: System-wide crypto policy is over-ridden" >> cis_compliance_check.txt
else
    echo "Compliant: System-wide crypto policy is not over-ridden" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.15" >> cis_compliance_check.txt
echo "Ensure SSH warning banner is configured" >> cis_compliance_check.txt

# Run the command and capture the output
ssh_banner=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep banner)

echo "Output of 'sshd' command:" >> cis_compliance_check.txt
echo "$ssh_banner" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output matches the expected banner configuration
if [ "$ssh_banner" == "banner /etc/issue.net" ]; then
    echo "Compliant: SSH warning banner is configured correctly" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH warning banner is not configured or configured incorrectly" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.16" >> cis_compliance_check.txt
echo "Ensure SSH MaxAuthTries is set to 4 or less" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
echo "Output of 'sshd' command:" >> cis_compliance_check.txt
sshd_output=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep maxauthtries)
echo "$sshd_output" >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Check if the output indicates MaxAuthTries is 4 or less
if grep -q "maxauthtries 4" <<< "$sshd_output"; then
    echo "Compliant: SSH MaxAuthTries is set to 4 or less" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH MaxAuthTries is not set to 4 or less" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.17" >> cis_compliance_check.txt
echo "Ensure SSH MaxStartups is configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
echo "Output of 'sshd' command:" >> cis_compliance_check.txt
sshd_output=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i maxstartups)
echo "$sshd_output" >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Check if the output indicates MaxStartups is configured appropriately
if grep -q "maxstartups 10:30:60" <<< "$sshd_output"; then
    echo "Compliant: SSH MaxStartups is configured" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH MaxStartups is not configured appropriately" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.18" >> cis_compliance_check.txt
echo "Ensure SSH MaxSessions is set to 10 or less" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
echo "Output of 'sshd' command:" >> cis_compliance_check.txt
sshd_output=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep -i maxsessions)
echo "$sshd_output" >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Check if the output indicates MaxSessions is configured appropriately
if grep -q "maxsessions 10" <<< "$sshd_output"; then
    echo "Compliant: SSH MaxSessions is set to 10 or less" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH MaxSessions is not set to 10 or less" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.19" >> cis_compliance_check.txt
echo "Ensure SSH LoginGraceTime is set to one minute or less" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
echo "Output of 'sshd' command:" >> cis_compliance_check.txt
sshd_output=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep logingracetime)
echo "$sshd_output" >> cis_compliance_check.txt

echo "" >> cis_compliance_check.txt

# Check if the output indicates LoginGraceTime is configured appropriately
if grep -Eq "logingracetime (6[0]|[1-5][0-9]|[1-9]|1m)" <<< "$sshd_output"; then
    echo "Compliant: SSH LoginGraceTime is set to one minute or less" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH LoginGraceTime is not set to one minute or less" >> cis_compliance_check.txt
fi

# Run the second command and capture the output
echo "" >> cis_compliance_check.txt
echo "Output of 'grep' command:" >> cis_compliance_check.txt
grep_output=$(grep -Ei '^\s*LoginGraceTime\s+(0|6[1-9]|[7-9][0-9]|[1-9][0-9][0-9]+|[^1]m)' /etc/ssh/sshd_config)
echo "$grep_output" >> cis_compliance_check.txt

# Check if the second command returned anything
if [ -z "$grep_output" ]; then
    echo "Compliant: No invalid LoginGraceTime configurations found in /etc/ssh/sshd_config" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Invalid LoginGraceTime configurations found in /etc/ssh/sshd_config" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.2.20" >> cis_compliance_check.txt
echo "Ensure SSH Idle Timeout Interval is configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the first command and capture the output
echo "Output of 'sshd' command for ClientAliveInterval:" >> cis_compliance_check.txt
client_alive_interval=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientaliveinterval)
echo "$client_alive_interval" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output indicates ClientAliveInterval is configured appropriately
if grep -Eq "clientaliveinterval (900|[1-8]?[0-9]?[0-9])" <<< "$client_alive_interval"; then
    echo "Compliant: SSH ClientAliveInterval is set correctly" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH ClientAliveInterval is not set correctly" >> cis_compliance_check.txt
fi

# Run the second command and capture the output
echo "" >> cis_compliance_check.txt
echo "Output of 'sshd' command for ClientAliveCountMax:" >> cis_compliance_check.txt
client_alive_count_max=$(sshd -T -C user=root -C host="$(hostname)" -C addr="$(grep $(hostname) /etc/hosts | awk '{print $1}')" | grep clientalivecountmax)
echo "$client_alive_count_max" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output indicates ClientAliveCountMax is configured appropriately
if grep -Eq "clientalivecountmax 0" <<< "$client_alive_count_max"; then
    echo "Compliant: SSH ClientAliveCountMax is set correctly" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SSH ClientAliveCountMax is not set correctly" >> cis_compliance_check.txt
fi

# Run the third command and capture the output
echo "" >> cis_compliance_check.txt
echo "Output of 'grep' command for ClientAliveInterval:" >> cis_compliance_check.txt
grep_client_alive_interval=$(grep -Ei '^\s*ClientAliveInterval\s+(0|9[0-9][1-9]|[1-9][0-9][0-9][0-9]+|1[6-9]m|[2-9][0-9]m|[1-9][0-9][0-9]+m)\b' /etc/ssh/sshd_config)
echo "$grep_client_alive_interval" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the third command returned anything
if [ -z "$grep_client_alive_interval" ]; then
    echo "Compliant: No invalid ClientAliveInterval configurations found in /etc/ssh/sshd_config" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Invalid ClientAliveInterval configurations found in /etc/ssh/sshd_config" >> cis_compliance_check.txt
fi

# Run the fourth command and capture the output
echo "" >> cis_compliance_check.txt
echo "Output of 'grep' command for ClientAliveCountMax:" >> cis_compliance_check.txt
grep_client_alive_count_max=$(grep -Ei '^\s*ClientAliveCountMax\s+([1-9]|[1-9][0-9]+)\b' /etc/ssh/sshd_config)
echo "$grep_client_alive_count_max" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the fourth command returned anything
if [ -z "$grep_client_alive_count_max" ]; then
    echo "Compliant: No invalid ClientAliveCountMax configurations found in /etc/ssh/sshd_config" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Invalid ClientAliveCountMax configurations found in /etc/ssh/sshd_config" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.3.1" >> cis_compliance_check.txt
echo "Ensure sudo is installed" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
echo "Output of 'dnf list sudo' command:" >> cis_compliance_check.txt
sudo_installed=$(dnf list sudo 2>&1)
echo "$sudo_installed" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if sudo is installed
if grep -q "Installed Packages" <<< "$sudo_installed"; then
    echo "Compliant: sudo is installed" >> cis_compliance_check.txt
else
    echo "Non-Compliant: sudo is not installed" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.3.2" >> cis_compliance_check.txt
echo "Ensure sudo commands use pty" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
echo "Output of 'grep' command:" >> cis_compliance_check.txt
sudo_pty=$(grep -rPi '^\h*Defaults\h+([^#\n\r]+,)?use_pty(,\h*\h*\h*)*\h*(#.*)?$' /etc/sudoers* 2>&1)
echo "$sudo_pty" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output matches the expected configuration
if grep -q 'Defaults use_pty' <<< "$sudo_pty"; then
    echo "Compliant: sudo commands use pty" >> cis_compliance_check.txt
else
    echo "Non-Compliant: sudo commands do not use pty" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.3.5" >> cis_compliance_check.txt
echo "Ensure re-authentication for privilege escalation is not disabled globally" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output to a temporary file
grep -r "^[^#].*\!authenticate" /etc/sudoers* > /tmp/sudo_no_authenticate_output 2>&1

# Read the content of the temporary file
sudo_no_authenticate_output=$(cat /tmp/sudo_no_authenticate_output)

# Display the output of the command
echo "Output of 'grep' command:" >> cis_compliance_check.txt
echo "$sudo_no_authenticate_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output contains any lines with '!authenticate'
if [ -z "$sudo_no_authenticate_output" ]; then
    echo "Compliant: No '!authenticate' tags found" >> cis_compliance_check.txt
else
    echo "Non-Compliant: '!authenticate' tags found, re-authentication for privilege escalation is disabled" >> cis_compliance_check.txt
fi

# Clean up the temporary file
rm /tmp/sudo_no_authenticate_output

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.3.6" >> cis_compliance_check.txt
echo "Ensure sudo authentication timeout is configured correctly" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the first command to check for timestamp_timeout in /etc/sudoers*
sudo_timeout_output=$(grep -roP "timestamp_timeout=\K[0-9]*" /etc/sudoers* 2>&1)

# Display the output of the first command
echo "Output of 'grep' command:" >> cis_compliance_check.txt
echo "$sudo_timeout_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the second command to check the default timeout if not configured in /etc/sudoers*
if [ -z "$sudo_timeout_output" ]; then
    default_timeout_output=$(sudo -V | grep "Authentication timestamp timeout:" 2>&1)

    # Display the output of the second command
    echo "Output of 'sudo -V' command:" >> cis_compliance_check.txt
    echo "$default_timeout_output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    # Check if the default timeout is more than 15 minutes or disabled
    if echo "$default_timeout_output" | grep -q "Authentication timestamp timeout: 5 minute"; then
        echo "Compliant: Default timeout is set to 5 minutes" >> cis_compliance_check.txt
    else
        echo "Non-Compliant: Default timeout is not set to 5 minutes" >> cis_compliance_check.txt
    fi
else
    # Check if the configured timeout is more than 15 minutes or disabled
    if echo "$sudo_timeout_output" | grep -qE "^(0|[1-9]|1[0-5])$"; then
        echo "Compliant: Sudo authentication timeout is configured correctly" >> cis_compliance_check.txt
    else
        echo "Non-Compliant: Sudo authentication timeout is more than 15 minutes or disabled" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.3.7" >> cis_compliance_check.txt
echo "Ensure access to the su command is restricted" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the first command to check the PAM configuration for 'su'
su_pam_output=$(grep -Pi '^\h*auth\h+(?:required|requisite)\h+pam_wheel\.so\h+(?:[^#\n\r]+\h+)?((?!\2)(use_uid\b|group=\H+\b))\h+(?:[^#\n\r]+\h+)?((?!\1)(use_uid\b|group=\H+\b))(\h+.*)?$' /etc/pam.d/su 2>&1)

# Display the output of the first command
echo "Output of 'grep' command for PAM configuration:" >> cis_compliance_check.txt
echo "$su_pam_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Extract the group name from the PAM configuration output
group_name=$(echo "$su_pam_output" | grep -oP 'group=\K\w+')

# Check if the group name was found
if [ -z "$group_name" ]; then
    echo "Non-Compliant: No group name found in PAM configuration for 'su'" >> cis_compliance_check.txt
else
    # Run the second command to check the group in /etc/group
    group_output=$(grep "^$group_name" /etc/group 2>&1)

    # Display the output of the second command
    echo "Output of 'grep' command for group:" >> cis_compliance_check.txt
    echo "$group_output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    # Verify the group has no users
    if echo "$group_output" | grep -q "^$group_name:[^:]*:[^:]*:$"; then
        echo "Compliant: Group '$group_name' exists and has no users" >> cis_compliance_check.txt
    else
        echo "Non-Compliant: Group '$group_name' has users or does not exist" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.4.2" >> cis_compliance_check.txt
echo "Ensure authselect includes with-faillock" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command to check if pam_faillock.so is enabled
faillock_output=$(grep pam_faillock.so /etc/pam.d/password-auth /etc/pam.d/system-auth 2>&1)

# Display the output of the command
echo "Output of 'grep' command for pam_faillock.so:" >> cis_compliance_check.txt
echo "$faillock_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify if the output contains the required lines
if echo "$faillock_output" | grep -q "/etc/authselect/password-auth:auth.*required.*pam_faillock.so.*preauth.*silent" &&
   echo "$faillock_output" | grep -q "/etc/authselect/password-auth:auth.*required.*pam_faillock.so.*authfail" &&
   echo "$faillock_output" | grep -q "/etc/authselect/password-auth:account.*required.*pam_faillock.so" &&
   echo "$faillock_output" | grep -q "/etc/authselect/system-auth:auth.*required.*pam_faillock.so.*preauth.*silent" &&
   echo "$faillock_output" | grep -q "/etc/authselect/system-auth:auth.*required.*pam_faillock.so.*authfail" &&
   echo "$faillock_output" | grep -q "/etc/authselect/system-auth:account.*required.*pam_faillock.so"; then
    echo "Compliant: faillock is enabled correctly in authselect" >> cis_compliance_check.txt
else
    echo "Non-Compliant: faillock is not enabled correctly in authselect" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.5.1" >> cis_compliance_check.txt
echo "Ensure password creation requirements are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command to check pam_pwquality.so configuration
pwquality_output=$(grep pam_pwquality.so /etc/pam.d/system-auth /etc/pam.d/password-auth 2>&1)

# Display the output of the command
echo "Output of 'grep pam_pwquality.so' command:" >> cis_compliance_check.txt
echo "$pwquality_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify if the pam_pwquality.so configuration is correct
if echo "$pwquality_output" | grep -q "/etc/pam.d/system-auth:password.*requisite.*pam_pwquality.so.*try_first_pass.*local_users_only.*enforce_for_root.*retry=3" &&
   echo "$pwquality_output" | grep -q "/etc/pam.d/password-auth:password.*requisite.*pam_pwquality.so.*try_first_pass.*local_users_only.*enforce_for_root.*retry=3"; then
    echo "Compliant: pam_pwquality.so configuration is correct" >> cis_compliance_check.txt
else
    echo "Non-Compliant: pam_pwquality.so configuration is incorrect" >> cis_compliance_check.txt
fi

# Run the command to check minlen in /etc/security/pwquality.conf
minlen_output=$(grep ^minlen /etc/security/pwquality.conf 2>&1)

# Display the output of the command
echo "Output of 'grep ^minlen' command:" >> cis_compliance_check.txt
echo "$minlen_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify if minlen is 14 or more
if echo "$minlen_output" | grep -q "^minlen[[:space:]]*=[[:space:]]*[1-9][4-9]*"; then
    echo "Compliant: minlen is 14 or more" >> cis_compliance_check.txt
else
    echo "Non-Compliant: minlen is less than 14" >> cis_compliance_check.txt
fi

# Run the command to check minclass in /etc/security/pwquality.conf
minclass_output=$(grep ^minclass /etc/security/pwquality.conf 2>&1)

# Display the output of the command
echo "Output of 'grep ^minclass' command:" >> cis_compliance_check.txt
echo "$minclass_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify if minclass configuration is present
if echo "$minclass_output" | grep -q "^minclass"; then
    echo "Compliant: minclass is configured" >> cis_compliance_check.txt
else
    echo "Non-Compliant: minclass is not configured" >> cis_compliance_check.txt
fi

# Run the command to check Scredit in /etc/security/pwquality.conf
scredit_output=$(grep -E '^\s*\Scredit\s*=' /etc/security/pwquality.conf 2>&1)

# Display the output of the command
echo "Output of 'grep -E \"^\\s*\\Scredit\\s*=\"' command:" >> cis_compliance_check.txt
echo "$scredit_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Verify if Scredit configuration is present
if echo "$scredit_output" | grep -q "Scredit"; then
    echo "Compliant: Scredit is configured" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Scredit is not configured" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.5.2" >> cis_compliance_check.txt
echo "Ensure lockout for failed password attempts is configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check the version of the system
version=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release)

# Verify for versions 8.2 and later
if [[ "$version" == "\"8.2\"" ]] || [[ "$version" > "\"8.2\"" ]]; then
    # Run the command to check deny in /etc/security/faillock.conf
    deny_output=$(grep -E '^\s*deny\s*=\s*[1-5]\b' /etc/security/faillock.conf 2>&1)

    # Display the output of the command
    echo "Output of 'grep -E \"^\\s*deny\\s*=\\s*[1-5]\\b\"' command:" >> cis_compliance_check.txt
    echo "$deny_output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    # Verify if deny is between 1 and 5
    if echo "$deny_output" | grep -q '^\s*deny\s*=\s*[1-5]\b'; then
        echo "Compliant: deny is configured correctly" >> cis_compliance_check.txt
    else
        echo "Non-Compliant: deny is not configured correctly" >> cis_compliance_check.txt
    fi

    # Run the command to check unlock_time in /etc/security/faillock.conf
    unlock_time_output=$(grep -E '^\s*unlock_time\s*=\s*(0|9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\b' /etc/security/faillock.conf 2>&1)

    # Display the output of the command
    echo "Output of 'grep -E \"^\\s*unlock_time\\s*=\\s*(0|9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\\b\"' command:" >> cis_compliance_check.txt
    echo "$unlock_time_output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    # Verify if unlock_time is 0 or 900 or more
    if echo "$unlock_time_output" | grep -q '^\s*unlock_time\s*=\s*(0|9[0-9][0-9]|[1-9][0-9][0-9][0-9]+)\b'; then
        echo "Compliant: unlock_time is configured correctly" >> cis_compliance_check.txt
    else
        echo "Non-Compliant: unlock_time is not configured correctly" >> cis_compliance_check.txt
    fi
else
    # Verify for versions 8.0 and 8.1
    # Run the command to check pam_faillock.so configuration in /etc/pam.d/password-auth and /etc/pam.d/system-auth
    pam_faillock_output=$(grep -E '^\s*auth\s+required\s+pam_faillock.so\s+' /etc/pam.d/password-auth /etc/pam.d/system-auth 2>&1)

    # Display the output of the command
    echo "Output of 'grep -E \"^\\s*auth\\s+required\\s+pam_faillock.so\\s+\"' command:" >> cis_compliance_check.txt
    echo "$pam_faillock_output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    # Verify if pam_faillock.so configuration is correct
    if echo "$pam_faillock_output" | grep -q 'preauth silent deny=5 unlock_time=900' &&
       echo "$pam_faillock_output" | grep -q 'authfail deny=5 unlock_time=900'; then
        echo "Compliant: pam_faillock.so configuration is correct" >> cis_compliance_check.txt
    else
        echo "Non-Compliant: pam_faillock.so configuration is incorrect" >> cis_compliance_check.txt
    fi
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.5.3" >> cis_compliance_check.txt
echo "Ensure password reuse is limited" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the command and capture the output
password_reuse_output=$(grep -P '^\h*password\h+(requisite|sufficient)\h+(pam_pwhistory\.so|pam_unix\.so)\h+([^#\n\r]+\h+)?remember=([5-9]|[1-9][0-9]+)\h*(\h+.*)?$' /etc/pam.d/system-auth 2>&1)

# Display the output of the command
echo "Output of 'grep -P \"^\\h*password\\h+(requisite|sufficient)\\h+(pam_pwhistory\\.so|pam_unix\\.so)\\h+([^#\\n\\r]+\\h+)?remember=([5-9]|[1-9][0-9]+)\\h*(\\h+.*)?$\"' command:" >> cis_compliance_check.txt
echo "$password_reuse_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output matches the expected configuration
if echo "$password_reuse_output" | grep -qP '^\h*password\h+(requisite|sufficient)\h+(pam_pwhistory\.so|pam_unix\.so)\h+([^#\n\r]+\h+)?remember=([5-9]|[1-9][0-9]+)\h*(\h+.*)?$'; then
    echo "Compliant: Password reuse is limited correctly" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Password reuse is not limited correctly" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.5.4" >> cis_compliance_check.txt
echo "Ensure password hashing algorithm is SHA-512" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check /etc/libuser.conf
echo "Checking /etc/libuser.conf" >> cis_compliance_check.txt
libuser_conf_output=$(grep -Ei '^\s*crypt_style\s*=\s*sha512\b' /etc/libuser.conf 2>&1)
echo "Output of 'grep -Ei \"^\\s*crypt_style\\s*=\\s*sha512\\b\" /etc/libuser.conf':" >> cis_compliance_check.txt
echo "$libuser_conf_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

if echo "$libuser_conf_output" | grep -qEi '^\s*crypt_style\s*=\s*sha512\b'; then
    echo "Compliant: SHA-512 is set in /etc/libuser.conf" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SHA-512 is not set in /etc/libuser.conf" >> cis_compliance_check.txt
fi

# Check /etc/login.defs
echo "Checking /etc/login.defs" >> cis_compliance_check.txt
login_defs_output=$(grep -Ei '^\s*ENCRYPT_METHOD\s+SHA512\b' /etc/login.defs 2>&1)
echo "Output of 'grep -Ei \"^\\s*ENCRYPT_METHOD\\s+SHA512\\b\" /etc/login.defs':" >> cis_compliance_check.txt
echo "$login_defs_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

if echo "$login_defs_output" | grep -qEi '^\s*ENCRYPT_METHOD\s+SHA512\b'; then
    echo "Compliant: SHA-512 is set in /etc/login.defs" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SHA-512 is not set in /etc/login.defs" >> cis_compliance_check.txt
fi

# Check /etc/pam.d/system-auth and /etc/pam.d/password-auth
echo "Checking /etc/pam.d/system-auth and /etc/pam.d/password-auth" >> cis_compliance_check.txt
pam_auth_output=$(grep -P -- '^\h*password\h+(requisite|required|sufficient)\h+pam_unix\.so(\h+[^#\n\r]+)?\h+sha512\b.*$' /etc/pam.d/password-auth /etc/pam.d/system-auth 2>&1)
echo "Output of 'grep -P -- \"^\\h*password\\h+(requisite|required|sufficient)\\h+pam_unix\\.so(\\h+[^#\\n\\r]+)?\\h+sha512\\b.*$\" /etc/pam.d/password-auth /etc/pam.d/system-auth':" >> cis_compliance_check.txt
echo "$pam_auth_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

if echo "$pam_auth_output" | grep -qP -- '^\h*password\h+(requisite|required|sufficient)\h+pam_unix\.so(\h+[^#\n\r]+)?\h+sha512\b.*$'; then
    echo "Compliant: SHA-512 is set in /etc/pam.d/system-auth and /etc/pam.d/password-auth" >> cis_compliance_check.txt
else
    echo "Non-Compliant: SHA-512 is not set in /etc/pam.d/system-auth and /etc/pam.d/password-auth" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.2" >> cis_compliance_check.txt
echo "Ensure system accounts are secured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the first command and capture the output
echo "Running command to check for non-secure system accounts in /etc/passwd" >> cis_compliance_check.txt
system_accounts_output=$(awk -F: '($1!~/^(root|halt|sync|shutdown|nfsnobody)$/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"' && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1 }' /etc/passwd 2>&1)
echo "Output of the command:" >> cis_compliance_check.txt
echo "$system_accounts_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output is empty
if [ -z "$system_accounts_output" ]; then
    echo "Compliant: No non-secure system accounts found in /etc/passwd" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Non-secure system accounts found in /etc/passwd" >> cis_compliance_check.txt
fi

# Run the second command and capture the output
echo "Running command to check for non-locked system accounts in /etc/passwd" >> cis_compliance_check.txt
non_locked_accounts_output=$(awk -F: '($1!="root" && $1!~/^\+/ && $3<'"$(awk '/^\s*UID_MIN/{print $2}' /etc/login.defs)"') {print $1}' /etc/passwd | xargs -I '{}' passwd -S '{}' | awk '($2!="L" && $2!="LK") {print $1}' 2>&1)
echo "Output of the command:" >> cis_compliance_check.txt
echo "$non_locked_accounts_output" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Check if the output is empty
if [ -z "$non_locked_accounts_output" ]; then
    echo "Compliant: No non-locked system accounts found in /etc/passwd" >> cis_compliance_check.txt
else
    echo "Non-Compliant: Non-locked system accounts found in /etc/passwd" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.3" >> cis_compliance_check.txt
echo "Ensure default user shell timeout is 900 seconds or less" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the verification script
{
    output1="" 
    output2=""
    [ -f /etc/bashrc ] && BRC="/etc/bashrc"
    for f in "$BRC" /etc/profile /etc/profile.d/*.sh; do
        grep -Pq '^\s*([^#]+\s+)?TMOUT=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9])\b' "$f" && \
        grep -Pq '^\s*([^#]+;\s*)?readonly\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" && \
        grep -Pq '^\s*([^#]+;\s*)?export\s+TMOUT(\s+|\s*;|\s*$|=(900|[1-8][0-9][0-9]|[1-9][0-9]|[1-9]))\b' "$f" && \
        output1="$f"
    done
    grep -Pq '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC" && \
    output2=$(grep -Ps '^\s*([^#]+\s+)?TMOUT=(9[0-9][1-9]|9[1-9][0-9]|0+|[1-9]\d{3,})\b' /etc/profile /etc/profile.d/*.sh "$BRC")
    
    # Log output to file
    echo "Output of the verification script:" >> cis_compliance_check.txt
    echo "Output1: $output1" >> cis_compliance_check.txt
    echo "Output2: $output2" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    # Determine compliance status
    if [ -n "$output1" ] && [ -z "$output2" ]; then
        echo "PASSED: TMOUT is configured correctly in: \"$output1\"" >> cis_compliance_check.txt
    else
        [ -z "$output1" ] && echo "FAILED: TMOUT is not configured" >> cis_compliance_check.txt
        [ -n "$output2" ] && echo "FAILED: TMOUT is incorrectly configured in: \"$output2\"" >> cis_compliance_check.txt
    fi
}

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.4" >> cis_compliance_check.txt
echo "Ensure default group for the root account is GID 0" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Run the verification command
gid=$(grep "^root:" /etc/passwd | cut -f4 -d:)

# Log output to file
echo "Output of the verification command:" >> cis_compliance_check.txt
echo "GID: $gid" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Determine compliance status
if [ "$gid" -eq 0 ]; then
    echo "PASSED: Default group for the root account is GID 0" >> cis_compliance_check.txt
else
    echo "FAILED: Default group for the root account is not GID 0" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.5" >> cis_compliance_check.txt
echo "Ensure default user umask is 027 or more restrictive" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check default user umask
check_default_user_umask() {
    local passing=""
    if grep -Eiq '^\s*UMASK\s+(0[0-7][2-7]7|[0-7][2-7]7)\b' /etc/login.defs && grep -Eqi '^\s*USERGROUPS_ENAB\s*"?no"?\b' /etc/login.defs && grep -Eq '^\s*session\s+(optional|requisite|required)\s+pam_umask\.so\b' /etc/pam.d/common-session; then
        passing=true
    fi
    if grep -REiq '^\s*UMASK\s+\s*(0[0-7][2-7]7|[0-7][2-7]7|u=(r?|w?|x?)(r?|w?|x?)(r?|w?|x?),g=(r?x?|x?r?),o=)\b' /etc/profile* /etc/bashrc*; then
        passing=true
    fi
    if [ "$passing" = true ]; then
        echo "Default user umask is set"
        return 0
    else
        return 1
    fi
}

# Function to check no less restrictive system wide umask is set
check_no_less_restrictive_umask() {
    local output
    output=$(grep -RPi '(^|^[^#]*)\s*umask\s+([0-7][0-7][01][0-7]\b|[0-7][0-7][0-7][0-6]\b|[0-7][01][0-7]\b|[0-7][0-7][0-6]\b|(u=[rwx]{0,3},)?(g=[rwx]{0,3},)?o=[rwx]+\b|(u=[rwx]{1,3},)?g=[^rx]{1,3}(,o=[rwx]{0,3})?\b)' /etc/login.defs /etc/profile* /etc/bashrc*)
    if [ -z "$output" ]; then
        return 0
    else
        return 1
    fi
}

# Check default user umask
if check_default_user_umask; then
    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "Default user umask is set" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt
else
    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "Default user umask is not set" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt
fi

# Check no less restrictive system wide umask
if check_no_less_restrictive_umask; then
    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "No less restrictive system wide umask is set" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt
else
    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "A less restrictive system wide umask is set" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_default_user_umask && check_no_less_restrictive_umask; then
    echo "PASSED: Default user umask is 027 or more restrictive, and no less restrictive system wide umask is set" >> cis_compliance_check.txt
else
    echo "FAILED: Default user umask is not 027 or more restrictive, or a less restrictive system wide umask is set" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.1.1" >> cis_compliance_check.txt
echo "Ensure password expiration is 365 days or less" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check PASS_MAX_DAYS in /etc/login.defs
check_pass_max_days_login_defs() {
    local output
    output=$(grep PASS_MAX_DAYS /etc/login.defs)
    if echo "$output" | grep -q "PASS_MAX_DAYS[[:space:]]\+365"; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Function to check PASS_MAX_DAYS for each user in /etc/shadow
check_pass_max_days_shadow() {
    local output
    output=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,5)
    local all_within_limit=true
    while IFS= read -r line; do
        local user
        local max_days
        user=$(echo "$line" | cut -d: -f1)
        max_days=$(echo "$line" | cut -d: -f2)
        if [ "$max_days" -gt 365 ]; then
            all_within_limit=false
            break
        fi
    done <<< "$output"

    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "$output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    if [ "$all_within_limit" = true ]; then
        return 0
    else
        return 1
    fi
}

# Check PASS_MAX_DAYS in /etc/login.defs
if check_pass_max_days_login_defs; then
    echo "PASS_MAX_DAYS is correctly set to 365 in /etc/login.defs" >> cis_compliance_check.txt
else
    echo "PASS_MAX_DAYS is not set to 365 in /etc/login.defs" >> cis_compliance_check.txt
fi

# Check PASS_MAX_DAYS for each user in /etc/shadow
if check_pass_max_days_shadow; then
    echo "All users have PASS_MAX_DAYS set to 365 or less" >> cis_compliance_check.txt
else
    echo "Some users have PASS_MAX_DAYS set to more than 365" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_pass_max_days_login_defs && check_pass_max_days_shadow; then
    echo "PASSED: Password expiration is 365 days or less" >> cis_compliance_check.txt
else
    echo "FAILED: Password expiration is more than 365 days for some users or in /etc/login.defs" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.1.2" >> cis_compliance_check.txt
echo "Ensure minimum days between password changes is 7 or more" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check PASS_MIN_DAYS in /etc/login.defs
check_pass_min_days_login_defs() {
    local output
    output=$(grep '^\s*PASS_MIN_DAYS' /etc/login.defs)
    if echo "$output" | grep -q "PASS_MIN_DAYS[[:space:]]\+7"; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Function to check PASS_MIN_DAYS for each user in /etc/shadow
check_pass_min_days_shadow() {
    local output
    output=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,4)
    local all_within_limit=true
    while IFS= read -r line; do
        local user
        local min_days
        user=$(echo "$line" | cut -d: -f1)
        min_days=$(echo "$line" | cut -d: -f2)
        if [ "$min_days" -lt 7 ]; then
            all_within_limit=false
            break
        fi
    done <<< "$output"

    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "$output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    if [ "$all_within_limit" = true ]; then
        return 0
    else
        return 1
    fi
}

# Check PASS_MIN_DAYS in /etc/login.defs
if check_pass_min_days_login_defs; then
    echo "PASS_MIN_DAYS is correctly set to 7 in /etc/login.defs" >> cis_compliance_check.txt
else
    echo "PASS_MIN_DAYS is not set to 7 in /etc/login.defs" >> cis_compliance_check.txt
fi

# Check PASS_MIN_DAYS for each user in /etc/shadow
if check_pass_min_days_shadow; then
    echo "All users have PASS_MIN_DAYS set to 7 or more" >> cis_compliance_check.txt
else
    echo "Some users have PASS_MIN_DAYS set to less than 7" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_pass_min_days_login_defs && check_pass_min_days_shadow; then
    echo "PASSED: Minimum days between password changes is 7 or more" >> cis_compliance_check.txt
else
    echo "FAILED: Minimum days between password changes is less than 7 for some users or in /etc/login.defs" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.1.3" >> cis_compliance_check.txt
echo "Ensure password expiration warning days is 7 or more" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check PASS_WARN_AGE in /etc/login.defs
check_pass_warn_age_login_defs() {
    local output
    output=$(grep '^\s*PASS_WARN_AGE' /etc/login.defs)
    if echo "$output" | grep -q "PASS_WARN_AGE[[:space:]]\+7"; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Function to check PASS_WARN_AGE for each user in /etc/shadow
check_pass_warn_age_shadow() {
    local output
    output=$(grep -E '^[^:]+:[^!*]' /etc/shadow | cut -d: -f1,6)
    local all_within_limit=true
    while IFS= read -r line; do
        local user
        local warn_age
        user=$(echo "$line" | cut -d: -f1)
        warn_age=$(echo "$line" | cut -d: -f2)
        if [ "$warn_age" -lt 7 ]; then
            all_within_limit=false
            break
        fi
    done <<< "$output"

    echo "Output of the verification command:" >> cis_compliance_check.txt
    echo "$output" >> cis_compliance_check.txt
    echo "" >> cis_compliance_check.txt

    if [ "$all_within_limit" = true ]; then
        return 0
    else
        return 1
    fi
}

# Check PASS_WARN_AGE in /etc/login.defs
if check_pass_warn_age_login_defs; then
    echo "PASS_WARN_AGE is correctly set to 7 in /etc/login.defs" >> cis_compliance_check.txt
else
    echo "PASS_WARN_AGE is not set to 7 in /etc/login.defs" >> cis_compliance_check.txt
fi

# Check PASS_WARN_AGE for each user in /etc/shadow
if check_pass_warn_age_shadow; then
    echo "All users have PASS_WARN_AGE set to 7 or more" >> cis_compliance_check.txt
else
    echo "Some users have PASS_WARN_AGE set to less than 7" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_pass_warn_age_login_defs && check_pass_warn_age_shadow; then
    echo "PASSED: Password expiration warning days is 7 or more" >> cis_compliance_check.txt
else
    echo "FAILED: Password expiration warning days is less than 7 for some users or in /etc/login.defs" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.1.4" >> cis_compliance_check.txt
echo "Ensure inactive password lock is 30 days or less" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check INACTIVE value in useradd -D
check_inactive_useradd() {
    local output
    output=$(useradd -D | grep 'INACTIVE')
    if echo "$output" | grep -q "INACTIVE=30"; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Function to check INACTIVE value for each user in /etc/shadow
check_inactive_shadow() {
    local output
    output=$(awk -F: '/^[^#:]+:[^\!\*:]*:[^:]*:[^:]*:[^:]*:[^:]*:(\s*|-1|3[1-9]|[4-9][0-9]|[1-9][0-9][0-9]+):[^:]*:[^:]*\s*$/ {print $1":"$7}' /etc/shadow)
    
    if [ -z "$output" ]; then
        return 0
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Check INACTIVE value in useradd -D
if check_inactive_useradd; then
    echo "INACTIVE is correctly set to 30 in useradd -D" >> cis_compliance_check.txt
else
    echo "INACTIVE is not set to 30 in useradd -D" >> cis_compliance_check.txt
fi

# Check INACTIVE value for each user in /etc/shadow
if check_inactive_shadow; then
    echo "All users have INACTIVE set to 30 or less" >> cis_compliance_check.txt
else
    echo "Some users have INACTIVE set to more than 30" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_inactive_useradd && check_inactive_shadow; then
    echo "PASSED: Inactive password lock is 30 days or less" >> cis_compliance_check.txt
else
    echo "FAILED: Inactive password lock is more than 30 days for some users or in useradd -D" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "5.6.1.5" >> cis_compliance_check.txt
echo "Ensure all users last password change date is in the past" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check if all users' last password change date is in the past
check_last_password_change() {
    local output
    output=$(awk -F: '/^[^:]+:[^!*]/{print $1}' /etc/shadow | while read -r usr; do
        change=$(date -d "$(chage --list $usr | grep '^Last password change' | cut -d: -f2 | grep -v 'never$')" +%s 2>/dev/null)
        if [[ $? -eq 0 && "$change" -gt "$(date +%s)" ]]; then
            echo "User: \"$usr\" last password change was \"$(chage --list $usr | grep '^Last password change' | cut -d: -f2)\""
        fi
    done)
    
    if [ -z "$output" ]; then
        return 0
    else
        echo "$output" >> cis_compliance_check.txt
        return 1
    fi
}

# Check last password change dates
if check_last_password_change; then
    echo "PASSED: All users' last password change dates are in the past" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have last password change dates in the future" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.2" >> cis_compliance_check.txt
echo "Ensure sticky bit is set on all world-writable directories" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt


# Function to check for world-writable directories without the sticky bit
check_world_writable_dirs() {
    local output
    output=$(df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2>/dev/null)
    
    if [ -z "$output" ]; then
        return 0
    else
        echo "$output" >> cis_compliance_check.txt
        return 1
    fi
}

# Check for world-writable directories without the sticky bit
if check_world_writable_dirs; then
    echo "PASSED: No world-writable directories without the sticky bit found" >> cis_compliance_check.txt
else
    echo "FAILED: Some world-writable directories without the sticky bit found" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.3" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/passwd are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/passwd
check_etc_passwd_permissions() {
    local stat_output
    stat_output=$(stat /etc/passwd 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Uid is 0/root and Gid is 0/root, and Access is 644 or more restrictive
        if echo "$stat_output" | grep -q "Access: (0644/-rw-r--r--)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/passwd
if check_etc_passwd_permissions; then
    echo "/etc/passwd permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/passwd permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.4" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/shadow are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/shadow
check_etc_shadow_permissions() {
    local stat_output
    stat_output=$(stat /etc/shadow 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0000 and Uid is 0/root and Gid is 0/root
        if echo "$stat_output" | grep -q "Access: (0000/----------)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/shadow
if check_etc_shadow_permissions; then
    echo "/etc/shadow permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/shadow permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.5" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/group are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/group
check_etc_group_permissions() {
    local stat_output
    stat_output=$(stat /etc/group 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0644 and Uid is 0/root and Gid is 0/root
        if echo "$stat_output" | grep -q "Access: (0644/-rw-r--r--)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/group
if check_etc_group_permissions; then
    echo "/etc/group permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/group permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.6" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/gshadow are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/gshadow
check_etc_gshadow_permissions() {
    local stat_output
    stat_output=$(stat /etc/gshadow 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0000 and Uid is 0/root and Gid is 0/root
        if echo "$stat_output" | grep -q "Access: (0000/----------)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/gshadow
if check_etc_gshadow_permissions; then
    echo "/etc/gshadow permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/gshadow permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.7" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/passwd- are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/passwd-
check_etc_passwd_minus_permissions() {
    local stat_output
    stat_output=$(stat /etc/passwd- 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0644 and Uid is 0/root and Gid is 0/root
        if echo "$stat_output" | grep -q "Access: (0644/-rw-r--r--)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/passwd-
if check_etc_passwd_minus_permissions; then
    echo "/etc/passwd- permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/passwd- permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.8" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/shadow- are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/shadow-
check_etc_shadow_minus_permissions() {
    local stat_output
    stat_output=$(stat /etc/shadow- 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0000 and Uid is 0/root and Gid is 0/root
        if echo "$stat_output" | grep -q "Access: (0000/----------)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/shadow-
if check_etc_shadow_minus_permissions; then
    echo "/etc/shadow- permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/shadow- permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.9" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/group- are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/group-
check_etc_group_minus_permissions() {
    local stat_output
    stat_output=$(stat /etc/group- 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0644 or more restrictive and Uid is 0/root and Gid is 0/root
        if echo "$stat_output" | grep -q "Access: (0644/-rw-------)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           echo "$stat_output" | grep -q "Gid: ( 0/ root)"; then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/group-
if check_etc_group_minus_permissions; then
    echo "/etc/group- permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/group- permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.10" >> cis_compliance_check.txt
echo "Ensure permissions on /etc/gshadow- are configured" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions on /etc/gshadow-
check_etc_gshadow_minus_permissions() {
    local stat_output
    stat_output=$(stat /etc/gshadow- 2>&1)

    # Check if stat command was successful
    if [ $? -eq 0 ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        # Check if Access is 0000 and Uid is 0/root and Gid is 0/root or <gid>/shadow
        if echo "$stat_output" | grep -q "Access: (0000/----------)" && \
           echo "$stat_output" | grep -q "Uid: ( 0/ root)" && \
           (echo "$stat_output" | grep -q "Gid: ( 0/ root)" || echo "$stat_output" | grep -q "Gid: ( [0-9]\+/shadow)"); then
            return 0
        else
            return 1
        fi
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$stat_output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1
    fi
}

# Run the function to check permissions on /etc/gshadow-
if check_etc_gshadow_minus_permissions; then
    echo "/etc/gshadow- permissions are correctly set" >> cis_compliance_check.txt
    echo "Compliance: PASSED" >> cis_compliance_check.txt
else
    echo "/etc/gshadow- permissions are not correctly set" >> cis_compliance_check.txt
    echo "Compliance: FAILED" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.11" >> cis_compliance_check.txt
echo "Ensure no world writable files exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check world-writable files on a specific partition
check_world_writable_files() {
    local partition="$1"
    local output
    output=$(find "$partition" -xdev -type f -perm -0002 2>/dev/null)

    # Check if any world-writable files are found
    if [ -z "$output" ]; then
        return 0  # No world-writable files found
    else
        echo "World-writable files found on partition: $partition" >> cis_compliance_check.txt
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # World-writable files found
    fi
}

# Retrieve list of partitions
partitions=$(df -P | awk '{if (NR!=1) print $6}')

# Loop through each partition and check for world-writable files
compliant=true
for partition in $partitions; do
    if check_world_writable_files "$partition"; then
        echo "No world-writable files found on partition: $partition" >> cis_compliance_check.txt
    else
        compliant=false
    fi
done

# Determine overall compliance status
if $compliant; then
    echo "PASSED: No world writable files exist" >> cis_compliance_check.txt
else
    echo "FAILED: World writable files exist on one or more partitions" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.12" >> cis_compliance_check.txt
echo "Ensure no unowned files or directories exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check unowned files or directories on a specific partition
check_unowned_items() {
    local partition="$1"
    local output
    output=$(find "$partition" -xdev \( -type f -o -type d \) -nouser 2>/dev/null)

    # Check if any unowned files or directories are found
    if [ -z "$output" ]; then
        return 0  # No unowned items found
    else
        echo "Unowned files or directories found on partition: $partition" >> cis_compliance_check.txt
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Unowned items found
    fi
}

# Retrieve list of partitions
partitions=$(df -P | awk '{if (NR!=1) print $6}')

# Loop through each partition and check for unowned files or directories
compliant=true
for partition in $partitions; do
    if check_unowned_items "$partition"; then
        echo "No unowned files or directories found on partition: $partition" >> cis_compliance_check.txt
    else
        compliant=false
    fi
done

# Determine overall compliance status
if $compliant; then
    echo "PASSED: No unowned files or directories exist" >> cis_compliance_check.txt
else
    echo "FAILED: Unowned files or directories exist on one or more partitions" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.1.13" >> cis_compliance_check.txt
echo "Ensure no ungrouped files or directories exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check ungrouped files or directories on a specific partition
check_ungrouped_items() {
    local partition="$1"
    local output
    output=$(find "$partition" -xdev \( -type f -o -type d \) -nogroup 2>/dev/null)

    # Check if any ungrouped files or directories are found
    if [ -z "$output" ]; then
        return 0  # No ungrouped items found
    else
        echo "Ungrouped files or directories found on partition: $partition" >> cis_compliance_check.txt
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Ungrouped items found
    fi
}

# Retrieve list of partitions
partitions=$(df -P | awk '{if (NR!=1) print $6}')

# Loop through each partition and check for ungrouped files or directories
compliant=true
for partition in $partitions; do
    if check_ungrouped_items "$partition"; then
        echo "No ungrouped files or directories found on partition: $partition" >> cis_compliance_check.txt
    else
        compliant=false
    fi
done

# Determine overall compliance status
if $compliant; then
    echo "PASSED: No ungrouped files or directories exist" >> cis_compliance_check.txt
else
    echo "FAILED: Ungrouped files or directories exist on one or more partitions" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.1" >> cis_compliance_check.txt
echo "Ensure password fields are not empty" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

check_empty_passwords() {
    local output
    output=$(awk -F: '($2 == "") { print $1 " does not have a password "}' /etc/shadow)
    
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No users found with empty password fields in /etc/shadow" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for empty password fields in /etc/shadow
if check_empty_passwords; then
    echo "PASSED: No users found with empty password fields in /etc/shadow" >> cis_compliance_check.txt
else
    echo "FAILED: Users found with empty password fields in /etc/shadow" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_empty_passwords; then
    echo "PASSED: All password fields in /etc/shadow are non-empty" >> cis_compliance_check.txt
else
    echo "FAILED: Some password fields in /etc/shadow are empty" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.2" >> cis_compliance_check.txt
echo "Ensure all groups in /etc/passwd exist in /etc/group" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check if all groups in /etc/passwd exist in /etc/group
check_groups_existence() {
    local groups_not_found=""
    
    for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
        if ! grep -q -P "^.*?:[^:]*:$i:" /etc/group; then
            groups_not_found+="Group $i is referenced by /etc/passwd but does not exist in /etc/group"$'\n'
        fi
    done
    
    if [ -z "$groups_not_found" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "All groups in /etc/passwd exist in /etc/group" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$groups_not_found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check if all groups in /etc/passwd exist in /etc/group
if check_groups_existence; then
    echo "PASSED: All groups in /etc/passwd exist in /etc/group" >> cis_compliance_check.txt
else
    echo "FAILED: Some groups in /etc/passwd do not exist in /etc/group" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_groups_existence; then
    echo "PASSED: All groups in /etc/passwd exist in /etc/group" >> cis_compliance_check.txt
else
    echo "FAILED: Some groups in /etc/passwd do not exist in /etc/group" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.3" >> cis_compliance_check.txt
echo "Ensure no duplicate UIDs exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for duplicate UIDs in /etc/passwd
check_duplicate_uids() {
    local duplicates_found=""
    
    cut -f3 -d":" /etc/passwd | sort -n | uniq -c | while read x ; do
        [ -z "$x" ] && break
        set - $x
        if [ $1 -gt 1 ]; then
            users=$(awk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd | xargs)
            duplicates_found+="Duplicate UID ($2): $users"$'\n'
        fi
    done
    
    if [ -z "$duplicates_found" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No duplicate UIDs found in /etc/passwd" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$duplicates_found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for duplicate UIDs in /etc/passwd
if check_duplicate_uids; then
    echo "PASSED: No duplicate UIDs found in /etc/passwd" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate UIDs found in /etc/passwd" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_duplicate_uids; then
    echo "PASSED: No duplicate UIDs found in /etc/passwd" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate UIDs found in /etc/passwd" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.4" >> cis_compliance_check.txt
echo "Ensure no duplicate GIDs exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for duplicate GIDs in /etc/group
check_duplicate_gids() {
    local duplicates_found=""
    
    cut -d: -f3 /etc/group | sort | uniq -d | while read x ; do
        duplicates_found+="Duplicate GID ($x) in /etc/group"$'\n'
    done
    
    if [ -z "$duplicates_found" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No duplicate GIDs found in /etc/group" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$duplicates_found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for duplicate GIDs in /etc/group
if check_duplicate_gids; then
    echo "PASSED: No duplicate GIDs found in /etc/group" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate GIDs found in /etc/group" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_duplicate_gids; then
    echo "PASSED: No duplicate GIDs found in /etc/group" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate GIDs found in /etc/group" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.5" >> cis_compliance_check.txt
echo "Ensure no duplicate user names exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for duplicate user names in /etc/passwd
check_duplicate_usernames() {
    local duplicates_found=""
    
    cut -d: -f1 /etc/passwd | sort | uniq -d | while read x; do
        duplicates_found+="Duplicate login name ${x} in /etc/passwd"$'\n'
    done
    
    if [ -z "$duplicates_found" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No duplicate user names found in /etc/passwd" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$duplicates_found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for duplicate user names in /etc/passwd
if check_duplicate_usernames; then
    echo "PASSED: No duplicate user names found in /etc/passwd" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate user names found in /etc/passwd" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_duplicate_usernames; then
    echo "PASSED: No duplicate user names found in /etc/passwd" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate user names found in /etc/passwd" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.6" >> cis_compliance_check.txt
echo "Ensure no duplicate group names exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for duplicate group names in /etc/group
check_duplicate_group_names() {
    local duplicates_found=""
    
    cut -d: -f1 /etc/group | sort | uniq -d | while read -r x; do
        duplicates_found+="Duplicate group name ${x} in /etc/group"$'\n'
    done
    
    if [ -z "$duplicates_found" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No duplicate group names found in /etc/group" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$duplicates_found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for duplicate group names in /etc/group
if check_duplicate_group_names; then
    echo "PASSED: No duplicate group names found in /etc/group" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate group names found in /etc/group" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_duplicate_group_names; then
    echo "PASSED: No duplicate group names found in /etc/group" >> cis_compliance_check.txt
else
    echo "FAILED: Duplicate group names found in /etc/group" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.7" >> cis_compliance_check.txt
echo "Ensure root PATH Integrity" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check root PATH integrity
check_root_path_integrity() {
    local RPCV
    RPCV=$(sudo -Hiu root env | grep '^PATH=' | cut -d= -f2)
    
    local errors_found=""
    
    echo "$RPCV" | grep -q "::" && errors_found+="root's path contains an empty directory (::)"$'\n'
    echo "$RPCV" | grep -q ":$" && errors_found+="root's path contains a trailing (:)"$'\n'
    
    echo "$RPCV" | tr ":" " " | while read -r x; do
        if [ -d "$x" ]; then
            # Check for conditions inside each directory in PATH
            ls -ldH "$x" | awk '
                $9 == "." {print "PATH contains current working directory (.)"}
                $3 != "root" {print $9, "is not owned by root"}
                substr($1,6,1) != "-" {print $9, "is group writable"}
                substr($1,9,1) != "-" {print $9, "is world writable"}
            '
        else
            errors_found+="$x is not a directory"$'\n'
        fi
    done
    
    if [ -z "$errors_found" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No issues found with root's PATH integrity" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$errors_found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check root PATH integrity
if check_root_path_integrity; then
    echo "PASSED: No issues found with root's PATH integrity" >> cis_compliance_check.txt
else
    echo "FAILED: Issues found with root's PATH integrity" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_root_path_integrity; then
    echo "PASSED: No issues found with root's PATH integrity" >> cis_compliance_check.txt
else
    echo "FAILED: Issues found with root's PATH integrity" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.8" >> cis_compliance_check.txt
echo "Ensure root is the only UID 0 account" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for other UID 0 accounts
check_uid_0_accounts() {
    local output
    output=$(awk -F: '($3 == 0 && $1 != "root") { print $1 }' /etc/passwd)
    
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No accounts found with UID 0 other than root" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for other UID 0 accounts
if check_uid_0_accounts; then
    echo "PASSED: No accounts found with UID 0 other than root" >> cis_compliance_check.txt
else
    echo "FAILED: Accounts found with UID 0 other than root" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_uid_0_accounts; then
    echo "PASSED: Only root has UID 0 account" >> cis_compliance_check.txt
else
    echo "FAILED: Accounts other than root have UID 0" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.9" >> cis_compliance_check.txt
echo "Ensure all users' home directories exist" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for existence of home directories
check_home_directories_exist() {
    local output
    output=$(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) { print $1 " " $6 }' /etc/passwd | while read -r user dir; do
        if [ ! -d "$dir" ]; then
            echo "User: \"$user\" home directory: \"$dir\" does not exist."
        fi
    done)
    
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "All users' home directories exist" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for existence of home directories
if check_home_directories_exist; then
    echo "PASSED: All users' home directories exist" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' home directories do not exist" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_home_directories_exist; then
    echo "PASSED: All users' home directories exist" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' home directories do not exist" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.10" >> cis_compliance_check.txt
echo "Ensure users own their home directories" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check ownership of home directories
check_home_directory_ownership() {
    local output
    local output2

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ ! -d "$dir" ]; then
            # Log users whose home directories don't exist
            [ -z "$output2" ] && output2="The following users' home directories don't exist: \"$user\"" || output2="$output2, \"$user\""
        else
            # Check ownership of the home directory
            owner="$(stat -L -c "%U" "$dir")"
            if [ "$owner" != "$user" ] && [ "$owner" != "root" ]; then
                # Log users whose home directories are not owned by themselves or root
                [ -z "$output" ] && output="The following users don't own their home directory: \"$user\" home directory is owned by \"$owner\"" || output="$output, \"$user\" home directory is owned by \"$owner\""
            fi
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "All users own their home directories or their directories do not exist" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "$output2" >> cis_compliance_check.txt
        echo "$output" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check ownership of home directories
if check_home_directory_ownership; then
    echo "PASSED: All users own their home directories or their directories do not exist" >> cis_compliance_check.txt
else
    echo "FAILED: Some users do not own their home directories" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_home_directory_ownership; then
    echo "PASSED: All users own their home directories or their directories do not exist" >> cis_compliance_check.txt
else
    echo "FAILED: Some users do not own their home directories" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.11" >> cis_compliance_check.txt
echo "Ensure users' home directories permissions are 750 or more restrictive" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions of home directories
check_home_directory_permissions() {
    local output

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ ! -d "$dir" ]; then
            echo "User: \"$user\" home directory: \"$dir\" doesn't exist" >> cis_compliance_check.txt
        else
            dirperm=$(stat -L -c "%A" "$dir")
            if [ "$(echo "$dirperm" | cut -c6)" != "-" ] || [ "$(echo "$dirperm" | cut -c8)" != "-" ] || [ "$(echo "$dirperm" | cut -c9)" != "-" ]; then
                echo "User: \"$user\" home directory: \"$dir\" has permissions: \"$dirperm\"" >> cis_compliance_check.txt
                output=1
            fi
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "All users' home directories have permissions of 750 or more restrictive" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check permissions of home directories
if check_home_directory_permissions; then
    echo "PASSED: All users' home directories have permissions of 750 or more restrictive" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' home directories do not have permissions of 750 or more restrictive" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_home_directory_permissions; then
    echo "PASSED: All users' home directories have permissions of 750 or more restrictive" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' home directories do not have permissions of 750 or more restrictive" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.12" >> cis_compliance_check.txt
echo "Ensure users' dot files are not group or world writable" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions of dot files in users' home directories
check_dot_file_permissions() {
    local output

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ -d "$dir" ]; then
            # Loop through each dot file in the user's home directory
            for file in "$dir"/.[^.]*; do
                if [ ! -h "$file" ] && [ -f "$file" ]; then
                    fileperm=$(stat -L -c "%A" "$file")
                    if [ "$(echo "$fileperm" | cut -c6)" != "-" ] || [ "$(echo "$fileperm" | cut -c9)" != "-" ]; then
                        echo "User: \"$user\" file: \"$file\" has permissions: \"$fileperm\"" >> cis_compliance_check.txt
                        output=1
                    fi
                fi
            done
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No users' dot files are group or world writable" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check permissions of dot files in users' home directories
if check_dot_file_permissions; then
    echo "PASSED: No users' dot files are group or world writable" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' dot files are group or world writable" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_dot_file_permissions; then
    echo "PASSED: All users' dot files are not group or world writable" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' dot files are group or world writable" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.13" >> cis_compliance_check.txt
echo "Ensure users' .netrc Files are not group or world accessible" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check permissions of .netrc files in users' home directories
check_netrc_permissions() {
    local output

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ -d "$dir" ]; then
            file="$dir/.netrc"
            if [ ! -h "$file" ] && [ -f "$file" ]; then
                fileperm=$(stat -L -c "%A" "$file")
                if ! echo "$fileperm" | grep -q "^-..-------$" && [ "$(stat -L -c "%a" "$file")" -lt 600 ]; then
                    echo "FAILED: User: \"$user\" file: \"$file\" exists with permissions: \"$fileperm\", remove file or adjust permissions" >> cis_compliance_check.txt
                    output=1
                elif ! echo "$fileperm" | grep -q "^-......-------$" && [ "$(stat -L -c "%a" "$file")" -ge 600 ]; then
                    echo "WARNING: User: \"$user\" file: \"$file\" exists with permissions: \"$fileperm\", review file necessity" >> cis_compliance_check.txt
                    output=1
                fi
            fi
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No users' .netrc files found with incorrect permissions" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check permissions of .netrc files in users' home directories
if check_netrc_permissions; then
    echo "PASSED: No users' .netrc files found with incorrect permissions" >> cis_compliance_check.txt
else
    echo "FAILED/WARNING: Some users' .netrc files found with incorrect permissions" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_netrc_permissions; then
    echo "PASSED: All users' .netrc files are compliant" >> cis_compliance_check.txt
else
    echo "FAILED: Some users' .netrc files are not compliant" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.14" >> cis_compliance_check.txt
echo "Ensure no users have .forward files" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for .forward files in users' home directories
check_forward_files() {
    local output

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ -d "$dir" ]; then
            file="$dir/.forward"
            if [ ! -h "$file" ] && [ -f "$file" ]; then
                echo "User: \"$user\" file: \"$file\" exists" >> cis_compliance_check.txt
                output=1
            fi
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No users' .forward files found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for .forward files in users' home directories
if check_forward_files; then
    echo "PASSED: No users have .forward files" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have .forward files" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_forward_files; then
    echo "PASSED: No users have .forward files" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have .forward files" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.15" >> cis_compliance_check.txt
echo "Ensure no users have .netrc files" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for .netrc files in users' home directories
check_netrc_files() {
    local output

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ -d "$dir" ]; then
            file="$dir/.netrc"
            if [ ! -h "$file" ] && [ -f "$file" ]; then
                echo "User: \"$user\" file: \"$file\" exists" >> cis_compliance_check.txt
                output=1
            fi
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No users' .netrc files found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for .netrc files in users' home directories
if check_netrc_files; then
    echo "PASSED: No users have .netrc files" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have .netrc files" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_netrc_files; then
    echo "PASSED: No users have .netrc files" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have .netrc files" >> cis_compliance_check.txt
fi

echo "================================================================================" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt
echo "6.2.16" >> cis_compliance_check.txt
echo "Ensure no users have .rhosts files" >> cis_compliance_check.txt
echo "" >> cis_compliance_check.txt

# Function to check for .rhosts files in users' home directories
check_rhosts_files() {
    local output

    # Loop through each user and their home directory from /etc/passwd
    while IFS=: read -r user dir; do
        if [ -d "$dir" ]; then
            file="$dir/.rhosts"
            if [ ! -h "$file" ] && [ -f "$file" ]; then
                echo "User: \"$user\" file: \"$file\" exists" >> cis_compliance_check.txt
                output=1
            fi
        fi
    done < <(awk -F: '($1!~/(halt|sync|shutdown|nfsnobody)/ && $7!~/^(\/usr)?\/sbin\/nologin(\/)?$/ && $7!~/(\/usr)?\/bin\/false(\/)?$/) {print $1":"$6}' /etc/passwd)

    # Log the output of the verification command
    if [ -z "$output" ]; then
        echo "Output of the verification command:" >> cis_compliance_check.txt
        echo "No users' .rhosts files found" >> cis_compliance_check.txt
        echo "" >> cis_compliance_check.txt
        return 0  # Compliant
    else
        echo "" >> cis_compliance_check.txt
        return 1  # Not compliant
    fi
}

# Check for .rhosts files in users' home directories
if check_rhosts_files; then
    echo "PASSED: No users have .rhosts files" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have .rhosts files" >> cis_compliance_check.txt
fi

# Determine overall compliance status
if check_rhosts_files; then
    echo "PASSED: No users have .rhosts files" >> cis_compliance_check.txt
else
    echo "FAILED: Some users have .rhosts files" >> cis_compliance_check.txt
fi

#Display the result
cat cis_compliance_check.txt
