terraform {
  backend "azurerm" {
    storage_account_name = "aztfdemobackendstorage"  # Replace with your storage account name
    container_name       = "backend"  # Replace with your container name
    key                  = "terraform.tfstate"
    access_key           = "Add your storage account access key here"
  }
}