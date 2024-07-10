#!/bin/bash

# Create resource group
az group create --name rg-oracle --location westeurope
echo "Resource group created successfully"

# Create virtual machine
az vm create --name vmoracle19c --resource-group rg-oracle --image Oracle:oracle-database-19-3:oracle-database-19-0904:latest --size Standard_D2s_v3 --admin-username azureuser --generate-ssh-keys --public-ip-address-allocation static --public-ip-address-dns-name vmoracle19c-5507
echo "Virtual machine created successfully"

# Create disk for Oracle data files
az vm disk attach --name oradata01 --new --resource-group rg-oracle --size-gb 64 --sku StandardSSD_LRS --vm-name vmoracle19c
echo "Disk for Oracle data files created successfully"

# Open ports for connectivity
az network nsg create --resource-group rg-oracle --name vmoracle19cNSG
echo "Network security group created successfully"
az network nsg rule create --resource-group rg-oracle --nsg-name vmoracle19cNSG --name allow-oracle --protocol tcp --priority 1001 --destination-port-range 1521
# used to listeners
echo "Network security group rule for Oracle created successfully"
az network nsg rule create --resource-group rg-oracle --nsg-name vmoracle19cNSG --name allow-oracle-EM --protocol tcp --priority 1002 --destination-port-range 5502
# used for Oracle Enterprise manager (monitoring, perfomrmance management)
echo "Network security group rule for Oracle EM created successfully"

### add ssh
# Create an inbound security rule to allow SSH access on port 22
az network nsg rule create --resource-group rg-oracle --nsg-name vmoracle19cNSG --name allow-ssh --protocol Tcp --direction Inbound --priority 100 --source-address-prefix '*' --source-port-range '*' --destination-address-prefix '*' --destination-port-range 22 --access Allow --description "Allow SSH access"
echo "Inbound security rule for SSH access on port 22 created successfully"

# Retrieve public IP address
public_ip=$(az network public-ip show --resource-group rg-oracle --name vmoracle19cPublicIP --query "ipAddress" --output tsv)
echo "ip assigned"

# Prepare VM environment
# SSH session with the VM
ssh azureuser@"$public_ip"
echo "entered with ssh"

# Switch to the root user
sudo su -
echo "entered as root"







# Format disk for Oracle data files
echo "Formatting disk label for Oracle data files"
parted /dev/sdc mklabel gpt

echo "Creating primary partition for Oracle data files"
parted -a optimal /dev/sdc mkpart primary 0GB 64GB

echo "Printing disk details"
parted /dev/sdc print

echo "Creating ext4 filesystem on the partition"
mkfs -t ext4 /dev/sdc1

echo "Creating directory for mounting the disk"
mkdir /u02

echo "Mounting the disk to /u02"
mount /dev/sdc1 /u02

echo "Setting permissions for /u02"
chmod 777 /u02

echo "Updating /etc/fstab file for automatic mount"
echo "/dev/sdc1 /u02 ext4 defaults 0 0" >> /etc/fstab


# Update the /etc/hosts file
echo "$public_ip vmoracle19c.westeurope.cloudapp.azure.com vmoracle19c" >> /etc/hosts
echo "Update of the /etc/hosts file"

# Add domain name of the VM to the /etc/hostname file
sed -i 's/$/\.westeurope\.cloudapp\.azure\.com &/' /etc/hostname

# Open firewall ports
firewall-cmd --zone=public --add-port=1521/tcp --permanent
echo "Open FW1"

firewall-cmd --zone=public --add-port=5502/tcp --permanent
echo "Open FW2"

firewall-cmd --reload
echo "reload FW"

# did work




# Switch to the oracle user and execute commands as the oracle user
sudo su - oracle
echo "switch to oracle user"

# Start the database listener
echo "Starting the database listener"
lsnrctl start

# Create a data directory for the Oracle data files
echo "Creating a data directory for the Oracle data files"
mkdir /u02/oradata

# Run the Database Creation Assistant to create the database
echo "Running the Database Creation Assistant to create the database"
dbca -silent \
    -createDatabase \
    -templateName General_Purpose.dbc \
    -gdbname oratest1 \
    -sid oratest1 \
    -responseFile NO_VALUE \
    -characterSet AL32UTF8 \
    -sysPassword OraPasswd1 \
    -systemPassword OraPasswd1 \
    -createAsContainerDatabase false \
    -databaseType MULTIPURPOSE \
    -automaticMemoryManagement false \
    -storageType FS \
    -datafileDestination "/u02/oradata/" \
    -ignorePreReqs

# Set Oracle variables
echo "Setting Oracle variables"
export ORACLE_SID=oratest1
echo "export ORACLE_SID=oratest1" >> ~oracle/.bashrc






### somewhere ~ sudo su, there's a lack of a command 

# send files to sudo and oracle users
