New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.vimrc -Target ((Convert-Path . ) + ".\gvim\.vimrc")
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.gvimrc -Target ((Convert-Path . ) + ".\gvim\.gvimrc")
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.vsvimrc -Target ((Convert-Path . ) + ".\vscode\.vsvimrc")
