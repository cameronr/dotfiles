
# Optional: Override 'cd' so you can use your usual habits
Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })

Import-Module PSFzf

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'


# Remove ugly blue background on ls
$PSStyle.FileInfo.Directory = ""

# normal dir listing
if (Get-Alias ls -ErrorAction SilentlyContinue) {
    Remove-Item Alias:ls
}
function ls { Get-ChildItem | Format-Wide -Column 4 }

# long listing
function l {
    Get-ChildItem @args
}
