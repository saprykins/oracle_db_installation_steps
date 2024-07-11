# Creation of Oracle in Azure  
[Prepare VM environment](https://learn.microsoft.com/en-us/azure/virtual-machines/workloads/oracle/oracle-database-quick-create)

# Creation of Oracle with .sh-script  
```
deploy-vm.sh
```
Example of .sh file below:  
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



# Oracle usage:  
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

# More details  
[Migration with DataPump](https://docs.oracle.com/en/cloud/paas/exadata-cloud/csexa/mig-data-pump-conventional.html#GUID-96DBC823-E990-4CB7-B842-5BF8BB78946C)

