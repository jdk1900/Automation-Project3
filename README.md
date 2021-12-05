# Automation-Project3

This solution demonstrates the way we can use automation in order to backup all application gateways we have in our subscription (but of course it could be VMs, keyvaults ctr).
It is well known that when an Azure service is been created, a configuration file (json) is also created along with the service.
More specifically,in this solution, the YAML pipeline will run every day at 12:00 midnight,it will export all application gateways in json format,upload json files on a container in a storage account in Azure and finally it will create a task in Azure DevOps Board.This way we can have an interaction between our Azure platform environment and Azure DevOps environment.

What we will use:
1) A storage account with a container where the backup files will be stored.
2) A Powershell script (for the backup process).
3) A Powershell script (for creating the work item in the Azure DevOps Boards).
4) A YAML pipeline.
