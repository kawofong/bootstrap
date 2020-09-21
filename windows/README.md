# Bootstrapping for Windows

1. Install [winget](https://docs.microsoft.com/en-us/windows/package-manager/winget/#install-winget)

1. Download **bootstrap-*.ps1** scripts

1. Open PowerShell

1. Execute below PowerShell command to allow execution of unsigned PowerShell scripts

```Powershell
Set-ExecutionPolicy unrestricted -Scope Process
```

1. Execute downloaded PowerShell scripts

```Powershell
C:\Users\kafong\Downloads\bootstrap-base.ps1
C:\Users\kafong\Downloads\bootstrap-msft.ps1
```
