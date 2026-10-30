#Requires -Version 5.1
<#
.SYNOPSIS
    WipeWise v0.3 Reset - guided, confirmed removal of the files/folders the WipeWise
    scanner found, plus clearing of well-known HKCU history keys, for the categories
    YOU approve. DRY-RUN BY DEFAULT: without -Execute it changes nothing, only prints a plan.

.DESCRIPTION
    Safety model (hardened after two adversarial reviews):
      * Dry-run unless -Execute. Recycle Bin by default; -Mode Delete is permanent.
      * Files/folders: acts ONLY on scan-reported targets in -Categories. Containment -
        every target must resolve UNDER your own profile (%USERPROFILE%); system folders,
        other users, other drives, drive roots are refused. Refuses any target whose leaf
        OR any ANCESTOR is a reparse point (junction/symlink), fail-closed. Recycle also
        refuses a target containing a reparse point in its SUBTREE and one too large for
        the Recycle Bin (would be permanent) - size measured on disk. Delete uses a
        reparse-skipping walk that re-checks each directory at removal time. Refuses
        hiberfil/pagefile and any target containing the scan/report/WipeWise files.
      * Registry: ONLY clears a fixed allowlist of known HKCU user-history keys (Recent/
        Run/Typed MRUs, ComDlg32, TypedURLs, RecentApps, Map Network Drive MRU, UserAssist,
        FeatureUsage, MUICache, ShellBags, and the RDP connection MRUs) - it removes their
        values/subkeys, keeps the anchor key, then verifies it is empty. Everything else
        (HKLM, HKCR, or an app's config / recent-files key) is left as GUIDANCE, never
        auto-changed. ShellBags clearing also resets Explorer folder-view prefs (cosmetic).
      * Cloud-sync refused unless -IncludeCloud (path-based). Admin-only file targets need
        -IncludeAdmin. -Execute also requires -Confirm <this PC's name>.
      * NOT auto-done (guidance only, by design): deleting other user accounts (delete the
        account in Settings instead), other-volume data, and system/admin locations
        outside your profile. The report holds counts/sizes, not your file names.

.NOTES WipeWise v0.3.0. Apache-2.0. EXPERIMENTAL. Always dry-run first; test in a disposable VM before using on real data.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ScanFile,
    [string[]]$Categories,
    [ValidateSet('Recycle', 'Delete')][string]$Mode = 'Recycle',
    [switch]$Execute,
    [string]$Confirm,
    [switch]$IncludeCloud,
    [switch]$IncludeAdmin,
    [string]$ReportFile
)

$ErrorActionPreference = 'Stop'

if ($Categories -and @($Categories).Count -eq 1 -and $Categories[0] -match ',') {
    $Categories = @($Categories[0] -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
}

if (-not (Test-Path -LiteralPath $ScanFile)) { throw "Scan file not found: $ScanFile" }
$scan = Get-Content -LiteralPath $ScanFile -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $scan.categories) { throw "This does not look like a WipeWise scan (no categories)." }
if (-not $Categories -or @($Categories).Count -eq 0) {
    throw "No -Categories given. Pass the category ids you approve, e.g. -Categories personal-files,browsers. Run the scanner first and review it."
}

# ---------------------------------------------------------------- native: silent recycle
$script:HaveShell = $false
try {
    Add-Type -Namespace WwShell -Name Op -ErrorAction Stop -MemberDefinition @'
[System.Runtime.InteropServices.StructLayout(System.Runtime.InteropServices.LayoutKind.Sequential, CharSet=System.Runtime.InteropServices.CharSet.Unicode)]
public struct SHFILEOPSTRUCT { public System.IntPtr hwnd; public uint wFunc; public string pFrom; public string pTo; public ushort fFlags; public int fAnyOperationsAborted; public System.IntPtr hNameMappings; public string lpszProgressTitle; }
[System.Runtime.InteropServices.DllImport("shell32.dll", CharSet=System.Runtime.InteropServices.CharSet.Unicode)]
public static extern int SHFileOperation(ref SHFILEOPSTRUCT lpFileOp);
'@
    $script:HaveShell = $true
} catch { $script:HaveShell = $false }

function Send-WwToRecycle([string]$path) {
    if ($script:HaveShell) {
        $FO_DELETE = 3
        $FOF_SILENT = 0x4; $FOF_NOCONFIRMATION = 0x10; $FOF_ALLOWUNDO = 0x40; $FOF_NOERRORUI = 0x400; $FOF_NOCONFIRMMKDIR = 0x200
        $op = New-Object WwShell.Op+SHFILEOPSTRUCT
        $op.wFunc = [uint32]$FO_DELETE
        $op.pFrom = $path + [char]0 + [char]0
        $op.fFlags = [uint16]($FOF_SILENT -bor $FOF_NOCONFIRMATION -bor $FOF_ALLOWUNDO -bor $FOF_NOERRORUI -bor $FOF_NOCONFIRMMKDIR)
        $rc = [WwShell.Op]::SHFileOperation([ref]$op)
        if ($rc -ne 0) { throw "recycle failed (SHFileOperation 0x$($rc.ToString('X')))" }
        if ($op.fAnyOperationsAborted -ne 0) { throw 'recycle aborted' }
    } else {
        Add-Type -AssemblyName Microsoft.VisualBasic
        if (Test-Path -LiteralPath $path -PathType Container) {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($path, [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs, [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin)
        } else {
            [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($path, [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs, [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin)
        }
    }
}

# ---------------------------------------------------------------- constants / guards
$ProfileRoot    = ([IO.Path]::GetFullPath($env:USERPROFILE)).TrimEnd('\')
$ProfileRootL   = $ProfileRoot.ToLowerInvariant()
$DenyCategories = @('other-users', 'other-volumes', 'installed-programs')
$CloudCategory  = 'cloud-storage'
$RecycleCapBytes = 1GB
$WalkCap        = 300000

$selfPaths = New-Object System.Collections.ArrayList
[void]$selfPaths.Add((([IO.Path]::GetFullPath($ScanFile)).ToLowerInvariant()))
[void]$selfPaths.Add((([IO.Path]::GetFullPath($PSCommandPath)).ToLowerInvariant()))
if ($ReportFile) { [void]$selfPaths.Add((([IO.Path]::GetFullPath($ReportFile)).ToLowerInvariant())) }
try { [void]$selfPaths.Add(((Split-Path -Parent $PSCommandPath).ToLowerInvariant())) } catch {}

$CloudRoots = New-Object System.Collections.ArrayList
foreach ($e in @($env:OneDrive, $env:OneDriveConsumer, $env:OneDriveCommercial)) {
    if ($e) { try { [void]$CloudRoots.Add((([IO.Path]::GetFullPath($e)).TrimEnd('\').ToLowerInvariant())) } catch {} }
}
foreach ($n in 'OneDrive', 'Dropbox', 'Google Drive', 'GoogleDrive', 'iCloudDrive', 'Box', 'pCloud', 'Nextcloud', 'ownCloud', 'Proton Drive', 'Sync', 'SpiderOak Hive', 'Jottacloud', 'MEGA', 'MEGAsync', 'Tresorit', 'Seafile', 'Creative Cloud Files') {
    [void]$CloudRoots.Add(((Join-Path $ProfileRoot $n)).ToLowerInvariant())
}
[void]$CloudRoots.Add(((Join-Path $ProfileRoot 'Pictures\iCloud Photos')).ToLowerInvariant())

function Get-WwFull([string]$p) {
    try { return ([IO.Path]::GetFullPath([Environment]::ExpandEnvironmentVariables($p))).TrimEnd('\') } catch { return $null }
}

function Test-WwReparseInPath([string]$full) {
    try {
        if ([string]::IsNullOrWhiteSpace($full)) { return $true }
        $cur = $full
        while ($cur) {
            if ($cur -match '^[A-Za-z]:\\?$') { break }
            if (Test-Path -LiteralPath $cur -ErrorAction SilentlyContinue) {
                $i = Get-Item -LiteralPath $cur -Force -ErrorAction Stop
                if ($i.Attributes -band [IO.FileAttributes]::ReparsePoint) { return $true }
            }
            $parent = Split-Path -Parent $cur
            if (-not $parent -or $parent -eq $cur) { break }
            $cur = $parent
        }
        return $false
    } catch { return $true }
}

function Get-WwTreeInfo([string]$path) {
    $r = [ordered]@{ bytes = [int64]0; hasReparse = $false; capped = $false; count = 0 }
    try {
        $root = Get-Item -LiteralPath $path -Force -ErrorAction Stop
        if (-not $root.PSIsContainer) { $r.bytes = [int64]$root.Length; return $r }
    } catch { $r.hasReparse = $true; return $r }
    $stack = New-Object System.Collections.Stack
    $stack.Push($path)
    while ($stack.Count -gt 0) {
        if ($r.count -ge $WalkCap) { $r.capped = $true; break }
        $d = $stack.Pop()
        $children = $null
        try { $children = Get-ChildItem -LiteralPath $d -Force -ErrorAction Stop } catch { $r.hasReparse = $true; break }
        foreach ($ch in $children) {
            $r.count++
            if ($ch.Attributes -band [IO.FileAttributes]::ReparsePoint) { $r.hasReparse = $true; return $r }
            if ($ch.PSIsContainer) { $stack.Push($ch.FullName) }
            else { $r.bytes += [int64]$ch.Length }
        }
    }
    return $r
}

function Get-WwDenyReason {
    param([string]$full, [bool]$isAdmin, [string]$catId)
    if ([string]::IsNullOrWhiteSpace($full)) { return 'unresolved path' }
    $l = $full.ToLowerInvariant()
    if ($full -match '^[A-Za-z]:\\?$') { return 'drive root' }
    if ($l -eq $ProfileRootL) { return 'the profile root itself' }
    foreach ($r in @($env:WINDIR, $env:ProgramData, "$env:ProgramFiles", "${env:ProgramFiles(x86)}")) {
        if ($r) { $rl = ([IO.Path]::GetFullPath($r)).TrimEnd('\').ToLowerInvariant(); if ($l -eq $rl -or $l.StartsWith($rl + '\')) { return 'system folder' } }
    }
    if (-not ($l.StartsWith($ProfileRootL + '\'))) { return 'outside your user profile' }
    foreach ($s in $selfPaths) { if ($l -eq $s -or $l.StartsWith($s + '\') -or $s.StartsWith($l + '\')) { return 'WipeWise / scan / report path' } }
    if ($l -match '(hiberfil|pagefile|swapfile)\.sys$') { return 'in-use system file' }
    if (-not $IncludeCloud) {
        if ($catId -eq $CloudCategory) { return 'cloud-sync (use -IncludeCloud; may delete cloud copy)' }
        foreach ($cr in $CloudRoots) { if ($cr -and ($l -eq $cr -or $l.StartsWith($cr + '\'))) { return 'cloud-sync folder (use -IncludeCloud; may delete cloud copy)' } }
    }
    if ($isAdmin -and -not $IncludeAdmin) { return 'needs admin (use -IncludeAdmin)' }
    return $null
}

# --- registry history clearing: ONLY a fixed allowlist of known HKCU history keys ---
function ConvertTo-WwRegPath([string]$p) {
    $x = $p
    $x = $x -replace '^HKEY_CURRENT_USER', 'HKCU' -replace '^HKEY_LOCAL_MACHINE', 'HKLM' -replace '^HKEY_CLASSES_ROOT', 'HKCR' -replace '^HKEY_USERS', 'HKU' -replace '^HKEY_CURRENT_CONFIG', 'HKCC'
    if ($x -match '^(HKCU|HKLM|HKCR|HKU|HKCC)\\') { $x = $x -replace '^(HKCU|HKLM|HKCR|HKU|HKCC)\\', '$1:\' }
    return $x
}
# EXACT full-path allowlist (lowercased). ONLY these known HKCU user-history keys are ever
# auto-cleared. Every entry is a leaf-anchor: Clear-WwRegKey removes its values and child
# subkeys and keeps the anchor itself, so each must be a pure history/MRU/telemetry key that
# Windows or the owning app rebuilds on next use - never a settings or config key. All are
# under HKCU (incl. HKCU\Software\Classes = the per-user USRCLASS hive); no HKLM/HKCR/HKU.
$SafeRegKeys = @(
    # --- Explorer MRUs / recent (activity-traces) ---
    'hkcu:\software\microsoft\windows\currentversion\explorer\recentdocs',
    'hkcu:\software\microsoft\windows\currentversion\explorer\runmru',
    'hkcu:\software\microsoft\windows\currentversion\explorer\typedpaths',
    'hkcu:\software\microsoft\windows\currentversion\explorer\wordwheelquery',
    'hkcu:\software\microsoft\windows\currentversion\explorer\comdlg32\opensavepidlmru',
    'hkcu:\software\microsoft\windows\currentversion\explorer\comdlg32\lastvisitedpidlmru',
    'hkcu:\software\microsoft\windows\currentversion\explorer\comdlg32\cidsizemru',
    'hkcu:\software\microsoft\windows\currentversion\explorer\comdlg32\firstfolder',
    'hkcu:\software\microsoft\windows\currentversion\explorer\map network drive mru',
    'hkcu:\software\microsoft\internet explorer\typedurls',
    'hkcu:\software\microsoft\windows\currentversion\search\recentapps',
    # --- program-execution history / telemetry (forensic-traces) ---
    'hkcu:\software\microsoft\windows\currentversion\explorer\userassist',
    'hkcu:\software\microsoft\windows\currentversion\explorer\featureusage',
    'hkcu:\software\classes\local settings\software\microsoft\windows\shell\muicache',
    # --- ShellBags: browsed-folder history (NTUSER + USRCLASS). Clearing resets folder view prefs (cosmetic) ---
    'hkcu:\software\microsoft\windows\shell\bagmru',
    'hkcu:\software\microsoft\windows\shell\bags',
    'hkcu:\software\classes\local settings\software\microsoft\windows\shell\bagmru',
    'hkcu:\software\classes\local settings\software\microsoft\windows\shell\bags',
    # --- Remote Desktop (mstsc) connection history: servers + UsernameHint (saved pw lives in Credential Manager) ---
    'hkcu:\software\microsoft\terminal server client\default',
    'hkcu:\software\microsoft\terminal server client\servers'
)
function Test-WwRegSafe([string]$regPath) {
    if ([string]::IsNullOrWhiteSpace($regPath)) { return $false }
    $l = $regPath.ToLowerInvariant().Trim().TrimEnd('\')
    return ($SafeRegKeys -contains $l)   # exact match to a known key; no suffix/prefix widening
}
function Clear-WwRegKey([string]$regPath) {
    # literal (non-wildcard) removal of this key's values and subkeys, keeping the key; verify empty or throw.
    $sub = $regPath -replace '^(?i)HKCU:\\', ''
    $k = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($sub, $true)
    if (-not $k) { throw "cannot open $regPath" }
    try {
        foreach ($vn in @($k.GetValueNames())) { if ($vn -ne '') { $k.DeleteValue($vn, $false) } }
        foreach ($sk in @($k.GetSubKeyNames())) { $k.DeleteSubKeyTree($sk, $false) }
        $remV = @($k.GetValueNames() | Where-Object { $_ -ne '' }).Count
        $remS = @($k.GetSubKeyNames()).Count
        if ($remV -ne 0 -or $remS -ne 0) { throw "values/subkeys remain ($remV values, $remS subkeys)" }
    } finally { $k.Close() }
}

function Remove-WwTreeSafe {
    param([string]$Path)
    $root = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if ($root.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        if ($root.PSIsContainer) { [System.IO.Directory]::Delete($Path, $false) } else { Remove-Item -LiteralPath $Path -Force -Confirm:$false -ErrorAction Stop }
        return
    }
    if (-not $root.PSIsContainer) { Remove-Item -LiteralPath $Path -Force -Confirm:$false -ErrorAction Stop; return }
    $stack = New-Object System.Collections.Stack
    $stack.Push($Path)
    $dirs = New-Object System.Collections.Generic.List[string]
    while ($stack.Count -gt 0) {
        $d = $stack.Pop()
        try { $di = Get-Item -LiteralPath $d -Force -ErrorAction Stop } catch { continue }
        if ($di.Attributes -band [IO.FileAttributes]::ReparsePoint) { try { [System.IO.Directory]::Delete($d, $false) } catch {}; continue }
        $dirs.Add($d)
        foreach ($ch in (Get-ChildItem -LiteralPath $d -Force -ErrorAction SilentlyContinue)) {
            $isReparse = ($ch.Attributes -band [IO.FileAttributes]::ReparsePoint)
            if ($ch.PSIsContainer) {
                if ($isReparse) { try { [System.IO.Directory]::Delete($ch.FullName, $false) } catch {} }
                else { $stack.Push($ch.FullName) }
            } else {
                Remove-Item -LiteralPath $ch.FullName -Force -Confirm:$false -ErrorAction SilentlyContinue
            }
        }
    }
    for ($i = $dirs.Count - 1; $i -ge 0; $i--) { Remove-Item -LiteralPath $dirs[$i] -Force -Recurse:$false -Confirm:$false -ErrorAction SilentlyContinue }
}

# ---------------------------------------------------------------- build plan
$plan = New-Object System.Collections.ArrayList
foreach ($cat in $scan.categories) {
    if (-not ($Categories -contains $cat.id)) { continue }
    if ($DenyCategories -contains $cat.id) {
        [void]$plan.Add([pscustomobject]@{ cat = $cat.id; path = '(whole category)'; action = 'refuse'; reason = 'out of scope - handle via guidance (delete the account in Settings / review the drive)'; bytes = 0; result = '' }); continue
    }
    foreach ($it in $cat.items) {
        if (-not $it.path) { continue }
        $isReg = ($it.PSObject.Properties['kind'] -and $it.kind -eq 'registry') -or ($it.path -match '^(HKLM|HKCU|HKEY_|HKCR|HKU|HKCC)')
        if ($isReg) {
            $rp = ConvertTo-WwRegPath $it.path
            if (Test-WwRegSafe $rp) {
                [void]$plan.Add([pscustomobject]@{ cat = $cat.id; path = $rp; action = 'clear-reg'; reason = ''; bytes = 0; result = '' })
            } else {
                [void]$plan.Add([pscustomobject]@{ cat = $cat.id; path = $it.path; action = 'skip-registry'; reason = 'registry: only known HKCU history keys are auto-cleared (this one is guidance-only)'; bytes = 0; result = '' })
            }
            continue
        }
        if ($it.PSObject.Properties['exists'] -and -not $it.exists) { continue }
        $full = Get-WwFull $it.path
        $deny = Get-WwDenyReason $full ([bool]$it.needsAdmin) $cat.id
        if ($deny) { [void]$plan.Add([pscustomobject]@{ cat = $cat.id; path = $full; action = 'refuse'; reason = $deny; bytes = [int64]$it.bytes; result = '' }); continue }
        if (-not (Test-Path -LiteralPath $full)) { continue }
        if (Test-WwReparseInPath $full) { [void]$plan.Add([pscustomobject]@{ cat = $cat.id; path = $full; action = 'refuse'; reason = 'reparse point in path (junction/symlink)'; bytes = 0; result = '' }); continue }
        [void]$plan.Add([pscustomobject]@{ cat = $cat.id; path = $full; action = 'remove'; reason = ''; bytes = [int64]$it.bytes; result = '' })
    }
}

$toRemove   = @($plan | Where-Object { $_.action -eq 'remove' })
$toClearReg = @($plan | Where-Object { $_.action -eq 'clear-reg' })
$refused    = @($plan | Where-Object { $_.action -eq 'refuse' })
$regSkip    = @($plan | Where-Object { $_.action -eq 'skip-registry' })
$sumBytes = ($toRemove | Measure-Object -Property bytes -Sum).Sum; if (-not $sumBytes) { $sumBytes = 0 }

# ---------------------------------------------------------------- report plan
Write-Host ""
Write-Host "WipeWise Reset - $(if($Execute){'EXECUTE'}else{'DRY-RUN (nothing will be changed)'})" -ForegroundColor $(if($Execute){'Red'}else{'Cyan'})
Write-Host ("Mode: {0} | Profile: {1} | Categories: {2}" -f $Mode, $ProfileRoot, ($Categories -join ', '))
Write-Host ("Would remove: {0} target(s), {1:N1} MB. Would clear: {2} registry history key(s). Refused: {3}. Registry guidance-only: {4}." -f $toRemove.Count, ($sumBytes/1MB), $toClearReg.Count, $refused.Count, $regSkip.Count)
Write-Host ""
Write-Host "-- files/folders to remove (by category) --"
$toRemove | Group-Object cat | Sort-Object Name | ForEach-Object {
    $b = ($_.Group | Measure-Object bytes -Sum).Sum; if (-not $b) { $b = 0 }
    Write-Host ("  {0,-18} {1,4} item(s)  {2,10:N1} MB" -f $_.Name, $_.Count, ($b/1MB))
}
if ($toClearReg.Count) {
    Write-Host ""
    Write-Host "-- registry history keys to clear (values + subkeys; key kept) --"
    $toClearReg | ForEach-Object { Write-Host ("  {0}" -f $_.path) }
}
if ($refused.Count) {
    Write-Host ""
    Write-Host "-- refused (left untouched) --"
    $refused | Group-Object reason | Sort-Object Name | ForEach-Object { Write-Host ("  {0,3}x  {1}" -f $_.Count, $_.Name) }
}
if ($Mode -eq 'Recycle') {
    Write-Host ""
    Write-Host ("Note: in Recycle mode, a target larger than {0:N0} GB, on a volume with Recycle disabled, or containing a junction/symlink is SKIPPED (not recycled) to avoid a silent permanent delete - use -Mode Delete for those." -f ($RecycleCapBytes/1GB)) -ForegroundColor Yellow
}

# ---------------------------------------------------------------- execute (gated)
if ($Execute) {
    if ($Confirm -ne $env:COMPUTERNAME) {
        throw "Refusing to execute: pass -Confirm $($env:COMPUTERNAME) to confirm you are resetting THIS computer. (Got: '$Confirm')"
    }
    if ($Mode -eq 'Delete') { Write-Host "`nPERMANENT DELETE on up to $($toRemove.Count) target(s)..." -ForegroundColor Red }
    else { Write-Host "`nSending up to $($toRemove.Count) target(s) to the Recycle Bin..." -ForegroundColor Yellow }
    foreach ($t in $toRemove) {
        try {
            if (-not (Test-Path -LiteralPath $t.path)) { $t.result = 'already gone'; continue }
            if (Test-WwReparseInPath $t.path) { $t.result = 'skipped (reparse point in path)'; continue }
            $deny = Get-WwDenyReason $t.path $false $t.cat
            if ($deny) { $t.result = "skipped ($deny)"; continue }
            if ($Mode -eq 'Recycle') {
                $info = Get-WwTreeInfo $t.path
                if ($info.hasReparse) { $t.result = 'skipped (contains junction/symlink - use -Mode Delete)'; continue }
                if ($info.capped)     { $t.result = 'skipped (too large/complex to verify - use -Mode Delete)'; continue }
                if ($info.bytes -ge $RecycleCapBytes) { $t.result = 'skipped (too large to recycle - would be permanent; use -Mode Delete)'; continue }
                Send-WwToRecycle $t.path
                if (Test-Path -LiteralPath $t.path) { throw 'recycle reported success but target remains' }
            } else {
                Remove-WwTreeSafe -Path $t.path
                if (Test-Path -LiteralPath $t.path) { throw 'partial delete: some items (locked/in-use) remain' }
            }
            $t.result = 'removed'
        } catch { $t.result = 'FAILED: ' + $_.Exception.Message }
    }
    if ($toClearReg.Count) { Write-Host "Clearing $($toClearReg.Count) registry history key(s)..." -ForegroundColor Yellow }
    foreach ($t in $toClearReg) {
        try {
            if (-not (Test-WwRegSafe $t.path)) { $t.result = 'skipped (not an allowlisted HKCU history key)'; continue }
            if (-not (Test-Path -LiteralPath $t.path)) { $t.result = 'already gone'; continue }
            Clear-WwRegKey $t.path
            $t.result = 'cleared'
        } catch { $t.result = 'FAILED: ' + $_.Exception.Message }
    }
    $ok   = @($toRemove | Where-Object { $_.result -eq 'removed' }).Count
    $skip = @($toRemove | Where-Object { $_.result -like 'skipped*' }).Count
    $fail = @(($toRemove + $toClearReg) | Where-Object { $_.result -like 'FAILED*' }).Count
    $rc   = @($toClearReg | Where-Object { $_.result -eq 'cleared' }).Count
    Write-Host ("`nDone. Removed: {0} | registry cleared: {1} | skipped: {2} | failed: {3}." -f $ok, $rc, $skip, $fail) -ForegroundColor Green
    if ($skip) { Write-Host "Some targets were skipped for safety (too large / junction / cloud). Use -Mode Delete or handle them manually." }
    Write-Host "Re-run Invoke-WipeWiseScan.ps1 and compare to verify what is gone."
} else {
    Write-Host "`nThis was a DRY-RUN. Re-run with -Execute -Confirm $($env:COMPUTERNAME) to act (add -Mode Delete for permanent)." -ForegroundColor Cyan
}

# ---------------------------------------------------------------- summary report (counts/sizes only; no file names)
if ($ReportFile) {
    function Get-WwBucket([string]$r) {
        if ([string]::IsNullOrEmpty($r)) { return 'planned' }
        if ($r -like 'FAILED*') { return 'failed' }
        if ($r -like 'skipped*') { return ($r -replace '^skipped \(', 'skipped: ' -replace '\)$', '') }
        return $r
    }
    $rep = [ordered]@{
        tool = 'WipeWise-Reset'; version = '0.3.0'; mode = $Mode; executed = [bool]$Execute
        generatedOn = (Get-Date).ToString('o'); computer = $env:COMPUTERNAME; user = $env:USERNAME
        categories = @($Categories); wouldRemove = $toRemove.Count; wouldRemoveBytes = [int64]$sumBytes
        wouldClearRegistry = $toClearReg.Count; refused = $refused.Count; registryGuidanceOnly = $regSkip.Count
        perCategory = @($toRemove | Group-Object cat | ForEach-Object { [pscustomobject]@{ id = $_.Name; items = $_.Count; bytes = [int64](($_.Group | Measure-Object bytes -Sum).Sum) } })
        refusedReasons = @($refused | Group-Object reason | ForEach-Object { [pscustomobject]@{ reason = $_.Name; count = $_.Count } })
        results = $(if ($Execute) { @(($toRemove + $toClearReg) | ForEach-Object { Get-WwBucket $_.result } | Group-Object | ForEach-Object { [pscustomobject]@{ result = $_.Name; count = $_.Count } }) } else { @() })
    }
    $rep | ConvertTo-Json -Depth 6 | Out-File -LiteralPath $ReportFile -Encoding UTF8
    Write-Host "Summary report: $ReportFile"
}
