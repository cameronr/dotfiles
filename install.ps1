
winget install ajeetdsouza.zoxide
winget install fzf

Install-Module -Name PSFzf -Scope CurrentUser -Force

if (-not (Test-Path $PROFILE)) { New-Item -ItemType SymbolicLink -Path $PROFILE -Target "$HOME\dotfiles\PowerShell\profile.ps1" }
