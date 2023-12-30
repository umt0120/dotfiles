New-Item -ItemType SymbolicLink -Path $env:XDG_CONFIG_HOME\.vimrc -Target ((Convert-Path . ) + ".\gvim\.vimrc")
New-Item -ItemType SymbolicLink -Path $env:XDG_CONFIG_HOME\.gvimrc -Target ((Convert-Path . ) + ".\gvim\.gvimrc")
New-Item -ItemType SymbolicLink -Path $env:XDG_CONFIG_HOME\.vsvimrc -Target ((Convert-Path . ) + ".\vscode\.vsvimrc")
