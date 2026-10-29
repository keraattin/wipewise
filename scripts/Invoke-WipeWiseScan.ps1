#Requires -Version 5.1
<#
.SYNOPSIS
    WipeWise read-only scanner. Reports the current user's personal data and
    usage traces on a Windows 10/11 PC, grouped by category, as JSON.

.DESCRIPTION
    STRICTLY READ-ONLY. It inspects the existence, size and item counts of
    folders/files, and the value/subkey COUNTS of registry keys. It NEVER
    deletes, moves, overwrites, formats, or writes to the registry, and it
    RUNS NO EXTERNAL COMMANDS (no netsh, cmdkey, vssadmin, etc.) and never
    reveals a secret value. The only thing it writes is its own JSON report,
    to -OutFile or stdout.

    Runs under Windows PowerShell 5.1 and PowerShell 7+, with or without
    Administrator. Some locations report fuller results only when elevated;
    those probes are flagged "needsAdmin": true.

.PARAMETER OutFile
    Path to write the JSON report. If omitted, JSON goes to stdout.

.PARAMETER Quick
    Skip deep folder sizing (existence + top-level count only). Much faster.

.PARAMETER ListProbes
    Print the category/probe counts and exit. Runs nothing against the system.

.NOTES
    WipeWise v0.1.1. Apache-2.0. No network access. No writes other than -OutFile.
    Reads files/folders and registry key counts only; executes no commands.
#>
[CmdletBinding()]
param(
    [string]$OutFile,
    [switch]$Quick,
    [switch]$ListProbes
)

$ErrorActionPreference = 'SilentlyContinue'
$ProgressPreference    = 'SilentlyContinue'

# --- helpers (all strictly read-only) --------------------------------------

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

function ConvertTo-WwRegPath {
    # Normalize a registry path to PowerShell PSDrive form (HKCU:\ , HKLM:\ ...).
    param([string]$Path)
    $p = $Path
    $p = $p -replace '^HKEY_CURRENT_USER',   'HKCU'
    $p = $p -replace '^HKEY_LOCAL_MACHINE',  'HKLM'
    $p = $p -replace '^HKEY_CLASSES_ROOT',   'HKCR'
    $p = $p -replace '^HKEY_USERS',          'HKU'
    $p = $p -replace '^HKEY_CURRENT_CONFIG', 'HKCC'
    # Insert the ':' PSDrive separator if missing (e.g. HKCU\Software -> HKCU:\Software)
    if ($p -match '^(HKCU|HKLM|HKCR|HKU|HKCC)\\') {
        $p = $p -replace '^(HKCU|HKLM|HKCR|HKU|HKCC)\\', '$1:\'
    }
    return $p
}

function Measure-WwTree {
    # Read-only size/count for a folder OR a single file. Skips reparse points
    # (junctions/symlinks) when recursing so we do not wander onto other volumes
    # or expand cloud placeholders.
    param([string]$Path, [switch]$Quick)
    $r = [ordered]@{ exists = $false; files = 0; bytes = 0; examples = @() }
    $p = Expand-WwPath $Path
    if ([string]::IsNullOrWhiteSpace($p)) { return $r }
    if ($p -match '%[^%]+%') { return $r }   # an environment variable was not set
    if (-not (Test-Path -LiteralPath $p -ErrorAction SilentlyContinue)) { return $r }
    $r.exists = $true

    # Single-file probe?
    try {
        $item = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
        if ($item -and -not $item.PSIsContainer) {
            $r.files = 1
            $r.bytes = [int64]$item.Length
            $r.examples = @($item.Name)
            return $r
        }
    } catch {}

    # Folder probe
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
    # Read-only count of values/subkeys under a registry key (PSDrive form).
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

# === category plan and probe table (generated from the trace catalog) ===
$Plan = @(
    @{ id='personal-files'; title='Personal files & recycle bin'; desc='Known folders in the user profile (Desktop, Documents, Downloads, Pictures/Camera Roll/Screenshots, Videos, Music, Contacts, Searches, Saved Games), the Public folder, device backups, and the per-drive Recycle Bin. Scanner must follow known-folder redirection and enumerate every fixed/removable volume (each has its own $Recycle.Bin and user data).' }
    @{ id='cloud-storage'; title='Cloud storage & sync clients'; desc='Local sync folders and client state/config for OneDrive, Dropbox, Google Drive, iCloud, Box, MEGA, pCloud, Nextcloud/ownCloud. The authoritative copy is in the cloud: unlink before deleting, then remove server-side.' }
    @{ id='browsers'; title='Web browsers'; desc='Per-profile stores for every Chromium browser (Edge/Chrome/Brave/Vivaldi/Chromium/Opera) plus Firefox and legacy IE/WinINET/Tor: history, cookies, saved logins, autofill/cards, bookmarks, tabs, caches, extensions, collections. Enumerate every profile, not just Default; sync means a cloud copy survives.' }
    @{ id='messaging'; title='Messaging & chat apps'; desc='Desktop clients (Teams, Slack, Discord, WhatsApp, Telegram, Signal, Zoom, Skype, Viber, WeChat, LINE, Element) holding linked-device sessions, cached chats/media and local recordings. Most history lives server-side or on the phone.' }
    @{ id='email'; title='Email clients'; desc='Outlook (classic OST/PST, autocomplete, signatures, profiles; new Outlook), Thunderbird/Betterbird, Windows Mail, eM Client, Mailbird. PST and POP-only mail may be the only copy; IMAP/Exchange resync from the server.' }
    @{ id='apps-media-gaming'; title='Productivity, media & gaming apps'; desc='Recent-file MRUs, notes apps, media players and libraries, creative tools, IDE/project state, and game launchers/saves. Mostly recent-use trails, local caches and saved-login tokens; accounts and cloud saves persist server-side.' }
    @{ id='finance-crypto'; title='Finance, crypto & authenticators'; desc='Tax returns, accounting files, crypto wallets and desktop 2FA apps - among the most sensitive data on the PC.' }
    @{ id='vm-backup'; title='Virtual machines & backups'; desc='Guest-OS disk images (VirtualBox/VMware/Hyper-V/WSL) and local or image backups - each a full copy of personal data.' }
    @{ id='identity-accounts'; title='Signed-in accounts & identity'; desc='The Windows/Microsoft, Entra (work/school) and app account identities and token caches: WAM/TokenBroker, AAD broker, IdentityStore, Office/Steam/Xbox/Minecraft sign-ins. Unlinking a device does not remove the server-side account or Entra/Intune device object.' }
    @{ id='credentials'; title='Windows credential vaults & password managers'; desc='Credential Manager/Vault on-disk stores, DPAPI master keys, Windows Hello NGC/biometric templates, and local password-manager caches (KeePass, Bitwarden, 1Password, Enpass). Existence/counts only, never values; a local delete is not a revoke.' }
    @{ id='dev-secrets'; title='Developer keys & secrets'; desc='SSH/GPG keys, cloud CLI credentials (AWS/Azure/gcloud/kube), package-registry tokens (npm/PyPI/NuGet), Git creds, .netrc/Maven, and SSH/FTP clients (PuTTY/WinSCP/FileZilla). Treat every secret as compromised and rotate at the service.' }
    @{ id='network'; title='Network & VPN configuration'; desc='Saved Wi-Fi profiles (names/count only), VPN clients (OpenVPN/WireGuard/Cisco/RAS phonebook), mapped drives, RDP targets, SMB shares, hosts file and proxy. Reveal employers, home/work networks and remote hosts; keys never displayed.' }
    @{ id='devices'; title='Attached-device history'; desc='Durable records of USB storage, mounted volumes, portable devices, Bluetooth pairings, printers (and spool queue), and camera/mic/location app-access history. Not cloud-synced; cleanly cleared only by a full reset.' }
    @{ id='activity-traces'; title='Activity & recent-use history'; desc='Recent items, jump lists, Explorer/Run/dialog MRUs, Timeline, clipboard history, notification previews, shell/PowerShell history and the search index. Rebuild on use, so clean last; synced items keep a Microsoft-account copy.' }
    @{ id='forensic-traces'; title='Forensic execution artifacts'; desc='Deeper, mostly admin-protected execution and browsing evidence: UserAssist, ShellBags, MUICache, Prefetch, Amcache, SRUM, BAM, ShimCache, thumbnail/RDP caches and event logs. WipeWise recommends a full Reset-this-PC rather than piecemeal hive edits.' }
    @{ id='recall-copilot'; title='Windows AI (Recall & Copilot)'; desc='Copilot+ Recall snapshot store (CoreAIPlatform) and local Copilot app cache, plus the Click-to-Do feature over the same stack. Recall is local-only but highly sensitive; Copilot conversation history lives in the Microsoft-account cloud.' }
    @{ id='system-traces'; title='System leftovers & caches'; desc='Temp folders, crash/error reports and dumps, Windows.old, restore points/shadow copies, hiberfil/pagefile, telemetry DB, update/installer caches. Can hold fragments of any in-memory or edited data; several need admin.' }
    @{ id='other-users'; title='Other user accounts'; desc='Personal data in other local accounts under C:\Users. The per-user probes only cover the signed-in account; reading others needs admin.' }
    @{ id='other-volumes'; title='Other drives & volumes'; desc='Recycle bins, shadow-copy stores and top-level data on non-system and removable drives.' }
    @{ id='installed-programs'; title='Installed programs'; desc='Programs to sign out of and uninstall; the list itself reveals the owner''s habits.' }
)

$Probes = @(
    # --- personal-files (24) ---
    @{ cat='personal-files'; name='Desktop'; path='%USERPROFILE%\Desktop'; kind='folder'; admin=$false; enum=$false; note='Files/shortcuts left on screen; may be redirected into OneDrive via KFM.' }
    @{ cat='personal-files'; name='Documents'; path='%USERPROFILE%\Documents'; kind='folder'; admin=$false; enum=$false; note='Primary document store; common KFM target; holds Outlook Files, My Games, Scanned Documents.' }
    @{ cat='personal-files'; name='Downloads'; path='%USERPROFILE%\Downloads'; kind='folder'; admin=$false; enum=$false; note='Installers, invoices, attachments, Nearby-Sharing receipts; often richest unreviewed folder.' }
    @{ cat='personal-files'; name='Pictures'; path='%USERPROFILE%\Pictures'; kind='folder'; admin=$false; enum=$false; note='Photos with EXIF GPS/time; common KFM target.' }
    @{ cat='personal-files'; name='Camera Roll'; path='%USERPROFILE%\Pictures\Camera Roll'; kind='folder'; admin=$false; enum=$false; note='Camera/webcam captures; created on demand, often absent.' }
    @{ cat='personal-files'; name='Screenshots'; path='%USERPROFILE%\Pictures\Screenshots'; kind='folder'; admin=$false; enum=$false; note='Win+PrtScn captures; can show logged-in apps, codes, chats.' }
    @{ cat='personal-files'; name='Saved Pictures'; path='%USERPROFILE%\Pictures\Saved Pictures'; kind='folder'; admin=$false; enum=$false; note='Images saved via Photos app; created on demand, often absent.' }
    @{ cat='personal-files'; name='Videos'; path='%USERPROFILE%\Videos'; kind='folder'; admin=$false; enum=$false; note='Personal and screen/game recordings.' }
    @{ cat='personal-files'; name='Music'; path='%USERPROFILE%\Music'; kind='folder'; admin=$false; enum=$false; note='Music library and any personal voice recordings.' }
    @{ cat='personal-files'; name='Favorites (legacy IE/Edge)'; path='%USERPROFILE%\Favorites'; kind='folder'; admin=$false; enum=$false; note='.url bookmarks revealing sites/interests; not modern Chrome/Edge bookmarks.' }
    @{ cat='personal-files'; name='Links'; path='%USERPROFILE%\Links'; kind='folder'; admin=$false; enum=$false; note='Explorer pinned-folder shortcuts; may point to shares/other drives.' }
    @{ cat='personal-files'; name='Contacts (Windows Contacts)'; path='%USERPROFILE%\Contacts'; kind='folder'; admin=$false; enum=$false; note='.contact cards with third parties'' names/phones/emails; also fed by People app.' }
    @{ cat='personal-files'; name='Searches'; path='%USERPROFILE%\Searches'; kind='folder'; admin=$false; enum=$false; note='Saved searches (.search-ms) with query terms and scoped paths.' }
    @{ cat='personal-files'; name='Saved Games'; path='%USERPROFILE%\Saved Games'; kind='folder'; admin=$false; enum=$false; note='Windows Saved Games known folder; profiles/play history.' }
    @{ cat='personal-files'; name='3D Objects'; path='%USERPROFILE%\3D Objects'; kind='folder'; admin=$false; enum=$false; note='Legacy known folder; usually absent/empty on Windows 11.' }
    @{ cat='personal-files'; name='Public (all-users) folder'; path='%PUBLIC%'; kind='folder'; admin=$false; enum=$false; note='Files shared to all accounts (Public Documents/Pictures/etc.); easy to miss.' }
    @{ cat='personal-files'; name='Recycle Bin (system drive)'; path='%SystemDrive%\$Recycle.Bin'; kind='folder'; admin=$true; enum=$false; note='Per-SID deleted files, restorable until emptied; other SIDs need admin; each drive has its own.' }
    @{ cat='personal-files'; name='Known-folder redirection map'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'; kind='registry'; admin=$false; enum=$false; note='Shows whether Desktop/Documents/Pictures redirected into OneDrive or another drive.' }
    @{ cat='personal-files'; name='Apple device backups (MobileSync)'; path='%USERPROFILE%\Apple\MobileSync\Backup'; kind='folder'; admin=$false; enum=$false; note='Full iPhone/iPad backups; classic iTunes at %APPDATA%\Apple Computer\MobileSync\Backup.' }
    @{ cat='personal-files'; name='Snipping Tool package'; path='%LOCALAPPDATA%\Packages\Microsoft.ScreenSketch_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Recent-snip state for Snipping Tool / Snip & Sketch.' }
    @{ cat='personal-files'; name='Photos app cache'; path='%LOCALAPPDATA%\Packages\Microsoft.Windows.Photos_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Thumbnail cache and index of viewed photos/folders.' }
    @{ cat='personal-files'; name='Sound recordings'; path='%USERPROFILE%\Documents\Sound recordings'; kind='folder'; admin=$false; enum=$false; note='Sound Recorder / Voice Recorder clips (older: Sound Recordings).' }
    @{ cat='personal-files'; name='Scanned Documents'; path='%USERPROFILE%\Documents\Scanned Documents'; kind='folder'; admin=$false; enum=$false; note='Windows Fax and Scan output; modern Scan app may use Pictures\Scans.' }
    @{ cat='personal-files'; name='Account pictures'; path='%APPDATA%\Microsoft\Windows\AccountPictures'; kind='folder'; admin=$false; enum=$false; note='Images set as the user account photo.' }
    # --- cloud-storage (44) ---
    @{ cat='cloud-storage'; name='OneDrive personal folder'; path='%USERPROFILE%\OneDrive'; kind='folder'; admin=$false; enum=$false; note='Local copy of personal OneDrive; cloud copy survives until unlinked and deleted server-side.' }
    @{ cat='cloud-storage'; name='OneDrive settings & cache'; path='%LOCALAPPDATA%\Microsoft\OneDrive'; kind='folder'; admin=$false; enum=$false; note='Client state/logs; settings\ reveals which accounts synced and their folder paths.' }
    @{ cat='cloud-storage'; name='OneDrive account registry'; path='HKCU:\Software\Microsoft\OneDrive'; kind='registry'; admin=$false; enum=$false; note='Presence indicates OneDrive configured; Accounts\Personal|Business1 appear only when signed in.' }
    @{ cat='cloud-storage'; name='OneDrive Business local folder'; path='%OneDriveCommercial%'; kind='folder'; admin=$false; enum=$false; note='Env var set only when a work/school account is configured; folder name includes company.' }
    @{ cat='cloud-storage'; name='Dropbox sync folder'; path='%USERPROFILE%\Dropbox'; kind='folder'; admin=$false; enum=$false; note='Default sync folder (user-chosen; authoritative path inside info.json).' }
    @{ cat='cloud-storage'; name='Dropbox config'; path='%APPDATA%\Dropbox'; kind='folder'; admin=$false; enum=$false; note='info.json records account type and folder path; may instead live under %LOCALAPPDATA%\Dropbox.' }
    @{ cat='cloud-storage'; name='Dropbox local state'; path='%LOCALAPPDATA%\Dropbox'; kind='folder'; admin=$false; enum=$false; note='Client state/cache and alternate info.json location.' }
    @{ cat='cloud-storage'; name='Google Drive cache (DriveFS)'; path='%LOCALAPPDATA%\Google\DriveFS'; kind='folder'; admin=$false; enum=$false; note='Drive-for-desktop content cache/state; content streamed from a virtual drive (default G:).' }
    @{ cat='cloud-storage'; name='Google Drive legacy folder'; path='%USERPROFILE%\Google Drive'; kind='folder'; admin=$false; enum=$false; note='Real folder used by the older Backup-and-Sync client, if present.' }
    @{ cat='cloud-storage'; name='iCloud Drive'; path='%USERPROFILE%\iCloudDrive'; kind='folder'; admin=$false; enum=$false; note='Classic-client junction; Store iCloud app uses a different on-disk name under Packages\.' }
    @{ cat='cloud-storage'; name='iCloud Photos'; path='%USERPROFILE%\Pictures\iCloud Photos'; kind='folder'; admin=$false; enum=$false; note='Default iCloud Photos download location (configurable); photos carry EXIF GPS/time.' }
    @{ cat='cloud-storage'; name='Box Drive mount'; path='%USERPROFILE%\Box'; kind='folder'; admin=$false; enum=$false; note='Default Box Drive mount point (streamed; configurable).' }
    @{ cat='cloud-storage'; name='Box Drive cache'; path='%LOCALAPPDATA%\Box\Box'; kind='folder'; admin=$false; enum=$false; note='Box Drive cache/state (cache subfolder) per Box admin guide.' }
    @{ cat='cloud-storage'; name='MEGAsync config & logs'; path='%LOCALAPPDATA%\Mega Limited\MEGAsync'; kind='folder'; admin=$false; enum=$false; note='MEGAsync state/database and logs; the local sync folder itself is user-chosen.' }
    @{ cat='cloud-storage'; name='pCloud cache'; path='%LOCALAPPDATA%\pCloud'; kind='folder'; admin=$false; enum=$false; note='pCloud Drive is a virtual mount (default P:); this LOCALAPPDATA cache path is unverified.' }
    @{ cat='cloud-storage'; name='Nextcloud sync folder'; path='%USERPROFILE%\Nextcloud'; kind='folder'; admin=$false; enum=$false; note='Default Nextcloud desktop sync folder.' }
    @{ cat='cloud-storage'; name='Nextcloud config'; path='%APPDATA%\Nextcloud'; kind='folder'; admin=$false; enum=$false; note='Client config revealing server URL and account.' }
    @{ cat='cloud-storage'; name='ownCloud sync folder'; path='%USERPROFILE%\ownCloud'; kind='folder'; admin=$false; enum=$false; note='Default ownCloud desktop sync folder.' }
    @{ cat='cloud-storage'; name='ownCloud config'; path='%APPDATA%\ownCloud'; kind='folder'; admin=$false; enum=$false; note='Client config revealing server URL and account.' }
    @{ cat='cloud-storage'; name='Proton Drive sync folder'; path='%USERPROFILE%\Proton Drive'; kind='folder'; admin=$false; enum=$false; note='Default local sync folder containing the owner''s synced files (relocatable).' }
    @{ cat='cloud-storage'; name='Sync.com folder'; path='%USERPROFILE%\Sync'; kind='folder'; admin=$false; enum=$false; note='Default Sync.com local folder with synced files.' }
    @{ cat='cloud-storage'; name='Tresorit app data'; path='%LOCALAPPDATA%\Tresorit'; kind='folder'; admin=$false; enum=$false; note='Per-device profiles/settings and sync.profile paths; also scan synced folders for hidden .tresorit dirs.' }
    @{ cat='cloud-storage'; name='SpiderOak Hive'; path='%USERPROFILE%\SpiderOak Hive'; kind='folder'; admin=$false; enum=$false; note='SpiderOak ONE sync folder; also look for a SpiderOak/SpiderOakONE config folder under %APPDATA%.' }
    @{ cat='cloud-storage'; name='Jottacloud sync folder'; path='%USERPROFILE%\Jottacloud'; kind='folder'; admin=$false; enum=$false; note='Default Jottacloud sync folder (relocatable).' }
    @{ cat='cloud-storage'; name='Koofr desktop folder'; path='%USERPROFILE%\Desktop\Koofr'; kind='folder'; admin=$false; enum=$false; note='Default Koofr sync folder (created on Desktop); custom syncs may exist elsewhere.' }
    @{ cat='cloud-storage'; name='Seafile ccnet config'; path='%USERPROFILE%\ccnet'; kind='folder'; admin=$false; enum=$false; note='Seafile client config/logs recording server and account; library/seafile-data folder is user-chosen.' }
    @{ cat='cloud-storage'; name='Amazon Drive/Photos app'; path='%LOCALAPPDATA%\Amazon Drive'; kind='folder'; admin=$false; enum=$false; note='App install and account/upload state; sync folder default %USERPROFILE%\Amazon Drive.' }
    @{ cat='cloud-storage'; name='Resilio Sync storage'; path='%APPDATA%\Resilio Sync'; kind='folder'; admin=$false; enum=$false; note='P2P config, shared-folders DB and device identity/share keys.' }
    @{ cat='cloud-storage'; name='Syncthing config/database'; path='%LOCALAPPDATA%\Syncthing'; kind='folder'; admin=$false; enum=$false; note='config.xml, device ID/keys and index DB listing peers and shared folders.' }
    @{ cat='cloud-storage'; name='IDrive'; path='%ProgramFiles(x86)%\IDrive'; kind='folder'; admin=$false; enum=$false; note='Machine-wide backup app + scheduler service; install folder holds account + backup-set definition and logs. Exact ProgramData/per-user config path uncertain.' }
    @{ cat='cloud-storage'; name='Backblaze Personal Backup'; path='%ProgramData%\Backblaze'; kind='folder'; admin=$false; enum=$false; note='bzdata subfolder (SYSTEM-restricted) holds file lists of everything backed up plus account/config; folder existence is listable without admin.' }
    @{ cat='cloud-storage'; name='CrashPlan (Code42)'; path='%ProgramData%\CrashPlan'; kind='folder'; admin=$false; enum=$false; note='conf/cache/log with the backup selection and account; Code42 brand uses the same layout.' }
    @{ cat='cloud-storage'; name='Carbonite Safe'; path='%ProgramData%\Carbonite'; kind='folder'; admin=$false; enum=$false; note='Config/logs for the backup service; exact subfolder (e.g. ''Carbonite Backup'') not fully confirmed.' }
    @{ cat='cloud-storage'; name='Degoo'; path='%APPDATA%\Degoo'; kind='folder'; admin=$false; enum=$false; note='Desktop build path; Degoo on Windows is mainly a Microsoft Store app under %LOCALAPPDATA%\Packages\ (exact package family name unconfirmed).' }
    @{ cat='cloud-storage'; name='Icedrive'; path='%APPDATA%\Icedrive'; kind='folder'; admin=$false; enum=$false; note='Account/config, cache, logs; may be cased ''icedrive''. Also mounts a virtual drive via a driver.' }
    @{ cat='cloud-storage'; name='Filen'; path='%APPDATA%\Filen'; kind='folder'; admin=$false; enum=$false; note='Account/config, sync-location list, cache; folder may be ''filen_desktop''/''filen-desktop'' by version. End-to-end encrypted service.' }
    @{ cat='cloud-storage'; name='Internxt Drive'; path='%APPDATA%\Internxt Drive'; kind='folder'; admin=$false; enum=$false; note='Account/config, cache; folder may be ''internxt-drive''. End-to-end encrypted service.' }
    @{ cat='cloud-storage'; name='Cryptomator vault list'; path='%APPDATA%\Cryptomator'; kind='folder'; admin=$false; enum=$false; note='settings.json lists vault paths/names and recent vaults only; vault contents and passwords stay encrypted and are never read.' }
    @{ cat='cloud-storage'; name='Yandex.Disk'; path='%USERPROFILE%\YandexDisk'; kind='folder'; admin=$false; enum=$false; note='Default sync folder; config under %APPDATA%\Yandex\YandexDisk and %LOCALAPPDATA%\Yandex\YandexDisk2 (2.0/streaming client).' }
    @{ cat='cloud-storage'; name='Cloud Mail.ru (Disk-O:)'; path='%APPDATA%\Mail.Ru'; kind='folder'; admin=$false; enum=$false; note='Mail.ru cloud / Disk-O: client; also %LOCALAPPDATA%\Mail.Ru. Exact subfolder (Disk-O vs Cloud) unconfirmed.' }
    @{ cat='cloud-storage'; name='Zoho WorkDrive TrueSync'; path='%LOCALAPPDATA%\Zoho WorkDrive TrueSync'; kind='folder'; admin=$false; enum=$false; note='Account/org, synced-folder config, cache; mounts a virtual drive. Exact folder name/casing not fully confirmed.' }
    @{ cat='cloud-storage'; name='Egnyte Desktop'; path='%LOCALAPPDATA%\Egnyte Connect'; kind='folder'; admin=$false; enum=$false; note='Classic ''Egnyte Connect''; newer ''Egnyte Desktop App'' uses %LOCALAPPDATA%\Egnyte + %ProgramData%\Egnyte. Reveals company.egnyte.com domain.' }
    @{ cat='cloud-storage'; name='Citrix ShareFile'; path='%LOCALAPPDATA%\Citrix\ShareFile'; kind='folder'; admin=$false; enum=$false; note='ShareFile Drive / ''Citrix Files for Windows''; may be a ''Citrix Files'' subfolder or %APPDATA%\Citrix\ShareFile. Reveals company.sharefile.com subdomain.' }
    @{ cat='cloud-storage'; name='odrive'; path='%USERPROFILE%\.odrive'; kind='folder'; admin=$false; enum=$false; note='Agent config under .odrive\common maps every linked cloud account (Drive/Dropbox/OneDrive/...); default sync folder %USERPROFILE%\odrive.' }
    # --- browsers (71) ---
    @{ cat='browsers'; name='Edge User Data root'; path='%LOCALAPPDATA%\Microsoft\Edge\User Data'; kind='folder'; admin=$false; enum=$false; note='Presence and profile subfolder count show Edge usage and profile count.' }
    @{ cat='browsers'; name='Chrome User Data root'; path='%LOCALAPPDATA%\Google\Chrome\User Data'; kind='folder'; admin=$false; enum=$false; note='Presence and Default/Profile N count show Chrome usage.' }
    @{ cat='browsers'; name='Brave User Data root'; path='%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data'; kind='folder'; admin=$false; enum=$false; note='Presence and profile count show Brave usage; built-in wallet keyring lives per-profile.' }
    @{ cat='browsers'; name='Vivaldi User Data root'; path='%LOCALAPPDATA%\Vivaldi\User Data'; kind='folder'; admin=$false; enum=$false; note='Standard Vivaldi profile root; absent if not installed.' }
    @{ cat='browsers'; name='Chromium User Data root'; path='%LOCALAPPDATA%\Chromium\User Data'; kind='folder'; admin=$false; enum=$false; note='Plain Chromium profile root; absent if not installed.' }
    @{ cat='browsers'; name='Opera Stable profile root'; path='%APPDATA%\Opera Software\Opera Stable'; kind='folder'; admin=$false; enum=$false; note='Opera keeps profile files directly here; presence shows Opera usage.' }
    @{ cat='browsers'; name='Opera GX profile root'; path='%APPDATA%\Opera Software\Opera GX Stable'; kind='folder'; admin=$false; enum=$false; note='Opera GX profile root; presence shows Opera GX usage.' }
    @{ cat='browsers'; name='Chromium Default profile folder'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default'; kind='folder'; admin=$false; enum=$false; note='Container for per-profile DBs; enumerate Default and each Profile N for every Chromium browser.' }
    @{ cat='browsers'; name='Chromium History database'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\History'; kind='folder'; admin=$false; enum=$false; note='SQLite with browsing history, typed search terms and download records; per profile.' }
    @{ cat='browsers'; name='Chromium Network (cookies + HSTS)'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Network'; kind='folder'; admin=$false; enum=$false; note='Cookies DB and TransportSecurity/reporting files revealing domains used.' }
    @{ cat='browsers'; name='Chromium autofill/addresses/cards'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Web Data'; kind='folder'; admin=$false; enum=$false; note='Saved addresses and cards (number encrypted); also Account Web Data when signed in.' }
    @{ cat='browsers'; name='Chromium Local Storage'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Storage'; kind='folder'; admin=$false; enum=$false; note='Per-origin leveldb; size/origin count indicate web-app data retained.' }
    @{ cat='browsers'; name='Chromium IndexedDB'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\IndexedDB'; kind='folder'; admin=$false; enum=$false; note='Per-origin app storage (cached messages/drafts); origin-folder count is the indicator.' }
    @{ cat='browsers'; name='Chromium Service Worker storage'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Service Worker'; kind='folder'; admin=$false; enum=$false; note='Offline web-app caches; size indicates retained site content.' }
    @{ cat='browsers'; name='Chromium installed extensions'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Extensions'; kind='folder'; admin=$false; enum=$false; note='Extension-ID count/names reveal password managers, wallets, VPNs.' }
    @{ cat='browsers'; name='Chromium disk cache'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Cache'; kind='folder'; admin=$false; enum=$false; note='Cache size indicates cached page/image/media remnants.' }
    @{ cat='browsers'; name='Chromium Sessions (open/recent tabs)'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Sessions'; kind='folder'; admin=$false; enum=$false; note='Session_/Tabs_ files record open and recently closed tabs.' }
    @{ cat='browsers'; name='Chromium Bookmarks'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Bookmarks'; kind='folder'; admin=$false; enum=$false; note='JSON bookmark set (+Bookmarks.bak); a clear map of interests/accounts. Not cleared by clear-browsing-data.' }
    @{ cat='browsers'; name='Chromium Top Sites'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Top Sites'; kind='folder'; admin=$false; enum=$false; note='SQLite of most-frequented sites (new-tab tiles).' }
    @{ cat='browsers'; name='Chromium omnibox Shortcuts'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Shortcuts'; kind='folder'; admin=$false; enum=$false; note='Address-bar text typed and suggestion chosen; surfaces sites/terms even if history trimmed.' }
    @{ cat='browsers'; name='Chromium Favicons'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Favicons'; kind='folder'; admin=$false; enum=$false; note='Cached site icons keyed by domain; independent domain list corroborating history.' }
    @{ cat='browsers'; name='Chromium Visited Links'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Visited Links'; kind='folder'; admin=$false; enum=$false; note='Hashed visited-URL table; appears on actively used profiles.' }
    @{ cat='browsers'; name='Chromium Network Action Predictor'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Network Action Predictor'; kind='folder'; admin=$false; enum=$false; note='Maps typed letters to predicted URLs; record of partial typing.' }
    @{ cat='browsers'; name='Chromium Media History'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Media History'; kind='folder'; admin=$false; enum=$false; note='Audio/video played in-browser; appears on profiles that played media.' }
    @{ cat='browsers'; name='Chromium Preferences'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Preferences'; kind='folder'; admin=$false; enum=$false; note='Account email, per-site permissions (domain list), default download dir, search engine.' }
    @{ cat='browsers'; name='Chromium Sync Data'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Sync Data'; kind='folder'; admin=$false; enum=$false; note='Indicates profile linked to a vendor account for sync; pointer to a cloud copy.' }
    @{ cat='browsers'; name='Chromium Session Storage'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Session Storage'; kind='folder'; admin=$false; enum=$false; note='Per-origin session storage; confirms sites used.' }
    @{ cat='browsers'; name='Chromium Code Cache'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Code Cache'; kind='folder'; admin=$false; enum=$false; note='Compiled-script cache; size indicates retained site content.' }
    @{ cat='browsers'; name='Chromium GPUCache'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\GPUCache'; kind='folder'; admin=$false; enum=$false; note='Shader/GPU cache remnants of rendered content.' }
    @{ cat='browsers'; name='Chromium crash reports (Crashpad)'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Crashpad'; kind='folder'; admin=$false; enum=$false; note='Crash dumps can hold in-memory URLs/form text; repeat per vendor path.' }
    @{ cat='browsers'; name='Edge Collections'; path='%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Collections'; kind='folder'; admin=$false; enum=$false; note='User-curated saved pages, images and notes (often personal).' }
    @{ cat='browsers'; name='Edge Workspaces'; path='%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Workspaces'; kind='folder'; admin=$false; enum=$false; note='Tab groups by project; reveals work/topics.' }
    @{ cat='browsers'; name='Edge Wallet'; path='%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\EdgeWallet'; kind='folder'; admin=$false; enum=$false; note='Wallet UI state for saved payment/passwords; existence only.' }
    @{ cat='browsers'; name='Edge autofill/cards/addresses'; path='%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\Web Data'; kind='folder'; admin=$false; enum=$false; note='Edge saved cards (encrypted) and addresses; check every profile.' }
    @{ cat='browsers'; name='Firefox profiles root'; path='%APPDATA%\Mozilla\Firefox\Profiles'; kind='folder'; admin=$false; enum=$false; note='Per <id>.<name> profile: places.sqlite, cookies, formhistory, logins.json+key4.db, permissions, certs.' }
    @{ cat='browsers'; name='Firefox cache root'; path='%LOCALAPPDATA%\Mozilla\Firefox\Profiles'; kind='folder'; admin=$false; enum=$false; note='cache2 per profile; size indicates cached web content remnants.' }
    @{ cat='browsers'; name='Tor Browser install folder'; path='%USERPROFILE%\Desktop\Tor Browser'; kind='folder'; admin=$false; enum=$false; note='Existence alone signals Tor usage; also check Downloads and removable drives.' }
    @{ cat='browsers'; name='IE/legacy WinINET WebCache'; path='%LOCALAPPDATA%\Microsoft\Windows\WebCache'; kind='folder'; admin=$false; enum=$false; note='WebCacheV01.dat indexes legacy IE/Edge history, cookies, downloads; locked while in use.' }
    @{ cat='browsers'; name='IE/WinINET cache (INetCache)'; path='%LOCALAPPDATA%\Microsoft\Windows\INetCache'; kind='folder'; admin=$false; enum=$false; note='Temporary Internet Files; size indicates cached legacy browsing content.' }
    @{ cat='browsers'; name='IE/WinINET cookies (INetCookies)'; path='%LOCALAPPDATA%\Microsoft\Windows\INetCookies'; kind='folder'; admin=$false; enum=$false; note='Legacy cookie store; count indicates domains used via WinINET.' }
    @{ cat='browsers'; name='IE DOM storage'; path='%LOCALAPPDATA%\Microsoft\Internet Explorer\DOMStore'; kind='folder'; admin=$false; enum=$false; note='WinINET/IE DOM storage per site; domain list.' }
    @{ cat='browsers'; name='IE typed URLs'; path='HKCU:\Software\Microsoft\Internet Explorer\TypedURLs'; kind='registry'; admin=$false; enum=$false; note='Value count = addresses typed into IE / the hosted web control; separate from Edge/Chrome.' }
    @{ cat='browsers'; name='Legacy UWP (Spartan) Edge package'; path='%LOCALAPPDATA%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Only on devices upgraded from early Windows 10; old EdgeHTML history/favorites.' }
    @{ cat='browsers'; name='Arc user data'; path='%LOCALAPPDATA%\Arc\User Data'; kind='folder'; admin=$false; enum=$false; note='Chromium profile root; presence shows Arc was installed and used.' }
    @{ cat='browsers'; name='Yandex Browser user data'; path='%LOCALAPPDATA%\Yandex\YandexBrowser\User Data'; kind='folder'; admin=$false; enum=$false; note='Chromium profile root for Yandex Browser.' }
    @{ cat='browsers'; name='LibreWolf profiles'; path='%APPDATA%\librewolf\Profiles'; kind='folder'; admin=$false; enum=$false; note='Firefox-fork profile root (history, logins, cookies).' }
    @{ cat='browsers'; name='Waterfox profiles'; path='%APPDATA%\Waterfox\Profiles'; kind='folder'; admin=$false; enum=$false; note='Firefox-fork profile root.' }
    @{ cat='browsers'; name='Pale Moon profiles'; path='%APPDATA%\Moonchild Productions\Pale Moon\Profiles'; kind='folder'; admin=$false; enum=$false; note='Firefox-derived profile root under Moonchild Productions.' }
    @{ cat='browsers'; name='Maxthon legacy data'; path='%APPDATA%\Maxthon3'; kind='folder'; admin=$false; enum=$false; note='Confirmed legacy Maxthon 3 data; also scan %APPDATA%/%LOCALAPPDATA% for Maxthon/MX6 folders.' }
    @{ cat='browsers'; name='Maxthon registry key'; path='HKCU:\Software\Maxthon3'; kind='registry'; admin=$false; enum=$false; note='Presence indicates Maxthon was installed.' }
    @{ cat='browsers'; name='Chrome Beta profile'; path='%LOCALAPPDATA%\Google\Chrome Beta\User Data'; kind='folder'; admin=$false; enum=$false; note='Separate pre-release Chrome profile; history/autofill/cookies/extensions. Missed when only stable Chrome is cleaned.' }
    @{ cat='browsers'; name='Chrome Dev profile'; path='%LOCALAPPDATA%\Google\Chrome Dev\User Data'; kind='folder'; admin=$false; enum=$false; note='Separate Chrome Dev-channel profile tree, independent of stable.' }
    @{ cat='browsers'; name='Chrome Canary profile'; path='%LOCALAPPDATA%\Google\Chrome SxS\User Data'; kind='folder'; admin=$false; enum=$false; note='Chrome Canary uses the ''Chrome SxS'' folder; full browsing profile.' }
    @{ cat='browsers'; name='Edge Beta profile'; path='%LOCALAPPDATA%\Microsoft\Edge Beta\User Data'; kind='folder'; admin=$false; enum=$false; note='Separate pre-release Edge profile; history/autofill/cookies/extensions.' }
    @{ cat='browsers'; name='Edge Dev profile'; path='%LOCALAPPDATA%\Microsoft\Edge Dev\User Data'; kind='folder'; admin=$false; enum=$false; note='Separate Edge Dev-channel profile tree.' }
    @{ cat='browsers'; name='Edge Canary profile'; path='%LOCALAPPDATA%\Microsoft\Edge SxS\User Data'; kind='folder'; admin=$false; enum=$false; note='Edge Canary uses the ''Edge SxS'' folder; full browsing profile.' }
    @{ cat='browsers'; name='Thorium profile'; path='%LOCALAPPDATA%\Thorium\User Data'; kind='folder'; admin=$false; enum=$false; note='Thorium (Chromium fork) browsing profile.' }
    @{ cat='browsers'; name='Cent Browser profile'; path='%APPDATA%\CentBrowser\User Data'; kind='folder'; admin=$false; enum=$false; note='Cent Browser installed build stores in Roaming AppData; portable builds store beside the exe instead.' }
    @{ cat='browsers'; name='Comodo Dragon profile'; path='%LOCALAPPDATA%\Comodo\Dragon\User Data'; kind='folder'; admin=$false; enum=$false; note='Comodo Dragon (Chromium-based) browsing profile.' }
    @{ cat='browsers'; name='Comodo IceDragon profiles'; path='%APPDATA%\Comodo\IceDragon\Profiles'; kind='folder'; admin=$false; enum=$false; note='Comodo IceDragon (Firefox-based) Mozilla-style profile with history/logins; cache under %LOCALAPPDATA%\Comodo\IceDragon.' }
    @{ cat='browsers'; name='Epic Privacy Browser profile'; path='%LOCALAPPDATA%\Epic Privacy Browser\User Data'; kind='folder'; admin=$false; enum=$false; note='Epic Privacy Browser local profile; still records local history/autofill/cookies despite the name.' }
    @{ cat='browsers'; name='Avast Secure Browser profile'; path='%LOCALAPPDATA%\AVAST Software\Browser\User Data'; kind='folder'; admin=$false; enum=$false; note='Avast Secure Browser profile; often bundled with Avast AV.' }
    @{ cat='browsers'; name='AVG Secure Browser profile'; path='%LOCALAPPDATA%\AVG\Browser\User Data'; kind='folder'; admin=$false; enum=$false; note='AVG Secure Browser profile (shares Avast codebase); often bundled with AVG AV.' }
    @{ cat='browsers'; name='Naver Whale profile'; path='%LOCALAPPDATA%\Naver\Naver Whale\User Data'; kind='folder'; admin=$false; enum=$false; note='Naver Whale browsing profile; syncs to Naver account if signed in.' }
    @{ cat='browsers'; name='360 Browser profile'; path='%APPDATA%\360se6\User Data'; kind='folder'; admin=$false; enum=$false; note='360 Secure Browser v6+ path; 360 Extreme Explorer uses %LOCALAPPDATA%\360Chrome\Chrome\User Data. Folder varies by product/version.' }
    @{ cat='browsers'; name='CocCoc Browser profile'; path='%LOCALAPPDATA%\CocCoc\Browser\User Data'; kind='folder'; admin=$false; enum=$false; note='CocCoc (Vietnamese Chromium) browsing profile and download-manager list.' }
    @{ cat='browsers'; name='Falkon profile'; path='%APPDATA%\falkon\profiles'; kind='folder'; admin=$false; enum=$false; note='Falkon (Qt) profile; browsedata.db history/bookmarks, cookies, cache.' }
    @{ cat='browsers'; name='Midori data'; path='%APPDATA%\Midori'; kind='folder'; admin=$false; enum=$false; note='Current Midori (Electron) profile/history/cookies/cache.' }
    @{ cat='browsers'; name='qutebrowser data'; path='%LOCALAPPDATA%\qutebrowser\data'; kind='folder'; admin=$false; enum=$false; note='qutebrowser history.sqlite/cookies/sessions; config separately in %APPDATA%\qutebrowser\config.' }
    @{ cat='browsers'; name='Min data'; path='%APPDATA%\Min'; kind='folder'; admin=$false; enum=$false; note='Min (Electron) history/full-text index, tasks/tab groups, bookmarks, cookies.' }
    @{ cat='browsers'; name='Opera Crypto profile'; path='%APPDATA%\Opera Software\Opera Crypto'; kind='folder'; admin=$false; enum=$false; note='Opera Crypto Browser profile + built-in wallet refs; cache under %LOCALAPPDATA%. Opera One reuses the existing Opera Stable folder.' }
    # --- messaging (50) ---
    @{ cat='messaging'; name='Teams (new) package'; path='%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='New Teams MSIX; LocalCache/LocalState hold account, cached chats and media.' }
    @{ cat='messaging'; name='Teams (classic) data'; path='%APPDATA%\Microsoft\Teams'; kind='folder'; admin=$false; enum=$false; note='Legacy Electron Teams cache, IndexedDB, logs; persists after migration.' }
    @{ cat='messaging'; name='Slack data'; path='%APPDATA%\Slack'; kind='folder'; admin=$false; enum=$false; note='Direct-download build: workspaces, cache, local storage, drafts.' }
    @{ cat='messaging'; name='Discord data'; path='%APPDATA%\discord'; kind='folder'; admin=$false; enum=$false; note='Stable build; Local Storage leveldb holds the session. PTB/Canary use discordptb/discordcanary.' }
    @{ cat='messaging'; name='WhatsApp Desktop (Store)'; path='%LOCALAPPDATA%\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm'; kind='folder'; admin=$false; enum=$false; note='Store WhatsApp; LocalState holds linked-device session and cached chats/media.' }
    @{ cat='messaging'; name='WhatsApp Desktop (classic)'; path='%APPDATA%\WhatsApp'; kind='folder'; admin=$false; enum=$false; note='Older non-Store desktop build cache.' }
    @{ cat='messaging'; name='Telegram tdata'; path='%APPDATA%\Telegram Desktop\tdata'; kind='folder'; admin=$false; enum=$false; note='Complete encrypted logged-in session plus cached cloud chats.' }
    @{ cat='messaging'; name='Signal Desktop'; path='%APPDATA%\Signal'; kind='folder'; admin=$false; enum=$false; note='Local sql/db.sqlite message store and attachments; device-only history.' }
    @{ cat='messaging'; name='Zoom app data'; path='%APPDATA%\Zoom'; kind='folder'; admin=$false; enum=$false; note='Account, meeting history, in-meeting chat, contacts, logs.' }
    @{ cat='messaging'; name='Zoom local recordings'; path='%USERPROFILE%\Documents\Zoom'; kind='folder'; admin=$false; enum=$false; note='Default local recordings; audio/video + participant names, may have no cloud copy.' }
    @{ cat='messaging'; name='Skype (classic desktop)'; path='%APPDATA%\Microsoft\Skype for Desktop'; kind='folder'; admin=$false; enum=$false; note='Skype 8 Electron cache; retired 2025 but data persists.' }
    @{ cat='messaging'; name='Skype (Store)'; path='%LOCALAPPDATA%\Packages\Microsoft.SkypeApp_kzf8qxf38zg5c'; kind='folder'; admin=$false; enum=$false; note='UWP Skype LocalState/cache.' }
    @{ cat='messaging'; name='Viber'; path='%APPDATA%\ViberPC'; kind='folder'; admin=$false; enum=$false; note='Per-phone-number subfolder with message DB and media; downloads in Documents\ViberDownloads.' }
    @{ cat='messaging'; name='WeChat chat files (3.x)'; path='%USERPROFILE%\Documents\WeChat Files'; kind='folder'; admin=$false; enum=$false; note='Per-wxid chat/media store; WeChat 4.0 uses a configurable xwechat_files folder.' }
    @{ cat='messaging'; name='WeChat config'; path='%APPDATA%\Tencent\WeChat'; kind='folder'; admin=$false; enum=$false; note='Account and app configuration under Tencent.' }
    @{ cat='messaging'; name='LINE (PC client)'; path='%APPDATA%\LINE'; kind='folder'; admin=$false; enum=$false; note='Data/Cache with cached messages, media and contacts.' }
    @{ cat='messaging'; name='Element (Matrix)'; path='%APPDATA%\Element'; kind='folder'; admin=$false; enum=$false; note='IndexedDB/Local Storage with encrypted session, rooms, device keys (legacy %APPDATA%\Riot).' }
    @{ cat='messaging'; name='Keybase data'; path='%LOCALAPPDATA%\Keybase'; kind='folder'; admin=$false; enum=$false; note='Account, linked identities, cached chats/teams and KBFS cache.' }
    @{ cat='messaging'; name='Threema Desktop'; path='%APPDATA%\ThreemaDesktop'; kind='folder'; admin=$false; enum=$false; note='Linked Threema ID and cached chats; Store build lives under %LOCALAPPDATA%\Packages\ThreemaDesktop*.' }
    @{ cat='messaging'; name='Session data'; path='%APPDATA%\Session'; kind='folder'; admin=$false; enum=$false; note='Session account and encrypted local message database.' }
    @{ cat='messaging'; name='Wire data'; path='%APPDATA%\Wire'; kind='folder'; admin=$false; enum=$false; note='Wire account/team, cached conversations and device keys.' }
    @{ cat='messaging'; name='Mattermost data'; path='%APPDATA%\Mattermost'; kind='folder'; admin=$false; enum=$false; note='Server list (often employer URL), account and cached channels.' }
    @{ cat='messaging'; name='Rocket.Chat data'; path='%APPDATA%\Rocket.Chat'; kind='folder'; admin=$false; enum=$false; note='Connected server list, account and cached messages.' }
    @{ cat='messaging'; name='Guilded data'; path='%APPDATA%\Guilded'; kind='folder'; admin=$false; enum=$false; note='Guilded account, cached servers/DMs and session (Electron-convention path).' }
    @{ cat='messaging'; name='Ferdium/Franz/Rambox wrappers'; path='%APPDATA%\Ferdium'; kind='folder'; admin=$false; enum=$false; note='Multi-service wrapper; also check %APPDATA%\Franz and %APPDATA%\Rambox for the embedded-service list and sessions.' }
    @{ cat='messaging'; name='Webex App data'; path='%LOCALAPPDATA%\CiscoSpark'; kind='folder'; admin=$false; enum=$false; note='Webex App cache and local call-history database.' }
    @{ cat='messaging'; name='Webex Meetings cache'; path='%LOCALAPPDATA%\WebEx'; kind='folder'; admin=$false; enum=$false; note='Webex Meetings client cache (wbxcache).' }
    @{ cat='messaging'; name='GoToMeeting data'; path='%LOCALAPPDATA%\GoToMeeting'; kind='folder'; admin=$false; enum=$false; note='GoTo/GoToMeeting app data; local recordings default to %USERPROFILE%\Documents.' }
    @{ cat='messaging'; name='Skype for Business (Lync) cache'; path='%LOCALAPPDATA%\Microsoft\Office\16.0\Lync'; kind='folder'; admin=$false; enum=$false; note='SfB/Lync sip_<addr> folder: GAL cache, contacts, local conversation cache. 15.0 for Lync 2013.' }
    @{ cat='messaging'; name='Discord PTB data'; path='%APPDATA%\discordptb'; kind='folder'; admin=$false; enum=$false; note='Discord PTB test client: account, cached messages/images, session token in Local Storage. Separate from stable ''discord''.' }
    @{ cat='messaging'; name='Discord Canary data'; path='%APPDATA%\discordcanary'; kind='folder'; admin=$false; enum=$false; note='Discord Canary test client; same contents as PTB, separate folder.' }
    @{ cat='messaging'; name='Jami data'; path='%LOCALAPPDATA%\jami'; kind='folder'; admin=$false; enum=$false; note='Jami account archive (private identity), contacts, local call/message history. P2P, no server copy.' }
    @{ cat='messaging'; name='qTox / Tox profile'; path='%APPDATA%\tox'; kind='folder'; admin=$false; enum=$false; note='.tox profile holds Tox ID + private key + contacts; settings.ini; optional history.db.' }
    @{ cat='messaging'; name='Pidgin data'; path='%APPDATA%\.purple'; kind='folder'; admin=$false; enum=$false; note='accounts.xml (accounts, sometimes plaintext passwords), blist.xml buddy list, logs\ transcripts.' }
    @{ cat='messaging'; name='Trillian data'; path='%APPDATA%\Trillian'; kind='folder'; admin=$false; enum=$false; note='Trillian accounts, contact lists, local chat logs, cached media.' }
    @{ cat='messaging'; name='Miranda NG profile'; path='%APPDATA%\Miranda NG'; kind='folder'; admin=$false; enum=$false; note='Installer default profile: <profile>.dat database with accounts/contacts/history. Portable builds store beside the exe.' }
    @{ cat='messaging'; name='Jitsi Desktop data'; path='%APPDATA%\Jitsi'; kind='folder'; admin=$false; enum=$false; note='Legacy Jitsi SIP/XMPP client: sip-communicator.properties accounts, contactlist, history\.' }
    @{ cat='messaging'; name='Jitsi Meet (desktop) data'; path='%APPDATA%\Jitsi Meet'; kind='folder'; admin=$false; enum=$false; note='Jitsi Meet Electron app: recent meeting rooms/URLs, display name, settings.' }
    @{ cat='messaging'; name='Gajim data'; path='%APPDATA%\Gajim'; kind='folder'; admin=$false; enum=$false; note='Gajim (XMPP): logs.db chat archive, account config, roster.' }
    @{ cat='messaging'; name='HexChat data'; path='%APPDATA%\HexChat'; kind='folder'; admin=$false; enum=$false; note='IRC: hexchat.conf/servlist.conf (networks, nicks, saved NickServ passwords), logs\ transcripts.' }
    @{ cat='messaging'; name='mIRC data'; path='%APPDATA%\mIRC'; kind='folder'; admin=$false; enum=$false; note='mirc.ini (servers, nick, server passwords), logs\. Portable installs keep this beside the exe.' }
    @{ cat='messaging'; name='WeCom / WeChat Work data'; path='%APPDATA%\Tencent\WXWork'; kind='folder'; admin=$false; enum=$false; note='WeCom account/login state and cache; received files default to Documents\WXWork.' }
    @{ cat='messaging'; name='DingTalk data'; path='%APPDATA%\DingTalk'; kind='folder'; admin=$false; enum=$false; note='DingTalk account/login state and cache; some data in account-id subfolders. Exact root may vary by version.' }
    @{ cat='messaging'; name='Lark data'; path='%APPDATA%\Lark'; kind='folder'; admin=$false; enum=$false; note='Lark (international) Electron client: account, cached chats/docs/files.' }
    @{ cat='messaging'; name='Feishu data'; path='%APPDATA%\Feishu'; kind='folder'; admin=$false; enum=$false; note='Feishu (China edition of Lark) Electron client data.' }
    @{ cat='messaging'; name='KakaoTalk data'; path='%APPDATA%\Kakao\KakaoTalk'; kind='folder'; admin=$false; enum=$false; note='KakaoTalk account/login state and cache; received files default to Documents\KakaoTalk Downloads.' }
    @{ cat='messaging'; name='Zalo data'; path='%APPDATA%\ZaloPC'; kind='folder'; admin=$false; enum=$false; note='Zalo PC account/login state and cache; received files default to Documents\Zalo Received Files.' }
    @{ cat='messaging'; name='Caprine data'; path='%APPDATA%\Caprine'; kind='folder'; admin=$false; enum=$false; note='Caprine (Facebook Messenger Electron wrapper): logged-in FB session, cookies, cached conversations.' }
    @{ cat='messaging'; name='Ferdi data'; path='%APPDATA%\Ferdi'; kind='folder'; admin=$false; enum=$false; note='Ferdi service-wrapper: per-service logins/cookies/cache. Distinct folder from Ferdium/Franz/Rambox.' }
    @{ cat='messaging'; name='Phone Link / Your Phone'; path='%LOCALAPPDATA%\Packages\Microsoft.YourPhone_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='SMS/MMS, photos, call history, contacts, notifications mirrored from linked phone + MS account (verified package on Win11)' }
    # --- email (25) ---
    @{ cat='email'; name='Outlook classic OST/PST'; path='%LOCALAPPDATA%\Microsoft\Outlook'; kind='folder'; admin=$false; enum=$false; note='Cached mailbox .ost and older default .pst; offline mailbox copy.' }
    @{ cat='email'; name='Outlook PST (Documents default)'; path='%USERPROFILE%\Documents\Outlook Files'; kind='folder'; admin=$false; enum=$false; note='Default location for user-created .pst archives; may be the only copy of archived mail.' }
    @{ cat='email'; name='Outlook autocomplete (RoamCache)'; path='%LOCALAPPDATA%\Microsoft\Outlook\RoamCache'; kind='folder'; admin=$false; enum=$false; note='Stream_Autocomplete_*.dat nickname cache: everyone the owner has emailed.' }
    @{ cat='email'; name='Outlook signatures'; path='%APPDATA%\Microsoft\Signatures'; kind='folder'; admin=$false; enum=$false; note='Name, title, company, phone, address embedded in signatures.' }
    @{ cat='email'; name='Outlook profiles (registry)'; path='HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles'; kind='registry'; admin=$false; enum=$false; note='Count = configured accounts and server settings. 16.0=2016-365; also 15.0 for 2013.' }
    @{ cat='email'; name='New Outlook for Windows'; path='%LOCALAPPDATA%\Packages\Microsoft.OutlookForWindows_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Cloud-backed; LocalState/LocalCache hold added accounts and a web cache.' }
    @{ cat='email'; name='Thunderbird profiles'; path='%APPDATA%\Thunderbird\Profiles'; kind='folder'; admin=$false; enum=$false; note='mbox mail, global-messages-db.sqlite, logins.json+key4.db, address books, prefs.js accounts.' }
    @{ cat='email'; name='Betterbird profiles'; path='%APPDATA%\Betterbird\Profiles'; kind='folder'; admin=$false; enum=$false; note='Thunderbird fork, same profile structure.' }
    @{ cat='email'; name='Windows Mail/Calendar/People'; path='%LOCALAPPDATA%\Packages\microsoft.windowscommunicationsapps_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Shared comms-apps package; LocalState holds accounts and cached mail/calendar/contacts.' }
    @{ cat='email'; name='eM Client data'; path='%APPDATA%\eM Client'; kind='folder'; admin=$false; enum=$false; note='Local database: accounts, mail, calendar, contacts, saved credentials.' }
    @{ cat='email'; name='Mailbird data'; path='%LOCALAPPDATA%\Mailbird'; kind='folder'; admin=$false; enum=$false; note='Mailbird data folder (Store subfolder DB) per vendor backup guidance.' }
    @{ cat='email'; name='Mailspring data'; path='%APPDATA%\Mailspring'; kind='folder'; admin=$false; enum=$false; note='config.json (accounts), edgehill.db, local SQLite mail/contacts cache. Syncs via Foundry376 (Mailspring ID).' }
    @{ cat='email'; name='Postbox profiles'; path='%APPDATA%\Postbox\Profiles'; kind='folder'; admin=$false; enum=$false; note='Thunderbird-style profile: local mail stores, address book, saved logins. Cache under %LOCALAPPDATA%\Postbox.' }
    @{ cat='email'; name='Claws Mail data'; path='%APPDATA%\Claws-mail'; kind='folder'; admin=$false; enum=$false; note='accountrc + Mail\ MH store. Some Windows builds use %USERPROFILE%\.claws-mail instead.' }
    @{ cat='email'; name='The Bat! mail store'; path='%APPDATA%\The Bat!'; kind='folder'; admin=$false; enum=$false; note='Default mail store: .TBB message bases, address book, account.cfg. User may relocate the store elsewhere.' }
    @{ cat='email'; name='Spark data'; path='%APPDATA%\Spark Desktop'; kind='folder'; admin=$false; enum=$false; note='Readdle Spark Windows: accounts + local mail/contacts cache. Routes through Readdle cloud. Exact folder name approximate.' }
    @{ cat='email'; name='Canary Mail data'; path='%APPDATA%\Canary Mail'; kind='folder'; admin=$false; enum=$false; note='Canary Mail Windows: accounts, cached mail/contacts, PGP identities if used. Exact folder name approximate.' }
    @{ cat='email'; name='Windows Live Mail store'; path='%LOCALAPPDATA%\Microsoft\Windows Live Mail'; kind='folder'; admin=$false; enum=$false; note='Legacy WLM: per-account .eml message store, .oeaccount account files, local folders.' }
    @{ cat='email'; name='Opera Mail data'; path='%APPDATA%\Opera Mail\Opera Mail'; kind='folder'; admin=$false; enum=$false; note='Standalone Opera Mail: Mail\ store + index, accounts, wand.dat saved passwords.' }
    @{ cat='email'; name='Vivaldi Mail store'; path='%LOCALAPPDATA%\Vivaldi\User Data\Default\Mail'; kind='folder'; admin=$false; enum=$false; note='Vivaldi''s built-in mail store inside the browser profile; full local copy of all messages, plus contacts/feeds in the Default profile.' }
    @{ cat='email'; name='Spike data'; path='%APPDATA%\Spike'; kind='folder'; admin=$false; enum=$false; note='Spike (Electron) accounts + local conversation cache. Cloud-backed; copy persists on Spike servers until account deleted.' }
    @{ cat='email'; name='Sylpheed data'; path='%APPDATA%\Sylpheed'; kind='folder'; admin=$false; enum=$false; note='Sylpheed Windows: accountrc/config + Mailbox\ MH store. Mailbox folder can be relocated at setup.' }
    @{ cat='email'; name='Zimbra Desktop data'; path='%APPDATA%\Zimbra'; kind='folder'; admin=$false; enum=$false; note='Legacy/EOL Zimbra Desktop account state; the bulk mail/contacts/calendar store is chosen at install (install dir or user folder).' }
    @{ cat='email'; name='Outlook 2013 / 2010 mail profiles'; path='HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles'; kind='registry'; admin=$false; enum=$false; note='2010 profiles live under Windows Messaging Subsystem\Profiles; exposes accounts, servers, OST/PST paths. Existence only.' }
    @{ cat='email'; name='Outlook Autodiscover cache'; path='HKCU:\Software\Microsoft\Office\16.0\Outlook\AutoDiscover'; kind='registry'; admin=$false; enum=$false; note='Value names are looked-up email addresses; also XML under %LOCALAPPDATA%\Microsoft\Outlook. Count/existence only.' }
    # --- apps-media-gaming (135) ---
    @{ cat='apps-media-gaming'; name='Office Word recent files (MRU)'; path='HKCU:\Software\Microsoft\Office\16.0\Word\File MRU'; kind='registry'; admin=$false; enum=$false; note='Recent document paths; also Excel/PowerPoint/Access and Place MRU keys under 16.0.' }
    @{ cat='apps-media-gaming'; name='Office recent-document shortcuts'; path='%APPDATA%\Microsoft\Office\Recent'; kind='folder'; admin=$false; enum=$false; note='.lnk shortcuts to recently opened Office files.' }
    @{ cat='apps-media-gaming'; name='Office Document Cache'; path='%LOCALAPPDATA%\Microsoft\Office\16.0\OfficeFileCache'; kind='folder'; admin=$false; enum=$false; note='Locally cached copies of OneDrive/SharePoint docs edited in Office.' }
    @{ cat='apps-media-gaming'; name='OneNote desktop cache'; path='%LOCALAPPDATA%\Microsoft\OneNote\16.0\cache'; kind='folder'; admin=$false; enum=$false; note='Cached notebook pages held locally; Backup folder alongside.' }
    @{ cat='apps-media-gaming'; name='OneNote (Store) data'; path='%LOCALAPPDATA%\Packages\Microsoft.Office.OneNote_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='UWP OneNote cached pages/sections.' }
    @{ cat='apps-media-gaming'; name='Sticky Notes store'; path='%LOCALAPPDATA%\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='plum.sqlite holds all note text; existence/size only.' }
    @{ cat='apps-media-gaming'; name='Notepad unsaved tabs'; path='%LOCALAPPDATA%\Packages\Microsoft.WindowsNotepad_8wekyb3d8bbwe\LocalState\TabState'; kind='folder'; admin=$false; enum=$false; note='Unsaved Windows 11 Notepad tab content as .bin files.' }
    @{ cat='apps-media-gaming'; name='Acrobat/Reader recent files'; path='HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cRecentFiles'; kind='registry'; admin=$false; enum=$false; note='Recently opened PDF paths; Acrobat Pro under Adobe Acrobat\DC.' }
    @{ cat='apps-media-gaming'; name='Lightroom Classic catalogs'; path='%USERPROFILE%\Pictures\Lightroom'; kind='folder'; admin=$false; enum=$false; note='.lrcat catalogs reference every photo path/metadata/GPS/faces; default location.' }
    @{ cat='apps-media-gaming'; name='Adobe media cache'; path='%APPDATA%\Adobe\Common\Media Cache Files'; kind='folder'; admin=$false; enum=$false; note='Cached audio/video from Premiere/After Effects edits.' }
    @{ cat='apps-media-gaming'; name='VLC config and recents'; path='%APPDATA%\vlc'; kind='folder'; admin=$false; enum=$false; note='vlc-qt-interface.ini recents + vlcrc settings (recently played paths).' }
    @{ cat='apps-media-gaming'; name='Windows Media Player library'; path='%LOCALAPPDATA%\Microsoft\Media Player'; kind='folder'; admin=$false; enum=$false; note='Legacy WMP library DB (CurrentDatabase_*.wmdb) and play history.' }
    @{ cat='apps-media-gaming'; name='Media Player app (Win11)'; path='%LOCALAPPDATA%\Packages\Microsoft.ZuneMusic_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='New Media Player app database + recent-media history.' }
    @{ cat='apps-media-gaming'; name='Movies & TV app'; path='%LOCALAPPDATA%\Packages\Microsoft.ZuneVideo_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='Movies & TV recent / play history.' }
    @{ cat='apps-media-gaming'; name='MPC-HC recent files'; path='HKCU:\Software\MPC-HC\MPC-HC'; kind='registry'; admin=$false; enum=$false; note='Recent File List values; portable mode uses an .ini; MPC-BE under Software\MPC-BE.' }
    @{ cat='apps-media-gaming'; name='Spotify prefs and cache'; path='%APPDATA%\Spotify'; kind='folder'; admin=$false; enum=$false; note='Remembered username / auto-login + settings; offline cache under %LOCALAPPDATA%\Spotify.' }
    @{ cat='apps-media-gaming'; name='iTunes library'; path='%USERPROFILE%\Music\iTunes'; kind='folder'; admin=$false; enum=$false; note='Library DB, playlists, play history; Apple-authorized computer.' }
    @{ cat='apps-media-gaming'; name='Notion desktop data'; path='%APPDATA%\Notion'; kind='folder'; admin=$false; enum=$false; note='Workspace/account + cached pages and session.' }
    @{ cat='apps-media-gaming'; name='Obsidian vault list'; path='%APPDATA%\obsidian'; kind='folder'; admin=$false; enum=$false; note='obsidian.json records absolute vault paths; notes live in those folders.' }
    @{ cat='apps-media-gaming'; name='Evernote local data'; path='%LOCALAPPDATA%\Evernote'; kind='folder'; admin=$false; enum=$false; note='Cached notes (.exb legacy) + account.' }
    @{ cat='apps-media-gaming'; name='Joplin profile'; path='%APPDATA%\joplin-desktop'; kind='folder'; admin=$false; enum=$false; note='database.sqlite (all notes) + sync config that may hold a sync credential.' }
    @{ cat='apps-media-gaming'; name='VS Code workspace storage'; path='%APPDATA%\Code\User\workspaceStorage'; kind='folder'; admin=$false; enum=$false; note='Per-project state keyed to workspace folder paths. Insiders/VSCodium/Cursor variants differ.' }
    @{ cat='apps-media-gaming'; name='VS Code local history'; path='%APPDATA%\Code\User\History'; kind='folder'; admin=$false; enum=$false; note='Local edit history (earlier content of edited files).' }
    @{ cat='apps-media-gaming'; name='JetBrains recent projects'; path='%APPDATA%\JetBrains'; kind='folder'; admin=$false; enum=$false; note='recentProjects.xml per product holds recent project paths + account.' }
    @{ cat='apps-media-gaming'; name='Windows Terminal settings'; path='%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='settings.json/state.json: configured shells/SSH profiles, starting dirs, window layout.' }
    @{ cat='apps-media-gaming'; name='Steam user data'; path='%ProgramFiles(x86)%\Steam\userdata'; kind='folder'; admin=$false; enum=$false; note='Per-account settings, screenshots, cloud-save staging; authoritative path in SteamPath.' }
    @{ cat='apps-media-gaming'; name='Epic Games Launcher saved'; path='%LOCALAPPDATA%\EpicGamesLauncher\Saved'; kind='folder'; admin=$false; enum=$false; note='Config + encrypted stay-signed-in token; existence/size only.' }
    @{ cat='apps-media-gaming'; name='Riot Client data'; path='%LOCALAPPDATA%\Riot Games'; kind='folder'; admin=$false; enum=$false; note='Private-settings yaml keeps the Riot login; existence only.' }
    @{ cat='apps-media-gaming'; name='Battle.net config'; path='%APPDATA%\Battle.net'; kind='folder'; admin=$false; enum=$false; note='Keep-logged-in token + cached account hint.' }
    @{ cat='apps-media-gaming'; name='EA app data'; path='%LOCALAPPDATA%\Electronic Arts'; kind='folder'; admin=$false; enum=$false; note='EA Desktop session/games; Origin legacy at %APPDATA%\Origin.' }
    @{ cat='apps-media-gaming'; name='Ubisoft Connect'; path='%LOCALAPPDATA%\Ubisoft Game Launcher'; kind='folder'; admin=$false; enum=$false; note='Saved login + local savegames cache.' }
    @{ cat='apps-media-gaming'; name='GOG Galaxy'; path='%PROGRAMDATA%\GOG.com\Galaxy'; kind='folder'; admin=$false; enum=$false; note='galaxy-2.0.db: account, owned games, friends.' }
    @{ cat='apps-media-gaming'; name='Xbox Game Bar captures'; path='%USERPROFILE%\Videos\Captures'; kind='folder'; admin=$false; enum=$false; note='Screen recordings/screenshots (anything on screen when recording).' }
    @{ cat='apps-media-gaming'; name='Game saves (My Games)'; path='%USERPROFILE%\Documents\My Games'; kind='folder'; admin=$false; enum=$false; note='Per-game local saves + config; may be OneDrive-redirected.' }
    @{ cat='apps-media-gaming'; name='Unity/other game data (LocalLow)'; path='%USERPROFILE%\AppData\LocalLow'; kind='folder'; admin=$false; enum=$false; note='Per-company game saves/settings; PlayerPrefs also in HKCU:\Software\<company>.' }
    @{ cat='apps-media-gaming'; name='Standard Notes'; path='%APPDATA%\Standard Notes'; kind='folder'; admin=$false; enum=$false; note='Account and encrypted local notes DB (existence/count only).' }
    @{ cat='apps-media-gaming'; name='Simplenote'; path='%APPDATA%\Simplenote'; kind='folder'; admin=$false; enum=$false; note='Account and cached notes (Simplenote notes are not E2E encrypted).' }
    @{ cat='apps-media-gaming'; name='Logseq config'; path='%USERPROFILE%\.logseq'; kind='folder'; admin=$false; enum=$false; note='Logseq config, plugins and graph cache (.logseq\graphs).' }
    @{ cat='apps-media-gaming'; name='Logseq app data'; path='%APPDATA%\Logseq'; kind='folder'; admin=$false; enum=$false; note='Logseq app data and logs; graph folders themselves are user-chosen.' }
    @{ cat='apps-media-gaming'; name='Roam Research app'; path='%APPDATA%\Roam Research'; kind='folder'; admin=$false; enum=$false; note='Electron desktop cache/session; exact folder name unconfirmed (Roam is web-hosted).' }
    @{ cat='apps-media-gaming'; name='Microsoft To Do package'; path='%LOCALAPPDATA%\Packages\Microsoft.Todos_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Microsoft account and cached task lists/reminders.' }
    @{ cat='apps-media-gaming'; name='Microsoft Journal package'; path='%LOCALAPPDATA%\Packages\Microsoft.Journal_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Microsoft Journal app data; confirm exact package family name.' }
    @{ cat='apps-media-gaming'; name='Journal notebooks'; path='%USERPROFILE%\Documents\Journals'; kind='folder'; admin=$false; enum=$false; note='Default Microsoft Journal notebook save location; also scan Documents for legacy .jnt/.jtp files.' }
    @{ cat='apps-media-gaming'; name='Kodi user data'; path='%APPDATA%\Kodi\userdata'; kind='folder'; admin=$false; enum=$false; note='Watch history, media sources, add-on logins; existence/size only.' }
    @{ cat='apps-media-gaming'; name='PotPlayer settings'; path='HKCU:\Software\DAUM\PotPlayer64'; kind='registry'; admin=$false; enum=$false; note='Recently played files/URLs and bookmarks (also PotPlayer key for 32-bit).' }
    @{ cat='apps-media-gaming'; name='foobar2000 profile'; path='%APPDATA%\foobar2000-v2'; kind='folder'; admin=$false; enum=$false; note='Playlists and play statistics; also %APPDATA%\foobar2000 for v1.' }
    @{ cat='apps-media-gaming'; name='MusicBee data'; path='%APPDATA%\MusicBee'; kind='folder'; admin=$false; enum=$false; note='Library database, recently/most played history.' }
    @{ cat='apps-media-gaming'; name='AIMP data'; path='%APPDATA%\AIMP'; kind='folder'; admin=$false; enum=$false; note='Playlists, bookmarks, recently played state.' }
    @{ cat='apps-media-gaming'; name='Winamp data'; path='%APPDATA%\Winamp'; kind='folder'; admin=$false; enum=$false; note='Current playlist, history plug-in recent.dat, media library.' }
    @{ cat='apps-media-gaming'; name='qBittorrent resume data'; path='%LOCALAPPDATA%\qBittorrent\BT_backup'; kind='folder'; admin=$false; enum=$false; note='Per-torrent .torrent/.fastresume: names, save paths, trackers (count only).' }
    @{ cat='apps-media-gaming'; name='qBittorrent config'; path='%APPDATA%\qBittorrent'; kind='folder'; admin=$false; enum=$false; note='Settings and last save path.' }
    @{ cat='apps-media-gaming'; name='uTorrent data'; path='%APPDATA%\uTorrent'; kind='folder'; admin=$false; enum=$false; note='resume.dat lists every torrent and save path.' }
    @{ cat='apps-media-gaming'; name='BitTorrent data'; path='%APPDATA%\BitTorrent'; kind='folder'; admin=$false; enum=$false; note='Same resume/settings data as uTorrent for the BitTorrent client.' }
    @{ cat='apps-media-gaming'; name='IDM download list'; path='HKCU:\Software\DownloadManager'; kind='registry'; admin=$false; enum=$false; note='Internet Download Manager history: file names and source URLs.' }
    @{ cat='apps-media-gaming'; name='JDownloader cfg'; path='%LOCALAPPDATA%\JDownloader 2.0\cfg'; kind='folder'; admin=$false; enum=$false; note='downloadList/linkcollector zips; install path varies, flag if missing.' }
    @{ cat='apps-media-gaming'; name='OBS Studio profiles'; path='%APPDATA%\obs-studio'; kind='folder'; admin=$false; enum=$false; note='Scenes/sources and streaming service; flag presence only, do not open service.json.' }
    @{ cat='apps-media-gaming'; name='NVIDIA GeForce Experience'; path='%LOCALAPPDATA%\NVIDIA Corporation\GeForceExperience'; kind='folder'; admin=$false; enum=$false; note='Signed-in NVIDIA account/config; ShadowPlay clips default to %USERPROFILE%\Videos.' }
    @{ cat='apps-media-gaming'; name='Camtasia output'; path='%USERPROFILE%\Documents\Camtasia'; kind='folder'; admin=$false; enum=$false; note='Screen-recording projects (.tscproj) and raw captures (.trec).' }
    @{ cat='apps-media-gaming'; name='Bandicam output'; path='%USERPROFILE%\Documents\Bandicam'; kind='folder'; admin=$false; enum=$false; note='Default captured videos/screenshots folder.' }
    @{ cat='apps-media-gaming'; name='ShareX history'; path='%USERPROFILE%\Documents\ShareX'; kind='folder'; admin=$false; enum=$false; note='History.json logs every capture and upload URL; Screenshots subfolder.' }
    @{ cat='apps-media-gaming'; name='LibreOffice profile'; path='%APPDATA%\LibreOffice\4\user'; kind='folder'; admin=$false; enum=$false; note='registrymodifications.xcu holds recent-documents list and user name.' }
    @{ cat='apps-media-gaming'; name='OpenOffice profile'; path='%APPDATA%\OpenOffice\4\user'; kind='folder'; admin=$false; enum=$false; note='Apache OpenOffice recent-documents list and settings.' }
    @{ cat='apps-media-gaming'; name='WPS Office data'; path='%APPDATA%\Kingsoft\Office6'; kind='folder'; admin=$false; enum=$false; note='Recent-document history and signed-in WPS account.' }
    @{ cat='apps-media-gaming'; name='Foxit recent files'; path='HKCU:\Software\Foxit Software'; kind='registry'; admin=$false; enum=$false; note='Recent File List for Foxit Reader/PDF Editor; product/version segment varies.' }
    @{ cat='apps-media-gaming'; name='SumatraPDF settings'; path='%LOCALAPPDATA%\SumatraPDF'; kind='folder'; admin=$false; enum=$false; note='SumatraPDF-settings.txt FileStates lists every document opened with path.' }
    @{ cat='apps-media-gaming'; name='mpv watch-later'; path='%APPDATA%\mpv\watch_later'; kind='folder'; admin=$false; enum=$false; note='Resume-position files; each references a watched media path. Existence/count shows playback history.' }
    @{ cat='apps-media-gaming'; name='Audacious data'; path='%APPDATA%\audacious'; kind='folder'; admin=$false; enum=$false; note='Config plus playlists folder referencing audio file paths. Confirmed present on this machine.' }
    @{ cat='apps-media-gaming'; name='SMPlayer config'; path='%APPDATA%\smplayer'; kind='folder'; admin=$false; enum=$false; note='smplayer.ini recents and per-file saved positions.' }
    @{ cat='apps-media-gaming'; name='QMPlay2 config'; path='%APPDATA%\QMPlay2'; kind='folder'; admin=$false; enum=$false; note='Settings and playlist with recently played media.' }
    @{ cat='apps-media-gaming'; name='MPC-BE settings'; path='HKCU:\Software\MPC-BE\MPC-BE'; kind='registry'; admin=$false; enum=$false; note='Recent-file list and favorites (portable builds use an .ini beside the exe instead).' }
    @{ cat='apps-media-gaming'; name='Clementine library DB'; path='%LOCALAPPDATA%\Clementine\Clementine'; kind='folder'; admin=$false; enum=$false; note='clementine.db music-library database (paths, play counts).' }
    @{ cat='apps-media-gaming'; name='Strawberry library DB'; path='%LOCALAPPDATA%\Strawberry\Strawberry'; kind='folder'; admin=$false; enum=$false; note='strawberry.db music-library database.' }
    @{ cat='apps-media-gaming'; name='Plex Media Server data'; path='%LOCALAPPDATA%\Plex Media Server'; kind='folder'; admin=$false; enum=$false; note='Server library DB, metadata and caches; indexes every media file path and watch history.' }
    @{ cat='apps-media-gaming'; name='Plex Media Server registry'; path='HKCU:\Software\Plex, Inc.\Plex Media Server'; kind='registry'; admin=$false; enum=$false; note='Server registration/config keys.' }
    @{ cat='apps-media-gaming'; name='Plex HTPC client'; path='%LOCALAPPDATA%\Plex HTPC'; kind='folder'; admin=$false; enum=$false; note='Client config; signed-in Plex account and connected servers. Exact folder name unconfirmed.' }
    @{ cat='apps-media-gaming'; name='Jellyfin Media Player'; path='%LOCALAPPDATA%\JellyfinMediaPlayer'; kind='folder'; admin=$false; enum=$false; note='Client config; Jellyfin server address and username (also may be under %APPDATA%).' }
    @{ cat='apps-media-gaming'; name='Emby Theater'; path='%APPDATA%\Emby Theater'; kind='folder'; admin=$false; enum=$false; note='Client config; Emby server and account. Exact folder name unconfirmed.' }
    @{ cat='apps-media-gaming'; name='GIMP config'; path='%APPDATA%\GIMP'; kind='folder'; admin=$false; enum=$false; note='Per-version subfolders (2.10 / 3.0) with settings and recently-opened document history.' }
    @{ cat='apps-media-gaming'; name='Inkscape config'; path='%APPDATA%\inkscape'; kind='folder'; admin=$false; enum=$false; note='preferences.xml with recent-file list and last-used folders.' }
    @{ cat='apps-media-gaming'; name='Blender config'; path='%APPDATA%\Blender Foundation\Blender'; kind='folder'; admin=$false; enum=$false; note='Per-version config\recent-files.txt (recent .blend paths) and bookmarks.txt.' }
    @{ cat='apps-media-gaming'; name='Krita config/resources'; path='%APPDATA%\krita'; kind='folder'; admin=$false; enum=$false; note='Resource folder and kritarc recent-documents list (kritarc may alternatively be under %LOCALAPPDATA%).' }
    @{ cat='apps-media-gaming'; name='DaVinci Resolve support'; path='%APPDATA%\Blackmagic Design\DaVinci Resolve'; kind='folder'; admin=$false; enum=$false; note='Preferences, layouts, logs, gallery stills, caches. Local project disk-database path varies (see uncertainties).' }
    @{ cat='apps-media-gaming'; name='Audacity config'; path='%APPDATA%\audacity'; kind='folder'; admin=$false; enum=$false; note='audacity.cfg [RecentFiles] and auto-save recovery data. Confirmed present on this machine.' }
    @{ cat='apps-media-gaming'; name='Kdenlive cache'; path='%LOCALAPPDATA%\kdenlive'; kind='folder'; admin=$false; enum=$false; note='Proxy clips and thumbnails of your footage; recent projects live in kdenliverc config (location varies).' }
    @{ cat='apps-media-gaming'; name='Shotcut config'; path='%APPDATA%\Meltytech'; kind='folder'; admin=$false; enum=$false; note='Shotcut.ini recent-project list with full paths.' }
    @{ cat='apps-media-gaming'; name='HandBrake config'; path='%APPDATA%\HandBrake'; kind='folder'; admin=$false; enum=$false; note='settings.json last source/destination paths; presets.json; logs.' }
    @{ cat='apps-media-gaming'; name='Paint.NET settings'; path='%LOCALAPPDATA%\paint.net'; kind='folder'; admin=$false; enum=$false; note='Classic-install settings incl. recent files; Store build lives under %LOCALAPPDATA%\Packages\dotPDNLLC.paintdotnet*.' }
    @{ cat='apps-media-gaming'; name='Clip Studio Paint settings'; path='%APPDATA%\CELSYSUserData'; kind='folder'; admin=$false; enum=$false; note='Settings/user data (also %APPDATA%\CELSYS).' }
    @{ cat='apps-media-gaming'; name='Clip Studio Paint documents'; path='%USERPROFILE%\Documents\CELSYS'; kind='folder'; admin=$false; enum=$false; note='Document catalog/management DB in a version-named subfolder; recent .clip references.' }
    @{ cat='apps-media-gaming'; name='Affinity apps'; path='%APPDATA%\Affinity'; kind='folder'; admin=$false; enum=$false; note='Per-app (Photo/Designer/Publisher) settings and recent-documents list; Store builds under %LOCALAPPDATA%\Packages.' }
    @{ cat='apps-media-gaming'; name='FL Studio user data'; path='%USERPROFILE%\Documents\Image-Line'; kind='folder'; admin=$false; enum=$false; note='Default Projects/Presets/Data and user settings.' }
    @{ cat='apps-media-gaming'; name='FL Studio registry'; path='HKCU:\Software\Image-Line'; kind='registry'; admin=$false; enum=$false; note='App config and recent-files list.' }
    @{ cat='apps-media-gaming'; name='Ableton Live preferences'; path='%APPDATA%\Ableton'; kind='folder'; admin=$false; enum=$false; note='Per-version Preferences with recent Live Set references and log.' }
    @{ cat='apps-media-gaming'; name='REAPER config'; path='%APPDATA%\REAPER'; kind='folder'; admin=$false; enum=$false; note='reaper.ini recent-project list and render/import folders (portable installs keep this beside the exe).' }
    @{ cat='apps-media-gaming'; name='Cakewalk registry'; path='HKCU:\Software\Cakewalk Music Software\Cakewalk'; kind='registry'; admin=$false; enum=$false; note='Recent-project MRU and settings (subkey naming varies by version).' }
    @{ cat='apps-media-gaming'; name='Cakewalk config'; path='%APPDATA%\Cakewalk'; kind='folder'; admin=$false; enum=$false; note='Cakewalk Core configuration folder.' }
    @{ cat='apps-media-gaming'; name='Calibre config'; path='%APPDATA%\calibre'; kind='folder'; admin=$false; enum=$false; note='Settings, viewer reading-position state, and stored library locations.' }
    @{ cat='apps-media-gaming'; name='Calibre library'; path='%USERPROFILE%\Calibre Library'; kind='folder'; admin=$false; enum=$false; note='Default library: metadata.db and book files in author/title subfolders (user may have chosen another folder).' }
    @{ cat='apps-media-gaming'; name='Kindle for PC content'; path='%USERPROFILE%\Documents\My Kindle Content'; kind='folder'; admin=$false; enum=$false; note='Downloaded book files (.azw/.kfx).' }
    @{ cat='apps-media-gaming'; name='Kindle for PC app data'; path='%LOCALAPPDATA%\Amazon\Kindle'; kind='folder'; admin=$false; enum=$false; note='Signed-in Amazon account/device registration and cache (newer builds also %APPDATA%\Amazon\Kindle).' }
    @{ cat='apps-media-gaming'; name='Adobe Digital Editions library'; path='%USERPROFILE%\Documents\My Digital Editions'; kind='folder'; admin=$false; enum=$false; note='EPUB/PDF ebook files and library database.' }
    @{ cat='apps-media-gaming'; name='Adobe Digital Editions activation'; path='%APPDATA%\Adobe\Digital Editions'; kind='folder'; admin=$false; enum=$false; note='Authorized Adobe ID activation data (also %LOCALAPPDATA%\Adobe\Digital Editions).' }
    @{ cat='apps-media-gaming'; name='Icecream Ebook Reader'; path='%APPDATA%\Icecream Ebook Reader'; kind='folder'; admin=$false; enum=$false; note='Library database, recently read, bookmarks.' }
    @{ cat='apps-media-gaming'; name='ONLYOFFICE Desktop Editors'; path='%APPDATA%\ONLYOFFICE\DesktopEditors'; kind='folder'; admin=$false; enum=$false; note='Recent-files list, settings, recent-document cache, connected portals.' }
    @{ cat='apps-media-gaming'; name='SoftMaker/FreeOffice registry'; path='HKCU:\Software\SoftMaker'; kind='registry'; admin=$false; enum=$false; note='Per-product, version-specific recent-file MRU.' }
    @{ cat='apps-media-gaming'; name='SoftMaker/FreeOffice data'; path='%APPDATA%\SoftMaker'; kind='folder'; admin=$false; enum=$false; note='User dictionaries, templates, settings.' }
    @{ cat='apps-media-gaming'; name='AbiWord profile'; path='%APPDATA%\AbiSuite'; kind='folder'; admin=$false; enum=$false; note='AbiWord.Profile recent-file MRU and settings.' }
    @{ cat='apps-media-gaming'; name='PDF-XChange Editor registry'; path='HKCU:\Software\Tracker Software\PDFXEditor'; kind='registry'; admin=$false; enum=$false; note='Recent-file MRU and settings (subkey name/version suffix varies).' }
    @{ cat='apps-media-gaming'; name='PDF-XChange Editor data'; path='%APPDATA%\Tracker Software'; kind='folder'; admin=$false; enum=$false; note='Config and cache.' }
    @{ cat='apps-media-gaming'; name='itch.io app'; path='%APPDATA%\itch'; kind='folder'; admin=$false; enum=$false; note='itch.io account + owned/installed indie games in db\butler.db; binaries in %LOCALAPPDATA%\itch' }
    @{ cat='apps-media-gaming'; name='Amazon Games'; path='%LOCALAPPDATA%\Amazon Games'; kind='folder'; admin=$false; enum=$false; note='Amazon account session + installed/Prime Gaming titles; games default to C:\Amazon Games' }
    @{ cat='apps-media-gaming'; name='Rockstar Games Launcher'; path='%LOCALAPPDATA%\Rockstar Games'; kind='folder'; admin=$false; enum=$false; note='Social Club offline sign-in cache; per-game profiles also in Documents\Rockstar Games' }
    @{ cat='apps-media-gaming'; name='Paradox Launcher'; path='%USERPROFILE%\Documents\Paradox Interactive'; kind='folder'; admin=$false; enum=$false; note='Per-game saves/settings/mods; launcher account data in %LOCALAPPDATA%\Paradox Interactive' }
    @{ cat='apps-media-gaming'; name='Humble App'; path='%APPDATA%\Humble App'; kind='folder'; admin=$false; enum=$false; note='Signed-in Humble account + owned/installed library (exact folder name not verified on reference machine)' }
    @{ cat='apps-media-gaming'; name='Playnite'; path='%APPDATA%\Playnite'; kind='folder'; admin=$false; enum=$false; note='library.db = cross-store game library + play time; extensions may hold linked-store tokens; portable variant beside exe' }
    @{ cat='apps-media-gaming'; name='Legacy Games Launcher'; path='%APPDATA%\legacy-games-launcher'; kind='folder'; admin=$false; enum=$false; note='Account email; often OEM pre-installed with prior user signed in; Electron folder name may also appear as ''Legacy Games''' }
    @{ cat='apps-media-gaming'; name='Dolphin Emulator (GameCube/Wii)'; path='%USERPROFILE%\Documents\Dolphin Emulator'; kind='folder'; admin=$false; enum=$false; note='GC memory cards, Wii NAND (profile/Mii/saves), game list; portable build keeps these beside exe' }
    @{ cat='apps-media-gaming'; name='PCSX2 (PS2)'; path='%USERPROFILE%\Documents\PCSX2'; kind='folder'; admin=$false; enum=$false; note='memcards (PS2 saves), sstates, inis/game list; portable build keeps these beside exe' }
    @{ cat='apps-media-gaming'; name='DuckStation (PS1)'; path='%USERPROFILE%\Documents\DuckStation'; kind='folder'; admin=$false; enum=$false; note='memcards, savestates, cached game list (ROM names/paths); portable build keeps these beside exe' }
    @{ cat='apps-media-gaming'; name='Ryujinx (Switch)'; path='%APPDATA%\Ryujinx'; kind='folder'; admin=$false; enum=$false; note='Switch profiles + bis save data, system keys/firmware, games list; portable subfolder variant exists' }
    @{ cat='apps-media-gaming'; name='yuzu (Switch, defunct)'; path='%APPDATA%\yuzu'; kind='folder'; admin=$false; enum=$false; note='nand profiles+saves, keys; project shut down 2024 but data folder remains' }
    @{ cat='apps-media-gaming'; name='Citra (3DS, defunct)'; path='%APPDATA%\Citra'; kind='folder'; admin=$false; enum=$false; note='sdmc save data, nand, Mii/profile; project shut down 2024 but data folder remains' }
    @{ cat='apps-media-gaming'; name='PPSSPP (PSP)'; path='%USERPROFILE%\Documents\PPSSPP'; kind='folder'; admin=$false; enum=$false; note='Installer memstick: PSP\SAVEDATA saves, ppsspp.ini recent-games list; zip build uses memstick beside exe' }
    @{ cat='apps-media-gaming'; name='Clipchamp video editor'; path='%LOCALAPPDATA%\Packages\Clipchamp.Clipchamp_yxz26nhyzhsrt'; kind='folder'; admin=$false; enum=$false; note='Video projects + references to personal footage, cached media, signed-in account (verified package on Win11)' }
    @{ cat='apps-media-gaming'; name='Paint and Paint 3D'; path='%LOCALAPPDATA%\Packages\Microsoft.Paint_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='New Paint verified on Win11; Paint 3D (if installed) at Microsoft.MSPaint_8wekyb3d8bbwe; recent image paths also in RecentDocs' }
    @{ cat='apps-media-gaming'; name='Calculator history'; path='%LOCALAPPDATA%\Packages\Microsoft.WindowsCalculator_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='Calculation history + memory entries (low sensitivity); verified package on Win11' }
    @{ cat='apps-media-gaming'; name='Weather app saved locations'; path='%LOCALAPPDATA%\Packages\Microsoft.BingWeather_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='Home/work/favorite cities = where prior user lives/travels; verified package on Win11; may resync from MS account' }
    @{ cat='apps-media-gaming'; name='News app interests and locations'; path='%LOCALAPPDATA%\Packages\Microsoft.BingNews_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='Followed topics/interests + locations (can imply politics/health/hobbies); verified package on Win11; may resync from MS account' }
    @{ cat='apps-media-gaming'; name='Feedback Hub'; path='%LOCALAPPDATA%\Packages\Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='Draft/submitted feedback text + attached screenshots/diagnostics + MS account; present only if app used (not installed on reference machine)' }
    @{ cat='apps-media-gaming'; name='Widgets board (Web Experience)'; path='%LOCALAPPDATA%\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy'; kind='folder'; admin=$false; enum=$false; note='MS account, weather-widget location, feed interests, pinned-widget data (calendar/To Do/Outlook); verified package on Win11' }
    @{ cat='apps-media-gaming'; name='Clock app (alarms/world clock/focus)'; path='%LOCALAPPDATA%\Packages\Microsoft.WindowsAlarms_8wekyb3d8bbwe\LocalState'; kind='folder'; admin=$false; enum=$false; note='Alarm labels (routines/meds/appointments), world-clock cities, focus-session data; verified package on Win11' }
    @{ cat='apps-media-gaming'; name='Classic Paint settings'; path='HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Paint'; kind='registry'; admin=$false; enum=$false; note='Classic mspaint settings; recently opened image paths surface via RecentDocs rather than here' }
    @{ cat='apps-media-gaming'; name='Office 2013 File MRU / Place MRU (Word, Excel, PowerPoint)'; path='HKCU:\Software\Microsoft\Office\15.0\Word\File MRU'; kind='registry'; admin=$false; enum=$false; note='Version 15.0; also Excel and PowerPoint; Place MRU holds recent folders incl. network/cloud paths. Count/existence only.' }
    @{ cat='apps-media-gaming'; name='Office 2010 File MRU (Word, Excel, PowerPoint)'; path='HKCU:\Software\Microsoft\Office\14.0\Word\File MRU'; kind='registry'; admin=$false; enum=$false; note='Version 14.0; also Excel and PowerPoint; no Place MRU in 2010. Count/existence only.' }
    @{ cat='apps-media-gaming'; name='Acrobat/Reader recent files (2020, 2017, 11.0 tracks)'; path='HKCU:\Software\Adobe\Acrobat Reader\2020\AVGeneral\cRecentFiles'; kind='registry'; admin=$false; enum=$false; note='Also tracks 2017 and 11.0, and the ''Adobe Acrobat'' full-product paths; tDIText holds PDF paths. Count/existence only.' }
    # --- finance-crypto (30) ---
    @{ cat='finance-crypto'; name='TurboTax return files'; path='%USERPROFILE%\Documents\TurboTax'; kind='folder'; admin=$false; enum=$false; note='Count .tax20## return files (each holds SSNs and full return); existence/count only, never open.' }
    @{ cat='finance-crypto'; name='H&R Block return files'; path='%USERPROFILE%\Documents\HRBlock'; kind='folder'; admin=$false; enum=$false; note='Count .T## tax return files; existence/count only.' }
    @{ cat='finance-crypto'; name='Quicken data file'; path='%USERPROFILE%\Documents\Quicken'; kind='folder'; admin=$false; enum=$false; note='Detect .QDF/.QDF-backup files; existence only.' }
    @{ cat='finance-crypto'; name='QuickBooks company files'; path='%PUBLIC%\Documents\Intuit\QuickBooks\Company Files'; kind='folder'; admin=$false; enum=$false; note='Detect .QBW/.QBB company files; existence only.' }
    @{ cat='finance-crypto'; name='GnuCash config/history'; path='%LOCALAPPDATA%\GnuCash'; kind='folder'; admin=$false; enum=$false; note='Presence of GnuCash config and recent-books list; existence only.' }
    @{ cat='finance-crypto'; name='Exodus wallet folder'; path='%APPDATA%\Exodus'; kind='folder'; admin=$false; enum=$false; note='Wallet present (exodus.wallet holds encrypted seed); existence only, never open files.' }
    @{ cat='finance-crypto'; name='Electrum wallets'; path='%APPDATA%\Electrum\wallets'; kind='folder'; admin=$false; enum=$false; note='Count wallet files (may be unencrypted); existence only, never read contents.' }
    @{ cat='finance-crypto'; name='Ledger Live data'; path='%APPDATA%\Ledger Live'; kind='folder'; admin=$false; enum=$false; note='Accounts/addresses present (seed stays on hardware); existence only.' }
    @{ cat='finance-crypto'; name='Atomic wallet folder'; path='%APPDATA%\atomic'; kind='folder'; admin=$false; enum=$false; note='Wallet data present (encrypted keys); existence only.' }
    @{ cat='finance-crypto'; name='Wasabi wallet folder'; path='%APPDATA%\WalletWasabi'; kind='folder'; admin=$false; enum=$false; note='Bitcoin privacy wallet present; existence only.' }
    @{ cat='finance-crypto'; name='Authy Desktop vault'; path='%APPDATA%\Authy Desktop'; kind='folder'; admin=$false; enum=$false; note='TOTP vault present (which accounts have 2FA); existence only, never read seeds.' }
    @{ cat='finance-crypto'; name='WinAuth file'; path='%APPDATA%\WinAuth'; kind='folder'; admin=$false; enum=$false; note='Detect winauth.xml (TOTP/HOTP entries); existence only, never parse.' }
    @{ cat='finance-crypto'; name='Intuit products (registry)'; path='HKCU:\Software\Intuit'; kind='registry'; admin=$false; enum=$false; note='Reveals installed Intuit products (TurboTax/Quicken/QuickBooks); product names only.' }
    @{ cat='finance-crypto'; name='Bitcoin Core'; path='%APPDATA%\Bitcoin'; kind='folder'; admin=$false; enum=$false; note='Bitcoin Core datadir: wallet.dat (or wallets\), bitcoin.conf, debug.log, and the full blockchain (blocks\, chainstate\ — very large).' }
    @{ cat='finance-crypto'; name='Monero GUI wallet'; path='%APPDATA%\monero-project'; kind='folder'; admin=$false; enum=$false; note='Monero GUI settings (monero-core.conf); bundled-node blockchain under %APPDATA%\bitmonero; wallet .keys/.address.txt files are user-placed (often Documents\Monero).' }
    @{ cat='finance-crypto'; name='Sparrow Wallet'; path='%APPDATA%\Sparrow'; kind='folder'; admin=$false; enum=$false; note='Sparrow Bitcoin wallet: wallets\*.mv.db (password-encrypted), wallets-backup\, config/cache holding labels and xpubs.' }
    @{ cat='finance-crypto'; name='Trezor Suite (desktop)'; path='%APPDATA%\@trezor'; kind='folder'; admin=$false; enum=$false; note='Trezor Suite (data under @trezor\suite-desktop): account list, labels, addresses, xpubs; private keys stay on the hardware device.' }
    @{ cat='finance-crypto'; name='Guarda desktop wallet'; path='%APPDATA%\Guarda'; kind='folder'; admin=$false; enum=$false; note='Guarda multi-currency wallet encrypted local data (assets, addresses, history).' }
    @{ cat='finance-crypto'; name='Coinomi desktop wallet'; path='%LOCALAPPDATA%\Coinomi'; kind='folder'; admin=$false; enum=$false; note='Coinomi multi-coin wallet; wallets commonly under Coinomi\Coinomi\wallets (nested layout can vary by version).' }
    @{ cat='finance-crypto'; name='Jaxx Liberty wallet'; path='%APPDATA%\Jaxx Liberty'; kind='folder'; admin=$false; enum=$false; note='Jaxx Liberty (discontinued 2021) encrypted wallet data; older Jaxx Classic used %APPDATA%\Jaxx. Weak local encryption historically.' }
    @{ cat='finance-crypto'; name='BitPay wallet'; path='%APPDATA%\BitPay'; kind='folder'; admin=$false; enum=$false; note='BitPay (ex-Copay) wallet encrypted key store; migrated installs may also leave %APPDATA%\Copay.' }
    @{ cat='finance-crypto'; name='Daedalus (Cardano)'; path='%APPDATA%\Daedalus Mainnet'; kind='folder'; admin=$false; enum=$false; note='Daedalus full-node wallet: encrypted spending keys in wallets\, full chain\ (very large), Logs\; Testnet/Preprod use sibling folders.' }
    @{ cat='finance-crypto'; name='Electron Cash / Electrum-LTC (Electrum forks)'; path='%APPDATA%\ElectronCash'; kind='folder'; admin=$false; enum=$false; note='Electron Cash (BCH); Litecoin fork under %APPDATA%\Electrum-LTC. Same layout as Electrum (wallets\, config); encryption not forced, so seed/keys may be exposed.' }
    @{ cat='finance-crypto'; name='Moneydance'; path='%APPDATA%\Moneydance'; kind='folder'; admin=$false; enum=$false; note='Moneydance (Java) preferences, default dataset + backups, and recent-files list; .moneydance datasets may be user-placed elsewhere.' }
    @{ cat='finance-crypto'; name='Microsoft Money (legacy)'; path='HKCU:\Software\Microsoft\Microsoft Money'; kind='registry'; admin=$false; enum=$false; note='Microsoft Money (discontinued) settings + recent-file (MRU) list; the .mny data file (+ .mbf backups) is user-placed, usually in Documents.' }
    @{ cat='finance-crypto'; name='Sage 50 Accounts (company data)'; path='%PROGRAMDATA%\Sage'; kind='folder'; admin=$false; enum=$false; note='Sage 50 UK company folders end in .saj (+ .sai index) under %PROGRAMDATA%\Sage\Accounts; US/Peachtree data location differs (Public Documents / chosen folder). Removal of ProgramData\Sage needs admin.' }
    @{ cat='finance-crypto'; name='Drake Tax (preparer client files)'; path='%SYSTEMDRIVE%\DrakeSoftware'; kind='folder'; admin=$false; enum=$false; note='Drake Tax installs to C:\DrakeSoftware\Drake<YY> (older: C:\Drake<YY>); client returns (SSNs, full tax detail) live inside. Machine-wide; removal needs admin. Usually a work device.' }
    @{ cat='finance-crypto'; name='Intuit ProSeries (preparer client files)'; path='%SYSTEMDRIVE%\ProWin<YY>'; kind='folder'; admin=$false; enum=$false; note='ProSeries installs per tax year to C:\ProWin<YY> (standalone) / C:\ProNet<YY> (network), client data in <YY>Data. Intuit registry (HKCU\Software\Intuit) already cataloged. Machine-wide; removal needs admin.' }
    @{ cat='finance-crypto'; name='Intuit Lacerte (preparer client files)'; path='%SYSTEMDRIVE%\Lacerte'; kind='folder'; admin=$false; enum=$false; note='Lacerte installs under C:\Lacerte\<YY>tax with client data in CLData/IData folders. Intuit registry already cataloged. Machine-wide; removal needs admin.' }
    @{ cat='finance-crypto'; name='TaxSlayer Pro (desktop)'; path='%SYSTEMDRIVE%\TaxSlayerPro'; kind='folder'; admin=$false; enum=$false; note='TaxSlayer Pro (preparer desktop) stores client returns under C:\TaxSlayerPro; machine-wide, removal needs admin. Consumer TaxSlayer is web-only (browser traces only).' }
    # --- vm-backup (21) ---
    @{ cat='vm-backup'; name='VirtualBox VMs'; path='%USERPROFILE%\VirtualBox VMs'; kind='folder'; admin=$false; enum=$false; note='Default VirtualBox machine folder; .vbox config plus .vdi/.vmdk/.vhd guest disks, each a full OS.' }
    @{ cat='vm-backup'; name='VirtualBox config & media registry'; path='%USERPROFILE%\.VirtualBox'; kind='folder'; admin=$false; enum=$false; note='VirtualBox.xml lists every registered VM and a recent-media MRU, even for deleted disks.' }
    @{ cat='vm-backup'; name='VMware virtual machines'; path='%USERPROFILE%\Documents\Virtual Machines'; kind='folder'; admin=$false; enum=$false; note='Default VMware VM store; .vmx config, .vmdk disks, and .vmem/.vmss saved memory state.' }
    @{ cat='vm-backup'; name='VMware preferences & inventory'; path='%APPDATA%\VMware'; kind='folder'; admin=$false; enum=$false; note='preferences.ini / inventory.vmls hold the recent-VM MRU and paths of every VM opened.' }
    @{ cat='vm-backup'; name='Hyper-V default virtual hard disks'; path='%PUBLIC%\Documents\Hyper-V\Virtual Hard Disks'; kind='folder'; admin=$false; enum=$false; note='Default .vhdx/.avhdx location; each is a full guest OS left behind after a VM is deleted.' }
    @{ cat='vm-backup'; name='Hyper-V VM configuration store'; path='%ProgramData%\Microsoft\Windows\Hyper-V'; kind='folder'; admin=$true; enum=$false; note='VM config (.vmcx) and runtime/state files; ACL-restricted, needs elevation to read.' }
    @{ cat='vm-backup'; name='WSL distribution registry'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss'; kind='registry'; admin=$false; enum=$false; note='Authoritative list of installed WSL distros; each subkey''s BasePath locates its ext4.vhdx.' }
    @{ cat='vm-backup'; name='WSL / Store distro disks'; path='%LOCALAPPDATA%\Packages'; kind='folder'; admin=$false; enum=$true; note='Store distros keep ext4.vhdx under <DistroPackage>\LocalState; scan for large ext4.vhdx files.' }
    @{ cat='vm-backup'; name='Docker Desktop WSL data'; path='%LOCALAPPDATA%\Docker\wsl'; kind='folder'; admin=$false; enum=$false; note='Backing .vhdx for Docker images/volumes/build cache (data/ext4.vhdx or disk/docker_data.vhdx).' }
    @{ cat='vm-backup'; name='BlueStacks 5 engine'; path='%ProgramData%\BlueStacks_nxt'; kind='folder'; admin=$false; enum=$false; note='Android engine disk images (.vhd) and bluestacks.conf per instance; carries Google/app logins.' }
    @{ cat='vm-backup'; name='MEmu emulator install'; path='%ProgramFiles%\Microvirt\MEmu'; kind='folder'; admin=$false; enum=$false; note='MEmu install root; bundled Android VM disk images stored beneath it (exact subfolder varies).' }
    @{ cat='vm-backup'; name='Windows Subsystem for Android package'; path='%LOCALAPPDATA%\Packages\MicrosoftCorporationII.WindowsSubsystemForAndroid_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='WSA Android user-data image under LocalCache; app logins and app data.' }
    @{ cat='vm-backup'; name='Windows File History'; path='%LOCALAPPDATA%\Microsoft\Windows\FileHistory'; kind='folder'; admin=$false; enum=$false; note='Config names the backup target drive; versioned file copies live on that target, not here.' }
    @{ cat='vm-backup'; name='Windows Backup configuration'; path='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup'; kind='registry'; admin=$false; enum=$false; note='Shows whether a Windows 7-style system-image/file backup job and its target are configured.' }
    @{ cat='vm-backup'; name='Macrium backup definitions'; path='%USERPROFILE%\Documents\Reflect'; kind='folder'; admin=$false; enum=$false; note='XML backup definitions naming imaged sources and the .mrimg/.mrbak target path.' }
    @{ cat='vm-backup'; name='Veeam Agent config'; path='%ProgramData%\Veeam\Endpoint'; kind='folder'; admin=$true; enum=$false; note='Job config/db naming the backup target (local disk, SMB share, or Veeam repository); service-owned.' }
    @{ cat='vm-backup'; name='Acronis config & logs'; path='%ProgramData%\Acronis'; kind='folder'; admin=$false; enum=$false; note='Reveals backup jobs and target incl. Acronis Cloud; .tib/.tibx archives live on the target.' }
    @{ cat='vm-backup'; name='EaseUS Todo Backup config'; path='%ProgramData%\EaseUS'; kind='folder'; admin=$false; enum=$false; note='Backup plans and target path; .pbd image files live on the chosen target drive.' }
    @{ cat='vm-backup'; name='Duplicati config & job databases'; path='%LOCALAPPDATA%\Duplicati'; kind='folder'; admin=$false; enum=$false; note='Duplicati-server.sqlite reveals backup sources and remote destinations (existence only).' }
    @{ cat='vm-backup'; name='Kopia repository config'; path='%APPDATA%\kopia'; kind='folder'; admin=$false; enum=$false; note='repository.config points at the (encrypted) backup repo location; report existence only.' }
    @{ cat='vm-backup'; name='restic cache'; path='%LOCALAPPDATA%\restic'; kind='folder'; admin=$false; enum=$false; note='Presence indicates restic backups and hints at repo usage; report existence only, never keys.' }
    # --- identity-accounts (17) ---
    @{ cat='identity-accounts'; name='Chromium Local State (account/profile list)'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Local State'; kind='folder'; admin=$false; enum=$false; note='Names profiles and last account; a synced account means a cloud copy survives. Repeat per browser.' }
    @{ cat='identity-accounts'; name='Office signed-in identity'; path='HKCU:\Software\Microsoft\Office\16.0\Common\Identity'; kind='registry'; admin=$false; enum=$false; note='Subkey count indicates accounts (emails/display names) signed into Office.' }
    @{ cat='identity-accounts'; name='Microsoft 365 token cache (OneAuth)'; path='%LOCALAPPDATA%\Microsoft\OneAuth'; kind='folder'; admin=$false; enum=$false; note='Cached MS account sign-in tokens; existence/size only. Role overlaps IdentityCache/TokenBroker.' }
    @{ cat='identity-accounts'; name='Adobe Creative Cloud sign-in'; path='%LOCALAPPDATA%\Adobe\OOBE'; kind='folder'; admin=$false; enum=$false; note='Adobe ID sign-in / licensing state; existence only.' }
    @{ cat='identity-accounts'; name='Steam remembered accounts'; path='HKCU:\Software\Valve\Steam'; kind='registry'; admin=$false; enum=$false; note='AutoLoginUser/RememberPassword/LastGameNameUsed + SteamPath.' }
    @{ cat='identity-accounts'; name='Xbox app'; path='%LOCALAPPDATA%\Packages\Microsoft.GamingApp_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Signed-in Xbox/Microsoft account + installed games.' }
    @{ cat='identity-accounts'; name='Minecraft launcher and worlds'; path='%APPDATA%\.minecraft'; kind='folder'; admin=$false; enum=$false; note='launcher_accounts.json (MS account) + saves/screenshots/servers.dat.' }
    @{ cat='identity-accounts'; name='Entra/Azure AD join'; path='HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo'; kind='registry'; admin=$false; enum=$false; note='Presence = device Entra-joined; holds tenant + user email.' }
    @{ cat='identity-accounts'; name='Registered accounts (WAM TokenBroker)'; path='%LOCALAPPDATA%\Microsoft\TokenBroker\Cache'; kind='folder'; admin=$false; enum=$false; note='Cached tokens for MSA/work accounts signed into Windows.' }
    @{ cat='identity-accounts'; name='AAD broker package'; path='%LOCALAPPDATA%\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy'; kind='folder'; admin=$false; enum=$false; note='Work/school account broker state; existence indicates AAD accounts added.' }
    @{ cat='identity-accounts'; name='Identity store'; path='HKLM:\SOFTWARE\Microsoft\IdentityStore'; kind='registry'; admin=$false; enum=$false; note='Cached identity records for accounts added to Windows.' }
    @{ cat='identity-accounts'; name='Office/M365 identity cache'; path='%LOCALAPPDATA%\Microsoft\IdentityCache'; kind='folder'; admin=$false; enum=$false; note='Cached sign-in identities; role overlaps OneAuth/TokenBroker.' }
    @{ cat='identity-accounts'; name='Local user profiles on disk'; path='%SystemDrive%\Users'; kind='folder'; admin=$false; enum=$true; note='One folder per account plus the hidden Default template and the shared Public profile; reading another profile''s contents needs admin.' }
    @{ cat='identity-accounts'; name='Profile list (registry)'; path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'; kind='registry'; admin=$false; enum=$false; note='Enumerates every profile SID and its on-disk ProfileImagePath, including orphaned/partly-removed profiles; readable without elevation (confirmed on Win11).' }
    @{ cat='identity-accounts'; name='Office 2013 signed-in identity'; path='HKCU:\Software\Microsoft\Office\15.0\Common\Identity'; kind='registry'; admin=$false; enum=$false; note='Email/display name of Microsoft or M365 account in Office 2013; 14.0 has no sign-in. Existence only.' }
    @{ cat='identity-accounts'; name='Work Folders'; path='%USERPROFILE%\Work Folders'; kind='folder'; admin=$false; enum=$false; note='Enterprise synced files + work account and server URL (config under HKCU/HKLM WorkFolders). Existence only.' }
    @{ cat='identity-accounts'; name='Cloud Experience Host account cache'; path='%LOCALAPPDATA%\Packages\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy'; kind='folder'; admin=$false; enum=$false; note='Transient sign-in webview cache (email/tenant, cookies); durable tokens are in AAD broker/WAM. Existence only.' }
    # --- credentials (26) ---
    @{ cat='credentials'; name='Chromium saved-password store'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Login Data'; kind='folder'; admin=$false; enum=$false; note='Count only: site+username list (passwords encrypted). Also Login Data For Account.' }
    @{ cat='credentials'; name='Chromium extension stored data'; path='%LOCALAPPDATA%\Google\Chrome\User Data\Default\Local Extension Settings'; kind='folder'; admin=$false; enum=$false; note='Count only: may hold wallet/password-manager vaults (encrypted); existence indicator.' }
    @{ cat='credentials'; name='IE IntelliForms saved form/password store'; path='HKCU:\Software\Microsoft\Internet Explorer\IntelliForms\Storage2'; kind='registry'; admin=$false; enum=$false; note='Count only: saved IE form/credential entries (encrypted, keyed by URL).' }
    @{ cat='credentials'; name='Credential store (local)'; path='%LOCALAPPDATA%\Microsoft\Credentials'; kind='folder'; admin=$false; enum=$false; note='File count = saved Windows credentials (shares, RDP, apps, Git); DPAPI-encrypted, never opened.' }
    @{ cat='credentials'; name='Credential store (roaming)'; path='%APPDATA%\Microsoft\Credentials'; kind='folder'; admin=$false; enum=$false; note='Roaming saved Windows credentials; existence/count only.' }
    @{ cat='credentials'; name='Web credential vault (local)'; path='%LOCALAPPDATA%\Microsoft\Vault'; kind='folder'; admin=$false; enum=$false; note='Legacy web/app saved logins behind Credential Manager Web Credentials; count only.' }
    @{ cat='credentials'; name='Web credential vault (roaming)'; path='%APPDATA%\Microsoft\Vault'; kind='folder'; admin=$false; enum=$false; note='Roaming Web Credentials vault; count only.' }
    @{ cat='credentials'; name='DPAPI master keys'; path='%APPDATA%\Microsoft\Protect'; kind='folder'; admin=$false; enum=$false; note='Per-user master keys that decrypt the other secrets; SID subfolder, never opened.' }
    @{ cat='credentials'; name='Windows Hello NGC store'; path='%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc'; kind='folder'; admin=$true; enum=$false; note='Non-empty = PIN/Hello/passkey enrolled; subfolder count only, do not open.' }
    @{ cat='credentials'; name='Hello biometric database'; path='%WINDIR%\System32\WinBioDatabase'; kind='folder'; admin=$true; enum=$false; note='On-PC fingerprint/face templates (not match-on-chip sensors).' }
    @{ cat='credentials'; name='KeePass config'; path='%APPDATA%\KeePass'; kind='folder'; admin=$false; enum=$false; note='KeePass.config.xml recent-files list reveals .kdbx paths/names and that a vault is used.' }
    @{ cat='credentials'; name='KeePassXC config'; path='%APPDATA%\keepassxc'; kind='folder'; admin=$false; enum=$false; note='keepassxc.ini recent-database list.' }
    @{ cat='credentials'; name='Bitwarden data'; path='%APPDATA%\Bitwarden'; kind='folder'; admin=$false; enum=$false; note='data.json = account email plus encrypted vault cache / PIN-unlock key.' }
    @{ cat='credentials'; name='1Password data'; path='%LOCALAPPDATA%\1Password'; kind='folder'; admin=$false; enum=$false; note='1password.sqlite + settings.json = account email, encrypted local cache.' }
    @{ cat='credentials'; name='Enpass data'; path='%APPDATA%\Enpass'; kind='folder'; admin=$false; enum=$false; note='Vault presence + account info (vault file may be in Documents or a synced folder).' }
    @{ cat='credentials'; name='LastPass desktop cache'; path='%LOCALAPPDATA%\LastPass'; kind='folder'; admin=$false; enum=$false; note='Desktop vault cache present (account email); folder name may vary by build.' }
    @{ cat='credentials'; name='Dashlane local data'; path='%LOCALAPPDATA%\Dashlane'; kind='folder'; admin=$false; enum=$false; note='Desktop cache present; current builds may store in browser extension instead.' }
    @{ cat='credentials'; name='NordPass local data'; path='%APPDATA%\NordPass'; kind='folder'; admin=$false; enum=$false; note='Signed-in NordPass cache present; existence only.' }
    @{ cat='credentials'; name='RoboForm local data'; path='%LOCALAPPDATA%\RoboForm'; kind='folder'; admin=$false; enum=$false; note='Presence of Profiles\Default Profile; existence only.' }
    @{ cat='credentials'; name='Proton Pass local data'; path='%APPDATA%\Proton Pass'; kind='folder'; admin=$false; enum=$false; note='Signed-in Proton Pass offline cache present; existence only.' }
    @{ cat='credentials'; name='KeeWeb config / recent DBs'; path='%APPDATA%\KeeWeb'; kind='folder'; admin=$false; enum=$false; note='Presence of KeeWeb config (recent-.kdbx list); do not read database paths'' contents.' }
    @{ cat='credentials'; name='Keeper Password Manager'; path='%APPDATA%\Keeper Password Manager'; kind='folder'; admin=$false; enum=$false; note='Keeper desktop (Electron) local encrypted vault cache + account email; some builds use %APPDATA%\Keeper instead.' }
    @{ cat='credentials'; name='Sticky Password'; path='%APPDATA%\Sticky Password'; kind='folder'; admin=$false; enum=$false; note='Sticky Password settings + local encrypted database; exact DB subpath not fully confirmed.' }
    @{ cat='credentials'; name='Password Safe (pwsafe)'; path='HKCU:\Software\Password Safe\Password Safe'; kind='registry'; admin=$false; enum=$false; note='pwsafe settings + recent-safe (MRU) list; the .psafe3 vault itself is user-placed (often in Documents).' }
    @{ cat='credentials'; name='Padloc'; path='%APPDATA%\Padloc'; kind='folder'; admin=$false; enum=$false; note='Padloc desktop (Electron) encrypted local store + account email; vault may sync to Padloc cloud or a self-hosted server.' }
    @{ cat='credentials'; name='Buttercup'; path='%APPDATA%\Buttercup'; kind='folder'; admin=$false; enum=$false; note='Buttercup desktop (Electron) config listing each .bcup vault''s name/location (local or cloud-linked).' }
    # --- dev-secrets (87) ---
    @{ cat='dev-secrets'; name='VS Code global state'; path='%APPDATA%\Code\User\globalStorage'; kind='folder'; admin=$false; enum=$false; note='storage.json + state.vscdb: recent folders and extension state that can hold tokens; existence only.' }
    @{ cat='dev-secrets'; name='Git stored credentials (plaintext)'; path='%USERPROFILE%\.git-credentials'; kind='folder'; admin=$false; enum=$false; note='Only if ''store'' helper used; plaintext https://user:token@host. Existence only, never opened.' }
    @{ cat='dev-secrets'; name='Git identity config'; path='%USERPROFILE%\.gitconfig'; kind='folder'; admin=$false; enum=$false; note='user.name/email + credential-helper config; existence only.' }
    @{ cat='dev-secrets'; name='Postman data'; path='%APPDATA%\Postman'; kind='folder'; admin=$false; enum=$false; note='Collections/environments (often API tokens) + account; existence/size only.' }
    @{ cat='dev-secrets'; name='Insomnia data'; path='%APPDATA%\Insomnia'; kind='folder'; admin=$false; enum=$false; note='Requests/environments (often tokens) + account; existence/size only.' }
    @{ cat='dev-secrets'; name='Docker config/auth'; path='%USERPROFILE%\.docker'; kind='folder'; admin=$false; enum=$false; note='config.json Hub login/registry auth or credsStore pointer (token often in Credential Manager).' }
    @{ cat='dev-secrets'; name='SSH keys'; path='%USERPROFILE%\.ssh'; kind='folder'; admin=$false; enum=$false; note='Private keys, known_hosts (servers), config (users/hosts), authorized_keys.' }
    @{ cat='dev-secrets'; name='GnuPG keyring'; path='%USERPROFILE%\.gnupg'; kind='folder'; admin=$false; enum=$false; note='Secret keyring (private-keys-v1.d) and trust/contacts.' }
    @{ cat='dev-secrets'; name='AWS credentials'; path='%USERPROFILE%\.aws'; kind='folder'; admin=$false; enum=$false; note='Access keys, account IDs, SSO/CLI token caches.' }
    @{ cat='dev-secrets'; name='Azure CLI tokens'; path='%USERPROFILE%\.azure'; kind='folder'; admin=$false; enum=$false; note='MSAL token cache + azureProfile.json (account email, subscriptions).' }
    @{ cat='dev-secrets'; name='gcloud credentials'; path='%APPDATA%\gcloud'; kind='folder'; admin=$false; enum=$false; note='credentials.db/access_tokens.db, legacy & application-default service-account keys.' }
    @{ cat='dev-secrets'; name='Kubernetes config'; path='%USERPROFILE%\.kube'; kind='folder'; admin=$false; enum=$false; note='Cluster endpoints, client certs, bearer tokens.' }
    @{ cat='dev-secrets'; name='npm token (.npmrc)'; path='%USERPROFILE%\.npmrc'; kind='folder'; admin=$false; enum=$false; note='_authToken lines for npm registries; single file.' }
    @{ cat='dev-secrets'; name='PyPI creds (.pypirc)'; path='%USERPROFILE%\.pypirc'; kind='folder'; admin=$false; enum=$false; note='PyPI / Test-PyPI upload credentials; single file.' }
    @{ cat='dev-secrets'; name='NuGet config'; path='%APPDATA%\NuGet\NuGet.Config'; kind='folder'; admin=$false; enum=$false; note='packageSourceCredentials for private feeds.' }
    @{ cat='dev-secrets'; name='.netrc / _netrc'; path='%USERPROFILE%\_netrc'; kind='folder'; admin=$false; enum=$false; note='Plaintext machine/login/password for curl, Git and CLI tools; single file.' }
    @{ cat='dev-secrets'; name='Maven settings'; path='%USERPROFILE%\.m2\settings.xml'; kind='folder'; admin=$false; enum=$false; note='<servers> repository passwords/tokens; single file.' }
    @{ cat='dev-secrets'; name='PuTTY sessions'; path='HKCU:\Software\SimonTatham\PuTTY\Sessions'; kind='registry'; admin=$false; enum=$false; note='Subkey count = saved SSH sessions (hosts, usernames, proxy).' }
    @{ cat='dev-secrets'; name='PuTTY host keys'; path='HKCU:\Software\SimonTatham\PuTTY\SshHostKeys'; kind='registry'; admin=$false; enum=$false; note='Value count = servers you have connected to.' }
    @{ cat='dev-secrets'; name='WinSCP sessions'; path='HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions'; kind='registry'; admin=$false; enum=$false; note='Subkey count = saved SFTP/FTP sites (saved passwords weakly/reversibly stored).' }
    @{ cat='dev-secrets'; name='FileZilla sites'; path='%APPDATA%\FileZilla'; kind='folder'; admin=$false; enum=$false; note='sitemanager.xml / recentservers.xml = FTP sites, passwords often plaintext/base64.' }
    @{ cat='dev-secrets'; name='MobaXterm sessions/passwords (registry)'; path='HKCU:\Software\Mobatek\MobaXterm'; kind='registry'; admin=$false; enum=$false; note='Count subkeys/sessions only; C/P/M subkeys hold creds but never read values.' }
    @{ cat='dev-secrets'; name='MobaXterm app data / INI'; path='%APPDATA%\MobaXterm'; kind='folder'; admin=$false; enum=$false; note='Existence of installer-edition MobaXterm.ini (saved sessions/passwords).' }
    @{ cat='dev-secrets'; name='SecureCRT sessions'; path='%APPDATA%\VanDyke\Config\Sessions'; kind='folder'; admin=$false; enum=$false; note='Count per-session .ini files; do not open them.' }
    @{ cat='dev-secrets'; name='Royal TS settings'; path='%APPDATA%\code4ward'; kind='folder'; admin=$false; enum=$false; note='App config presence; .rtsz/.rtsx documents live wherever the user saved them.' }
    @{ cat='dev-secrets'; name='KiTTY sessions (registry)'; path='HKCU:\Software\9bis.com\KiTTY'; kind='registry'; admin=$false; enum=$false; note='Count Sessions/SshHostKeys subkeys only.' }
    @{ cat='dev-secrets'; name='Termius data'; path='%APPDATA%\Termius'; kind='folder'; admin=$false; enum=$false; note='Signed-in Termius cache present (account email, host list).' }
    @{ cat='dev-secrets'; name='mRemoteNG connections'; path='%APPDATA%\mRemoteNG'; kind='folder'; admin=$false; enum=$false; note='Existence of confCons.xml and backups; do not read.' }
    @{ cat='dev-secrets'; name='OpenSSH ssh-agent persisted keys'; path='HKCU:\Software\OpenSSH\Agent\Keys'; kind='registry'; admin=$false; enum=$false; note='Count cached agent keys only; values are encrypted blobs, never decrypt.' }
    @{ cat='dev-secrets'; name='DBeaver workspace'; path='%APPDATA%\DBeaverData'; kind='folder'; admin=$false; enum=$false; note='Presence of data-sources.json/credentials-config.json; existence only.' }
    @{ cat='dev-secrets'; name='pgAdmin data'; path='%APPDATA%\pgAdmin'; kind='folder'; admin=$false; enum=$false; note='Existence of pgadmin4.db (saved servers); do not query it.' }
    @{ cat='dev-secrets'; name='HeidiSQL sessions (registry)'; path='HKCU:\Software\HeidiSQL'; kind='registry'; admin=$false; enum=$false; note='Count Servers subkeys only.' }
    @{ cat='dev-secrets'; name='MySQL Workbench connections'; path='%APPDATA%\MySQL\Workbench'; kind='folder'; admin=$false; enum=$false; note='Existence of connections.xml; do not read passwords vault.' }
    @{ cat='dev-secrets'; name='SSMS connection history'; path='%APPDATA%\Microsoft\SQL Server Management Studio'; kind='folder'; admin=$false; enum=$false; note='Presence of UserSettings.xml/SqlStudio.bin (recent-server MRU).' }
    @{ cat='dev-secrets'; name='GitHub CLI token'; path='%APPDATA%\GitHub CLI'; kind='folder'; admin=$false; enum=$false; note='Existence of hosts.yml (OAuth token); do not read the token.' }
    @{ cat='dev-secrets'; name='HashiCorp Vault token'; path='%USERPROFILE%\.vault-token'; kind='folder'; admin=$false; enum=$false; note='File-exists check only; never read the token value.' }
    @{ cat='dev-secrets'; name='Terraform Cloud credentials'; path='%APPDATA%\terraform.d'; kind='folder'; admin=$false; enum=$false; note='Existence of credentials.tfrc.json; do not read.' }
    @{ cat='dev-secrets'; name='Databricks config'; path='%USERPROFILE%\.databrickscfg'; kind='folder'; admin=$false; enum=$false; note='File-exists only; never read host/token.' }
    @{ cat='dev-secrets'; name='SnowSQL config'; path='%USERPROFILE%\.snowsql'; kind='folder'; admin=$false; enum=$false; note='Presence of SnowSQL config (connections); existence only.' }
    @{ cat='dev-secrets'; name='Snowflake CLI config'; path='%USERPROFILE%\.snowflake'; kind='folder'; admin=$false; enum=$false; note='Presence of config.toml; existence only (path unconfirmed on Windows).' }
    @{ cat='dev-secrets'; name='DigitalOcean doctl config'; path='%APPDATA%\doctl'; kind='folder'; admin=$false; enum=$false; note='Existence of config.yaml (API token); do not read.' }
    @{ cat='dev-secrets'; name='cloudflared credentials'; path='%USERPROFILE%\.cloudflared'; kind='folder'; admin=$false; enum=$false; note='Presence of cert.pem/tunnel JSON; existence only, never read.' }
    @{ cat='dev-secrets'; name='Oracle OCI CLI'; path='%USERPROFILE%\.oci'; kind='folder'; admin=$false; enum=$false; note='OCI CLI config + API signing keys (oci_api_key.pem)' }
    @{ cat='dev-secrets'; name='IBM Cloud CLI'; path='%USERPROFILE%\.bluemix'; kind='folder'; admin=$false; enum=$false; note='config.json with account + cached IAM tokens; newer builds may use .ibmcloud' }
    @{ cat='dev-secrets'; name='Alibaba Cloud aliyun CLI'; path='%USERPROFILE%\.aliyun'; kind='folder'; admin=$false; enum=$false; note='config.json holds AccessKey ID/secret in clear' }
    @{ cat='dev-secrets'; name='Linode CLI'; path='%USERPROFILE%\.config\linode-cli'; kind='folder'; admin=$false; enum=$false; note='single config file with personal access token; Windows path may vary' }
    @{ cat='dev-secrets'; name='Scaleway CLI (scw)'; path='%USERPROFILE%\.config\scw'; kind='folder'; admin=$false; enum=$false; note='config.yaml with access/secret key + org/project IDs' }
    @{ cat='dev-secrets'; name='Fly.io flyctl'; path='%APPDATA%\flyctl'; kind='folder'; admin=$false; enum=$false; note='config.yml with access token; older installs used %USERPROFILE%\.fly' }
    @{ cat='dev-secrets'; name='Vercel CLI'; path='%APPDATA%\com.vercel.cli'; kind='folder'; admin=$false; enum=$false; note='auth.json token; AppData subdir (Roaming vs Local) may vary' }
    @{ cat='dev-secrets'; name='Netlify CLI (configstore)'; path='%USERPROFILE%\.config\configstore'; kind='folder'; admin=$false; enum=$false; note='netlify.json holds auth token + user ID; exact path version-dependent' }
    @{ cat='dev-secrets'; name='Supabase CLI'; path='%USERPROFILE%\.supabase'; kind='folder'; admin=$false; enum=$false; note='may not exist; access token usually in Windows Credential Manager' }
    @{ cat='dev-secrets'; name='PlanetScale pscale'; path='%USERPROFILE%\.config\planetscale'; kind='folder'; admin=$false; enum=$false; note='cached OAuth token; config dir may differ on Windows' }
    @{ cat='dev-secrets'; name='Fastly CLI'; path='%APPDATA%\fastly'; kind='folder'; admin=$false; enum=$false; note='config.toml with API token(s) per profile' }
    @{ cat='dev-secrets'; name='Akamai EdgeGrid (.edgerc)'; path='%USERPROFILE%\.edgerc'; kind='folder'; admin=$false; enum=$false; note='file: client token/secret, access token, host per section' }
    @{ cat='dev-secrets'; name='Heroku CLI'; path='%LOCALAPPDATA%\heroku'; kind='folder'; admin=$false; enum=$false; note='config/cache (account email); the API token lives in netrc' }
    @{ cat='dev-secrets'; name='rclone'; path='%APPDATA%\rclone'; kind='folder'; admin=$false; enum=$false; note='rclone.conf aggregates tokens/passwords for many cloud remotes' }
    @{ cat='dev-secrets'; name='GitHub Desktop'; path='%APPDATA%\GitHub Desktop'; kind='folder'; admin=$false; enum=$false; note='recent repos + paths, account; token in Credential Manager' }
    @{ cat='dev-secrets'; name='GitKraken'; path='%APPDATA%\.gitkraken'; kind='folder'; admin=$false; enum=$false; note='account, hosting integrations, repo list' }
    @{ cat='dev-secrets'; name='Sourcetree'; path='%LOCALAPPDATA%\Atlassian\SourceTree'; kind='folder'; admin=$false; enum=$false; note='accounts.json + bookmarks.xml (hosting accounts, repo paths)' }
    @{ cat='dev-secrets'; name='Fork (Git client)'; path='%APPDATA%\Fork'; kind='folder'; admin=$false; enum=$false; note='settings + repository list; subpaths may vary' }
    @{ cat='dev-secrets'; name='Tower (Git client)'; path='%APPDATA%\Tower'; kind='folder'; admin=$false; enum=$false; note='accounts + repo bookmarks; folder name may differ (e.g. com.fournova.*)' }
    @{ cat='dev-secrets'; name='Sublime Merge'; path='%APPDATA%\Sublime Merge'; kind='folder'; admin=$false; enum=$false; note='Session.sublime_session repo paths, author identity' }
    @{ cat='dev-secrets'; name='GitLab glab CLI'; path='%APPDATA%\glab-cli'; kind='folder'; admin=$false; enum=$false; note='config.yml token; may instead be %USERPROFILE%\.config\glab-cli or a keyring' }
    @{ cat='dev-secrets'; name='Bitvise SSH Client'; path='HKCU:\Software\Bitvise'; kind='registry'; admin=$false; enum=$false; note='settings + known host keys; profile files (.bscp/.tlp) saved separately' }
    @{ cat='dev-secrets'; name='Xshell (NetSarang) sessions'; path='%USERPROFILE%\Documents\NetSarang Computer'; kind='folder'; admin=$false; enum=$false; note='Xshell\Sessions\*.xsh (host/user, optional saved pw); older in %APPDATA%\NetSarang' }
    @{ cat='dev-secrets'; name='ZOC Terminal'; path='%USERPROFILE%\Documents\ZOC8 Files'; kind='folder'; admin=$false; enum=$false; note='host directory/settings; path may vary (also %APPDATA%\ZOC8)' }
    @{ cat='dev-secrets'; name='Devolutions Remote Desktop Manager'; path='%LOCALAPPDATA%\Devolutions\RemoteDesktopManager'; kind='folder'; admin=$false; enum=$false; note='saved RDP/SSH/VNC sessions + any local data source' }
    @{ cat='dev-secrets'; name='MongoDB Compass'; path='%APPDATA%\MongoDB Compass'; kind='folder'; admin=$false; enum=$false; note='saved/favorite connections + recents (secrets in OS vault)' }
    @{ cat='dev-secrets'; name='RedisInsight'; path='%APPDATA%\RedisInsight-v2'; kind='folder'; admin=$false; enum=$false; note='local DB of Redis connections; older edition at %USERPROFILE%\.redisinsight' }
    @{ cat='dev-secrets'; name='TablePlus'; path='%APPDATA%\TablePlus'; kind='folder'; admin=$false; enum=$false; note='saved connections + recents; folder name may vary' }
    @{ cat='dev-secrets'; name='Navicat'; path='HKCU:\Software\PremiumSoft'; kind='registry'; admin=$false; enum=$false; note='saved servers (host/user/db) with encrypted passwords; also %APPDATA%\PremiumSoft' }
    @{ cat='dev-secrets'; name='Azure Data Studio'; path='%APPDATA%\azuredatastudio'; kind='folder'; admin=$false; enum=$false; note='connection profiles, history, Azure sign-in; extensions in %USERPROFILE%\.azuredatastudio' }
    @{ cat='dev-secrets'; name='Beekeeper Studio'; path='%APPDATA%\beekeeper-studio'; kind='folder'; admin=$false; enum=$false; note='SQLite of saved DB connections + query history; capitalization may vary' }
    @{ cat='dev-secrets'; name='DbVisualizer'; path='%USERPROFILE%\.dbvis'; kind='folder'; admin=$false; enum=$false; note='config*/dbvis.xml saved connections (+ encrypted passwords)' }
    @{ cat='dev-secrets'; name='Visual Studio'; path='%LOCALAPPDATA%\Microsoft\VisualStudio'; kind='folder'; admin=$false; enum=$false; note='recent-solutions MRU in privateregistry.bin + settings' }
    @{ cat='dev-secrets'; name='Visual Studio identity cache'; path='%LOCALAPPDATA%\.IdentityService'; kind='folder'; admin=$false; enum=$false; note='VS signed-in Microsoft/Azure DevOps account + cached tokens' }
    @{ cat='dev-secrets'; name='Android Studio config'; path='%APPDATA%\Google'; kind='folder'; admin=$false; enum=$false; note='AndroidStudio* subfolders: recent projects, settings' }
    @{ cat='dev-secrets'; name='Android SDK/.android'; path='%USERPROFILE%\.android'; kind='folder'; admin=$false; enum=$false; note='AVD emulator images, adbkey, debug keystore' }
    @{ cat='dev-secrets'; name='Eclipse secure storage'; path='%USERPROFILE%\.eclipse'; kind='folder'; admin=$false; enum=$false; note='Equinox secure_storage: saved Git/server passwords (encrypted)' }
    @{ cat='dev-secrets'; name='Sublime Text session'; path='%APPDATA%\Sublime Text'; kind='folder'; admin=$false; enum=$false; note='Session.sublime_session recents/unsaved buffers; v3 folder differs' }
    @{ cat='dev-secrets'; name='Cursor'; path='%APPDATA%\Cursor'; kind='folder'; admin=$false; enum=$false; note='recents, AI chat history, account; extensions in %USERPROFILE%\.cursor' }
    @{ cat='dev-secrets'; name='VSCodium'; path='%APPDATA%\VSCodium'; kind='folder'; admin=$false; enum=$false; note='recents, settings; extensions in %USERPROFILE%\.vscode-oss' }
    @{ cat='dev-secrets'; name='Cargo (Rust) credentials'; path='%USERPROFILE%\.cargo'; kind='folder'; admin=$false; enum=$false; note='credentials.toml holds crates.io + registry tokens (if present)' }
    @{ cat='dev-secrets'; name='Composer (PHP) auth'; path='%APPDATA%\Composer'; kind='folder'; admin=$false; enum=$false; note='auth.json: private repo + GitHub/GitLab tokens in clear' }
    @{ cat='dev-secrets'; name='Gradle properties'; path='%USERPROFILE%\.gradle'; kind='folder'; admin=$false; enum=$false; note='gradle.properties may hold repo/signing creds in clear (if present)' }
    @{ cat='dev-secrets'; name='conda config'; path='%USERPROFILE%\.condarc'; kind='folder'; admin=$false; enum=$false; note='file: channels (private URLs), embedded tokens, proxy creds' }
    @{ cat='dev-secrets'; name='Anaconda.org token store'; path='%USERPROFILE%\.continuum\anaconda-client\tokens'; kind='folder'; admin=$false; enum=$false; note='saved Anaconda.org API tokens' }
    # --- network (36) ---
    @{ cat='network'; name='Saved Wi-Fi profiles'; path='%ProgramData%\Microsoft\Wlansvc\Profiles\Interfaces'; kind='folder'; admin=$true; enum=$false; note='XML-per-network count = saved SSIDs; keys never read (no key=clear).' }
    @{ cat='network'; name='OpenVPN profiles'; path='%USERPROFILE%\OpenVPN\config'; kind='folder'; admin=$false; enum=$false; note='*.ovpn files (may embed certs/keys) plus auth-user-pass credential files.' }
    @{ cat='network'; name='WireGuard tunnels'; path='%ProgramFiles%\WireGuard\Data\Configurations'; kind='folder'; admin=$true; enum=$false; note='Count of .conf.dpapi tunnels (DPAPI-encrypted under Local System).' }
    @{ cat='network'; name='Cisco Secure Client profiles'; path='%ProgramData%\Cisco\Cisco Secure Client\VPN\Profile'; kind='folder'; admin=$false; enum=$false; note='Profile XMLs = corporate VPN gateways/groups (older path: Cisco AnyConnect...\Profile).' }
    @{ cat='network'; name='Windows VPN/dial phonebook'; path='%APPDATA%\Microsoft\Network\Connections\Pbk'; kind='folder'; admin=$false; enum=$false; note='rasphone.pbk = saved VPN/dial connections (names, servers, usernames).' }
    @{ cat='network'; name='Mapped network drives'; path='HKCU:\Network'; kind='registry'; admin=$false; enum=$false; note='Subkeys = mapped drives with \\server\share paths.' }
    @{ cat='network'; name='RDP connected hosts'; path='HKCU:\Software\Microsoft\Terminal Server Client\Servers'; kind='registry'; admin=$false; enum=$false; note='Subkey count = RDP hosts connected to, plus UsernameHint; saved pw in Credential Manager.' }
    @{ cat='network'; name='SMB shares (this PC)'; path='HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares'; kind='registry'; admin=$true; enum=$false; note='Folders this PC shared on the network (excl. default admin shares).' }
    @{ cat='network'; name='Hosts file'; path='%SystemRoot%\System32\drivers\etc\hosts'; kind='folder'; admin=$false; enum=$false; note='Custom host mappings reveal blocked/internal hosts.' }
    @{ cat='network'; name='Proxy settings'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'; kind='registry'; admin=$false; enum=$false; note='Configured proxy server / PAC URL values.' }
    @{ cat='network'; name='NordVPN account/device state'; path='%LOCALAPPDATA%\NordVPN'; kind='folder'; admin=$false; enum=$false; note='Signed-in NordVPN session/config present; existence only.' }
    @{ cat='network'; name='ExpressVPN account/device state'; path='%LOCALAPPDATA%\ExpressVPN'; kind='folder'; admin=$false; enum=$false; note='Signed-in ExpressVPN data present; existence only.' }
    @{ cat='network'; name='Proton VPN logs/settings'; path='%LOCALAPPDATA%\ProtonVPN'; kind='folder'; admin=$false; enum=$false; note='Presence of ProtonVPN logs/settings (account was signed in).' }
    @{ cat='network'; name='Surfshark account/device state'; path='%LOCALAPPDATA%\Surfshark'; kind='folder'; admin=$false; enum=$false; note='Signed-in Surfshark data present; existence only.' }
    @{ cat='network'; name='Mullvad daemon store'; path='%ProgramData%\Mullvad VPN'; kind='folder'; admin=$true; enum=$false; note='Existence of settings.json (device/WireGuard keys); ACL-restricted, existence only.' }
    @{ cat='network'; name='Tailscale daemon state'; path='%ProgramData%\Tailscale'; kind='folder'; admin=$true; enum=$false; note='Existence of server-state.conf/tailscaled.state (node key); restricted, existence only.' }
    @{ cat='network'; name='Tailscale GUI/user data'; path='%LOCALAPPDATA%\Tailscale'; kind='folder'; admin=$false; enum=$false; note='Presence of Tailscale GUI data/logs (legacy state location).' }
    @{ cat='network'; name='Private Internet Access (PIA)'; path='%ProgramData%\pia'; kind='folder'; admin=$false; enum=$false; note='Daemon account token, chosen regions/settings, daemon.log; older client used %LOCALAPPDATA%\pia_manager. Runs a service.' }
    @{ cat='network'; name='CyberGhost VPN'; path='%LOCALAPPDATA%\CyberGhost 8'; kind='folder'; admin=$false; enum=$false; note='Account/config, settings, logs; also %ProgramData%\CyberGhost 8. Version-named folder; older versions differ.' }
    @{ cat='network'; name='IPVanish'; path='%LOCALAPPDATA%\IPVanish'; kind='folder'; admin=$false; enum=$false; note='Account/username, server prefs, logs; some builds use %APPDATA%\IPVanish. Installs an OpenVPN helper service.' }
    @{ cat='network'; name='Windscribe'; path='%APPDATA%\Windscribe'; kind='folder'; admin=$false; enum=$false; note='Config/logs under the Windscribe2 subfolder (account, server/firewall prefs). Installs a helper service.' }
    @{ cat='network'; name='hide.me VPN'; path='%APPDATA%\hide.me VPN'; kind='folder'; admin=$false; enum=$false; note='Account/username, server prefs, logs; may instead be %LOCALAPPDATA%\hide.me VPN. Exact folder unconfirmed. Installs a helper service.' }
    @{ cat='network'; name='TunnelBear'; path='%LOCALAPPDATA%\TunnelBear'; kind='folder'; admin=$false; enum=$false; note='Account email, server prefs, logs; some state may also sit under %APPDATA%\TunnelBear. Installs a helper service.' }
    @{ cat='network'; name='PrivadoVPN'; path='%APPDATA%\PrivadoVPN'; kind='folder'; admin=$false; enum=$false; note='Account, server prefs, logs; may instead be %LOCALAPPDATA%\PrivadoVPN. Exact folder unconfirmed. Installs a helper service.' }
    @{ cat='network'; name='Hola VPN'; path='%APPDATA%\hola'; kind='folder'; admin=$false; enum=$false; note='Desktop client (hola_svc service); also %LOCALAPPDATA%\Hola. Hola is often only a browser extension (browsers cluster). Exact folder unconfirmed.' }
    @{ cat='network'; name='AdGuard VPN'; path='%LOCALAPPDATA%\AdGuardVPN'; kind='folder'; admin=$false; enum=$false; note='Account email, server/exclusion prefs, logs; distinct from the AdGuard ad-blocker (%LOCALAPPDATA%\AdGuard). Exact folder unconfirmed.' }
    @{ cat='network'; name='Cloudflare WARP (1.1.1.1)'; path='%APPDATA%\Cloudflare'; kind='folder'; admin=$false; enum=$false; note='Client settings/logs; %ProgramData%\Cloudflare holds service config and Zero Trust enrollment (org/team name) when used. Runs a service.' }
    @{ cat='network'; name='ZeroTier One'; path='%ProgramData%\ZeroTier One'; kind='folder'; admin=$false; enum=$false; note='networks.d lists joined virtual-network IDs; identity.public = node address. identity.secret/authtoken.secret are SYSTEM-only and never read. Count/name networks only.' }
    @{ cat='network'; name='OpenVPN Connect (v3)'; path='%APPDATA%\OpenVPN Connect'; kind='folder'; admin=$false; enum=$false; note='Imported profiles\ + config.json + logs (server addresses, provider/employer, saved username). Official Connect client; community OpenVPN GUI profiles are a separate catalog entry.' }
    @{ cat='network'; name='SoftEther VPN Client'; path='%ProgramFiles%\SoftEther VPN Client'; kind='folder'; admin=$false; enum=$false; note='vpn_client.config holds saved connection settings (server hostnames/ports, virtual hub, account names). Runs a service + virtual adapter.' }
    @{ cat='network'; name='LogMeIn Hamachi'; path='%ProgramData%\LogMeIn Hamachi'; kind='folder'; admin=$false; enum=$false; note='client.cfg (node Hamachi address/ID) + network/peer databases. Runs a service + virtual adapter.' }
    @{ cat='network'; name='Palo Alto GlobalProtect'; path='%APPDATA%\Palo Alto Networks'; kind='folder'; admin=$false; enum=$false; note='GlobalProtect per-user config/logs; portal address in HKLM\SOFTWARE\Palo Alto Networks\GlobalProtect; PanGPS service logs in %ProgramData%. Corporate VPN.' }
    @{ cat='network'; name='FortiClient VPN tunnels'; path='HKCU:\Software\Fortinet\FortiClient\Sslvpn\Tunnels'; kind='registry'; admin=$false; enum=$false; note='Each subkey is a saved SSL-VPN tunnel (gateway Server + often a username); machine config under %ProgramData%\Fortinet\FortiClient. Often EMS/IT-managed.' }
    @{ cat='network'; name='SonicWall NetExtender'; path='HKCU:\Software\SonicWall\NetExtender'; kind='registry'; admin=$false; enum=$false; note='Saved profiles (server address, username, domain); also %APPDATA%\SonicWall\NetExtender. Key casing (historically ''SonicWALL'') and newer-version layout vary.' }
    @{ cat='network'; name='Ivanti / Pulse Secure'; path='%APPDATA%\Pulse Secure'; kind='folder'; admin=$false; enum=$false; note='User connection store (e.g. ConnectionStore\connstore.dat) with sign-in URLs/realms; also %ProgramData%\Pulse Secure. Ivanti Secure Access rebrand may use an Ivanti folder. Exact path varies.' }
    @{ cat='network'; name='Twingate'; path='%ProgramData%\Twingate'; kind='folder'; admin=$false; enum=$false; note='Service config/logs incl. the Twingate network name (company.twingate.com); also %LOCALAPPDATA%\Twingate. Device/account also live in the org admin console.' }
    # --- devices (15) ---
    @{ cat='devices'; name='USB storage history'; path='HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR'; kind='registry'; admin=$false; enum=$false; note='Subkey count = USB storage devices ever attached (vendor/model/serial).' }
    @{ cat='devices'; name='USB device enumeration'; path='HKLM:\SYSTEM\CurrentControlSet\Enum\USB'; kind='registry'; admin=$false; enum=$false; note='All USB devices ever attached; some properties ACL-restricted.' }
    @{ cat='devices'; name='Mounted volumes map'; path='HKLM:\SYSTEM\MountedDevices'; kind='registry'; admin=$true; enum=$false; note='Drive-letter/volume to disk mappings for attached media.' }
    @{ cat='devices'; name='Per-user mount points'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2'; kind='registry'; admin=$false; enum=$false; note='Drive letters for USB volumes and network shares the user opened.' }
    @{ cat='devices'; name='Portable devices'; path='HKLM:\SOFTWARE\Microsoft\Windows Portable Devices\Devices'; kind='registry'; admin=$false; enum=$false; note='Friendly names of phones/cameras/media players (often include owner name).' }
    @{ cat='devices'; name='Device install log'; path='%SystemRoot%\INF\setupapi.dev.log'; kind='folder'; admin=$false; enum=$false; note='Chronological log of every device/driver installed.' }
    @{ cat='devices'; name='Device containers'; path='HKLM:\SYSTEM\CurrentControlSet\Control\DeviceContainers'; kind='registry'; admin=$false; enum=$false; note='Container records with device friendly names (peripherals attached).' }
    @{ cat='devices'; name='Bluetooth paired devices'; path='HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Devices'; kind='registry'; admin=$true; enum=$false; note='Subkey count = paired Bluetooth devices (names/MACs).' }
    @{ cat='devices'; name='Installed printers'; path='HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers'; kind='registry'; admin=$false; enum=$false; note='Printer names and network printer hosts/IPs.' }
    @{ cat='devices'; name='Printer connections (per-user)'; path='HKCU:\Printers\Connections'; kind='registry'; admin=$false; enum=$false; note='Per-user connected printers, incl. network printers.' }
    @{ cat='devices'; name='Print spool queue'; path='%SystemRoot%\System32\spool\PRINTERS'; kind='folder'; admin=$true; enum=$false; note='Leftover spooled print jobs (document content).' }
    @{ cat='devices'; name='Camera/mic/location app access'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore'; kind='registry'; admin=$false; enum=$false; note='Per-app subkeys show which apps used webcam/mic/location and when.' }
    @{ cat='devices'; name='Game controllers / joysticks (DirectInput)'; path='HKCU:\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM'; kind='registry'; admin=$false; enum=$false; note='Friendly names of gamepads, wheels and flight sticks connected. Existence only.' }
    @{ cat='devices'; name='Imaging devices - scanners/cameras (WIA class)'; path='HKLM:\SYSTEM\CurrentControlSet\Control\Class\{6bdd1fc6-810f-11d0-bec7-08002be2092f}'; kind='registry'; admin=$true; enum=$false; note='FriendlyName per installed scanner/webcam/camera; remove via Device Manager. Existence only.' }
    @{ cat='devices'; name='Portable device (MTP) enumeration (WpdBusEnumRoot)'; path='HKLM:\SYSTEM\CurrentControlSet\Enum\WpdBusEnumRoot'; kind='registry'; admin=$true; enum=$false; note='Phones/cameras/media players connected over MTP/PTP; bus-level, deeper than Windows Portable Devices list. Existence only.' }
    # --- activity-traces (21) ---
    @{ cat='activity-traces'; name='Recent items'; path='%APPDATA%\Microsoft\Windows\Recent'; kind='folder'; admin=$false; enum=$false; note='Count of .lnk shortcuts = recently opened files/folders, incl. removed drives.' }
    @{ cat='activity-traces'; name='Jump lists (automatic)'; path='%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations'; kind='folder'; admin=$false; enum=$false; note='One file per app; count = apps that kept recent-item history. Backs Quick Access.' }
    @{ cat='activity-traces'; name='Jump lists (custom)'; path='%APPDATA%\Microsoft\Windows\Recent\CustomDestinations'; kind='folder'; admin=$false; enum=$false; note='App-pinned/task jump-list entries; count of per-app files.' }
    @{ cat='activity-traces'; name='RecentDocs'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs'; kind='registry'; admin=$false; enum=$false; note='Subkey/value count = recently opened file names per extension.' }
    @{ cat='activity-traces'; name='RunMRU'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU'; kind='registry'; admin=$false; enum=$false; note='Value count = commands/paths typed into the Win+R Run box.' }
    @{ cat='activity-traces'; name='TypedPaths'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths'; kind='registry'; admin=$false; enum=$false; note='Value count = paths/UNC/URLs typed into the Explorer address bar.' }
    @{ cat='activity-traces'; name='WordWheelQuery'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery'; kind='registry'; admin=$false; enum=$false; note='Value count = Explorer search-box terms; key absent until Explorer search used.' }
    @{ cat='activity-traces'; name='ComDlg32 OpenSavePidlMRU'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\OpenSavePidlMRU'; kind='registry'; admin=$false; enum=$false; note='Subkey/value count = files chosen in Open/Save dialogs, per extension.' }
    @{ cat='activity-traces'; name='ComDlg32 LastVisitedPidlMRU'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\LastVisitedPidlMRU'; kind='registry'; admin=$false; enum=$false; note='Value count = apps and the last folder their Open/Save dialog visited.' }
    @{ cat='activity-traces'; name='ComDlg32 CIDSizeMRU'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\CIDSizeMRU'; kind='registry'; admin=$false; enum=$false; note='Value count = apps that opened a common dialog.' }
    @{ cat='activity-traces'; name='ComDlg32 FirstFolder'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32\FirstFolder'; kind='registry'; admin=$false; enum=$false; note='Subkey/value count = initial folder each app''s dialog showed.' }
    @{ cat='activity-traces'; name='Activity history / Timeline DB'; path='%LOCALAPPDATA%\ConnectedDevicesPlatform'; kind='folder'; admin=$false; enum=$false; note='Per-identity ActivitiesCache.db (apps/files opened); existence+size indicator.' }
    @{ cat='activity-traces'; name='Clipboard store'; path='%LOCALAPPDATA%\Microsoft\Windows\Clipboard'; kind='folder'; admin=$false; enum=$false; note='Persisted/pinned clipboard items; folder absent until history enabled.' }
    @{ cat='activity-traces'; name='Clipboard settings key'; path='HKCU:\Software\Microsoft\Clipboard'; kind='registry'; admin=$false; enum=$false; note='Existence = clipboard history/sync configured; no content read.' }
    @{ cat='activity-traces'; name='Notification history'; path='%LOCALAPPDATA%\Microsoft\Windows\Notifications'; kind='folder'; admin=$false; enum=$false; note='wpndatabase.db of Action Center toast previews; existence+size indicator.' }
    @{ cat='activity-traces'; name='Cortana data (legacy)'; path='%LOCALAPPDATA%\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy'; kind='folder'; admin=$false; enum=$false; note='Legacy; normally absent on current Windows 11, present on older Win10/upgrades.' }
    @{ cat='activity-traces'; name='PowerShell history (PSReadLine)'; path='%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine'; kind='folder'; admin=$false; enum=$false; note='ConsoleHost_history.txt (plain-text commands); existence+size only, no content.' }
    @{ cat='activity-traces'; name='RDP connection MRU'; path='HKCU:\Software\Microsoft\Terminal Server Client\Default'; kind='registry'; admin=$false; enum=$false; note='Value count = recent RDP targets; absent until mstsc used.' }
    @{ cat='activity-traces'; name='Windows Search index (Windows.edb)'; path='%ProgramData%\Microsoft\Search\Data\Applications\Windows'; kind='folder'; admin=$true; enum=$false; note='Content index of file names/text; protected, reports empty when unelevated.' }
    @{ cat='activity-traces'; name='Maps app data'; path='%LOCALAPPDATA%\Packages\Microsoft.WindowsMaps_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Search history, favorites (home/work), offline-map regions.' }
    @{ cat='activity-traces'; name='Ditto clipboard history'; path='%APPDATA%\Ditto'; kind='folder'; admin=$false; enum=$false; note='Ditto.db clipboard-history database; flag existence/count only, never read values.' }
    # --- forensic-traces (16) ---
    @{ cat='forensic-traces'; name='UserAssist'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist'; kind='registry'; admin=$false; enum=$false; note='Subkey count = GUI programs launched (ROT13 names, run counts, last-run times).' }
    @{ cat='forensic-traces'; name='ShellBags (NTUSER)'; path='HKCU:\Software\Microsoft\Windows\Shell\BagMRU'; kind='registry'; admin=$false; enum=$false; note='Subkey count = depth of browsed-folder history (incl. removed/network/deleted).' }
    @{ cat='forensic-traces'; name='ShellBags (USRCLASS)'; path='HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU'; kind='registry'; admin=$false; enum=$false; note='Primary per-user shellbags in USRCLASS hive; subkey count.' }
    @{ cat='forensic-traces'; name='MUICache'; path='HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache'; kind='registry'; admin=$false; enum=$false; note='Value count = executables run (paths + friendly names cached).' }
    @{ cat='forensic-traces'; name='FeatureUsage'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage'; kind='registry'; admin=$false; enum=$false; note='Subkey count = taskbar app launch/switch tracking (Win10 1903+).' }
    @{ cat='forensic-traces'; name='Prefetch'; path='%WINDIR%\Prefetch'; kind='folder'; admin=$true; enum=$false; note='Count of .pf files = programs executed (run counts, timestamps); needs admin.' }
    @{ cat='forensic-traces'; name='Amcache'; path='%WINDIR%\AppCompat\Programs'; kind='folder'; admin=$true; enum=$false; note='Amcache.hve (executed/installed apps, hashes); protected, needs admin.' }
    @{ cat='forensic-traces'; name='SRUM'; path='%WINDIR%\System32\sru'; kind='folder'; admin=$true; enum=$false; note='SRUDB.dat (per-app CPU/network/disk by user); protected, needs admin.' }
    @{ cat='forensic-traces'; name='BAM/DAM'; path='HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings'; kind='registry'; admin=$true; enum=$false; note='Subkey count = per-SID records of executables run and last-run times; admin.' }
    @{ cat='forensic-traces'; name='ShimCache (AppCompatCache)'; path='HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache'; kind='registry'; admin=$true; enum=$false; note='Existence of AppCompatCache value = executable-path/time cache; admin.' }
    @{ cat='forensic-traces'; name='Thumbnail & icon cache'; path='%LOCALAPPDATA%\Microsoft\Windows\Explorer'; kind='folder'; admin=$false; enum=$false; note='thumbcache_*.db/iconcache_*.db: thumbnails of viewed (even deleted) media; existence+size.' }
    @{ cat='forensic-traces'; name='RDP bitmap cache'; path='%LOCALAPPDATA%\Microsoft\Terminal Server Client\Cache'; kind='folder'; admin=$false; enum=$false; note='Cache*.bin/bcache*.bmc: reconstructable tiles of remote screens; existence+size.' }
    @{ cat='forensic-traces'; name='Event logs'; path='%WINDIR%\System32\winevt\Logs'; kind='folder'; admin=$true; enum=$false; note='Count/size of .evtx logins, device and app events; needs admin to read or clear.' }
    @{ cat='forensic-traces'; name='RecentApps (Windows 10 launch history)'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps'; kind='registry'; admin=$false; enum=$false; note='Win10-centric, usually absent on Win11; apps launched + recent files + last-access time. Count/existence only.' }
    @{ cat='forensic-traces'; name='Program Compatibility Assistant (PCA) logs'; path='%WINDIR%\appcompat\pca'; kind='folder'; admin=$true; enum=$false; note='Win11 22H2+; PcaAppLaunchDic.txt/PcaGeneralDb*.txt record executable paths + run times. Existence only.' }
    @{ cat='forensic-traces'; name='Compatibility Assistant Store (AppCompatFlags)'; path='HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store'; kind='registry'; admin=$false; enum=$false; note='Also HKLM copy (admin); records paths of executables that ran. Count/existence only.' }
    # --- recall-copilot (2) ---
    @{ cat='recall-copilot'; name='Recall snapshots'; path='%LOCALAPPDATA%\CoreAIPlatform.00'; kind='folder'; admin=$false; enum=$false; note='Recall screenshot DB/images on Copilot+ PCs; also governs Click to Do.' }
    @{ cat='recall-copilot'; name='Copilot app data'; path='%LOCALAPPDATA%\Packages\Microsoft.Copilot_8wekyb3d8bbwe'; kind='folder'; admin=$false; enum=$false; note='Local Copilot app cache; authoritative history is in the MSA cloud.' }
    # --- system-traces (25) ---
    @{ cat='system-traces'; name='User temp'; path='%TEMP%'; kind='folder'; admin=$false; enum=$false; note='Per-user scratch files; apps leave documents, installers and logs here.' }
    @{ cat='system-traces'; name='Windows temp'; path='%SystemRoot%\Temp'; kind='folder'; admin=$true; enum=$false; note='Machine-level service/installer scratch files.' }
    @{ cat='system-traces'; name='Windows Error Reporting (user)'; path='%LOCALAPPDATA%\Microsoft\Windows\WER'; kind='folder'; admin=$false; enum=$false; note='Crash reports naming apps, file paths and data fragments.' }
    @{ cat='system-traces'; name='Windows Error Reporting (machine)'; path='%ProgramData%\Microsoft\Windows\WER'; kind='folder'; admin=$true; enum=$false; note='Machine-wide crash reports; needs admin.' }
    @{ cat='system-traces'; name='Application crash dumps'; path='%LOCALAPPDATA%\CrashDumps'; kind='folder'; admin=$false; enum=$false; note='User-mode .dmp files can hold in-memory personal data.' }
    @{ cat='system-traces'; name='Kernel crash dumps'; path='%SystemRoot%\Minidump'; kind='folder'; admin=$true; enum=$false; note='BSOD dumps; MEMORY.DMP in the same area can hold RAM contents.' }
    @{ cat='system-traces'; name='Windows.old'; path='%SystemDrive%\Windows.old'; kind='folder'; admin=$true; enum=$false; note='Entire previous install including old user profiles.' }
    @{ cat='system-traces'; name='System Restore config'; path='HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore'; kind='registry'; admin=$false; enum=$false; note='Indicates restore points/shadow copies hold prior file versions; full count needs elevated VSS.' }
    @{ cat='system-traces'; name='Hibernation file'; path='%SystemDrive%\hiberfil.sys'; kind='folder'; admin=$true; enum=$false; note='Presence/size of on-disk RAM image.' }
    @{ cat='system-traces'; name='Page file'; path='%SystemDrive%\pagefile.sys'; kind='folder'; admin=$true; enum=$false; note='Paged memory on disk; swapfile.sys is adjacent.' }
    @{ cat='system-traces'; name='Delivery Optimization cache'; path='%SystemRoot%\SoftwareDistribution\DeliveryOptimization'; kind='folder'; admin=$true; enum=$false; note='Update/Store content chunks; minimal personal data (path varies by build).' }
    @{ cat='system-traces'; name='Defender detection history'; path='%ProgramData%\Microsoft\Windows Defender\Scans\History'; kind='folder'; admin=$true; enum=$false; note='Names/paths of files flagged as threats; Quarantine folder adjacent.' }
    @{ cat='system-traces'; name='Diagnostic telemetry DB'; path='%ProgramData%\Microsoft\Diagnosis\EventTranscript\EventTranscript.db'; kind='folder'; admin=$true; enum=$false; note='Diagnostic events incl. app usage, when diagnostics enabled.' }
    @{ cat='system-traces'; name='Windows Update download cache'; path='%SystemRoot%\SoftwareDistribution\Download'; kind='folder'; admin=$true; enum=$false; note='Downloaded update/driver packages; minimal personal data.' }
    @{ cat='system-traces'; name='Installer/package cache'; path='%ProgramData%\Package Cache'; kind='folder'; admin=$true; enum=$false; note='Cached installers reveal installed software.' }
    @{ cat='system-traces'; name='Windows Installer cache'; path='%SystemRoot%\Installer'; kind='folder'; admin=$true; enum=$false; note='Cached MSI/MSP reveal installed apps; do not delete (breaks repair/uninstall), existence only.' }
    @{ cat='system-traces'; name='Themes wallpaper cache'; path='%APPDATA%\Microsoft\Windows\Themes'; kind='folder'; admin=$false; enum=$false; note='TranscodedWallpaper and CachedFiles copies of the desktop wallpaper.' }
    @{ cat='system-traces'; name='Recent wallpapers list'; path='HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers'; kind='registry'; admin=$false; enum=$false; note='Paths of the last few wallpapers used.' }
    @{ cat='system-traces'; name='System Volume Information (per volume)'; path='%SystemDrive%\System Volume Information'; kind='folder'; admin=$true; enum=$true; note='Present on every NTFS volume, not just the system drive; holds shadow copies / previous-version and restore data under a SYSTEM-only ACL, so enumerating contents needs elevation.' }
    @{ cat='system-traces'; name='Registry hive backups (RegBack)'; path='%SystemRoot%\System32\config\RegBack'; kind='folder'; admin=$true; enum=$false; note='Backup copies of SYSTEM/SOFTWARE/SAM/etc.; empty (0-byte) by default since Win10 1803 unless re-enabled. The live config hives and per-profile NTUSER.DAT.LOG1/.LOG2 also retain residue. Folder is admin-protected (access-denied without elevation, confirmed).' }
    @{ cat='system-traces'; name='Reliability Monitor data (RAC)'; path='%ProgramData%\Microsoft\RAC'; kind='folder'; admin=$true; enum=$false; note='StateData + PublishedData (RacWmiDatabase.sdf); install/uninstall/crash timeline, rebuilt from event logs. Existence only.' }
    @{ cat='system-traces'; name='Windows Setup logs (Panther)'; path='%WINDIR%\Panther'; kind='folder'; admin=$true; enum=$false; note='setupact/setuperr logs; setup username, computer name, edition, timestamps. Existence only.' }
    @{ cat='system-traces'; name='Component-Based Servicing (CBS) logs'; path='%WINDIR%\Logs\CBS'; kind='folder'; admin=$true; enum=$false; note='Package/update servicing history; low personal content. Existence only.' }
    @{ cat='system-traces'; name='Live kernel reports (LiveKernelReports)'; path='%WINDIR%\LiveKernelReports'; kind='folder'; admin=$true; enum=$false; note='*.dmp live kernel dumps; memory fragments + fault dates. Existence only.' }
    @{ cat='system-traces'; name='PowerShell transcripts'; path='%USERPROFILE%\Documents\PowerShell\transcripts'; kind='folder'; admin=$false; enum=$false; note='Only if transcription was enabled; full command+output logs; separate from PSReadLine history. Existence only.' }
)

# --- run -------------------------------------------------------------------

if ($ListProbes) {
    $tally = @{}
    foreach ($pr in $Probes) {
        if (-not $tally.ContainsKey($pr.cat)) { $tally[$pr.cat] = 0 }
        $tally[$pr.cat]++
    }
    foreach ($id in ($tally.Keys | Sort-Object)) { '{0,-20} {1}' -f $id, $tally[$id] }
    ''
    ('TOTAL: {0} probes across {1} categories (+ installed-programs enumerated live).' -f @($Probes).Count, @($Plan).Count)
    return
}

$isAdmin = Test-WwAdmin
$report = [ordered]@{
    tool        = 'WipeWise'
    version     = '0.1.3'
    mode        = $(if ($Quick) { 'quick' } else { 'full' })
    generatedOn = (Get-Date).ToString('o')
    computer    = $env:COMPUTERNAME
    user        = $env:USERNAME
    elevated    = $isAdmin
    readonly    = $true
    probeCount  = @($Probes).Count
    categories  = @()
}

# group probes by category id
$byCat = @{}
foreach ($pr in $Probes) {
    if (-not $byCat.ContainsKey($pr.cat)) { $byCat[$pr.cat] = @() }
    $byCat[$pr.cat] += $pr
}

foreach ($cat in $Plan) {
    $id    = $cat.id
    $items = @()
    $note  = $null

    if ($id -eq 'installed-programs') {
        # read-only enumeration of the uninstall registry (no commands)
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
                        $apps += [ordered]@{ name = [string]$_.DisplayName; version = [string]$_.DisplayVersion; publisher = [string]$_.Publisher }
                    }
            } catch {}
        }
        $apps = $apps | Sort-Object { $_.name } -Unique
        $note = ('{0} programs found. Sign out and deactivate licenses before uninstalling.' -f @($apps).Count)
        $items = @($apps | ForEach-Object { [pscustomobject]$_ })
    }
    elseif ($id -eq 'other-users') {
        # Enumerate OTHER local user profiles (not the signed-in one, not system profiles).
        $cur  = ($env:USERPROFILE).TrimEnd('\')
        $skip = @('Public','Default','Default User','All Users','WDAGUtilityAccount','defaultuser0','systemprofile','LocalService','NetworkService')
        $profiles = @()
        try {
            Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList' -ErrorAction SilentlyContinue | ForEach-Object {
                $pip = (Get-ItemProperty -LiteralPath $_.PSPath -ErrorAction SilentlyContinue).ProfileImagePath
                if ($pip) { $profiles += [string]$pip }
            }
        } catch {}
        if (-not $profiles) {
            try { $profiles = Get-ChildItem (Join-Path $env:SystemDrive 'Users') -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName } } catch {}
        }
        $userCount = 0
        foreach ($pp in ($profiles | Sort-Object -Unique)) {
            if ([string]::IsNullOrWhiteSpace($pp)) { continue }
            if ($pp -notmatch '\\Users\\') { continue }
            $leaf = Split-Path $pp -Leaf
            if ($skip -contains $leaf) { continue }
            if ($pp.TrimEnd('\') -ieq $cur) { continue }
            $userCount++
            $m = Measure-WwTree -Path $pp -Quick
            $items += [pscustomobject]([ordered]@{ name=("{0} - profile" -f $leaf); path=$pp; kind='folder'; exists=[bool]$m.exists; files=[int]$m.files; bytes=0; examples=@($m.examples); needsAdmin=$true; note='Another local account profile (top-level count). Reading its files needs Administrator; delete the account in Settings > Accounts or clean it signed in as that user.' })
            foreach ($sub in 'Desktop','Documents','Downloads') {
                $ms = Measure-WwTree -Path (Join-Path $pp $sub) -Quick:$Quick
                if ($ms.exists) {
                    $items += [pscustomobject]([ordered]@{ name=("{0} - {1}" -f $leaf,$sub); path=(Join-Path $pp $sub); kind='folder'; exists=$true; files=[int]$ms.files; bytes=[int64]$ms.bytes; examples=@($ms.examples); needsAdmin=$true; note="Another account's personal files." })
                }
            }
        }
        $note = ('{0} other local user account(s) found. Only the signed-in account is cleaned by the per-user probes above.' -f $userCount)
    }
    elseif ($id -eq 'other-volumes') {
        # Enumerate non-system fixed/removable volumes: their recycle bin, shadow-copy store, and top-level data.
        $sysDrive = ($env:SystemDrive).TrimEnd('\')
        $volCount = 0
        $drives = @()
        try { $drives = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady -and ($_.DriveType -eq 'Fixed' -or $_.DriveType -eq 'Removable') } } catch {}
        foreach ($d in $drives) {
            $root = $d.Name.TrimEnd('\')
            if ($root -ieq $sysDrive) { continue }
            $volCount++
            $dtype = [string]$d.DriveType
            $mv = Measure-WwTree -Path ($root + '\') -Quick
            $items += [pscustomobject]([ordered]@{ name=("{0} - top-level items" -f $root); path=($root + '\'); kind='folder'; exists=[bool]$mv.exists; files=[int]$mv.files; bytes=0; examples=@($mv.examples); needsAdmin=$false; note=("{0} volume. Top-level item count; this drive carries its own user data." -f $dtype) })
            $mr = Measure-WwTree -Path ($root + '\$Recycle.Bin') -Quick:$Quick
            $items += [pscustomobject]([ordered]@{ name=("{0} - Recycle Bin" -f $root); path=($root + '\$Recycle.Bin'); kind='folder'; exists=[bool]$mr.exists; files=[int]$mr.files; bytes=[int64]$mr.bytes; examples=@(); needsAdmin=$true; note='Deleted files on this volume; empty the Recycle Bin per volume.' })
            $msvi = Measure-WwTree -Path ($root + '\System Volume Information') -Quick
            $items += [pscustomobject]([ordered]@{ name=("{0} - System Volume Information" -f $root); path=($root + '\System Volume Information'); kind='folder'; exists=[bool]$msvi.exists; files=[int]$msvi.files; bytes=0; examples=@(); needsAdmin=$true; note='Shadow copies / restore data on this volume (top-level count; needs admin).' })
        }
        $note = ('{0} non-system volume(s) found. The system drive is covered by the other categories.' -f $volCount)
    }
    elseif ($byCat.ContainsKey($id)) {
        foreach ($pr in $byCat[$id]) {
            if ($pr.kind -eq 'registry') {
                $rp = ConvertTo-WwRegPath $pr.path
                $rc = Get-WwRegCount -Path $rp
                $items += [pscustomobject]([ordered]@{
                    name       = $pr.name
                    path       = $pr.path
                    kind       = 'registry'
                    exists     = [bool]$rc.exists
                    files      = [int]$rc.values
                    subkeys    = [int]$rc.subkeys
                    bytes      = 0
                    examples   = @()
                    needsAdmin = [bool]$pr.admin
                    note       = $pr.note
                })
            }
            else {
                # Broad containers (enum=true, e.g. C:\Users, Packages) are counted
                # top-level only, never deep-sized: their bytes overlap other categories
                # and a recursive sum double-counts and is misleadingly huge.
                $useQuick = $Quick -or $pr.enum
                $m = Measure-WwTree -Path $pr.path -Quick:$useQuick
                $noteOut = $pr.note
                if ($pr.enum) { $noteOut = ($pr.note + ' (top-level count only, not deep-sized)') }
                $items += [pscustomobject]([ordered]@{
                    name       = $pr.name
                    path       = $pr.path
                    kind       = 'folder'
                    exists     = [bool]$m.exists
                    files      = [int]$m.files
                    bytes      = [int64]$m.bytes
                    examples   = @($m.examples)
                    needsAdmin = [bool]$pr.admin
                    note       = $noteOut
                })
            }
        }
    }

    $present  = @($items | Where-Object { $_.PSObject.Properties['exists'] -and $_.exists }).Count
    if ($id -eq 'installed-programs') { $present = @($items).Count }
    $catBytes = ($items | Where-Object { $_.PSObject.Properties['bytes'] } | Measure-Object -Property bytes -Sum).Sum
    if (-not $catBytes) { $catBytes = 0 }

    $report.categories += [pscustomobject]([ordered]@{
        id          = $id
        title       = $cat.title
        description = $cat.desc
        itemCount   = @($items).Count
        present     = $present
        bytes       = [int64]$catBytes
        note        = $note
        items       = $items
    })
}

$json = $report | ConvertTo-Json -Depth 6
if ($OutFile) {
    $json | Out-File -LiteralPath $OutFile -Encoding UTF8
    Write-Host ("WipeWise scan written to {0} (read-only; {1} mode; elevated={2}; {3} probes)." -f $OutFile, $report.mode, $isAdmin, $report.probeCount)
} else {
    $json
}
