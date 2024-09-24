echo "Removing all resources"

az group delete --name rg-kofoedcloud-shared --yes --no-wait
az group delete --name rg-drueriket --yes --no-wait