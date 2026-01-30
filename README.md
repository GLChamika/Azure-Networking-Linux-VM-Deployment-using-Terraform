# Azure Networking and Linux VM using Terraform
<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/c33a761e-ddde-49ae-bac9-8caaaaef5971" />

This project uses **Terraform** to provision Azure infrastructure including:

- Resource Group  
- Virtual Network (VNet)  
- Subnet  
- Network Security Group (NSG) with SSH access  
- Public IP  
- Network Interface (NIC)  
- Ubuntu Linux Virtual Machine  
- Remote Terraform state stored in Azure Blob Storage  

The infrastructure is created using the **AzureRM provider** and follows Infrastructure as Code (IaC) best practices.

---

## 🧱 Architecture

Resources created by this project:

- Azure Resource Group  
- Virtual Network (10.0.0.0/16)  
- Subnet (10.0.2.0/24)  
- Network Security Group (allows SSH on port 22)  
- Public IP (Static)  
- Network Interface  
- Linux VM (Ubuntu 22.04 LTS)  
- SSH public key is stored in Azure (best practice is to use Azure AD login or store SSH keys in a centralized service such as Key Vault)

Note: Terraform state is stored remotely in **Azure Blob Storage** using an Azure backend configuration.

---

## ⚙️ Prerequisites

- Azure Subscription  
- Terraform v1.x installed  
- Azure CLI installed and logged in  
- SSH key pair (RSA) generated  
- Azure Storage Account for remote backend  

---

## 🔐 Backend Configuration (Remote State)

Terraform state is stored in Azure Blob Storage.

```hcl
terraform {
  backend "azurerm" {
    storage_account_name = "Add your blob storage account name here"
    container_name       = "Add container name here" 
    key                  = "terraform.tfstate"
    access_key           = "Add your storage account access key here"
  }
}
```

<img width="1891" height="862" alt="image" src="https://github.com/user-attachments/assets/b7595cb3-c942-4624-bc12-a4751b99c9ca" />


