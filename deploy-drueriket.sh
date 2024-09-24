dotnet publish src/drueriket/drueriket.csproj -c Release -o ./publish
cd publish
zip -r publish.zip .

az webapp deploy --resource-group rg-drueriket --name 'drueriket' --src-path publish.zip --type zip

cd ..


