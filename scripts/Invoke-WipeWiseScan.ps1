#Requires -Version 5.1
<#
.SYNOPSIS
    WipeWise read-only scanner. Reports the current user's personal data and
    usage traces on a Windows 10/11 PC, grouped by category, as JSON.

.DESCRIPTION
    This script is STRICTLY READ-ONLY. It inspects files, folders, registry
    keys, and read-only command output (netsh wlan show profiles, cmdkey /list)
    to estimate what exists. It never deletes, moves, overwrites, formats, or
    writes to the registry. The only thing it writes is its own JSON report, to
    -OutFile or stdout.

    It is designed to run under Windows PowerShell 5.1 and PowerShell 7+, with or
    without Administrator rights. A few system locations report fuller sizes only
    when elevated; those items are flagged "needsAdmin": true.

.PARAMETER OutFile
    Path to write the JSON report. If omitted, JSON is written to stdout.

.PARAMETER Quick
    Skip deep folder sizing (existence + top-level count only). Much faster.

.PARAMETER ListProbes
    Print the category/probe plan and exit. Runs nothing against the system.

.NOTES
    WipeWise v0.1. Apache-2.0. No network access. No writes other than -OutFile.
#>
[CmdletBinding()]
param(
    [string]$OutFile,
    [switch]$Quick,
    [switch]$ListProbes
)

$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference    = 'SilentlyContinue'

# --- helpers (all read-only) ------------------------------------------------

function Expand-WwPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $Path }
    return [Environment]::ExpandEnvironmentVariables($Path)
}

function Test-WwAdmin {
    try {
        $id = [Security.Principal.WindowsIdentity]::GetCurrent()
        $p  = New-Object Security.Principal.WindowsPrincipal($id)
        return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch { return $false }
}

function Measure-WwTree {
    # Read-only size/count for a folder. Skips reparse points (junctions/symlinks)
    # at the top level so we do not wander onto other volumes or cloud placeholders.
    param([string]$Path, [switch]$Quick)
    $r = [ordered]@{ exists = $false; files = 0; bytes = 0; examples = @() }
    $p = Expand-WwPath $Path
    if (-not (Test-Path -LiteralPath $p)) { return $r }
    $r.exists = $true
    try {
        $top = Get-ChildItem -LiteralPath $p -Force -ErrorAction SilentlyContinue
        $r.examples = @(
            $top | Sort-Object LastWriteTime -Descending |
                Select-Object -First 3 | ForEach-Object { $_.Name }
        )
    } catch {}
    if ($Quick) {
        try { $r.files = @($top).Count } catch {}
        return $r
    }
    try {
        $sum = 0L; $cnt = 0
        $files = Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { -not ($_.Attributes -band [IO.FileAttributes]::ReparsePoint) }
        foreach ($f in $files) { $sum += [int64]$f.Length; $cnt++ }
        $r.files = $cnt
        $r.bytes = $sum
    } catch {}
    return $r
}

function Get-WwRegCount {
    # Read-only count of values/subkeys under a registry path (PSDrive form, e.g. HKCU:\...).
    param([string]$Path)
    $r = [ordered]@{ exists = $false; values = 0; subkeys = 0 }
    try {
        $k = Get-Item -LiteralPath $Path -ErrorAction SilentlyContinue
        if ($k) {
            $r.exists  = $true
            $r.values  = [int]$k.ValueCount
            $r.subkeys = [int]$k.SubKeyCount
        }
    } catch {}
    return $r
}

function Get-WwWifiCount {
    # Read-only: number of saved Wi-Fi profiles. netsh ... show profiles does not reveal keys.
    try {
        $out = & netsh.exe wlan show profiles 2>$null
        if (-not $out) { return 0 }
        return @($out | Select-String -SimpleMatch 'All User Profile', 'User Profile').Count
    } catch { return 0 }
}

function Get-WwCredCount {
    # Read-only: number of stored Windows credentials. cmdkey /list only lists, does not reveal secrets.
    try {
        $out = & cmdkey.exe /list 2>$null
        if (-not $out) { return 0 }
        return @($out | Select-String -SimpleMatch 'Target:').Count
    } catch { return 0 }
}

function New-WwItem {
    param([string]$Name, [string]$Path, [hashtable]$Measure, [string]$Note, [switch]$NeedsAdmin)
    $o = [ordered]@{
        name      = $Name
        path      = $Path
        exists    = [bool]$Measure.exists
        files     = [int]$Measure.files
        bytes     = [int64]$Measure.bytes
        examples  = @($Measure.examples)
        needsAdmin= [bool]$NeedsAdmin
        note      = $Note
    }
    return [pscustomobject]$o
}

# --- probe plan (declarative, human-reviewable) -----------------------------
# Each folder probe: @{ name; path (env vars ok); note; needsAdmin }
$FolderProbes = @{
    'personal-files' = @(
        @{ name='Desktop';   path='%USERPROFILE%\Desktop' }
        @{ name='Documents'; path='%USERPROFILE%\Documents' }
        @{ name='Downloads'; path='%USERPROFILE%\Downloads' }
        @{ name='Pictures';  path='%USERPROFILE%\Pictures' }
        @{ name='Videos';    path='%USERPROFILE%\Videos' }
        @{ name='Music';     path='%USERPROFILE%\Music' }
        @{ name='Favorites'; path='%USERPROFILE%\Favorites' }
        @{ name='OneDrive (local copy)'; path='%USERPROFILE%\OneDrive'; note='Cloud-synced. Stop sync before deleting local files, or the cloud copy is deleted too.' }
    )
    'browsers' = @(
        @{ name='Edge profile';    path='%LOCALAPPDATA%\Microsoft\Edge\User Data' }
        @{ name='Chrome profile';  path='%LOCALAPPDATA%\Google\Chrome\User Data' }
        @{ name='Brave profile';   path='%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data' }
        @{ name='Firefox profiles';path='%APPDATA%\Mozilla\Firefox\Profiles' }
        @{ name='Opera profile';   path='%APPDATA%\Opera Software\Opera Stable' }
    )
    'app-data' = @(
        @{ name='Microsoft Teams (new)'; path='%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe' }
        @{ name='Slack';    path='%APPDATA%\Slack' }
        @{ name='Discord';  path='%APPDATA%\discord' }
        @{ name='WhatsApp (Store)'; path='%LOCALAPPDATA%\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm' }
        @{ name='Telegram'; path='%APPDATA%\Telegram Desktop' }
        @{ name='Signal';   path='%APPDATA%\Signal' }
        @{ name='Zoom';     path='%APPDATA%\Zoom' }
        @{ name='Outlook data (classic)'; path='%LOCALAPPDATA%\Microsoft\Outlook' }
    )
    'credentials' = @(
        @{ name='DPAPI master keys'; path='%APPDATA%\Microsoft\Protect' }
        @{ name='Credential files';  path='%APPDATA%\Microsoft\Credentials' }
        @{ name='Vault';             path='%LOCALAPPDATA%\Microsoft\Vault' }
        @{ name='SSH keys';          path='%USERPROFILE%\.ssh' }
        @{ name='AWS credentials';   path='%USERPROFILE%\.aws' }
        @{ name='Azure CLI';         path='%USERPROFILE%\.azure' }
        @{ name='Kubernetes config'; path='%USERPROFILE%\.kube' }
        @{ name='PowerShell history';path='%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine' }
    )
    'activity-traces' = @(
        @{ name='Recent items';  path='%APPDATA%\Microsoft\Windows\Recent' }
        @{ name='Jump lists (auto)'; path='%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations' }
        @{ name='Jump lists (custom)'; path='%APPDATA%\Microsoft\Windows\Recent\CustomDestinations' }
        @{ name='Clipboard history'; path='%LOCALAPPDATA%\Microsoft\Windows\Clipboard' }
        @{ name='Activity history DB'; path='%LOCALAPPDATA%\ConnectedDevicesPlatform' }
    )
    'recall-copilot' = @(
        @{ name='Recall store (Copilot+ PC)'; path='%LOCALAPPDATA%\CoreAIPlatform.00'; note='Only present on Copilot+ PCs with Recall enabled. Remove via Settings > Privacy & security > Recall & snapshots.' }
    )
    'system-traces' = @(
        @{ name='User temp';       path='%TEMP%' }
        @{ name='Windows temp';    path='%WINDIR%\Temp'; needsAdmin=$true }
        @{ name='Prefetch';        path='%WINDIR%\Prefetch'; needsAdmin=$true; note='Reset-this-PC removes it; a per-trace reference.' }
        @{ name='Windows.old';     path='%SystemDrive%\Windows.old'; needsAdmin=$true; note='Previous Windows, may hold a prior user profile.' }
        @{ name='Error reports';   path='%LOCALAPPDATA%\Microsoft\Windows\WER' }
    )
}

# --- build the plan ---------------------------------------------------------
$plan = @(
    @{ id='personal-files';  title='Personal files';            desc='Files in your profile folders and local cloud-sync folders.' }
    @{ id='browsers';        title='Browser data';              desc='History, cookies, saved passwords, autofill and cache per browser.' }
    @{ id='app-data';        title='App data and messages';     desc='Local data and caches for messaging, mail and meeting apps.' }
    @{ id='credentials';     title='Saved credentials & keys';  desc='Windows credentials, Wi-Fi keys, developer and cloud secrets.' }
    @{ id='activity-traces'; title='Activity history';          desc='Recent items, jump lists, clipboard and activity history.' }
    @{ id='recall-copilot';  title='Recall & Copilot';          desc='Recall snapshots and Copilot history (Copilot+ PCs).' }
    @{ id='network';         title='Network & credentials list';desc='Saved Wi-Fi profiles and stored Windows credentials (counts).' }
    @{ id='system-traces';   title='System traces';             desc='Temp, Prefetch, error reports, Windows.old and similar.' }
    @{ id='installed-programs'; title='Installed programs';     desc='Programs you may want to sign out of and uninstall.' }
)

if ($ListProbes) {
    $plan | ForEach-Object { '{0,-20} {1}' -f $_.id, $_.title }
    return
}

# --- run ---------------------------------------------------------------------
$isAdmin = Test-WwAdmin
$report = [ordered]@{
    tool        = 'WipeWise'
    version     = '0.1.0'
    mode        = $(if ($Quick) { 'quick' } else { 'full' })
    generatedOn = (Get-Date).ToString('o')
    computer    = $env:COMPUTERNAME
    user        = $env:USERNAME
    elevated    = $isAdmin
    readonly    = $true
    categories  = @()
}

foreach ($cat in $plan) {
    $id    = $cat.id
    $items = @()
    $note  = $null

    if ($FolderProbes.ContainsKey($id)) {
        foreach ($probe in $FolderProbes[$id]) {
            $m = Measure-WwTree -Path $probe.path -Quick:$Quick
            $na = [bool]$probe.needsAdmin
            $items += (New-WwItem -Name $probe.name -Path $probe.path -Measure $m -Note $probe.note -NeedsAdmin:$na)
        }
        # registry MRUs add detail to the activity category
        if ($id -eq 'activity-traces') {
            $mru = @(
                @{ n='RecentDocs';   p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs' }
                @{ n='RunMRU';       p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU' }
                @{ n='TypedPaths';   p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths' }
                @{ n='WordWheelQuery';p='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery' }
            )
            foreach ($r in $mru) {
                $rc = Get-WwRegCount -Path $r.p
                $items += [pscustomobject]([ordered]@{
                    name='Registry: ' + $r.n; path=$r.p; exists=$rc.exists
                    files=[int]$rc.values; bytes=0; examples=@(); needsAdmin=$false
                    note='Registry MRU; counts are value entries.'
                })
            }
        }
    }
    elseif ($id -eq 'network') {
        $wifi = Get-WwWifiCount
        $cred = Get-WwCredCount
        $items += [pscustomobject]([ordered]@{ name='Saved Wi-Fi profiles'; path='netsh wlan'; exists=($wifi -gt 0); files=$wifi; bytes=0; examples=@(); needsAdmin=$false; note='Each profile may store a network key.' })
        $items += [pscustomobject]([ordered]@{ name='Stored Windows credentials'; path='cmdkey /list'; exists=($cred -gt 0); files=$cred; bytes=0; examples=@(); needsAdmin=$false; note='Saved sign-ins for sites, shares and apps.' })
    }
    elseif ($id -eq 'installed-programs') {
        $apps = @()
        $uninstallRoots = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
        foreach ($root in $uninstallRoots) {
            try {
                Get-ItemProperty -Path $root -ErrorAction SilentlyContinue |
                    Where-Object { $_.DisplayName -and -not $_.SystemComponent -and -not $_.ParentKeyName } |
                    ForEach-Object {
                        $apps += [ordered]@{ name=[string]$_.DisplayName; version=[string]$_.DisplayVersion; publisher=[string]$_.Publisher }
                    }
            } catch {}
        }
        $apps = $apps | Sort-Object { $_.name } -Unique
        $note = ('{0} programs found. Sign out and deactivate licenses before uninstalling.' -f @($apps).Count)
        $items = @($apps | ForEach-Object { [pscustomobject]$_ })
    }

    $catBytes = ($items | Where-Object { $_.PSObject.Properties['bytes'] } | Measure-Object -Property bytes -Sum).Sum
    if (-not $catBytes) { $catBytes = 0 }

    $report.categories += [pscustomobject]([ordered]@{
        id          = $id
        title       = $cat.title
        description = $cat.desc
        itemCount   = @($items).Count
        bytes       = [int64]$catBytes
        note        = $note
        items       = $items
    })
}

$json = $report | ConvertTo-Json -Depth 6
if ($OutFile) {
    $json | Out-File -LiteralPath $OutFile -Encoding UTF8
    Write-Host ("WipeWise scan written to {0} (read-only; {1} mode; elevated={2})." -f $OutFile, $report.mode, $isAdmin)
} else {
    $json
}
