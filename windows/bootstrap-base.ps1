Echo "=== Bootstrapping workstation ==="

# Powertoys  
winget install Microsoft.Powertoys  
if ($?) {
    Echo "=== Powertoys installed successfully ==="
}
 
# Terminal
winget install Microsoft.WindowsTerminal
if ($?) {
    Echo "=== Windows Terminal installed successfully ==="
}

# VS Code
winget install Microsoft.VisualStudioCode
if ($?) {
    Echo "=== Windows Terminal installed successfully ==="
}

# Sublime
winget install SublimeHQ.SublimeText
if ($?) {
    Echo "=== Sublime Text installed successfully ==="
}

# KeePass
winget install DominikReichl.KeePass
if ($?) {
    Echo "=== KeePass installed successfully ==="
}

