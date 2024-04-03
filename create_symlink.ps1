New-Item -ItemType SymbolicLink -Path $env:XDG_CONFIG_HOME\.vimrc -Target ((Convert-Path . ) + ".\gvim\.vimrc")
New-Item -ItemType SymbolicLink -Path $env:XDG_CONFIG_HOME\.gvimrc -Target ((Convert-Path . ) + ".\gvim\.gvimrc")
New-Item -ItemType SymbolicLink -Path $env:XDG_CONFIG_HOME\.vsvimrc -Target ((Convert-Path . ) + ".\vscode\.vsvimrc")

# NeoVim用のディレクトリ
$nvimDirectory = "$env:XDG_CONFIG_HOME\nvim"
# ディレクトリが存在しない場合は作成
if (-not (Test-Path -Path $nvimDirectory)) {
    New-Item -ItemType Directory -Path $nvimDirectory
}
# シンボリックリンクを作成
New-Item -ItemType SymbolicLink -Path "$nvimDirectory\init.lua" -Target ((Convert-Path . ) + "\nvim\init.lua")
