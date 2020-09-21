Echo "=== Installing Microsoft apps ==="

# Teams
#winget install Microsoft.Teams
#if ($?) {
#    Echo "=== Microsoft Teams installed successfully ==="
#}

# Power BI  
winget install Microsoft.PowerBI 
if ($?) {
    Echo "=== Power BI installed successfully ==="
}

# Azure Storage Explorer
winget install Microsoft.AzureStorageExplorer
if ($?) {
    Echo "=== Azure Storage Explorer installed successfully ==="
}

# Azure Data Studio
winget install Microsoft.AzureDataStudio
if ($?) {
    Echo "=== Azure Data Studio installed successfully ==="
}

# Azure Cosmos Emulator
winget install Microsoft.AzureCosmosEmulator
if ($?) {
    Echo "=== Azure Cosmos Emulator installed successfully ==="
}

