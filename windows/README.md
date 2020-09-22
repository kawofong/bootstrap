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

1. Refer to `windows-terminal-settings.json` in repo for Winfows Terminal configurations

1. Install [WSL 2](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

1. Add following text to `/etc/wsl.conf` (create `wsl.conf` if it doesn't exist)
    ```text
    [automount]
    options = "metadata"
    ```

1. Restart WSL 2 session

1. Install [Lightshot](https://app.prntscr.com/en/index.html) 

## Reference

- [Have a great looking terminal and a more effective shell with Oh my Zsh on WSL 2 using Windows](https://pascalnaber.wordpress.com/2019/10/05/have-a-great-looking-terminal-and-a-more-effective-shell-with-oh-my-zsh-on-wsl-2-using-windows/)