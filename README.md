# oracle_db_installation_steps

Run file:  
```
deploy-vm.sh
```
```
#!/bin/bash
az group create --name rg-oracle --location eastus
```
```
chmod +x deploy-vm.sh
```
```
./deploy-vm.sh
```



source is here: https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/oracle/oracle-database-quick-create

Steps 

az group create --name rg-oracle --location westeurope

az vm create --name vmoracle19c --resource-group rg-oracle --image Oracle:oracle-database-19-3:oracle-database-19-0904:latest --size Standard_D2s_v3 --admin-username azureuser --generate-ssh-keys --public-ip-address-allocation static --public-ip-address-dns-name vmoracle19c-5507


// ip: 
52.232.21.127
52.236.175.7

az vm disk attach --name oradata01 --new --resource-group rg-oracle --size-gb 64 --sku StandardSSD_LRS --vm-name vmoracle19c

az network nsg create --resource-group rg-oracle --name vmoracle19cNSG

az network nsg rule create --resource-group rg-oracle --nsg-name vmoracle19cNSG --name allow-oracle --protocol tcp --priority 1001 --destination-port-range 1521

az network nsg rule create --resource-group rg-oracle --nsg-name vmoracle19cNSG --name allow-oracle-EM --protocol tcp --priority 1002 --destination-port-range 5502

vm -> NSG -> add -> 22
	(NSG): Determine the NSG associated with your Azure virtual machine. You can find this in the Azure Portal under the "Networking" section of your virtual machine's settings.

	Inbound Rule: Add an rule to the NSG to allow traffic on port 22. You can do this in the NSG settings by creating a new inbound security rule with the following settings:

	Source: You can specify the source IP address range from which you want to allow SSH access. If you want to allow SSH access from any IP address, you can use * as the source.
	Source Port Range: Use * to allow traffic from any source port.
	Destination: Use * to allow traffic to any destination.
	Destination Port Range: Specify 22 to allow traffic on port 22 (SSH).
	Protocol: Select TCP as the protocol.
	Action: Set the action to Allow.

Prepare VM environment
https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/oracle/oracle-database-quick-create
ssh azureuser@<publicIPAddress>
ssh azureuser@52.236.175.7
echo "52.236.175.7 vmoracle19c.eastus.cloudapp.azure.com vmoracle19c" >> /etc/hosts


dbca -silent \
    -createDatabase \
    -templateName General_Purpose.dbc \
    -gdbname oratest1 \
    -sid oratest1 \
    -responseFile NO_VALUE \
    -characterSet AL32UTF8 \
    -sysPassword 123456 \
    -systemPassword 123456 \
    -createAsContainerDatabase false \
    -databaseType MULTIPURPOSE \
    -automaticMemoryManagement false \
    -storageType FS \
    -datafileDestination "/u02/oradata/" \
    -ignorePreReqs


```
sqlplus / as sysdba  
```
```
select instance_name,status from v$instance;  
```
```
startup  
```
   but it's already running
```
shutdown
```
```
startup
```
```
exit
```

[Migration with DataPump](https://docs.oracle.com/en/cloud/paas/exadata-cloud/csexa/mig-data-pump-conventional.html#GUID-96DBC823-E990-4CB7-B842-5BF8BB78946C)

