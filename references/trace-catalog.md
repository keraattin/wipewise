# WipeWise Trace Catalog

A reference map of the personal data and usage traces a Windows 10/11 PC accumulates, for an owner preparing to **sell, return, recycle, or hand over** the machine. For each trace it records **where** it lives, **what it reveals**, **how the user removes it**, and **what survives** that removal.

WipeWise is **read-only**: it reports what exists; it never deletes or changes anything. Every "Remove" step below is performed by **you**, through Windows' own UI, an app's own UI, or a command you run yourself. This catalog is for **devices and data you own or are authorized to erase**.

## How to read each entry

Every artifact is written as a block:

- **Where** — the exact path(s) (in `%ENVVAR%` form) and/or registry key(s).
- **Reveals** — what personal information it exposes about the previous user.
- **Remove (user runs)** — exactly how *you* clear it.
- **Survives** — what the removal does **not** reach.
- **Admin** — whether reading or removing needs Administrator.

## The three things that survive almost everything

Read this before trusting any single "Remove" step:

1. **A local delete is not a secure erase.** Deleting a file or a registry value only unlinks it. The content stays on the drive until its space is reused — on an SSD until TRIM/garbage-collection runs, on an HDD until it is overwritten — and remains recoverable with forensic tools until then. Recovery-proof erasure of the whole device is the planned **Maximum mode** (see `standards.md`), not a per-file clean.
2. **Cloud and backup copies are separate.** Anything synced (OneDrive, Google Drive, iCloud, browser sync, messaging history) or backed up (File History, image backups, another device) has a copy that wiping this PC does **not** touch. Stop sync / unlink first, then clean locally, then remove the cloud copy from the provider — in that order (see `delink-checklist.md`).
3. **Other accounts, other volumes, and shadow copies hold the same data again.** A handover PC often has several user profiles under `C:\Users`, secondary and USB volumes with their own `$Recycle.Bin` and `System Volume Information`, and System Restore / Volume Shadow Copies and `Windows.old` that each keep older copies of files and registry hives. A thorough clean covers all of them, not just the signed-in profile on `C:`.

Honest limits and the standards behind them: `limitations.md` and `standards.md`.

## Contents

- [Personal files & cloud storage](#personal-files--cloud-storage)
- [Browser data (all browsers, deep)](#browser-data-all-browsers-deep)
- [Messaging & email apps](#messaging--email-apps)
- [Productivity, media & gaming apps](#productivity-media--gaming-apps)
- [More browsers, cloud, messengers & notes](#more-browsers-cloud-messengers--notes)
- [Media, capture, conferencing & Windows built-ins](#media-capture-conferencing--windows-built-ins)
- [Finance, crypto wallets & authenticators](#finance-crypto-wallets--authenticators)
- [Virtual machines, WSL & backups](#virtual-machines-wsl--backups)
- [Credentials, keys & secrets](#credentials-keys--secrets)
- [More credentials: remote, database, CLI, managers & VPN](#more-credentials-remote-database-cli-managers--vpn)
- [Activity history & forensic traces](#activity-history--forensic-traces)
- [System, devices, network, identity & AI](#system-devices-network-identity--ai)
- [More browsers, messaging & email clients](#more-browsers-messaging--email-clients)
- [More media, creative, games & built-in apps](#more-media-creative-games--built-in-apps)
- [More developer, cloud & database tools](#more-developer-cloud--database-tools)
- [More password managers, wallets, cloud & VPN](#more-password-managers-wallets-cloud--vpn)
- [Version-specific hives & deeper forensic/system traces](#version-specific-hives--deeper-forensicsystem-traces)
- [Scope: other accounts, other volumes & recoverability](#scope-other-accounts-other-volumes--recoverability)

---

## Personal files & cloud storage

The largest and most obvious store of the previous owner's data: the files in the user profile, on secondary drives, in the Recycle Bin, and in local cloud-sync folders. Paths use environment variables (`%USERPROFILE%`, `%LOCALAPPDATA%`, `%APPDATA%`, `%PUBLIC%`, `%SystemDrive%`). WipeWise only reads and reports; every removal below is performed by the **user**, through Windows' own UI, the app's own UI, or a command the user runs themselves.

The single most important point in this whole cluster: **a local cloud-sync folder has a copy in the cloud.** Deleting the local folder while the client is still linked and syncing can delete the cloud copy too — or do nothing, because the files were only online-only placeholders. In both directions the cloud account is the real control. Stop sync / unlink the device **first**, then clean locally, then remove the cloud copy from the provider's website. This ordering is repeated in `delink-checklist.md`.

---

### Desktop
- **Where:** `%USERPROFILE%\Desktop` (and the all-users desktop `%PUBLIC%\Desktop`). Under OneDrive Known Folder Move this folder is redirected into OneDrive — see "Known-folder redirection" below.
- **Reveals:** Everything the owner parked on screen: documents, installers, screenshots, shortcuts whose names and targets name people, projects, servers and apps.
- **Remove (user runs):** Back up anything to keep to external media, then delete the contents in File Explorer and empty the Recycle Bin. If the Desktop is redirected into OneDrive, unlink OneDrive first (see below).
- **Survives:** Cloud copy if the Desktop is in OneDrive/another sync root and sync was not stopped first. Shortcut *target* paths can still be inferred from jump lists and Recent items (activity-traces cluster). Emptied files remain recoverable on an SSD until TRIM, and on an HDD until the space is overwritten.
- **Admin:** No for your own profile; reading another user's Desktop needs Administrator.

### Documents
- **Where:** `%USERPROFILE%\Documents` (all-users: `%PUBLIC%\Documents`). Common target of OneDrive Known Folder Move. Apps also drop data here (e.g. `Documents\Outlook Files` for PST/OST, `Documents\Custom Office Templates`, scanner/notetaking folders).
- **Reveals:** The bulk of personal and work documents — letters, statements, scans of IDs, spreadsheets, tax and medical files, app-created subfolders.
- **Remove (user runs):** Back up, delete in File Explorer, empty the Recycle Bin. Export/back up any PST before deleting `Documents\Outlook Files`.
- **Survives:** Cloud copy if redirected into OneDrive and sync not stopped. SSD/HDD remnants until TRIM/overwrite. App-specific caches of the same documents live elsewhere (browsers, Office MRU) and are separate clusters.
- **Admin:** No for your own profile.

### Downloads
- **Where:** `%USERPROFILE%\Downloads`.
- **Reveals:** A timeline of what the owner fetched: installers, invoices and tickets with names and order numbers, email attachments, media, and documents saved from web and chat apps. Frequently the richest unreviewed folder.
- **Remove (user runs):** Review (it often holds forgotten sensitive PDFs), back up anything needed, delete, empty the Recycle Bin. Settings > System > Storage > Temporary files can also clear Downloads if you tick that box.
- **Survives:** SSD/HDD remnants until TRIM/overwrite. Browser download *history* (the list of what was downloaded and from where) lives in the browser profile, not here — that is the browsers cluster.
- **Admin:** No.

### Pictures
- **Where:** `%USERPROFILE%\Pictures` (all-users: `%PUBLIC%\Pictures`). Common OneDrive Known Folder Move target. Holds the subfolders below plus app folders (e.g. `Pictures\Feedback`, `Pictures\iCloud Photos` when iCloud is installed).
- **Reveals:** Personal photos and their embedded metadata — EXIF timestamps and, for phone photos, often GPS coordinates that map the owner's home and routine; faces; documents photographed for convenience.
- **Remove (user runs):** Back up, delete in File Explorer, empty the Recycle Bin. If redirected into OneDrive or synced by iCloud Photos, stop that sync first (see the cloud blocks).
- **Survives:** Cloud copy (OneDrive Camera Backup, iCloud Photos, Google Photos) until removed server-side. SSD/HDD remnants until TRIM/overwrite. EXIF GPS/time stays inside any copied-out file.
- **Admin:** No for your own profile.

### Camera Roll
- **Where:** `%USERPROFILE%\Pictures\Camera Roll` (created on demand by the Camera app / webcam capture; absent if never used).
- **Reveals:** Photos and videos taken with the device's own camera/webcam — faces, surroundings, whatever was in frame — with capture timestamps.
- **Remove (user runs):** Back up, delete the folder contents, empty the Recycle Bin.
- **Survives:** OneDrive "Camera Backup" copy if that was enabled — stop OneDrive sync and remove the cloud copy. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Screenshots
- **Where:** `%USERPROFILE%\Pictures\Screenshots` (created when Win+PrtScn is first used).
- **Reveals:** Exactly what the owner had on screen when capturing — messages, banking pages, tokens/codes, personal chats, work in progress. Often unreviewed.
- **Remove (user runs):** Review, back up anything needed, delete, empty the Recycle Bin.
- **Survives:** Cloud copy if Pictures is synced. SSD/HDD remnants until TRIM/overwrite. Clipboard-based screenshots (Win+Shift+S) are not saved here but may appear in clipboard history (activity-traces cluster).
- **Admin:** No.

### Saved Pictures
- **Where:** `%USERPROFILE%\Pictures\Saved Pictures` (created by the Photos app when images are saved; absent if never used).
- **Reveals:** Images the owner chose to keep from the Photos app, web or messaging.
- **Remove (user runs):** Back up, delete, empty the Recycle Bin.
- **Survives:** Cloud copy if Pictures is synced. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Videos
- **Where:** `%USERPROFILE%\Videos` (all-users: `%PUBLIC%\Videos`). Game capture tools (Xbox Game Bar) write to `Videos\Captures`.
- **Reveals:** Personal recordings, screen/game captures (which can show logged-in apps and desktops), downloaded video.
- **Remove (user runs):** Back up, delete, empty the Recycle Bin.
- **Survives:** Cloud copy if synced. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Music
- **Where:** `%USERPROFILE%\Music` (all-users: `%PUBLIC%\Music`). Some apps keep libraries/recordings here (e.g. voice memos, `Music\iTunes` for older iTunes).
- **Reveals:** Music library and any personal audio — voice recordings can contain private speech.
- **Remove (user runs):** Back up, delete, empty the Recycle Bin.
- **Survives:** Cloud copy if synced. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Favorites (Internet Explorer / legacy Edge)
- **Where:** `%USERPROFILE%\Favorites` (`.url` shortcut files).
- **Reveals:** Saved sites — interests, employer intranet and webmail URLs, banking and shopping sites. (Modern Chrome/Edge/Firefox bookmarks live in the browser profile, not here; those are the browsers cluster.)
- **Remove (user runs):** Delete the `.url` files in File Explorer, or in Internet Explorer/legacy Edge remove the favorites, then empty the Recycle Bin.
- **Survives:** Bookmarks synced to a Microsoft/Google/Mozilla account persist server-side until that sync is turned off and cleared. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Links (Explorer navigation-pane favorites)
- **Where:** `%USERPROFILE%\Links` (`.lnk` shortcuts shown under Favorites/Quick access targets).
- **Reveals:** Folders the owner pinned for quick access — often named for projects, clients or people, and may point to network shares or other drives, revealing where more personal data lives.
- **Remove (user runs):** Delete the shortcuts in File Explorer, empty the Recycle Bin. (These are pointers; also clean the folders they point to.)
- **Survives:** The actual target folders — the shortcut only names them.
- **Admin:** No.

### Contacts (Windows Contacts)
- **Where:** `%USERPROFILE%\Contacts` (`.contact` files).
- **Reveals:** Names, phone numbers, email and postal addresses of the owner's contacts — third-party personal data, not just the owner's.
- **Remove (user runs):** Delete the `.contact` files in File Explorer, empty the Recycle Bin.
- **Survives:** Contacts synced from a mail/account app (Outlook, People app, iCloud Contacts) are re-created from the server while that account is signed in — remove the account too. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Searches (saved searches)
- **Where:** `%USERPROFILE%\Searches` (`.search-ms` saved-search files).
- **Reveals:** Saved File Explorer search queries — the terms and the folders/drives they were scoped to, hinting at what and where the owner looked.
- **Remove (user runs):** Delete the `.search-ms` files in File Explorer, empty the Recycle Bin. (Typed-into-the-box search history is separate — registry `WordWheelQuery`, in the activity-traces cluster.)
- **Survives:** SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Saved Games
- **Where:** `%USERPROFILE%\Saved Games` (many titles also save under `Documents\My Games`, `%APPDATA%`, or the launcher's folders).
- **Reveals:** Game save files and profiles — can embed player names and play history; less sensitive but still personal.
- **Remove (user runs):** Back up any saves worth keeping, delete, empty the Recycle Bin. Also sign out of game launchers (apps-media-gaming cluster) so cloud saves are not re-synced.
- **Survives:** Steam Cloud / Xbox / launcher cloud saves re-download on next sign-in — handle in the launcher. Saves in other folders listed above.
- **Admin:** No.

### 3D Objects
- **Where:** `%USERPROFILE%\3D Objects`. Legacy known folder; removed from the "This PC" view in Windows 10 1903+ and usually absent or empty on Windows 11, but the folder can still exist on upgraded systems.
- **Reveals:** 3D model files, if the owner used Paint 3D / Mixed Reality tools.
- **Remove (user runs):** If present, back up anything needed, delete, empty the Recycle Bin.
- **Survives:** SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Public (all-users) folder
- **Where:** `%PUBLIC%` (= `%SystemDrive%\Users\Public`), containing `Public Desktop`, `Public Documents`, `Public Downloads`, `Public Music`, `Public Pictures`, `Public Videos`.
- **Reveals:** Files the owner shared to every account on the PC, or that installers/media apps dropped here. Easy to miss because it is outside your own profile.
- **Remove (user runs):** Review each Public subfolder in File Explorer, back up, delete, empty the Recycle Bin.
- **Survives:** SSD/HDD remnants until TRIM/overwrite. Some `Public Desktop` shortcuts are placed by apps and reappear if those apps are reinstalled.
- **Admin:** No to read/delete most Public contents; a few items placed by the system may need Administrator.

### Additional drives & partitions
- **Where:** Any fixed or removable volume other than `%SystemDrive%` — e.g. `D:\`, `E:\` — plus that volume's own hidden `D:\$Recycle.Bin`. Data-drive setups keep media libraries, backups, disk images, VM files, project and game folders here.
- **Reveals:** Often the single biggest block of personal data, entirely outside the user profile, and the most commonly forgotten in a handover.
- **Remove (user runs):** Review every drive in File Explorer; back up and delete personal data, and empty each drive's Recycle Bin separately. If a whole data drive goes with the PC and holds nothing to keep, the owner can format it (Disk Management > right-click the volume > Format) — note a quick format is **not** a secure wipe.
- **Survives:** A quick format leaves file content recoverable until overwritten; SSD remnants persist until TRIM/whole-device sanitize. Each drive keeps its own separate Recycle Bin. Drive-wide erase to a sanitization standard is the planned Maximum mode (`standards.md`), not this step.
- **Admin:** No for your own files; another user's `$Recycle.Bin` subfolder on that drive needs Administrator.

### Recycle Bin
- **Where:** `%SystemDrive%\$Recycle.Bin` (hidden, with one subfolder per user SID), and a matching `$Recycle.Bin` on every other drive. "Deleting" a file normally just moves it here.
- **Reveals:** Everything the owner thought they had deleted — fully restorable with original names, paths and timestamps until the bin is emptied.
- **Remove (user runs):** Right-click the Recycle Bin > **Empty Recycle Bin**, or Settings > System > Storage > Temporary files > tick Recycle Bin > Remove. Empty the bin on **every** drive. Confirm it is empty before handover.
- **Survives:** Emptying only unlinks the files — content stays recoverable on an SSD until TRIM runs and on an HDD until the space is overwritten; it is not a secure erase. Each drive's bin is separate. Other users' SID subfolders are not emptied by your sign-in.
- **Admin:** No to empty your own bin; reading/clearing another user's SID subfolder needs Administrator.

### Known-folder redirection (where your folders really point)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders` and `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders` (values are the real paths for Desktop, Documents, Pictures, Downloads, etc.).
- **Reveals:** Not data itself, but **where the data is** — whether Desktop/Documents/Pictures were redirected into OneDrive (Known Folder Move) or onto another drive (e.g. `D:\Data\Documents`). Essential for finding personal data that is not under the default `%USERPROFILE%` paths.
- **Remove (user runs):** Do not edit these keys (Windows needs them). Use them as a map: read the real target of each folder, then clean *that* location, and if a folder points into OneDrive, unlink OneDrive first.
- **Survives:** N/A — this is a pointer, not a data store. Cleaning it does not remove any files.
- **Admin:** No.

### OneDrive — personal (local copy)
- **Where:** `%OneDrive%` / `%OneDriveConsumer%` (default `%USERPROFILE%\OneDrive`). With Known Folder Move the Desktop/Documents/Pictures *inside* this folder are your real known folders.
- **Reveals:** Documents, photos and anything the owner synced to a personal Microsoft account; folder and file names reveal projects, people and finances.
- **Remove (user runs):** First open OneDrive (taskbar cloud icon) > Settings > **Account > Unlink this PC** — this stops sync. Then delete the local `%USERPROFILE%\OneDrive` folder and empty the Recycle Bin. To remove the cloud copy, sign in at onedrive.live.com and delete the files there (and empty OneDrive's online recycle bin).
- **Survives:** **The cloud copy persists on the Microsoft account until deleted server-side** — unlinking and local deletion do not touch it. With Files On-Demand, "online-only" items were never fully on disk, so the cloud is the only real copy. If you delete locally *without* unlinking, the deletion syncs up and removes the cloud copy too. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### OneDrive — Business / Known Folder Move
- **Where:** `%OneDriveCommercial%` (default `%USERPROFILE%\OneDrive - <Company Name>`). Present when signed in to a work/school Microsoft 365 account; set only when such an account is configured.
- **Reveals:** Work documents synced from SharePoint/OneDrive for Business, plus any personal known folders redirected into it.
- **Remove (user runs):** This is organizational data — prefer handing the device to the organization's IT. If authorized: OneDrive > Settings > Account > Unlink this PC, then remove the work account under Settings > Accounts > Access work or school, then delete the local folder.
- **Survives:** The tenant's cloud copy and any retention/legal-hold policy — only the organization can remove those. Entra ID / Intune / Autopilot enrollment is separate (`delink-checklist.md`). SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to read your own folder; removing enrollment is an org/IT action.

### OneDrive — local settings & cache
- **Where:** `%LOCALAPPDATA%\Microsoft\OneDrive` (client binaries, `settings\` folder with per-account `.dat`/`.ini` state and logs) and `HKCU:\Software\Microsoft\OneDrive` (plus an `Accounts\Personal` / `Accounts\Business1` subkey when an account is configured).
- **Reveals:** Which Microsoft accounts (personal and work) were signed in, the account email/CID, and the sync-folder paths — even after the synced files are gone.
- **Remove (user runs):** Unlink the PC in OneDrive settings (above). A full removal is Settings > Apps > OneDrive > Uninstall, which clears the client; the local settings folder can then be deleted by the user.
- **Survives:** Account identifiers remain until OneDrive is unlinked/uninstalled. Device still shown on the Microsoft account's device list until removed at account.microsoft.com (`delink-checklist.md`). SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Dropbox
- **Where:** Sync folder default `%USERPROFILE%\Dropbox` (user-chosen; its real path is in `info.json`). Config/state: `%APPDATA%\Dropbox` and `%LOCALAPPDATA%\Dropbox`, including `info.json` (`%APPDATA%\Dropbox\info.json` or `%LOCALAPPDATA%\Dropbox\info.json`) which records the account type and the Dropbox folder location.
- **Reveals:** All synced files, and the account/email plus the on-disk folder path from the config.
- **Remove (user runs):** In the Dropbox app: account avatar > Preferences > Account > **Sign out / Unlink this Dropbox**, then quit Dropbox, delete the local `Dropbox` folder and the `%APPDATA%\Dropbox` / `%LOCALAPPDATA%\Dropbox` config, empty the Recycle Bin. Uninstall via Settings > Apps. Remove the cloud copy at dropbox.com.
- **Survives:** **The cloud copy on the Dropbox account persists until deleted at dropbox.com** (check its deleted-files area too). Smart Sync "online-only" files had no local content. Deleting while still linked propagates to the cloud. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Google Drive for desktop
- **Where:** Mounts as a virtual drive (default `G:`), so synced content is streamed, not stored under the profile. Local content cache and state: `%LOCALAPPDATA%\Google\DriveFS`. (The older "Backup and Sync" client instead used a real folder, default `%USERPROFILE%\Google Drive`.)
- **Reveals:** Google account email(s), the local cache of opened/pinned Drive files, and file metadata. Mirrored folders keep full local copies.
- **Remove (user runs):** In Drive for desktop: Settings (gear) > **Disconnect account** (sign out) for each account, then quit and uninstall via Settings > Apps. Delete any `%USERPROFILE%\Google Drive` folder from the legacy client and the `%LOCALAPPDATA%\Google\DriveFS` cache, empty the Recycle Bin. Remove the cloud copy at drive.google.com.
- **Survives:** **Everything in Google Drive/Google Photos stays in the Google account until removed server-side** (including the Drive Trash). Streamed files were never fully local. SSD/HDD remnants of the cache until TRIM/overwrite.
- **Admin:** No.

### iCloud Drive
- **Where:** `%USERPROFILE%\iCloudDrive` (shown in File Explorer as "iCloud Drive"). The iCloud for Windows app itself is a Microsoft Store app with state under `%LOCALAPPDATA%\Packages\` (Apple's iCloud package).
- **Reveals:** Documents synced from the owner's Apple ID across their Apple devices, and the Apple ID itself.
- **Remove (user runs):** In the iCloud app: turn **off iCloud Drive**, then **Sign Out** of the Apple ID; quit and uninstall iCloud via Settings > Apps; delete any leftover local `iCloudDrive` folder and empty the Recycle Bin. Remove the cloud copy at iCloud.com or on an Apple device.
- **Survives:** **The iCloud copy persists on the Apple ID until deleted** (also in iCloud.com "Recently Deleted"). Online-only items had no local content. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### iCloud Photos
- **Where:** `%USERPROFILE%\Pictures\iCloud Photos` by default (download location is configurable in the iCloud app).
- **Reveals:** The owner's photo library synced from their Apple devices — faces, locations (EXIF GPS), and capture dates.
- **Remove (user runs):** In the iCloud app turn **off Photos**, then Sign Out of the Apple ID; delete the local `Pictures\iCloud Photos` folder and empty the Recycle Bin. Remove the cloud library at iCloud.com or on an Apple device.
- **Survives:** **The photo library stays in iCloud until deleted** (and in iCloud "Recently Deleted" for ~30 days). EXIF GPS/time stays inside any copied-out photo. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Box Drive
- **Where:** Mount folder default `%USERPROFILE%\Box` (streamed virtual folder). Local cache: `%LOCALAPPDATA%\Box\Box` (with a `cache` subfolder).
- **Reveals:** Box account/email and the cache of opened files; often work/enterprise data.
- **Remove (user runs):** In Box Drive: Settings > Account > **Sign out / Unlink**, then uninstall via Settings > Apps (Box removes its cache on uninstall). Confirm the `%USERPROFILE%\Box` mount is gone; empty the Recycle Bin. Remove the cloud copy at app.box.com. If this is enterprise Box, prefer handing the device to IT.
- **Survives:** **The Box cloud copy and any enterprise retention policy persist until removed server-side.** Streamed files were not fully local. SSD/HDD remnants of the cache until TRIM/overwrite.
- **Admin:** No for your own account; enterprise policy removal is an org action.

### MEGAsync
- **Where:** A user-chosen local sync folder (historically defaulting under `%USERPROFILE%`). Config, database and logs: `%LOCALAPPDATA%\Mega Limited\MEGAsync` (includes a `logs\` folder).
- **Reveals:** MEGA account/email, which local folders were synced, and the synced files themselves.
- **Remove (user runs):** In MEGAsync: Settings > Account > **Logout**, then quit and uninstall via Settings > Apps; delete the local sync folder and the `%LOCALAPPDATA%\Mega Limited\MEGAsync` config/logs, empty the Recycle Bin. Remove the cloud copy at mega.nz (and its Rubbish Bin).
- **Survives:** **The MEGA cloud copy persists until deleted server-side** (check the Rubbish Bin). SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### pCloud Drive
- **Where:** Mounts as a virtual drive (default `P:`), so files are streamed rather than stored under the profile; a local cache/database is kept in pCloud's app-data folder under `%LOCALAPPDATA%`. (Exact cache folder name is noted as uncertain in the return.)
- **Reveals:** pCloud account/email and a cache of opened files; pCloud Crypto folders if the owner used them.
- **Remove (user runs):** In pCloud Drive: account > **Logout / Unlink**, then quit and uninstall via Settings > Apps; confirm the `P:` mount is gone and remove the local cache folder, empty the Recycle Bin. Remove the cloud copy at my.pcloud.com (and its Trash).
- **Survives:** **The pCloud cloud copy persists until deleted server-side** (check Trash). Streamed files were not fully local. SSD/HDD remnants of the cache until TRIM/overwrite.
- **Admin:** No.

### Nextcloud / ownCloud
- **Where:** Sync folder default `%USERPROFILE%\Nextcloud` (ownCloud: `%USERPROFILE%\ownCloud`); client config/state: `%APPDATA%\Nextcloud` (ownCloud: `%APPDATA%\ownCloud`). These clients connect to a self-hosted or provider server.
- **Reveals:** The server URL and account, which local folders were synced, and the files themselves — often a private/home server, pointing to where more data lives.
- **Remove (user runs):** In the client: Account > **Remove account / Log out**, then quit and uninstall via Settings > Apps; delete the local sync folder and the `%APPDATA%\Nextcloud` / `%APPDATA%\ownCloud` config, empty the Recycle Bin. Remove the server-side copy by signing in to that server's web UI.
- **Survives:** **The copy on the Nextcloud/ownCloud server persists until deleted there** (and in its server-side trash). Virtual-files/online-only items were not fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No on this PC; server-side removal depends on that server's account.

---

## Browser data (all browsers, deep)

### Chromium profile folders and Local State (the base every artifact below lives under)
- **Where:** Every Chromium-family browser keeps one *User Data* root, and inside it one folder per profile — `Default`, then `Profile 1`, `Profile 2`, … plus `System Profile` and `Guest Profile`. Roots on Windows 10/11:
  - Microsoft Edge — `%LOCALAPPDATA%\Microsoft\Edge\User Data`
  - Google Chrome — `%LOCALAPPDATA%\Google\Chrome\User Data`
  - Brave — `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data`
  - Vivaldi — `%LOCALAPPDATA%\Vivaldi\User Data`
  - plain Chromium — `%LOCALAPPDATA%\Chromium\User Data`
  - Opera — `%APPDATA%\Opera Software\Opera Stable` (this folder is itself the profile root; cache lives under `%LOCALAPPDATA%\Opera Software\Opera Stable\Cache`)
  - Opera GX — `%APPDATA%\Opera Software\Opera GX Stable`
  The profile list and the last-used account live in `…\User Data\Local State` (JSON). Every per-profile artifact in the blocks below sits at `<UserData>\<Profile>\<name>`, and must be checked **for each profile**, not just `Default`.
- **Reveals:** Which browsers were installed and used; how many separate profiles exist and their display names (people often name a profile after themselves, a workplace, or an email); which profile was last active; and the signed-in account identity recorded in `Local State` / `Preferences`.
- **Remove (user runs):** Close the browser completely (check Task Manager for leftover processes). In File Explorer delete the whole `User Data` folder, or just the specific `<Profile>` subfolder you want gone. Cleaner: in the browser, Settings → Profiles → remove each profile, then uninstall and tick "Also clear your browsing data" if the uninstaller offers it.
- **Survives:** Deleting the folder leaves the data recoverable in SSD free space until TRIM/garbage-collection or a full-disk overwrite. Any profile that had **Sync** on still has a full copy on the vendor's servers (see the sync block). Windows backups, File History, restore points, and OneDrive folder backup may hold copies.
- **Admin:** No — everything is under your own user profile.

### Browsing history and typed search terms (History)
- **Where:** `<UserData>\<Profile>\History` (SQLite). Confirmed present in Edge and Chrome profiles on this machine.
- **Reveals:** Every page URL and title you visited with timestamps and visit counts, the sites you typed directly, and the search terms you entered into site search boxes (`keyword_search_terms`). A near-complete record of where you went and what you looked for.
- **Remove (user runs):** In the browser press `Ctrl+Shift+Delete` → set Time range to **All time** → tick "Browsing history" → Clear now. Or delete the `History` file with the browser closed.
- **Survives:** Clearing marks rows deleted but the SQLite file keeps freed pages until it is vacuumed, so fragments can linger inside the file; the file itself persists in SSD free space until overwritten. If Sync was on, server history remains until cleared from the account. Does not touch Google "Web & App Activity" or the Microsoft privacy-dashboard copy (separate blocks).
- **Admin:** No.

### Download history (download records inside History)
- **Where:** The `downloads` and `downloads_url_chains` tables inside `<UserData>\<Profile>\History`.
- **Reveals:** Every file you downloaded — original URL, the saved filename and full local path, size, and time. Exposes what you fetched and where it was saved even after the file itself is gone.
- **Remove (user runs):** `Ctrl+Shift+Delete` → All time → tick "Download history" → Clear. (This clears the list only; it does not delete the downloaded files on disk.)
- **Survives:** Same SQLite vacuum/free-space caveats as History. The actual downloaded files in `%USERPROFILE%\Downloads` (or wherever saved) remain untouched. Sync/account copies persist.
- **Admin:** No.

### Visited Links
- **Where:** `<UserData>\<Profile>\Visited Links` (binary hash table). Appears on profiles with browsing activity.
- **Reveals:** A set of hashed URLs the browser treats as "already visited" (used to colour visited links). Not human-readable on its own, but confirms specific URLs were visited if those URLs are known/guessed.
- **Remove (user runs):** Cleared together with "Browsing history" in `Ctrl+Shift+Delete` (All time), or removed when the profile folder is deleted.
- **Survives:** Free-space remnants until overwrite; rebuilt from history/sync if those are not also cleared.
- **Admin:** No.

### Cookies and network state
- **Where:** `<UserData>\<Profile>\Network\Cookies` (SQLite; moved into the `Network` subfolder on modern Chromium — older builds used `<Profile>\Cookies`). The same `Network` folder also holds `Network Persistent State`, `TransportSecurity` (HSTS list), `Reporting and NEL`, and `Trust Tokens`.
- **Reveals:** Login/session cookies for sites you were signed into (can keep you logged in if copied), plus the set of domains you interacted with. `TransportSecurity` records HTTPS hosts you reached; the reporting files list contacted domains.
- **Remove (user runs):** `Ctrl+Shift+Delete` → All time → tick "Cookies and other site data" → Clear. This also clears HSTS/reporting entries. Signing out of each website first is wise.
- **Survives:** SQLite free-space fragments until vacuum/overwrite. Server-side sessions stay valid until you sign out on the site or revoke sessions in each account. Synced cookies (where enabled) persist in the cloud.
- **Admin:** No.

### Saved passwords (Login Data / Login Data For Account)
- **Where:** `<UserData>\<Profile>\Login Data` and `<UserData>\<Profile>\Login Data For Account` (SQLite; the "For Account" file holds passwords scoped to the signed-in account). Both confirmed in Edge and Chrome on this machine.
- **Reveals:** The list of sites you saved passwords for (usernames in clear, the password blob encrypted with DPAPI+AES tied to your Windows account). Even reading just the site+username list exposes which services you hold accounts on.
- **Remove (user runs):** Open the browser password manager (`edge://passwords`, `chrome://password-manager/passwords`, `brave://settings/passwords`) and delete each entry, or use "Delete all". Also tick "Passwords and other sign-in data" in `Ctrl+Shift+Delete` (under Advanced) at All time.
- **Survives:** Encrypted blobs persist in SSD free space until overwritten (still decryptable by anyone who later signs in as the same Windows user if the file is recovered). If the browser password manager syncs (Google Password Manager, Microsoft account, Firefox), a cloud copy remains until deleted from that account.
- **Admin:** No.

### Autofill, saved addresses and payment cards (Web Data / Account Web Data)
- **Where:** `<UserData>\<Profile>\Web Data` and `<UserData>\<Profile>\Account Web Data` (SQLite). Confirmed present.
- **Reveals:** Saved autofill form entries, full postal addresses, names, phone numbers, email addresses, and payment cards (cardholder name, expiry and last four digits in clear; the full number is encrypted). Highly personal — identity and billing detail.
- **Remove (user runs):** Settings → Profiles/Autofill → Addresses and Payment methods → delete each entry. Also tick "Autofill form data" (and "Payment methods" where offered) in `Ctrl+Shift+Delete` at All time.
- **Survives:** Free-space remnants until overwrite; synced addresses/cards remain in the Google/Microsoft account until removed there. Cards saved to the account (not just the device) live server-side.
- **Admin:** No.

### Bookmarks / Favorites
- **Where:** `<UserData>\<Profile>\Bookmarks` and `Bookmarks.bak` (JSON). (Edge additionally keeps `EncryptedBookmarks2`.) The file appears once at least one bookmark exists.
- **Reveals:** Saved sites — often the clearest map of your interests, accounts, employer tools, and routine destinations, with folder names and the date each was added.
- **Remove (user runs):** Use the browser Bookmark manager (`Ctrl+Shift+O`) to delete bookmarks/folders, or delete the `Bookmarks` and `Bookmarks.bak` files with the browser closed.
- **Survives:** `Ctrl+Shift+Delete` does **not** clear bookmarks — they must be removed deliberately. Synced bookmarks persist in the account. `.bak` and free-space copies linger until overwritten.
- **Admin:** No.

### Top Sites
- **Where:** `<UserData>\<Profile>\Top Sites` (SQLite). Confirmed present.
- **Reveals:** Your most-frequented sites (the tiles on the new-tab page), ranked — a quick summary of habitual destinations.
- **Remove (user runs):** Cleared with "Browsing history" in `Ctrl+Shift+Delete` (All time); also removed with the profile folder.
- **Survives:** SQLite free-space fragments until vacuum/overwrite; rebuilt from history if history is not cleared.
- **Admin:** No.

### Omnibox autocomplete (Shortcuts)
- **Where:** `<UserData>\<Profile>\Shortcuts` (SQLite). Confirmed present.
- **Reveals:** What you typed into the address bar and which suggestion you then chose — including partial text, search queries, and destinations, so it can surface sites/terms even if the main history was trimmed.
- **Remove (user runs):** Cleared with "Browsing history" in `Ctrl+Shift+Delete` (All time), or by deleting the profile folder.
- **Survives:** Free-space/vacuum caveats; regenerates from ongoing typing.
- **Admin:** No.

### Address-bar prediction (Network Action Predictor)
- **Where:** `<UserData>\<Profile>\Network Action Predictor` (SQLite). Confirmed present.
- **Reveals:** A map of the letters you typed in the address bar to the URLs the browser predicted/preconnected to — effectively a record of partial typing and the sites associated with it.
- **Remove (user runs):** Cleared with "Browsing history" in `Ctrl+Shift+Delete` (All time), or with the profile folder.
- **Survives:** Free-space/vacuum caveats; rebuilds with use.
- **Admin:** No.

### Open and recently closed tabs (Sessions)
- **Where:** `<UserData>\<Profile>\Sessions\` (holds `Session_*` and `Tabs_*` files) plus the legacy `Current Session`, `Current Tabs`, `Last Session`, `Last Tabs` files where present. Edge also writes `Sessions_Encrypted`.
- **Reveals:** The exact tabs and windows you had open and recently closed, with URLs and titles — a snapshot of what you were doing when you last used the browser.
- **Remove (user runs):** Set the browser to not reopen tabs (Settings → On startup → "Open the new tab page"), then close all windows; or delete the `Sessions` folder and the Current/Last session files with the browser closed.
- **Survives:** Free-space remnants until overwrite; "continue where you left off" and tab sync can restore the set from the account on another device.
- **Admin:** No.

### Favicons
- **Where:** `<UserData>\<Profile>\Favicons` (SQLite). Confirmed present.
- **Reveals:** Cached site icons keyed by domain — an independent list of domains you visited, useful to reconstruct history even if `History` was cleared but this was not.
- **Remove (user runs):** Cleared with "Cached images and files" plus "Browsing history" in `Ctrl+Shift+Delete` (All time), or with the profile folder.
- **Survives:** Free-space/vacuum caveats; rebuilt as you browse.
- **Admin:** No.

### Browser caches (Cache, Code Cache, GPUCache, media/shader caches)
- **Where:** `<UserData>\<Profile>\Cache\Cache_Data`, `<UserData>\<Profile>\Code Cache`, `<UserData>\<Profile>\GPUCache`, plus shader caches such as `DawnWebGPUCache`/`GrShaderCache`. (Opera's cache is under `%LOCALAPPDATA%\Opera Software\Opera Stable\Cache`.)
- **Reveals:** Fragments of pages, images, scripts and media you loaded — thumbnails, cached API responses, sometimes personal content from web apps. Can expose what you viewed even without the history list.
- **Remove (user runs):** `Ctrl+Shift+Delete` → All time → tick "Cached images and files" → Clear; or delete the Cache/Code Cache/GPUCache folders with the browser closed.
- **Survives:** Cache files persist in SSD free space until overwritten; carved cache artifacts are a common recovery source.
- **Admin:** No.

### Service Worker storage (offline site data)
- **Where:** `<UserData>\<Profile>\Service Worker\` (`CacheStorage`, `ScriptCache`). Confirmed present.
- **Reveals:** Offline caches installed by web apps (mail, chat, docs, PWAs) — can contain cached messages, documents, and account-specific content stored for offline use.
- **Remove (user runs):** `Ctrl+Shift+Delete` → All time → "Cookies and other site data" + "Cached images and files"; or per site via `edge://settings/content/all` / `chrome://settings/content/all` → remove the site's data; or delete the `Service Worker` folder with the browser closed.
- **Survives:** Free-space remnants until overwrite; re-created when you revisit the web app while signed in.
- **Admin:** No.

### IndexedDB (structured site storage)
- **Where:** `<UserData>\<Profile>\IndexedDB\` (per-origin leveldb folders). Present once a site uses it.
- **Reveals:** Rich per-site data stored by web apps — can include cached emails, chat logs, drafts, notes, tokens, and other account content held locally.
- **Remove (user runs):** `Ctrl+Shift+Delete` → All time → "Cookies and other site data"; or clear per site in the site-data settings page; or delete the `IndexedDB` folder with the browser closed.
- **Survives:** Free-space remnants until overwrite; re-populates on next sign-in to the web app.
- **Admin:** No.

### Local Storage and Session Storage
- **Where:** `<UserData>\<Profile>\Local Storage\leveldb\` and `<UserData>\<Profile>\Session Storage\`. Confirmed present.
- **Reveals:** Per-site key/value data — preferences, identifiers, cached profile info, sometimes tokens — tied to specific domains, so it both exposes content and confirms which sites you used.
- **Remove (user runs):** `Ctrl+Shift+Delete` → All time → "Cookies and other site data"; or per site in site-data settings; or delete the two folders with the browser closed.
- **Survives:** leveldb keeps deleted keys in free pages until compaction; file remnants persist in SSD free space; re-created on next visit.
- **Admin:** No.

### Installed extensions and their stored data
- **Where:** `<UserData>\<Profile>\Extensions\<extID>\`, plus `Extension State`, `Extension Rules`, `Local Extension Settings\<extID>\`, and `Sync Extension Settings\`. Confirmed present.
- **Reveals:** Which extensions you installed (password managers, VPNs, crypto wallets, work tools) — revealing habits and services. `Local Extension Settings` holds each extension's own stored data; for example a browser crypto-wallet extension keeps its encrypted vault here, and a password-manager extension keeps account/session state. Existence and extension identity are exposed even where the vault value itself is encrypted.
- **Remove (user runs):** `edge://extensions` / `chrome://extensions` / `brave://extensions` → Remove each extension (this deletes its stored settings). For wallet/password extensions, sign out inside the extension first. Removing the profile folder clears all of it.
- **Survives:** Encrypted vault blobs persist in free space until overwritten; the extension's own cloud account (wallet seed backup, password-manager vault on its server) is unaffected by local removal. Synced extension lists restore on another device.
- **Admin:** No.

### Media playback history (Media History)
- **Where:** `<UserData>\<Profile>\Media History` (SQLite). Appears on profiles that played media.
- **Reveals:** Audio/video you played in the browser — origins, sometimes titles, positions and watch/listen counts — exposing what you watched or listened to.
- **Remove (user runs):** Cleared with "Browsing history" + "Cookies and other site data" in `Ctrl+Shift+Delete` (All time), or with the profile folder.
- **Survives:** Free-space/vacuum caveats; account-side watch history (e.g. on the streaming service) is separate and unaffected.
- **Admin:** No.

### Profile preferences (Preferences / Secure Preferences)
- **Where:** `<UserData>\<Profile>\Preferences` and `<UserData>\<Profile>\Secure Preferences` (JSON). Confirmed present.
- **Reveals:** The signed-in account email/name, per-site content settings and permissions (camera, mic, location, notifications — each keyed by the site, so it lists domains you granted), per-site zoom levels (another domain list), default download directory, search engine, and enabled features.
- **Remove (user runs):** Removed when the profile folder is deleted. Clearing site permissions individually in site-data settings reduces what is exposed, but the account identity is only gone once the profile/sign-out is done.
- **Survives:** Free-space remnants until overwrite; account email reappears if the profile is re-synced.
- **Admin:** No.

### Sync metadata (Sync Data, local side)
- **Where:** `<UserData>\<Profile>\Sync Data\` (leveldb) and sync fields inside `Preferences`/`Local State`.
- **Reveals:** That the profile was linked to a vendor account for sync, and which data types were syncing — a direct pointer to a cloud copy existing under a named account.
- **Remove (user runs):** In the browser, Settings → turn off Sync / Sign out, and when prompted choose to **clear data from this device**. Then also delete the cloud copy from the account (see the sync block).
- **Survives:** Turning off sync locally does **not** delete the server copy. Free-space remnants until overwrite.
- **Admin:** No.

### Browser crash reports (Crashpad)
- **Where:** `%LOCALAPPDATA%\<vendor path>\User Data\Crashpad\` (e.g. `…\Microsoft\Edge\User Data\Crashpad`, `…\Google\Chrome\User Data\Crashpad`).
- **Reveals:** Crash dumps can contain fragments of in-memory data at crash time — URLs, form field contents, or page text.
- **Remove (user runs):** Delete the `Crashpad` folder with the browser closed; disable "help improve" crash reporting in Settings to stop new dumps and uploads.
- **Survives:** Reports already uploaded to the vendor are server-side. Local free-space remnants until overwrite.
- **Admin:** No.

### Edge Collections, Workspaces and Edge Wallet (Edge-specific)
- **Where:** `%LOCALAPPDATA%\Microsoft\Edge\User Data\<Profile>\Collections\` (confirmed real on this machine), plus `Workspaces`, `EdgeWallet`, and `EdgeHubAppUsage` in the same profile folder.
- **Reveals:** Collections are user-curated saved pages, images and typed notes grouped by topic — often very personal (shopping, health, trip planning, research). Workspaces group tabs by project. Edge Wallet holds saved payment/passwords surfaced in the wallet UI.
- **Remove (user runs):** In Edge open Collections (and Wallet) and delete each item/collection; remove workspaces from the workspace menu. Removing the Edge profile folder clears all of it.
- **Survives:** Collections and wallet entries sync with the Microsoft account, so a cloud copy remains until removed there. Free-space remnants until overwrite.
- **Admin:** No.

### Brave Rewards and Brave Wallet (Brave-specific)
- **Where:** Inside the Brave profile `…\BraveSoftware\Brave-Browser\User Data\<Profile>\` — Rewards/ads state and the built-in crypto wallet's keyring data (the wallet seed is stored encrypted within the profile).
- **Reveals:** That Brave Rewards/ads were used, and that a crypto wallet exists on the device — exposing crypto usage; the seed value itself is encrypted (existence only).
- **Remove (user runs):** In Brave, reset Rewards and remove/reset the wallet from `brave://settings`, then sign out of Brave Sync. Removing the Brave profile folder clears local wallet/rewards state.
- **Survives:** On-chain assets and any seed phrase you backed up elsewhere are entirely outside the device and unaffected. Encrypted keyring remnants persist in free space until overwritten; Brave Sync chain data persists on sync servers until the chain is removed.
- **Admin:** No.

### Firefox profiles and profiles.ini
- **Where:** `%APPDATA%\Mozilla\Firefox\Profiles\<id>.default-release\` (and other `<id>.<name>` profiles), listed in `%APPDATA%\Mozilla\Firefox\profiles.ini` and `installs.ini`. Cache lives separately at `%LOCALAPPDATA%\Mozilla\Firefox\Profiles\<id>.<name>\cache2\`. All confirmed on this machine.
- **Reveals:** How many Firefox profiles exist and their names; the folder is the container for every Firefox artifact below. Check **each** profile.
- **Remove (user runs):** Open `about:profiles` in Firefox → Remove each profile (tick "Delete Files"); or close Firefox and delete the `Profiles\<id>.<name>` folders under both `%APPDATA%` and `%LOCALAPPDATA%`.
- **Survives:** Free-space remnants until overwrite; a profile linked to a Firefox Account keeps a cloud copy (see sync block). `profiles.ini` may still name removed profiles.
- **Admin:** No.

### Firefox history, bookmarks and downloads (places.sqlite)
- **Where:** `…\Firefox\Profiles\<profile>\places.sqlite` (+ `-wal`/`-shm`). Confirmed present.
- **Reveals:** Full visit history (URLs, titles, timestamps, visit counts), all bookmarks with folders, and the download record (source URL, saved path, time) — Firefox's central record of where you went and what you saved.
- **Remove (user runs):** In Firefox, `Ctrl+Shift+Delete` → Time range "Everything" → tick Browsing & Download History → Clear Now. Library (`Ctrl+Shift+O`) to delete bookmarks. Or delete `places.sqlite` with Firefox closed (this also removes bookmarks).
- **Survives:** WAL/free-page fragments inside the SQLite file until vacuum; file remnants in SSD free space; synced history/bookmarks remain in the Firefox Account; `bookmarkbackups` folder keeps copies (separate block).
- **Admin:** No.

### Firefox cookies (cookies.sqlite)
- **Where:** `…\Firefox\Profiles\<profile>\cookies.sqlite`. Confirmed present.
- **Reveals:** Session/login cookies and the set of domains you used.
- **Remove (user runs):** `Ctrl+Shift+Delete` → Everything → tick Cookies → Clear; or Settings → Privacy & Security → Cookies and Site Data → Clear Data. Sign out of sites first.
- **Survives:** SQLite free-page fragments until vacuum; free-space remnants; server-side sessions valid until revoked.
- **Admin:** No.

### Firefox form and search autofill (formhistory.sqlite)
- **Where:** `…\Firefox\Profiles\<profile>\formhistory.sqlite`. Confirmed present.
- **Reveals:** Text you typed into web forms and the search bar — names, emails, addresses, search queries — remembered for autocomplete.
- **Remove (user runs):** `Ctrl+Shift+Delete` → Everything → tick "Form & Search History" → Clear; or delete the file with Firefox closed.
- **Survives:** SQLite/free-space caveats; regenerates with use.
- **Admin:** No.

### Firefox saved addresses and payment cards (autofill-profiles.json)
- **Where:** `…\Firefox\Profiles\<profile>\autofill-profiles.json` (appears once you save an address/card in Firefox autofill).
- **Reveals:** Saved postal addresses, names, phones, emails, and payment-card details (number encrypted; name/expiry may be present).
- **Remove (user runs):** Settings → Privacy & Security → Forms and Autofill → Saved Addresses / Payment Methods → delete each; or delete the file with Firefox closed.
- **Survives:** Free-space remnants until overwrite.
- **Admin:** No.

### Firefox saved passwords (logins.json + key4.db)
- **Where:** `…\Firefox\Profiles\<profile>\logins.json` with `key4.db` (the key store). Newer Firefox also writes `logins.db` and `logins-backup.json` (all confirmed on this machine). Legacy equivalents: `signons.sqlite`, `key3.db`.
- **Reveals:** Saved site logins — usernames and site list in the clear, passwords encrypted by `key4.db`. If no Primary Password is set, the encryption is unlocked by anyone opening that profile.
- **Remove (user runs):** Firefox → Passwords (`about:logins`) → menu → Remove All Logins; and delete `logins.json`, `logins-backup.json`, `logins.db` and `key4.db` with Firefox closed to remove the key material too.
- **Survives:** Encrypted blobs + key store persist in free space until overwritten; a Firefox Account sync keeps a cloud copy until removed; `logins-backup.json` is an extra copy to clear.
- **Admin:** No.

### Firefox certificates and site exceptions (cert9.db)
- **Where:** `…\Firefox\Profiles\<profile>\cert9.db`. Confirmed present.
- **Reveals:** Imported client certificates and stored certificate exceptions — can indicate specific secure sites, VPNs, or workplaces you connected to.
- **Remove (user runs):** Settings → Privacy & Security → Certificates → View Certificates → remove entries; or delete `cert9.db` with Firefox closed.
- **Survives:** Free-space remnants until overwrite.
- **Admin:** No.

### Firefox site permissions (permissions.sqlite)
- **Where:** `…\Firefox\Profiles\<profile>\permissions.sqlite`. Confirmed present.
- **Reveals:** Per-site permissions you granted/denied (camera, microphone, location, notifications, autoplay, pop-ups) — each keyed to a domain, so it lists sites you used and trusted.
- **Remove (user runs):** Settings → Privacy & Security → Permissions (and per-site via the padlock) → clear; or delete the file with Firefox closed.
- **Survives:** SQLite/free-space caveats.
- **Admin:** No.

### Firefox per-site content settings (content-prefs.sqlite)
- **Where:** `…\Firefox\Profiles\<profile>\content-prefs.sqlite`. Confirmed present.
- **Reveals:** Per-site preferences such as zoom level and character encoding — an incidental list of domains you visited.
- **Remove (user runs):** Deleted with the profile folder, or delete the file with Firefox closed.
- **Survives:** SQLite/free-space caveats; rebuilt with use.
- **Admin:** No.

### Firefox favicons (favicons.sqlite)
- **Where:** `…\Firefox\Profiles\<profile>\favicons.sqlite`. Confirmed present.
- **Reveals:** Cached site icons keyed by domain — an independent domain list that can corroborate history.
- **Remove (user runs):** Cleared with history via `Ctrl+Shift+Delete` (Everything), or with the profile folder.
- **Survives:** SQLite/free-space caveats; rebuilt as you browse.
- **Admin:** No.

### Firefox open and recently closed tabs (sessionstore)
- **Where:** `…\Firefox\Profiles\<profile>\sessionstore.jsonlz4` (written on close) and `…\sessionstore-backups\` (`recovery.jsonlz4`, `previous.jsonlz4`, `upgrade.*`). The backups folder is confirmed present.
- **Reveals:** The tabs and windows you had open and recently closed, with URLs and form/scroll state — a snapshot of your last session.
- **Remove (user runs):** Settings → disable "Open previous windows and tabs", close Firefox, then delete `sessionstore.jsonlz4` and the `sessionstore-backups` folder.
- **Survives:** Free-space remnants until overwrite; synced tabs restore from the Firefox Account.
- **Admin:** No.

### Firefox site storage (storage/ — IndexedDB, localStorage, Cache API)
- **Where:** `…\Firefox\Profiles\<profile>\storage\default\<origin>\` plus `storage.sqlite` and `storage-sync-v2.sqlite` (extension storage). Confirmed present.
- **Reveals:** Per-site DOM storage, IndexedDB databases and Cache-API data for web apps — can include cached messages, drafts, tokens and account content, keyed by origin.
- **Remove (user runs):** Settings → Privacy & Security → Cookies and Site Data → Clear Data (tick cached web content + site data); or Manage Data to remove per site; or delete the `storage` folder with Firefox closed.
- **Survives:** Free-space remnants until overwrite; re-created on next sign-in to the web app.
- **Admin:** No.

### Firefox disk cache (cache2)
- **Where:** `%LOCALAPPDATA%\Mozilla\Firefox\Profiles\<profile>\cache2\` (`entries\`, `doomed\`). Confirmed present.
- **Reveals:** Cached pages, images, scripts and media you loaded — can expose viewed content independent of history.
- **Remove (user runs):** `Ctrl+Shift+Delete` → Everything → tick "Cache" → Clear; or delete the `cache2` folder with Firefox closed.
- **Survives:** Cache files persist in SSD free space until overwritten.
- **Admin:** No.

### Firefox add-ons and their settings (extensions)
- **Where:** `…\Firefox\Profiles\<profile>\extensions\`, `extensions.json`, `addons.json`, and `storage-sync-v2.sqlite`. Confirmed present.
- **Reveals:** Installed add-ons (password managers, VPNs, wallets, work tools) and their stored settings — revealing habits, services, and sometimes account/session data held by the add-on.
- **Remove (user runs):** `about:addons` → remove each add-on; sign out inside account-based add-ons first; removing the profile folder clears all add-on data.
- **Survives:** Free-space remnants until overwrite; the add-on's own cloud account (e.g. a password-manager vault) is unaffected.
- **Admin:** No.

### Firefox preferences (prefs.js)
- **Where:** `…\Firefox\Profiles\<profile>\prefs.js` (+ `user.js` if present) and `xulstore.json`. Confirmed present.
- **Reveals:** Firefox settings including the last download directory, homepage/startup URLs, the signed-in Firefox Account identity, and feature toggles — incidental personal pointers.
- **Remove (user runs):** Removed with the profile folder; or use Help → "Refresh Firefox" which resets prefs while keeping some data.
- **Survives:** Free-space remnants until overwrite; account identity reappears if the profile is re-synced.
- **Admin:** No.

### Firefox bookmark backups (bookmarkbackups)
- **Where:** `…\Firefox\Profiles\<profile>\bookmarkbackups\*.jsonlz4`. Confirmed present.
- **Reveals:** Dated JSON-compressed snapshots of your entire bookmark set — can restore bookmarks you thought you deleted.
- **Remove (user runs):** Delete the `bookmarkbackups` folder with Firefox closed (do this in addition to clearing live bookmarks).
- **Survives:** Free-space remnants until overwrite; newly auto-generated after bookmark changes.
- **Admin:** No.

### Tor Browser (portable install)
- **Where:** Wherever the user extracted it — commonly `%USERPROFILE%\Desktop\Tor Browser\`, `%USERPROFILE%\Downloads\Tor Browser\`, or a USB drive. Profile at `…\Tor Browser\Browser\TorBrowser\Data\Browser\profile.default\`; Tor config/state at `…\Tor Browser\Browser\TorBrowser\Data\Tor\` (`torrc`, `state`). Desktop/Start-menu shortcuts may also point to it.
- **Reveals:** The strongest trace is simply that Tor Browser is or was installed — that alone indicates Tor usage. By default Tor Browser runs like permanent private browsing and does not write history to disk, but saved bookmarks, any `torrc` edits (e.g. bridges), and the `state` file persist, and a used `places.sqlite` can exist if defaults were changed.
- **Remove (user runs):** Close Tor Browser, then delete the entire `Tor Browser` folder and any shortcut. Empty the Recycle Bin afterward.
- **Survives:** Free-space remnants until overwrite; the folder may sit inside a backup or on a synced drive. On an SSD the data is recoverable until TRIM/overwrite.
- **Admin:** No (unless it was installed to a protected location).

### Internet Explorer / legacy WebCache (WebCacheV01.dat)
- **Where:** `%LOCALAPPDATA%\Microsoft\Windows\WebCache\WebCacheV01.dat` (ESE database). Folder confirmed present on this machine.
- **Reveals:** The legacy WinINET store used by Internet Explorer and older apps — browsing history, visited-URL and cookie index, typed URLs, and download history, often carrying entries from when the PC ran Windows 10 or used IE/IE-mode.
- **Remove (user runs):** Control Panel → Internet Options → General → "Delete browsing history…" → tick all → Delete. The `WebCacheV01.dat` file is locked while the system/Explorer is using it, so a reboot (or signing in as a different user) may be needed before it can be removed.
- **Survives:** The ESE database retains freed records internally until compacted; file remnants persist in SSD free space until overwritten. Some apps rebuild parts of it.
- **Admin:** No (it is under your own profile; the lock, not permissions, is the obstacle).

### Internet Explorer typed URLs (registry)
- **Where:** `HKCU:\Software\Microsoft\Internet Explorer\TypedURLs` and `HKCU:\Software\Microsoft\Internet Explorer\TypedURLsTime`.
- **Reveals:** Web addresses you typed directly into Internet Explorer's address bar, with timestamps — a short but explicit list of destinations.
- **Remove (user runs):** Internet Options → "Delete browsing history…" (includes typed URLs); or the user can delete the values under those two keys in `regedit`.
- **Survives:** Deleted registry values can persist in free space of the registry hive and in restore points/backups until overwritten.
- **Admin:** No (HKCU is your own user hive).

### Internet Explorer autocomplete and saved form data (IntelliForms, registry)
- **Where:** `HKCU:\Software\Microsoft\Internet Explorer\IntelliForms\Storage1` and `…\IntelliForms\Storage2`.
- **Reveals:** Internet Explorer's saved form autocomplete entries and saved web credentials (encrypted, keyed to the site URL) — the list exposes which sites you saved form data or passwords for.
- **Remove (user runs):** Internet Options → Content → AutoComplete → Settings → "Delete AutoComplete history", and/or "Delete browsing history…" → tick "Form data" and "Passwords"; the user may also delete the `Storage1`/`Storage2` values in `regedit`.
- **Survives:** Encrypted values can linger in hive free space and in backups/restore points until overwritten.
- **Admin:** No.

### Internet Explorer / WinINET cache and cookies (INetCache, INetCookies)
- **Where:** `%LOCALAPPDATA%\Microsoft\Windows\INetCache\` (Temporary Internet Files), `%LOCALAPPDATA%\Microsoft\Windows\INetCookies\`, and the legacy `%APPDATA%\Microsoft\Windows\Cookies\`; DOM storage at `%LOCALAPPDATA%\Microsoft\Internet Explorer\DOMStore\`. INetCache/INetCookies folders confirmed present.
- **Reveals:** Cached page content and images, and cookies, from Internet Explorer / WinINET-based browsing — exposing viewed content and the domains you used.
- **Remove (user runs):** Internet Options → "Delete browsing history…" → tick "Temporary Internet Files" and "Cookies and website data" → Delete.
- **Survives:** Free-space remnants until overwrite; the index in `WebCacheV01.dat` may retain references until it is also cleared/compacted.
- **Admin:** No.

### Internet Explorer favorites
- **Where:** `%USERPROFILE%\Favorites\` (IE/Windows favorites), with `.url` shortcut files.
- **Reveals:** Bookmarked sites from Internet Explorer — a map of interests and accounts, same sensitivity as browser bookmarks.
- **Remove (user runs):** Delete the `.url` files/folders under `%USERPROFILE%\Favorites`.
- **Survives:** Free-space remnants until overwrite; may be present in backups or synced via a Microsoft account roaming feature.
- **Admin:** No.

### Legacy UWP "Spartan" Edge data (only if upgraded from early Windows 10)
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\` (AC, LocalState, and a nested WebCache/spartan store). Present only on machines carried over from the original EdgeHTML-based Edge.
- **Reveals:** Old EdgeHTML-era history, favorites, reading list and cached content, if the device predates the Chromium Edge switch.
- **Remove (user runs):** Settings → Apps → the legacy Edge entry (where present), or delete the package folder with the app closed; otherwise it is cleared when the whole user profile is removed during a reset.
- **Survives:** Free-space remnants until overwrite. On a clean Windows 11 install the folder is usually absent (note it in uncertainties if not found).
- **Admin:** No.

### Browser sync — cloud copies survive a local wipe
- **Where:** Not a local file — a server-side copy tied to the account each browser signed into: Microsoft account (Edge), Google account (Chrome), Mozilla/Firefox Account (Firefox), Brave Sync chain (Brave), Opera account (Opera/Opera GX), Vivaldi account (Vivaldi). Local pointers are in `Local State`, `Preferences`/`Sync Data`, and Firefox `prefs.js`.
- **Reveals:** Whatever was enabled for sync — history, bookmarks, passwords, autofill/addresses/cards, open tabs, extensions, settings — all mirrored to the vendor's servers under a named account, reachable from any device signed in.
- **Remove (user runs):** In each browser, turn Sync off / sign out and choose to clear local data; then delete the cloud copy from the account: Chrome via the Google Dashboard "reset sync"/clear data, Edge via the Microsoft account privacy dashboard, Firefox by disconnecting with "delete data" (or deleting from the Firefox Account), Brave by removing/clearing the sync chain, Opera/Vivaldi via their account settings. Finally sign out so the new owner cannot resync.
- **Survives:** Clearing only the local device leaves the full cloud copy intact. Other devices still signed in can re-upload data. Vendor backups may lag deletion.
- **Admin:** No.

### Account-side browsing and search activity (separate from sync)
- **Where:** Server-side logs under the browser's account, not a device file: Google "Web & App Activity"/My Activity (when signed into Chrome/Google), and the Microsoft account privacy dashboard for Edge/Bing activity.
- **Reveals:** Searches and, where enabled, browsing and interaction history recorded to the account independently of the local `History` database — so it survives any local clearing.
- **Remove (user runs):** Delete activity in the Google account (myactivity.google.com → delete by range/all, and pause Web & App Activity) and in the Microsoft account privacy dashboard (clear browsing/search history). This is done in the account, from any device.
- **Survives:** Purely server-side; local wiping does nothing to it. Retention/backup on the vendor side may persist briefly after deletion.
- **Admin:** No.

---

## Messaging & email apps

### Microsoft Teams (new / Teams 2.0)
- **Where:** `%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe` (MSIX package). Local web cache and message/presence data live under `...\LocalCache\Microsoft\MSTeams` (Cache, Code Cache, IndexedDB, Local Storage, Service Worker). Account hints also appear under `...\LocalState` and `...\Settings`.
- **Reveals:** Which work/school or personal Microsoft account was signed in, display name and email, recent chats and channel names, cached message text and inline images, meeting/call history, and the other people and organisations the owner communicated with.
- **Remove (user runs):** In Teams, click the profile picture > Sign out. Then Settings > Apps > Installed apps > Microsoft Teams > Advanced options > **Reset** (wipes the package's LocalCache/LocalState), or **Uninstall**. Optionally, after signing out, the owner can delete the leftover package folder in File Explorer.
- **Survives:** All chats, channels, files and meeting history stay on Microsoft 365 / Teams servers and in the owner's mailbox — signing out of this PC removes nothing server-side. The account stays signed in on phone and web until signed out there. On an SSD the removed local cache may linger in unallocated space until TRIM or an overwrite. A tenant admin can still see the account's activity.
- **Admin:** No (per-user profile data).

### Microsoft Teams (classic)
- **Where:** `%APPDATA%\Microsoft\Teams` (Electron build; now largely retired but the folder persists after migration). Subfolders include `Cache`, `Code Cache`, `IndexedDB`, `Local Storage`, `databases`, `media-stack`, `meeting-addin`, and `Logs`.
- **Reveals:** Same classes as new Teams — signed-in account and email, cached conversations, contact/organisation names, presence and call logs, plus verbose diagnostic logs that can name meetings and participants.
- **Remove (user runs):** Sign out in the app, uninstall "Microsoft Teams classic" from Settings > Apps > Installed apps, then delete any remaining `%APPDATA%\Microsoft\Teams` folder in File Explorer.
- **Survives:** Server-side history and mailbox copies remain; other devices stay signed in. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Slack
- **Where:** `%APPDATA%\Slack` (direct-download desktop build). Holds `storage` (workspace list), `Cache`, `Code Cache`, `IndexedDB`, `Local Storage`, `Service Worker`, `logs`, and `root-state.json`.
- **Reveals:** Every workspace the owner joined, their user/display name and email, cached channel and DM content, draft messages, downloaded file names, and workspace/organisation identities.
- **Remove (user runs):** In Slack, sign out of each workspace (profile > Sign out), then Help/File > uninstall via Settings > Apps > Installed apps. Delete any remaining `%APPDATA%\Slack` folder in File Explorer. For the Microsoft Store build, use Settings > Apps > Slack > Advanced options > Reset.
- **Survives:** Messages and files stay on each Slack workspace's servers (and are visible to those workspace admins); the account stays signed in on phone/web. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Discord
- **Where:** `%APPDATA%\discord` (stable; `%APPDATA%\discordptb` and `%APPDATA%\discordcanary` for PTB/Canary builds). Holds `Local Storage\leveldb` (the session token lives here), `Cache`, `Code Cache`, `IndexedDB`, `sessionData`, and `settings.json`.
- **Reveals:** The signed-in account, cached servers (guilds) and DMs, draft messages, recently viewed channels, and account settings. The leveldb store can retain an authentication token that keeps the session alive.
- **Remove (user runs):** In Discord, User Settings > scroll down > **Log Out**. Uninstall via Settings > Apps > Installed apps, then delete any remaining `%APPDATA%\discord` (and PTB/Canary) folders in File Explorer.
- **Survives:** All messages and servers remain on Discord's servers and on the owner's other logged-in devices until the session is removed there (User Settings > Devices / Sessions). SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### WhatsApp Desktop (Microsoft Store)
- **Where:** `%LOCALAPPDATA%\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm` (LocalState holds the linked-device session, cached chats and media).
- **Reveals:** The phone number/account linked to this PC, contact names, cached chat text and media (photos, voice notes, documents), and recent conversations.
- **Remove (user runs):** On the **phone**, open WhatsApp > Settings > Linked Devices > tap this computer > **Log out** (this is the authoritative step — it ends the link). Then on the PC, Settings > Apps > WhatsApp > Advanced options > **Reset**, or Uninstall.
- **Survives:** The full chat history lives on the phone (and in the owner's phone/cloud backup — Google Drive or iCloud); unlinking the PC does not touch it. SSD remnants of the local cache persist until TRIM/overwrite.
- **Admin:** No.

### WhatsApp Desktop (classic / native)
- **Where:** `%APPDATA%\WhatsApp` (the older non-Store desktop build) — `Cache`, `IndexedDB`, `Local Storage`, and cached media.
- **Reveals:** Same as the Store build: linked phone number, contacts, cached messages and media.
- **Remove (user runs):** Log the PC out from the phone (Settings > Linked Devices), uninstall from Settings > Apps > Installed apps, then delete any remaining `%APPDATA%\WhatsApp` folder in File Explorer.
- **Survives:** History remains on the phone and phone/cloud backup. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Telegram Desktop (tdata)
- **Where:** `%APPDATA%\Telegram Desktop\tdata` (the encrypted local session and cache for the direct-download build). The Microsoft Store build keeps an equivalent store under its own `%LOCALAPPDATA%\Packages\` folder.
- **Reveals:** That a Telegram account was signed in on this PC, and — because Telegram is cloud-based — a local cache of chats, contacts, media and recently opened conversations. The `tdata` folder is a complete logged-in session: anyone who copies it can resume the account unless the session is terminated.
- **Remove (user runs):** In Telegram, Settings > Devices (or Privacy & Security > Active Sessions) > **Terminate** this PC's session (can be done from the phone too). Then Settings > Advanced > or simply uninstall, and delete any remaining `%APPDATA%\Telegram Desktop` folder in File Explorer.
- **Survives:** All non-secret chats live on Telegram's cloud and resync to every logged-in device — clearing this PC removes nothing server-side. Secret chats are device-only. The account stays active on other devices until each session is terminated. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Signal Desktop
- **Where:** `%APPDATA%\Signal` — `sql\db.sqlite` (the message database, encrypted with a key stored in `config.json`), `attachments.noindex`, `stickers.noindex`, `Cache`, `IndexedDB`, and `logs`.
- **Reveals:** That a Signal account was linked here, plus a local copy of messages, attachments, and contact/group names cached on this PC.
- **Remove (user runs):** On the **phone**, Signal > Settings > Linked Devices > remove this computer. On the PC, in Signal use File > **Delete All Data** (or uninstall), then delete any remaining `%APPDATA%\Signal` folder in File Explorer.
- **Survives:** Signal keeps almost nothing server-side, so the authoritative copy of the conversation stays on the **phone and any other linked device** — those are untouched by clearing this PC. SSD remnants of the local database persist until TRIM/overwrite.
- **Admin:** No.

### Zoom
- **Where:** `%APPDATA%\Zoom` (app data, including `data\zoomus.enc.db` — the local meeting/chat/contact store — and `logs`). Local recordings default to `%USERPROFILE%\Documents\Zoom\<meeting folders>`.
- **Reveals:** The signed-in Zoom account and email, meeting history and saved meeting IDs, in-meeting chat, contacts, and — in Documents\Zoom — local recordings with audio/video and participant names.
- **Remove (user runs):** In Zoom, profile > **Sign Out**. Uninstall via Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Zoom` folder. Separately review and delete local recordings under `%USERPROFILE%\Documents\Zoom` in File Explorer (move any to keep onto backup first).
- **Survives:** Cloud recordings, meeting history and contacts stay in the Zoom account; the account stays signed in on other devices and web. Local recordings that were only on this PC are the exception (no cloud copy) — once deleted, SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Skype (classic desktop)
- **Where:** `%APPDATA%\Microsoft\Skype for Desktop` (Skype 8 Electron build; Skype was retired in May 2025 but installed data persists). Very old Skype 7 and earlier kept per-user `main.db` chat databases under `%APPDATA%\Skype\<skype-name>`.
- **Reveals:** The Skype/Microsoft account signed in, cached conversations and call history, contact lists, and (in legacy `main.db`) full local chat history and transferred-file records.
- **Remove (user runs):** In Skype, sign out, then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Microsoft\Skype for Desktop` (and legacy `%APPDATA%\Skype`) folders in File Explorer.
- **Survives:** Skype chat history is stored in the Microsoft cloud and tied to the Microsoft account; it remains until the owner deletes it from their account and is visible after signing in elsewhere. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Skype (Microsoft Store)
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.SkypeApp_kzf8qxf38zg5c` (LocalState/cache for the UWP build).
- **Reveals:** Same as classic Skype — signed-in account, cached chats, contacts and call history.
- **Remove (user runs):** Sign out in the app, then Settings > Apps > Skype > Advanced options > **Reset**, or Uninstall.
- **Survives:** Cloud-stored Skype history tied to the Microsoft account remains and reappears on next sign-in anywhere. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Facebook Messenger (desktop)
- **Where:** The Meta "Messenger" desktop app (a Store/Electron wrapper, discontinued for Windows in 2024) stored data under a Facebook-published package in `%LOCALAPPDATA%\Packages\` (a `Facebook...`-named folder with a `LocalState` tree) and/or an Electron cache folder under `%APPDATA%`. The exact package identifier varies by version — confirm by looking for a `Facebook`- or `Messenger`-named folder under `%LOCALAPPDATA%\Packages`.
- **Reveals:** The Facebook account signed in, cached conversations and contacts, and downloaded media.
- **Remove (user runs):** Sign out in the app; if it is a Store package, Settings > Apps > (the Messenger/Facebook entry) > Advanced options > **Reset** or Uninstall; otherwise uninstall and delete the leftover cache folder in File Explorer.
- **Survives:** All messages remain on Facebook/Meta servers and in the Messenger mobile app and web — clearing this PC removes nothing server-side. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Viber
- **Where:** `%APPDATA%\ViberPC` — the local database and per-account data under `%APPDATA%\ViberPC\<phone number>` (message DB and cached media). Downloaded files default to `%USERPROFILE%\Documents\ViberDownloads`.
- **Reveals:** The phone number/account used, contact names, cached messages and media, call history, and downloaded files.
- **Remove (user runs):** In Viber, Settings > Account > **Deactivate this device** (or log out), then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\ViberPC` and `%USERPROFILE%\Documents\ViberDownloads` folders in File Explorer.
- **Survives:** Message history is held primarily on the owner's phone (Viber's primary device); other activated devices remain until deactivated. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### WeChat
- **Where:** Configuration and account data under `%APPDATA%\Tencent\WeChat`. Chat data (WeChat 3.x) defaults to `%USERPROFILE%\Documents\WeChat Files\<wxid_...>`; WeChat 4.0 uses a separate `xwechat_files` folder whose location is user-configurable (shown in the app under Settings > General/Storage > Storage location, often under Documents). Check both.
- **Reveals:** The WeChat ID/account signed in, contact names, cached chat text and media (images, voice, video, files), and Moments cache.
- **Remove (user runs):** Sign out of WeChat, uninstall from Settings > Apps > Installed apps, then delete the `%APPDATA%\Tencent\WeChat` folder and the chat-files folder (`Documents\WeChat Files` and/or the configured `xwechat_files`) in File Explorer (move any to keep onto backup first).
- **Survives:** Recent chat history syncs from the phone/servers and can reappear on next sign-in; the account stays active on the phone. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### LINE
- **Where:** `%APPDATA%\LINE` (PC client; `Data` and `Cache` subfolders hold local messages and media). A Microsoft Store build keeps an equivalent store under its own `%LOCALAPPDATA%\Packages\` folder.
- **Reveals:** The LINE account signed in, cached chats and media, contacts, and recently opened conversations.
- **Remove (user runs):** In LINE, Settings > log out, then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\LINE` folder in File Explorer. For the Store build use Settings > Apps > LINE > Advanced options > Reset.
- **Survives:** Chat history is tied to the account and the phone; letting chats back up/sync restores them on next sign-in. The account stays active on the phone. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Element (Matrix)
- **Where:** `%APPDATA%\Element` (Electron; older installs used `%APPDATA%\Riot`). Holds `IndexedDB` and `Local Storage` with the encrypted session, cached rooms and messages, and device keys. Note: this is **not** the "Riot Client" / "riot-client-ux" folder, which belongs to Riot Games.
- **Reveals:** The Matrix user ID and homeserver signed in, cached room (chat) names and messages, and this device's end-to-end-encryption keys.
- **Remove (user runs):** In Element, click the avatar > **Sign out** (confirm the key-backup prompt if shown), then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Element` (and legacy `%APPDATA%\Riot`) folder in File Explorer.
- **Survives:** Messages remain on the Matrix homeserver and sync to the owner's other sessions until each is signed out; the account itself is unaffected. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Classic Outlook — mail data files (.ost / .pst)
- **Where:** Cached Exchange/IMAP mailboxes (`.ost`) default to `%LOCALAPPDATA%\Microsoft\Outlook`. Personal archive/local stores (`.pst`) created by newer Outlook default to `%USERPROFILE%\Documents\Outlook Files`; older Outlook placed them in `%LOCALAPPDATA%\Microsoft\Outlook`. A `.pst` may also sit anywhere the user chose.
- **Reveals:** A full offline copy of the owner's mailbox — emails, attachments, calendar, contacts and tasks for each configured account. A `.pst` can be the **only** copy of archived mail (no server copy).
- **Remove (user runs):** In Outlook, File > Account Settings > Account Settings > remove each account (this detaches and lets Windows clear the `.ost`). For `.pst` files, back up anything to keep first, then File > Account Settings > Data Files > remove, and delete the `.pst` in File Explorer with Outlook closed.
- **Survives:** Server mailboxes (Exchange, Microsoft 365, Outlook.com, Gmail/IMAP) keep everything and stay signed in on web and phone — deleting the `.ost` changes nothing there. `.pst`-only archives are the exception: once deleted, SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Classic Outlook — autocomplete / nickname cache (RoamCache)
- **Where:** `%LOCALAPPDATA%\Microsoft\Outlook\RoamCache` (the `Stream_Autocomplete_*.dat` nickname cache). Pre-2010 Outlook used an `.nk2` file under `%APPDATA%\Microsoft\Outlook`.
- **Reveals:** The names and email addresses Outlook suggests when composing — effectively a list of everyone the owner has emailed, including one-off and personal contacts not in the address book.
- **Remove (user runs):** In Outlook, File > Options > Mail > Send messages > **Empty Auto-Complete List**. Alternatively, with Outlook closed, delete the files in `%LOCALAPPDATA%\Microsoft\Outlook\RoamCache` in File Explorer.
- **Survives:** On Exchange/Microsoft 365 the autocomplete stream can roam with the mailbox, so it may repopulate after the account signs in on another machine. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Classic Outlook — profiles & account configuration (registry)
- **Where:** `HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles` (16.0 = Office 2016/2019/2021/365; 15.0 = 2013). Account definitions and server settings also live under `...\Outlook\Profiles\<profile>\9375CFF0413111d3B88A00104B2A6676`.
- **Reveals:** The configured account names, email addresses, mail-server and Exchange/host names, and data-file paths — identifying the owner and their mail providers even without the mailbox content.
- **Remove (user runs):** In Outlook, File > Account Settings, remove the accounts; or Control Panel > Mail (Microsoft Outlook) > Show Profiles > remove the profile. (Registry editing is advanced and out of scope for v0.1 — use the Mail applet instead.)
- **Survives:** Removing the profile does not delete anything on the mail servers; those accounts stay active. Re-adding the account recreates the profile.
- **Admin:** No (HKCU, the current user's hive).

### Classic Outlook — signatures
- **Where:** `%APPDATA%\Microsoft\Signatures` (`.htm`, `.rtf`, `.txt` and a matching assets folder per signature).
- **Reveals:** The owner's full name, job title, company, phone numbers, address, and sometimes a photo or social links embedded in the email signature.
- **Remove (user runs):** In Outlook, File > Options > Mail > Signatures > delete each signature; or delete the files in `%APPDATA%\Microsoft\Signatures` in File Explorer.
- **Survives:** New Outlook and Outlook on the web store signatures in the cloud/roaming settings separately; those remain until cleared there. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### New Outlook for Windows
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.OutlookForWindows_8wekyb3d8bbwe` (LocalState/LocalCache hold account hints and a web cache; the new Outlook is largely a cloud-backed web wrapper with limited local mail storage).
- **Reveals:** The accounts added to new Outlook (email addresses), cached message previews and attachments, and recent contacts.
- **Remove (user runs):** In new Outlook, Settings > Accounts > remove each account, then Settings > Apps > Outlook (new) > Advanced options > **Reset**, or Uninstall.
- **Survives:** Mail lives in the cloud mailbox (Microsoft 365 / Outlook.com, or the connected Gmail/IMAP account) and stays signed in on web and phone. SSD remnants of the local cache persist until TRIM/overwrite.
- **Admin:** No.

### Mozilla Thunderbird / Betterbird
- **Where:** `%APPDATA%\Thunderbird\Profiles\<random>.default-release` (Betterbird: `%APPDATA%\Betterbird\Profiles\...`), indexed by `profiles.ini`. Key items in each profile: `Mail\` and `ImapMail\` (mbox message stores), `global-messages-db.sqlite` (a full-text index of all messages), `logins.json` + `key4.db` (saved email passwords), `abook.sqlite` / address-book files (contacts), and `prefs.js` (account addresses and server names).
- **Reveals:** A complete local copy of the owner's mail for each account, a searchable index of message content, saved mail-account passwords, contacts, and account/server configuration. POP accounts' mail may exist **only** here.
- **Remove (user runs):** In Thunderbird, remove each account (Account Settings > Account Actions > Remove Account, including message data) and clear saved passwords (Settings > Privacy & Security > Saved Passwords > Remove All); or delete the whole profile via the Profile Manager (`thunderbird -P`) and then delete the `%APPDATA%\Thunderbird` (or `Betterbird`) folder in File Explorer. Back up any POP-only mail first.
- **Survives:** IMAP/Exchange mail stays on the server and resyncs if the account is re-added; those mailboxes stay signed in elsewhere. POP-only mail that was local is the exception. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Windows Mail & Calendar / People
- **Where:** `%LOCALAPPDATA%\Packages\microsoft.windowscommunicationsapps_8wekyb3d8bbwe` (the built-in Mail, Calendar and People apps share this package; `LocalState` holds account data and cached mail/calendar/contacts). These apps are being retired in favour of new Outlook, but the package and its data persist.
- **Reveals:** The email accounts added (addresses and provider), cached messages and calendar events, and the People app's aggregated contacts.
- **Remove (user runs):** In Mail, Settings > Manage accounts > remove each account; then Settings > Apps > Mail and Calendar > Advanced options > **Reset**, or Uninstall.
- **Survives:** Mail, calendar and contacts live in the cloud accounts (Microsoft 365 / Outlook.com / Gmail / IMAP) and stay signed in on web and phone. SSD remnants of the local cache persist until TRIM/overwrite.
- **Admin:** No.

### eM Client
- **Where:** `%APPDATA%\eM Client` (the local database: accounts, mail, calendar and contacts; logs may also appear under `%LOCALAPPDATA%\eM Client`).
- **Reveals:** Every account configured (email addresses and servers), a local copy of mail, calendar and contacts, and saved account credentials.
- **Remove (user runs):** In eM Client, Menu > Accounts > remove each account; then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\eM Client` folder in File Explorer. Back up any POP-only mail first.
- **Survives:** IMAP/Exchange mailboxes remain on their servers and stay signed in elsewhere; POP-only local mail is the exception. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Mailbird
- **Where:** `%LOCALAPPDATA%\Mailbird` (the data folder Mailbird's own backup guidance names; the local database — accounts, messages, contacts — lives in the `Store` subfolder, e.g. `%LOCALAPPDATA%\Mailbird\Store`).
- **Reveals:** The accounts configured (email addresses and servers), a local copy of mail and contacts, and saved account credentials.
- **Remove (user runs):** In Mailbird, Settings > Accounts > remove each account; then uninstall from Settings > Apps > Installed apps and delete any remaining `%LOCALAPPDATA%\Mailbird` folder in File Explorer. Back up any POP-only mail first.
- **Survives:** IMAP/Exchange mailboxes remain on their servers and stay signed in elsewhere; POP-only local mail is the exception. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

---

## Productivity, media & gaming apps

### Microsoft Office recent files and places (registry MRU)
- **Where:** `HKCU:\Software\Microsoft\Office\16.0\Word\File MRU`, and the matching `...\Excel\File MRU`, `...\PowerPoint\File MRU`, `...\Access\File MRU`, plus each app's `...\Place MRU`. The `16.0` segment is the Office version (16.0 = 2016/2019/2021/Microsoft 365; 15.0 = 2013; 14.0 = 2010).
- **Reveals:** Full names and full paths of recently opened documents, including local paths, mapped network drives, SharePoint/Teams URLs and OneDrive links — this exposes employer/client names, project names and folder structure even after the files themselves are gone.
- **Remove (user runs):** In each Office app, File > Open (or the Recent list) > right-click an entry > "Remove from list" / "Clear unpinned items". To wipe a whole list at once you can delete the key yourself, e.g. `reg delete "HKCU\Software\Microsoft\Office\16.0\Word\File MRU" /f` (repeat per app and for the `Place MRU` keys). You can also set File > Options > Advanced > "Show this number of Recent Documents" to 0.
- **Survives:** The recent list roams to the Microsoft 365 cloud and reappears on next sign-in with the same account, so you must also sign Office out of the account. Does not touch the documents themselves.
- **Admin:** no

### Office recent-document shortcuts
- **Where:** `%APPDATA%\Microsoft\Office\Recent` (holds `.lnk` shortcuts to recently opened Office files).
- **Reveals:** Names and target paths of recently opened documents — the same exposure as the registry MRU, in file form.
- **Remove (user runs):** Delete the contents of the folder in File Explorer.
- **Survives:** The registry MRU and the cloud recent list are separate — clear those too.
- **Admin:** no

### Office Document Cache (OneDrive / SharePoint)
- **Where:** `%LOCALAPPDATA%\Microsoft\Office\16.0\OfficeFileCache`
- **Reveals:** Locally cached copies of documents you edited from OneDrive/SharePoint/Teams, so their content can remain on disk even after the online files are gone.
- **Remove (user runs):** In any Office app: File > Options > Save > "Delete cached files" (Cache Settings); on older builds, Microsoft Office Upload Center > Settings > Delete cached files. Then sign Office out.
- **Survives:** The authoritative copies remain in OneDrive/SharePoint until removed there.
- **Admin:** no

### Microsoft 365 / Office signed-in identity and token cache
- **Where:** `HKCU:\Software\Microsoft\Office\16.0\Common\Identity`; `%LOCALAPPDATA%\Microsoft\OneAuth`; `%LOCALAPPDATA%\Microsoft\IdentityCache`; `%LOCALAPPDATA%\Microsoft\TokenBroker\Cache`
- **Reveals:** The email address(es) and display name of the account signed into Office/OneDrive, plus cached sign-in tokens that keep the session alive.
- **Remove (user runs):** In any Office app: File > Account > Sign out; then remove the account under Settings > Accounts > "Email & accounts" and "Access work or school".
- **Survives:** Server-side the account is untouched — sign-out only ends this device's session. Token caches rebuild if you sign in again.
- **Admin:** no

### OneNote notebooks (local cache)
- **Where:** Desktop OneNote: `%LOCALAPPDATA%\Microsoft\OneNote\16.0\cache` and `...\16.0\Backup`. Store/UWP OneNote: `%LOCALAPPDATA%\Packages\Microsoft.Office.OneNote_8wekyb3d8bbwe\LocalState`.
- **Reveals:** Cached and backup copies of notebook pages and section names — the actual note content, held locally even for cloud notebooks.
- **Remove (user runs):** In OneNote: File > Info > close each notebook, then File > Account > Sign out. For the UWP app, sign out in-app and reset it via Settings > Apps > Installed apps > OneNote > Advanced options > Reset.
- **Survives:** Notebooks stored in OneDrive/SharePoint remain in the cloud until removed there.
- **Admin:** no

### Sticky Notes content
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.MicrosoftStickyNotes_8wekyb3d8bbwe\LocalState\plum.sqlite`
- **Reveals:** The full text of every sticky note — people often keep to-do lists, phone numbers, addresses, even passwords here.
- **Remove (user runs):** Delete each note in the Sticky Notes app; if the notes sync, sign out via the app's Settings. To clear everything, reset the app via Settings > Apps > Installed apps > Microsoft Sticky Notes > Advanced options > Reset.
- **Survives:** If notes sync to your Microsoft account, they remain in the cloud (and on other devices) until deleted there.
- **Admin:** no

### Windows 11 Notepad unsaved tabs
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsNotepad_8wekyb3d8bbwe\LocalState\TabState` (and the sibling `WindowState`).
- **Reveals:** The text of Notepad tabs you left open but never saved to a file — current Windows 11 Notepad restores these on relaunch, so the content sits on disk as `.bin` files.
- **Remove (user runs):** In Notepad, close each tab (choosing "Don't save"), or turn off Settings > "When Notepad starts" > Open content from the previous session, then close all tabs. To clear everything, reset the app via Settings > Apps > Installed apps > Notepad > Advanced options > Reset.
- **Survives:** Nothing cloud-side (Notepad tabs are local). The `.bin` files remain until the tabs are closed or the app is reset; SSD remnants until overwritten.
- **Admin:** no

### Adobe Creative Cloud account and sign-in
- **Where:** `%LOCALAPPDATA%\Adobe\OOBE` and `%APPDATA%\Adobe\OOBE` (sign-in/licensing state); broader data under `%APPDATA%\Adobe` and `%LOCALAPPDATA%\Adobe`.
- **Reveals:** The signed-in Adobe ID (email), and keeps your Creative Cloud session and licensing active on this machine.
- **Remove (user runs):** In the Creative Cloud desktop app: account icon > Sign out (this deactivates licenses on this PC). Confirm on your Adobe account page that the device is removed.
- **Survives:** Your Adobe account, cloud documents and cloud libraries stay on Adobe's servers. Signing out does not delete local preference folders.
- **Admin:** no

### Adobe Acrobat / Reader recent files and preferences
- **Where:** Reader: `HKCU:\Software\Adobe\Acrobat Reader\DC\AVGeneral\cRecentFiles`. Acrobat Pro: `HKCU:\Software\Adobe\Adobe Acrobat\DC\AVGeneral\cRecentFiles`. Preferences and a recent-files cache under `%APPDATA%\Adobe\Acrobat\DC`. (The `DC` segment is the track; older installs use `2020`, `2017`, `11.0`, etc.)
- **Reveals:** Names and full paths of recently opened PDFs — contracts, statements, scans — exposing what you read even if the PDFs are deleted.
- **Remove (user runs):** In Acrobat/Reader: Edit > Preferences > Documents > set "Documents in recently used list" to 0, and clear File > Open Recent. To wipe the stored list you can delete the key yourself, e.g. `reg delete "HKCU\Software\Adobe\Acrobat Reader\DC\AVGeneral\cRecentFiles" /f`.
- **Survives:** Adobe Document Cloud "recents" (if used) persist in your Adobe account.
- **Admin:** no

### Adobe Lightroom Classic catalogs
- **Where:** Default `%USERPROFILE%\Pictures\Lightroom\*.lrcat` plus `*.lrcat-data` and preview `*.lrdata` folders; preferences under `%APPDATA%\Adobe\Lightroom`. (Users may store catalogs anywhere.)
- **Reveals:** A database referencing every imported photo's original file path, capture dates, GPS/location, keywords, face/people tags (names) and edit history — a detailed map of your photo library even where the photos live elsewhere.
- **Remove (user runs):** Back up any catalog you want to keep, then delete the `.lrcat` / `.lrcat-data` / `.lrdata` files in File Explorer. In cloud Lightroom (not Classic), sign out of the app.
- **Survives:** Photos synced to Adobe's Lightroom cloud remain online; the original image files are separate and remain wherever they are stored.
- **Admin:** no

### Adobe media cache (Premiere / After Effects)
- **Where:** `%APPDATA%\Adobe\Common\Media Cache` and `%APPDATA%\Adobe\Common\Media Cache Files`
- **Reveals:** Cached and indexed copies of audio/video you edited, revealing which media files you worked on (by name and content).
- **Remove (user runs):** In Premiere Pro / After Effects: Edit > Preferences > Media Cache > Delete (Clean / Remove), or delete the two folders above in File Explorer.
- **Survives:** The source media files are separate and remain where stored.
- **Admin:** no

### VLC media player recents and configuration
- **Where:** `%APPDATA%\vlc\vlc-qt-interface.ini` (the Recents / RecentsMRL list) and `%APPDATA%\vlc\vlcrc` (settings).
- **Reveals:** Full paths of recently played media files — exposing the names and locations of videos/audio you watched.
- **Remove (user runs):** In VLC: Media > Open Recent Media > Clear. To remove settings too, delete the `%APPDATA%\vlc` folder.
- **Survives:** Nothing cloud-side (VLC is local). The media files themselves are separate.
- **Admin:** no

### Windows Media Player library (legacy)
- **Where:** `%LOCALAPPDATA%\Microsoft\Media Player` (database files `CurrentDatabase_*.wmdb` and playlists).
- **Reveals:** A catalogue of media files on the PC, play counts and recently/most-played history.
- **Remove (user runs):** Close Windows Media Player, then delete the `.wmdb` files in that folder (the library rebuilds empty on next launch).
- **Survives:** The media files themselves remain; only the index is cleared.
- **Admin:** no

### Media Player / Movies & TV app (Windows 11)
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.ZuneMusic_8wekyb3d8bbwe\LocalState` (the new Media Player app — database and recent-media history) and `%LOCALAPPDATA%\Packages\Microsoft.ZuneVideo_8wekyb3d8bbwe\LocalState` (Movies & TV).
- **Reveals:** Recently played music/video and the local library the app indexed.
- **Remove (user runs):** Clear recents in the app, then reset it via Settings > Apps > Installed apps > Media Player (or Movies & TV) > Advanced options > Reset.
- **Survives:** Any purchases/entitlements tied to your Microsoft account remain in the account.
- **Admin:** no

### MPC-HC recent files
- **Where:** `HKCU:\Software\MPC-HC\MPC-HC` (the "Recent File List" values), or, in portable mode, `mpc-hc64.ini` / `mpc-hc.ini` beside the executable. MPC-BE uses `HKCU:\Software\MPC-BE`.
- **Reveals:** Full paths of recently played media files.
- **Remove (user runs):** In MPC-HC: File > Recent Files > Clear, and View > Options > Player > "Clear history". Or delete the key yourself, e.g. `reg delete "HKCU\Software\MPC-HC\MPC-HC" /f`.
- **Survives:** Nothing cloud-side; the media files are separate.
- **Admin:** no

### Spotify account, cache and preferences
- **Where:** `%APPDATA%\Spotify` (preferences including the remembered username / auto-login) and `%LOCALAPPDATA%\Spotify\Storage` and `...\Data` (offline cache).
- **Reveals:** The signed-in Spotify username, cached playback data and (for Premium) downloaded offline tracks.
- **Remove (user runs):** In Spotify: profile > Log out. To force all devices off, use "Sign out everywhere" on your Spotify account page. Then uninstall, or delete the `%APPDATA%\Spotify` and `%LOCALAPPDATA%\Spotify` folders.
- **Survives:** Your Spotify account, playlists and library stay on Spotify's servers.
- **Admin:** no

### iTunes / Apple Music library
- **Where:** `%USERPROFILE%\Music\iTunes` (`iTunes Library.itl`, `iTunes Music Library.xml`, media). The Windows 11 Apple Music app (Store) stores under `%LOCALAPPDATA%\Packages\AppleInc.AppleMusicWin_*`.
- **Reveals:** Your music/media library, playlists and play history, and that this computer is authorized to your Apple Account.
- **Remove (user runs):** In iTunes: Account > Authorizations > Deauthorize This Computer (you have a limited number of authorizations), then Account > Sign Out. Back up anything to keep, then remove the library folder. In the Apple Music app, sign out in-app.
- **Survives:** Your Apple Account, iCloud Music Library and purchases remain with Apple. Deauthorizing matters because the authorization slot is otherwise consumed by this PC.
- **Admin:** no

### Apple device backups (iPhone / iPad)
- **Where:** Store "Apple Devices" / Apple Music app: `%USERPROFILE%\Apple\MobileSync\Backup`. Classic iTunes: `%APPDATA%\Apple Computer\MobileSync\Backup`.
- **Reveals:** Full local backups of a phone/tablet — messages, photos, app data, contacts, call history. One of the highest-exposure items on a PC.
- **Remove (user runs):** In the Apple Devices app / iTunes: Edit > Preferences > Devices > select the backup > Delete Backup. Or delete the per-device folders under the `Backup` path above.
- **Survives:** iCloud backups of the device (if enabled) remain in Apple's cloud. An unencrypted backup folder may leave recoverable remnants on an SSD until overwritten.
- **Admin:** no

### Notion (desktop)
- **Where:** `%APPDATA%\Notion` (config, logs, local cache and the signed-in session).
- **Reveals:** Your workspace name and account email, plus locally cached pages/content you viewed.
- **Remove (user runs):** In Notion: Settings > log out. On the web, use Settings > active sessions / "Log out of all devices" to end this device server-side. Then delete `%APPDATA%\Notion`.
- **Survives:** All workspace content stays on Notion's servers under your account.
- **Admin:** no

### Obsidian (vault list and notes)
- **Where:** `%APPDATA%\obsidian\obsidian.json` records every opened vault's absolute path; the vaults themselves are ordinary folders wherever you created them (commonly under `%USERPROFILE%\Documents`), each containing a `.obsidian` config folder and your `.md` notes.
- **Reveals:** The names and locations of your knowledge vaults (revealing by title alone) and, inside them, all note content in plain Markdown.
- **Remove (user runs):** Back up any vault to keep, delete the vault folders in File Explorer, then delete `%APPDATA%\obsidian` to clear the opened-vault list.
- **Survives:** If you used Obsidian Sync or a third-party sync (Git, OneDrive, iCloud), copies remain in that remote.
- **Admin:** no

### Evernote (local database)
- **Where:** Legacy Evernote: `%LOCALAPPDATA%\Evernote\Evernote\Databases\*.exb`. Evernote v10+: `%APPDATA%\Evernote` and `%LOCALAPPDATA%\Evernote`.
- **Reveals:** Cached note content and the signed-in account email.
- **Remove (user runs):** In Evernote, sign out; on the web (Account Settings > Devices / Applications), revoke this device. Then uninstall and delete the folders above.
- **Survives:** Notes remain in your Evernote account in the cloud.
- **Admin:** no

### Joplin (notes and sync config)
- **Where:** `%APPDATA%\joplin-desktop` (the `database.sqlite` holding all notes, plus settings).
- **Reveals:** All note content, and the sync target configuration — which may include a sync-service account or a token/credential for WebDAV/S3/OneDrive/Dropbox.
- **Remove (user runs):** In Joplin, disable/clear synchronisation (Tools > Options > Synchronisation), then close Joplin and delete the `%APPDATA%\joplin-desktop` folder.
- **Survives:** Notes already uploaded to your sync target remain there until removed at the remote.
- **Admin:** no

### Visual Studio Code (recent folders, history, extension state)
- **Where:** `%APPDATA%\Code\User\settings.json`; `%APPDATA%\Code\User\globalStorage\storage.json` and `...\globalStorage\state.vscdb` (recent workspaces and extension state); `%APPDATA%\Code\User\workspaceStorage` (per-project state, each subfolder keyed to a workspace path); `%APPDATA%\Code\User\History` (local edit history of files); extensions in `%USERPROFILE%\.vscode\extensions`. Variants: Insiders `%APPDATA%\Code - Insiders`, VSCodium `%APPDATA%\VSCodium`, Cursor `%APPDATA%\Cursor`.
- **Reveals:** Paths of recently opened folders/projects (exposing employer/client/project names), local file edit history (actual earlier content of files), and extension-stored state that can include access tokens for some extensions.
- **Remove (user runs):** File > Open Recent > "Clear Recently Opened"; sign out of the Accounts menu (bottom-left) for GitHub/Microsoft and any extension accounts; turn off Settings Sync if used ("turn off and clear data"). To wipe local state, close VS Code and delete the `globalStorage`, `workspaceStorage` and `History` folders under `%APPDATA%\Code\User`.
- **Survives:** Settings Sync keeps a copy in your GitHub/Microsoft account until you clear it there; extension tokens held in Windows Credential Manager are separate (see the credentials section).
- **Admin:** no

### JetBrains IDEs recent projects
- **Where:** `%APPDATA%\JetBrains\<Product><version>\options\recentProjects.xml` (e.g. `IntelliJIdea2024.2`, `PyCharm2024.2`); caches, logs and indexes under `%LOCALAPPDATA%\JetBrains\<Product><version>`.
- **Reveals:** Full paths and names of recently opened projects, and the signed-in JetBrains Account.
- **Remove (user runs):** On the IDE Welcome screen, remove each entry from the recent-projects list; sign out under Settings > your JetBrains Account (or Help > Register). To wipe fully, close the IDE and delete the product folders under `%APPDATA%\JetBrains` and `%LOCALAPPDATA%\JetBrains`.
- **Survives:** The JetBrains Account and any settings synced to it remain in the cloud. Project folders on disk are separate personal files.
- **Admin:** no

### Git identity and stored credentials
- **Where:** `%USERPROFILE%\.gitconfig` (your `user.name` / `user.email` and config); `%USERPROFILE%\.git-credentials` only if the plaintext "store" helper was configured (it holds tokens in clear text); each repository's `.git\config` holds remote URLs that can embed a username or token, and its commit history holds author name/email.
- **Reveals:** Your Git identity (name + email), and — if the store helper was used — access tokens in plain text; repo remotes can expose private host names and accounts.
- **Remove (user runs):** Delete `%USERPROFILE%\.git-credentials` if present (do not open it); clear Git entries in Windows Credential Manager (Control Panel > Credential Manager > Windows Credentials, remove `git:*` entries), since Git Credential Manager stores there; edit or delete `%USERPROFILE%\.gitconfig`; and handle local repositories as personal files (back up, then delete).
- **Survives:** Tokens remain valid on the server (GitHub/GitLab/etc.) until you revoke them in that account. Remote repositories are unaffected.
- **Admin:** no

### Postman (collections, environments, account)
- **Where:** `%APPDATA%\Postman` (app data, IndexedDB, signed-in session).
- **Reveals:** Saved API requests, environment variables that frequently contain API keys / bearer tokens, request history, and your Postman account email.
- **Remove (user runs):** In Postman, sign out; on the Postman website review active sessions to end this device server-side. Then uninstall and delete `%APPDATA%\Postman`.
- **Survives:** Collections/environments synced to your Postman account stay in the cloud. Any API tokens remain valid until revoked at their source.
- **Admin:** no

### Insomnia (requests, environments, account)
- **Where:** `%APPDATA%\Insomnia` (local database of requests and environments, plus account/session).
- **Reveals:** API requests and environment values (often tokens/keys), and the signed-in account.
- **Remove (user runs):** In Insomnia, log out; then uninstall and delete `%APPDATA%\Insomnia`.
- **Survives:** Data synced to an Insomnia/Kong account remains in the cloud; tokens remain valid until revoked at their source.
- **Admin:** no

### Docker Desktop (Hub login and registry credentials)
- **Where:** `%USERPROFILE%\.docker\config.json` (logged-in Docker Hub account and registry auth, or a credsStore pointer); app data under `%APPDATA%\Docker`, `%APPDATA%\Docker Desktop` and `%LOCALAPPDATA%\Docker`.
- **Reveals:** Your Docker Hub account, which registries you authenticated to, and image names you pulled/built.
- **Remove (user runs):** Run `docker logout` yourself (removes stored registry auth), sign out in Docker Desktop (account menu), then delete the Docker data folders above. Images live in the Docker/WSL data and are removed by uninstalling Docker Desktop or using its "Reset to factory defaults" in the troubleshoot menu.
- **Survives:** Your Docker Hub account and pushed images stay in the cloud. WSL distro data can remain until Docker is uninstalled/reset.
- **Admin:** no

### Windows Terminal settings
- **Where:** Store install: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`. Unpackaged install: `%LOCALAPPDATA%\Microsoft\Windows Terminal\settings.json`.
- **Reveals:** Custom profiles that can disclose SSH targets, hostnames, usernames and default starting directories (project paths).
- **Remove (user runs):** Edit `settings.json` to remove custom profiles, or reset the app via Settings > Apps > Installed apps > Windows Terminal > Advanced options > Reset.
- **Survives:** Shell command history is stored separately (e.g. PowerShell's `ConsoleHost_history.txt` — see the credentials / activity section).
- **Admin:** no

### Steam (accounts, saved login, user data)
- **Where:** Default install `%ProgramFiles(x86)%\Steam` (the exact path is in `HKCU:\Software\Valve\Steam` > `SteamPath`). Within it: `config\loginusers.vdf` (remembered accounts — SteamID, persona name, most-recent flag), `config\config.vdf`, `userdata\<id>\` (per-account settings, screenshots, cloud-save staging), and `ssfn*` files in the Steam root (the Steam Guard "remember this computer" token). Registry `HKCU:\Software\Valve\Steam` holds `AutoLoginUser`, `RememberPassword`, `LastGameNameUsed`.
- **Reveals:** Your Steam account name(s) and ID, which games you own/played, screenshots, and a token that keeps this PC trusted for sign-in.
- **Remove (user runs):** In Steam: account name > Sign out of account, and tick "Don't save account credentials". On the Steam website (Account details > Manage Steam Guard / Deauthorize all devices) remove this computer. Then uninstall, or delete `loginusers.vdf`, the `ssfn*` files and `userdata`.
- **Survives:** Your Steam account, library and Steam Cloud saves stay on Valve's servers. Deauthorizing is what stops this PC being a trusted device.
- **Admin:** no

### Epic Games Launcher (account and saved login)
- **Where:** `%LOCALAPPDATA%\EpicGamesLauncher\Saved\Config\Windows` (settings) and the launcher's `Saved` folder / web cache (the encrypted "stay signed in" token); machine data under `%PROGRAMDATA%\Epic`.
- **Reveals:** Your Epic account session, installed/owned games and settings.
- **Remove (user runs):** In the Epic launcher, sign out (profile > Sign Out). On your Epic account page, review and sign out active sessions / authorized devices. Then uninstall, or delete the `%LOCALAPPDATA%\EpicGamesLauncher\Saved` folder.
- **Survives:** Your Epic account, library and any cloud saves stay online.
- **Admin:** no

### Riot Client (League of Legends / Valorant)
- **Where:** `%LOCALAPPDATA%\Riot Games\Riot Client\Data` (the `RiotClientPrivateSettings.yaml` / `RiotGamesPrivateSettings.yaml` holds the "stay signed in" cookie/token).
- **Reveals:** That this PC stays signed in to your Riot account.
- **Remove (user runs):** In the Riot Client, sign out; to be sure, delete the private-settings `.yaml` file (or the `%LOCALAPPDATA%\Riot Games` folder). Change your Riot password if you want to invalidate the stored session everywhere.
- **Survives:** Your Riot account and its data stay online.
- **Admin:** no

### Battle.net (Blizzard) launcher
- **Where:** `%APPDATA%\Battle.net` and `%PROGRAMDATA%\Battle.net` (config including a "keep me logged in" token and cached account hints).
- **Reveals:** The Blizzard / Battle.net account email hint and the kept-login session.
- **Remove (user runs):** In Battle.net, log out (account menu) and uncheck "Keep me logged in". On account.battle.net (Security) you can review connected sessions. Then uninstall, or delete the `%APPDATA%\Battle.net` folder.
- **Survives:** Your Blizzard account and games stay online.
- **Admin:** no

### EA app / Origin
- **Where:** EA app: `%LOCALAPPDATA%\Electronic Arts\EA Desktop` and `%PROGRAMDATA%\Electronic Arts\EA Desktop`. Origin (legacy): `%APPDATA%\Origin`, `%LOCALAPPDATA%\Origin`, `%PROGRAMDATA%\Origin`.
- **Reveals:** Your EA account session and owned/installed games; a local cache of account details.
- **Remove (user runs):** In the EA app / Origin, sign out (and uncheck "stay signed in"). On your EA account security page, review connected logins. Then uninstall, or delete the folders above.
- **Survives:** Your EA account and cloud saves stay online.
- **Admin:** no

### Ubisoft Connect
- **Where:** `%LOCALAPPDATA%\Ubisoft Game Launcher` (settings, saved login, and `savegames\<userid>\` local copies of cloud saves).
- **Reveals:** Your Ubisoft account session, installed games and local save data.
- **Remove (user runs):** In Ubisoft Connect, log out (and disable "remember me"); on account.ubisoft.com (Security) review connected devices. Then uninstall, or delete the `%LOCALAPPDATA%\Ubisoft Game Launcher` folder.
- **Survives:** Your Ubisoft account and cloud saves stay online.
- **Admin:** no

### GOG Galaxy
- **Where:** `%PROGRAMDATA%\GOG.com\Galaxy` (config and the `storage\galaxy-2.0.db` database of owned games, friends and the logged-in account); `%LOCALAPPDATA%\GOG.com\Galaxy`.
- **Reveals:** Your GOG account, owned games, play time and friends.
- **Remove (user runs):** In GOG Galaxy, log out (account menu). Then uninstall, or delete the `GOG.com` folders under `%PROGRAMDATA%` and `%LOCALAPPDATA%`.
- **Survives:** Your GOG account and cloud saves stay online.
- **Admin:** no

### Xbox app and Gaming Services
- **Where:** Xbox app: `%LOCALAPPDATA%\Packages\Microsoft.GamingApp_8wekyb3d8bbwe`. Xbox Game Bar: `%LOCALAPPDATA%\Packages\Microsoft.XboxGamingOverlay_8wekyb3d8bbwe`. The identity is the Microsoft account signed into Windows / the app.
- **Reveals:** The signed-in Xbox / Microsoft account, installed Game Pass / Store games and gaming activity.
- **Remove (user runs):** In the Xbox app, sign out (profile > Sign out). Because the gaming identity follows the Windows Microsoft account, also remove that account at handover (Settings > Accounts).
- **Survives:** Your Xbox account, cloud saves and Game Pass entitlements stay with Microsoft. Game installs under the protected `WindowsApps` folder are removed by uninstalling the games.
- **Admin:** no (removing installed games / Gaming Services components can prompt for admin)

### Xbox Game Bar captures
- **Where:** `%USERPROFILE%\Videos\Captures`
- **Reveals:** Screen recordings and screenshots taken with Win+G / Win+Alt+R — gameplay, but also anything else that was on screen when recording.
- **Remove (user runs):** Review and delete the files in File Explorer, then empty the Recycle Bin.
- **Survives:** Copies synced to OneDrive remain in the cloud until removed there; SSD remnants until overwritten.
- **Admin:** no

### Minecraft (Java) launcher and worlds
- **Where:** `%APPDATA%\.minecraft` — `launcher_accounts.json` (signed-in Microsoft / Minecraft account), `saves\` (worlds), `screenshots\`, and `servers.dat` (saved multiplayer server addresses).
- **Reveals:** The Minecraft / Microsoft account signed in, your single-player worlds, screenshots, and the addresses of servers you joined.
- **Remove (user runs):** In the Minecraft Launcher, sign out of the account; back up any worlds to keep, then delete the `%APPDATA%\.minecraft` folder (or at least `launcher_accounts.json`, `saves`, `screenshots`, `servers.dat`).
- **Survives:** Your Minecraft / Microsoft account and any Realms worlds stay in the cloud.
- **Admin:** no

### Game saves — Documents\My Games
- **Where:** `%USERPROFILE%\Documents\My Games\<game>`
- **Reveals:** Local save files and per-game config — which games you played, character/profile names, and sometimes screenshots or logs.
- **Remove (user runs):** Confirm you don't need the saves (or that cloud saves hold them), then delete the per-game folders in File Explorer.
- **Survives:** Cloud saves (Steam Cloud, Xbox, etc.) remain on the platform. If Documents is redirected to OneDrive, deletions sync to the cloud — stop OneDrive sync first if you want to keep the cloud copy.
- **Admin:** no

### Game saves — Saved Games
- **Where:** `%USERPROFILE%\Saved Games\<game>` (the Windows "Saved Games" known folder).
- **Reveals:** Local save files and profiles for games that use this standard location.
- **Remove (user runs):** Delete the per-game folders in File Explorer after confirming cloud saves hold anything you want to keep.
- **Survives:** Platform cloud saves remain online.
- **Admin:** no

### Other local game data (LocalLow, publisher and Unity folders)
- **Where:** `%USERPROFILE%\AppData\LocalLow\<company>\<game>` (common for Unity games), `%LOCALAPPDATA%\<game>`, `%APPDATA%\<game>`; Unity "PlayerPrefs" live in the registry under `HKCU:\Software\<company>\<game>`.
- **Reveals:** Additional saves, settings and profile names that are not under My Games or Saved Games — scattered by publisher/engine.
- **Remove (user runs):** Delete the relevant per-game folders in File Explorer; for Unity PlayerPrefs you can remove the specific `HKCU:\Software\<company>\<game>` key yourself. Uninstalling a game often leaves these behind, so check after uninstalling.
- **Survives:** Platform cloud saves remain online. Exact locations vary by game, so some per-game folders may be missed.
- **Admin:** no

---

## More browsers, cloud, messengers & notes

### Arc (Windows)
- **Where:** `%LOCALAPPDATA%\Arc\User Data` — the standard Chromium *User Data* root, with one folder per profile (`Default`, `Profile 1`, …) and a `Local State` file. Every Chromium per-profile artifact documented in the browsers section (History, Cookies, Login Data, Web Data, Bookmarks, Sessions, Cache, Local Storage, IndexedDB, Extensions, Preferences) lives under each profile here.
- **Reveals:** That Arc was used, the signed-in Arc/Google account identity, and the full Chromium record — browsing history, saved passwords and autofill, cookies/sessions, open and recently closed tabs, and Arc's "Spaces"/pinned-tab layout (a map of the sites and projects the owner kept open).
- **Remove (user runs):** Close Arc fully (check Task Manager). In Arc, sign out of the account, then uninstall from Settings > Apps > Installed apps. In File Explorer delete any remaining `%LOCALAPPDATA%\Arc` folder.
- **Survives:** Anything synced to the Arc account (Spaces, tabs, settings) stays on The Browser Company's servers and on other signed-in devices until removed there. Passwords saved to a Google account remain in Google Password Manager. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Yandex Browser
- **Where:** `%LOCALAPPDATA%\Yandex\YandexBrowser\User Data` — a Chromium *User Data* root (profiles + `Local State`). All the Chromium per-profile artifacts from the browsers section apply here, per profile.
- **Reveals:** That Yandex Browser was used and the signed-in Yandex account; full browsing history, saved passwords/autofill, cookies and sessions, bookmarks, and open tabs. Yandex-specific extras include the "Alice" assistant state and Yandex Zen/feed personalisation, which reflect interests and voice/search usage.
- **Remove (user runs):** Close the browser, sign out of the Yandex account inside it, then uninstall from Settings > Apps > Installed apps and delete any remaining `%LOCALAPPDATA%\Yandex` folder in File Explorer.
- **Survives:** Data synced to the Yandex account (history, passwords, bookmarks, tabs) stays on Yandex servers and on other signed-in devices until cleared there; Yandex also keeps server-side search/activity under the account. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### LibreWolf
- **Where:** `%APPDATA%\librewolf\Profiles\<id>.default*` (listed in `%APPDATA%\librewolf\profiles.ini`); cache at `%LOCALAPPDATA%\librewolf\Profiles\<id>.default*\cache2`. A Firefox-family layout, so every Firefox artifact in the browsers section applies: `places.sqlite` (history/bookmarks/downloads), `cookies.sqlite`, `formhistory.sqlite`, `logins.json` + `key4.db` (saved passwords), `sessionstore.jsonlz4`, `storage\`, and `prefs.js`.
- **Reveals:** That LibreWolf (a hardened Firefox fork) was used; browsing history, bookmarks and downloads, saved logins (encrypted by `key4.db`; site+username list readable), cookies/sessions, form autofill, and the tabs last open.
- **Remove (user runs):** In LibreWolf, `Ctrl+Shift+Delete` > Everything to clear history/cookies/cache, and `about:logins` > Remove All Logins; or close LibreWolf and delete the `librewolf` folders under both `%APPDATA%` and `%LOCALAPPDATA%` in File Explorer. Then uninstall from Settings > Apps.
- **Survives:** LibreWolf disables Firefox Sync by default, so there is usually no cloud copy — the local profile is the authoritative copy. SQLite free-page fragments remain until vacuum; `bookmarkbackups` and SSD free-space remnants persist until overwritten.
- **Admin:** No.

### Waterfox
- **Where:** `%APPDATA%\Waterfox\Profiles\<id>.default*` (listed in `%APPDATA%\Waterfox\profiles.ini`); cache at `%LOCALAPPDATA%\Waterfox\Profiles\<id>.default*\cache2`. Firefox-family layout — same `places.sqlite`, `cookies.sqlite`, `formhistory.sqlite`, `logins.json` + `key4.db`, `sessionstore.jsonlz4`, `storage\`, `prefs.js` as the Firefox blocks.
- **Reveals:** That Waterfox was used; full history, bookmarks and downloads, saved logins (site+username readable, passwords encrypted), cookies/sessions, form entries, and last-open tabs.
- **Remove (user runs):** In Waterfox, `Ctrl+Shift+Delete` > Everything, and `about:logins` > Remove All Logins; or close Waterfox and delete the `Waterfox` folders under `%APPDATA%` and `%LOCALAPPDATA%`. Then uninstall from Settings > Apps.
- **Survives:** If a Mozilla/Firefox Account or Waterfox sync was connected, a cloud copy remains until disconnected with "delete data." SQLite/free-space remnants persist until vacuum/overwrite.
- **Admin:** No.

### Pale Moon
- **Where:** `%APPDATA%\Moonchild Productions\Pale Moon\Profiles\<id>.default*` (listed in `…\Pale Moon\profiles.ini`); cache under `%LOCALAPPDATA%\Moonchild Productions\Pale Moon\Profiles\<id>.default*\cache2`. Older Firefox-derived layout — history/bookmarks/downloads in `places.sqlite`, cookies in `cookies.sqlite`, saved passwords in `logins.json`/`signons.sqlite` with `key4.db`/`key3.db`, form data in `formhistory.sqlite`, session in `sessionstore.jsonlz4`.
- **Reveals:** That Pale Moon was used; browsing history, bookmarks and downloads, saved logins (site+username readable), cookies/sessions and form autofill.
- **Remove (user runs):** In Pale Moon, Tools > Clear Recent History > Everything, and remove saved logins in the password manager; or close Pale Moon and delete the `Moonchild Productions` folders under `%APPDATA%` and `%LOCALAPPDATA%`. Then uninstall from Settings > Apps.
- **Survives:** Pale Moon has no first-party cloud sync, so the local profile is normally the only copy. SQLite/free-space remnants persist until vacuum/overwrite; bookmark backups linger.
- **Admin:** No.

### DuckDuckGo browser for Windows
- **Where:** A per-user Store/WebView2 package under `%LOCALAPPDATA%\Packages\` whose name begins with `DuckDuckGo.DesktopBrowser` (confirm the exact folder — some builds use a different DuckDuckGo-prefixed name). Browsing data sits in that package's `LocalState`, with the Chromium/WebView2 store under an `EBWebView` subfolder (its own `Default` profile holding History, Cookies, Local Storage, etc.); a `browser-v1.db`-style local database also appears there.
- **Reveals:** That DuckDuckGo's desktop browser was used; bookmarks, browsing history, cookies/sessions, autofill, and locally stored "fireproof" site data — plus the account if Sync & Backup was enabled.
- **Remove (user runs):** In the browser use the "Fire Button" / Settings > Clear browsing data, and disable Sync & Backup. Then Settings > Apps > DuckDuckGo > Advanced options > **Reset**, or Uninstall; delete any leftover `DuckDuckGo*` folder under `%LOCALAPPDATA%\Packages` in File Explorer.
- **Survives:** If DuckDuckGo Sync & Backup was on, a copy (bookmarks/passwords) stays synced to other linked devices until the sync is disconnected. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Maxthon
- **Where:** The current Maxthon (MX6, Chromium-based) keeps its data in a Maxthon-named folder — check `%APPDATA%` and `%LOCALAPPDATA%` for `Maxthon`, `MX6` or `Maxthon6`, and for a cloud-account layout such as `…\Users\<account>\` / `…\SharedAccount\<account>\Data\`. Legacy Maxthon 3 is confirmed at `%APPDATA%\Maxthon3` with the registry key `HKCU:\Software\Maxthon3`.
- **Reveals:** That Maxthon was used and (because Maxthon ties the browser to a Maxthon Passport cloud account) the signed-in account; browsing history, favorites/bookmarks, saved form data, and cached pages. Its per-account folder names can expose the account email.
- **Remove (user runs):** Close Maxthon, sign out of the Maxthon account inside it, uninstall from Settings > Apps > Installed apps, then delete any remaining Maxthon-named folder under `%APPDATA%`/`%LOCALAPPDATA%` in File Explorer.
- **Survives:** Maxthon's cloud account mirrors favorites, tabs and some history to its servers and to other signed-in devices until cleared there. SSD remnants persist until TRIM/overwrite. (The exact MX6 data path is listed in uncertainties.)
- **Admin:** No.

### Proton Drive (Windows app)
- **Where:** The synced files live in the Proton Drive folder, default `%USERPROFILE%\Proton Drive` (relocatable in the app's Settings > Location). The app keeps local sync state, cache and logs under a `Proton` folder in local app data (a `Drive` subtree under `%LOCALAPPDATA%\Proton` — confirm the exact path on the machine).
- **Reveals:** The actual files the owner synced (documents, photos, anything in Proton Drive), their names, and the signed-in Proton account/email. Proton Drive is end-to-end encrypted, so the local store may also hold an encrypted key/session blob (existence only — never read it).
- **Remove (user runs):** In the app, sign out, then review and move anything to keep out of `%USERPROFILE%\Proton Drive` before deleting its contents. Uninstall from Settings > Apps > Installed apps and delete any leftover `Proton` app folder in File Explorer.
- **Survives:** The full copy stays in Proton Drive in the cloud under the account and on other signed-in devices — signing out locally removes nothing server-side. Files kept "online-only" were never fully local. SSD remnants of cached/local files persist until TRIM/overwrite.
- **Admin:** No.

### Sync.com (desktop app)
- **Where:** The synced files live in the Sync folder, default `%USERPROFILE%\Sync`. The app keeps its local database and account/sync state in a Sync-named folder under app data (check `%APPDATA%\Sync` / `%LOCALAPPDATA%\sync` — confirm on the machine).
- **Reveals:** The files synced via Sync.com and their names, plus the signed-in Sync.com account/email. Sync.com is end-to-end encrypted, so the local store may hold an encrypted key/session (existence only).
- **Remove (user runs):** In the app, sign out; review and move anything to keep out of `%USERPROFILE%\Sync`, then delete its contents. Uninstall from Settings > Apps > Installed apps and delete any leftover Sync app folder in File Explorer.
- **Survives:** The full copy remains in the Sync.com cloud under the account and on other devices until removed there. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Tresorit (desktop)
- **Where:** Tresorit mounts an on-demand virtual drive (Tresorit Drive) and syncs "tresors" into folders the owner chose; each synced folder holds a hidden `.tresorit` directory. Per-device settings, the account profile and cache sit in a `Tresorit` folder under local app data (a `Profiles` subtree with `sync.profile` recording the synced paths — confirm the exact root, e.g. `%LOCALAPPDATA%\Tresorit`).
- **Reveals:** Which local folders were encrypted/synced and their paths (via `sync.profile`), cached file content, and the signed-in Tresorit account/email. End-to-end encrypted, so any local key material is an encrypted blob (existence only).
- **Remove (user runs):** In Tresorit, sign out and unlink the device; review and move anything to keep out of the synced folders, then delete the local `.tresorit` folders and cached content. Uninstall from Settings > Apps and delete any leftover `Tresorit` app folder in File Explorer.
- **Survives:** Tresors remain in the Tresorit cloud under the account and on other linked devices until removed there. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### SpiderOak ONE (backup/sync)
- **Where:** The sync folder is the "Hive" at `%USERPROFILE%\SpiderOak Hive`. Config, the account identity and the local backup index sit in a SpiderOak-named folder under app data (look for `SpiderOak ONE` / `SpiderOakONE` under `%APPDATA%` — confirm the exact path).
- **Reveals:** Which folders/files on the PC were selected for backup and their paths (a map of the owner's data even where file bodies are encrypted), the Hive-synced files, and the signed-in SpiderOak account. End-to-end encrypted — any local key is an encrypted blob (existence only).
- **Remove (user runs):** In SpiderOak ONE, sign out; review and clear the `SpiderOak Hive` folder; uninstall from Settings > Apps > Installed apps and delete the leftover SpiderOak app folder in File Explorer.
- **Survives:** Backed-up/synced data remains in the SpiderOak cloud under the account until deleted there (note SpiderOak ONE has been wound down for new signups; existing data may still reside server-side). SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Jottacloud (desktop app)
- **Where:** The sync folder default is `%USERPROFILE%\Jottacloud` (relocatable in the app). Account/sync state and logs sit in a Jottacloud-named folder under app data (check `%LOCALAPPDATA%\Jottacloud` / `%APPDATA%\Jottacloud` — confirm the exact path). Backup (as opposed to sync) tracks original folders in place rather than a single sync folder.
- **Reveals:** The files synced or backed up and their names/paths, and the signed-in Jottacloud account/email.
- **Remove (user runs):** In the app, sign out and disable backup/sync; review and move anything to keep out of `%USERPROFILE%\Jottacloud`, then delete its contents. Uninstall from Settings > Apps and delete any leftover Jottacloud app folder in File Explorer.
- **Survives:** The copy in Jottacloud's cloud under the account (including prior versions/backups) remains until deleted there and on other devices. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Koofr (desktop app)
- **Where:** By default a `Koofr` sync folder is created on the Desktop (`%USERPROFILE%\Desktop\Koofr`); the owner may also have created custom syncs elsewhere. Account/sync state sits in a Koofr-named folder under app data (check `%APPDATA%\Koofr` / `%LOCALAPPDATA%\Koofr` — confirm the exact path).
- **Reveals:** The files synced to/from Koofr and their names, any custom sync folder locations, and the signed-in Koofr account/email (Koofr can also aggregate other clouds, so connected-provider hints may appear).
- **Remove (user runs):** In the app, remove each sync and sign out; review and move anything to keep out of the Koofr sync folder(s), then delete their contents. Uninstall from Settings > Apps and delete any leftover Koofr app folder in File Explorer.
- **Survives:** The copy in Koofr's cloud under the account remains until removed there and on other devices. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Seafile (desktop client)
- **Where:** Client config and logs sit in `%USERPROFILE%\ccnet` (e.g. `applet.log`), with the account and server URL recorded there; synced libraries download to a user-chosen "Seafile" folder, and the internal `seafile-data` store's location is recorded in `ccnet\seafile.ini`.
- **Reveals:** The Seafile server(s) and account the owner connected to, which libraries were synced and their local paths, and the synced files themselves. The server address can expose an employer or private host.
- **Remove (user runs):** In the Seafile client, unsync each library and sign out; review and move anything to keep out of the Seafile library folder, then delete it and the `seafile-data` store. Uninstall from Settings > Apps and delete the `%USERPROFILE%\ccnet` folder in File Explorer.
- **Survives:** Libraries remain on the Seafile server under the account until deleted there. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Amazon Photos / Amazon Drive (desktop app)
- **Where:** The app installs under `%LOCALAPPDATA%\Amazon Drive` (holds the executable, account state and upload/sync index); the default local sync folder is `%USERPROFILE%\Amazon Drive`.
- **Reveals:** The signed-in Amazon account, which local folders were set to auto-upload (often `Pictures`/`Camera Roll`), and cached/synced photos and files with their names — exposing personal photos and the account identity.
- **Remove (user runs):** In the app, sign out and turn off auto-save/backup; review and move anything to keep out of `%USERPROFILE%\Amazon Drive`. Uninstall from Settings > Apps > Installed apps and delete the `%LOCALAPPDATA%\Amazon Drive` folder in File Explorer.
- **Survives:** Photos and files already uploaded remain in Amazon Photos/Drive under the Amazon account and on other devices until deleted there. (Amazon Drive as a general file service was retired at the end of 2023; Amazon Photos continues for photos and videos.) SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Resilio Sync (peer-to-peer)
- **Where:** `%APPDATA%\Resilio Sync` — the storage folder holding the app configuration, the shared-folders database, and the identity/keys; the synced folders themselves are wherever the owner added them on disk.
- **Reveals:** Which folders were shared peer-to-peer and their local paths, the device identity, and the set of share keys/links the device participates in — a map of what was synced and with whom (no central account, so these local records are the main evidence the owner used it).
- **Remove (user runs):** In Resilio Sync, remove each folder from syncing and quit the app; review and move anything to keep out of the synced folders. Uninstall from Settings > Apps > Installed apps and delete the `%APPDATA%\Resilio Sync` folder in File Explorer.
- **Survives:** Because sync is peer-to-peer, copies persist on every other peer/device that still holds the share key — removing this PC does not touch them. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Syncthing
- **Where:** `%LOCALAPPDATA%\Syncthing` — holds `config.xml`, the device certificate/keys (`cert.pem`/`key.pem`), and the index database; the synced folders are wherever the owner placed them. (Often run via a wrapper such as SyncTrayzor, which may add its own folder.)
- **Reveals:** This device's Syncthing ID, the IDs of every remote device it paired with, the names/paths of all shared folders, and the folders' contents — a detailed map of what was synced and the peers involved.
- **Remove (user runs):** In the Syncthing web UI (`127.0.0.1:8384`), remove each folder and remote device, then stop Syncthing; review and move anything to keep out of the synced folders. Uninstall the app/wrapper and delete the `%LOCALAPPDATA%\Syncthing` folder in File Explorer.
- **Survives:** Peer-to-peer, so copies remain on every paired device still holding the folders. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Keybase
- **Where:** `%LOCALAPPDATA%\Keybase` — the app config, local database, the encrypted KBFS cache, and logs; a service/mount may also expose a `K:` drive while running.
- **Reveals:** The signed-in Keybase account and linked identities (the username, and proofs linking it to Twitter/GitHub/Reddit/etc. — a strong real-identity map), cached chats and team names, and files stored in KBFS. Device keys live here as encrypted material (existence only).
- **Remove (user runs):** In Keybase, log out and (from another device or the account) remove/revoke this device; then uninstall from Settings > Apps > Installed apps and delete any remaining `%LOCALAPPDATA%\Keybase` folder in File Explorer.
- **Survives:** Chats, teams, and KBFS files remain on Keybase servers under the account and on other devices until removed there; identity proofs stay public until deleted. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Threema (desktop 2.0)
- **Where:** `%APPDATA%\ThreemaDesktop` (a `consumer-live-default` subfolder holds the data; `work-live-default` for Threema Work). A Microsoft Store build instead keeps it under `%LOCALAPPDATA%\Packages\` in a folder beginning `ThreemaDesktop`.
- **Reveals:** That a Threema ID was linked to this PC, the device/session, and a local copy of chats, contacts and media cached for the desktop client.
- **Remove (user runs):** On the **phone**, open Threema > remove/unlink this desktop device. On the PC, close Threema, then delete the contents of `%APPDATA%\ThreemaDesktop` (or the Store package's folder) in File Explorer, and uninstall from Settings > Apps.
- **Survives:** The authoritative chats live on the owner's phone (Threema is phone-primary); unlinking the desktop does not touch them. SSD remnants of the local cache persist until TRIM/overwrite.
- **Admin:** No.

### Session
- **Where:** `%APPDATA%\Session` — an Electron store modelled on Signal: an encrypted SQLite message database (`sql\db.sqlite` with the key in `config.json`), `attachments.noindex`, `Cache`, `IndexedDB`, and logs.
- **Reveals:** That a Session account (its Account ID / onion-routed identity) was used here, plus a local copy of conversations, attachments and contact/group names cached on this PC.
- **Remove (user runs):** In Session, Settings > **Clear Data** (and choose to delete the account/data if leaving the device), or uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Session` folder in File Explorer.
- **Survives:** Session stores little centrally; the account's recovery phrase (kept by the owner elsewhere) can restore it on another device. SSD remnants of the local database persist until TRIM/overwrite.
- **Admin:** No.

### Wire
- **Where:** `%APPDATA%\Wire` — Electron store holding the encrypted session, cached conversations and device keys in `IndexedDB`/`Local Storage`, plus `Cache` and logs.
- **Reveals:** The signed-in Wire account/email and team, cached conversation names and messages, and this device's end-to-end-encryption keys.
- **Remove (user runs):** In Wire, click the avatar > sign out (and remove this device from Settings > Devices, which can be done from another device too); uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Wire` folder in File Explorer.
- **Survives:** Messages remain on the Wire backend under the account/team and on other signed-in devices until each is removed. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Mattermost (desktop)
- **Where:** `%APPDATA%\Mattermost` — Electron store holding the list of servers signed into, the session, cached channels/messages in `IndexedDB`/`Local Storage`, `Cache`, and logs.
- **Reveals:** Which Mattermost servers (often an employer's self-hosted URL) and accounts the owner used, cached channel and DM content, and the team/organisation identities — the server URLs alone can reveal a workplace.
- **Remove (user runs):** In the app, sign out of each server and remove it from the server list; uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Mattermost` folder in File Explorer.
- **Survives:** Messages remain on each Mattermost server under the account (visible to that server's admins) and on other devices until the session is removed. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Rocket.Chat (desktop)
- **Where:** `%APPDATA%\Rocket.Chat` — Electron store holding the connected server list, session, cached messages in `IndexedDB`/`Local Storage`, `Cache`, and logs.
- **Reveals:** Which Rocket.Chat servers (often a self-hosted/employer URL) and accounts were used, cached channel and DM content, and the organisation identities exposed by the server addresses.
- **Remove (user runs):** In the app, sign out of each server and remove it from the list; uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Rocket.Chat` folder in File Explorer.
- **Survives:** Messages remain on each server under the account (visible to its admins) and on other devices until the session is cleared. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Guilded (desktop)
- **Where:** `%APPDATA%\Guilded` — Electron store holding the signed-in session, cached servers/DMs in `Local Storage`/`IndexedDB`, `Cache`, `Code Cache`, and logs.
- **Reveals:** The signed-in Guilded account, cached servers (teams/communities) and DMs, recently viewed channels, and settings; the `Local Storage` can retain a session token.
- **Remove (user runs):** In Guilded, log out (and review active sessions in account settings); uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Guilded` folder in File Explorer.
- **Survives:** Messages and servers remain on Guilded's servers under the account and on other logged-in devices until the session is removed there. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Multi-service messaging wrappers (Franz / Ferdium / Rambox)
- **Where:** `%APPDATA%\Franz`, `%APPDATA%\Ferdium`, and `%APPDATA%\Rambox` respectively — each an Electron shell that embeds many web services, with a per-service partition tree (`Partitions\` / service webviews) holding each service's cookies, `Local Storage`, `IndexedDB` and `Cache`, plus a `service` list and config.
- **Reveals:** The full list of services the owner added (Gmail, WhatsApp Web, Slack, Messenger, Telegram, work tools, etc.) — a broad map of their accounts in one place — plus the signed-in sessions and cached content for each embedded service.
- **Remove (user runs):** In the app, sign out of and delete each service, and sign out of the Franz/Ferdium/Rambox account itself; uninstall from Settings > Apps > Installed apps and delete the matching `%APPDATA%\Franz` / `%APPDATA%\Ferdium` / `%APPDATA%\Rambox` folder in File Explorer.
- **Survives:** Each embedded service still has its own server-side account and other sessions, untouched by clearing this wrapper; a Ferdium/Franz account can resync the service list. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Standard Notes
- **Where:** `%APPDATA%\Standard Notes` — Electron store holding the signed-in account, the locally cached (encrypted) notes database, and `Local Storage`/`IndexedDB`, plus logs. A local backups folder may also have been configured elsewhere by the owner.
- **Reveals:** The signed-in Standard Notes account/email and that notes exist locally. Standard Notes is end-to-end encrypted, so the cached notes/database are encrypted blobs (existence and count only — never read the contents or keys).
- **Remove (user runs):** In the app, sign out (which clears the local account data), then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Standard Notes` folder and any configured local-backup folder in File Explorer.
- **Survives:** All notes remain in the Standard Notes cloud under the account and on other signed-in devices until removed there. Any plaintext/encrypted export the owner saved elsewhere persists. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Simplenote
- **Where:** `%APPDATA%\Simplenote` — Electron store holding the signed-in account, cached notes in `IndexedDB`/`Local Storage`, and logs.
- **Reveals:** The signed-in Simplenote (Automattic/WordPress.com) account and a local cache of the owner's notes — and Simplenote notes are **not** end-to-end encrypted, so cached note text can be readable content.
- **Remove (user runs):** In Simplenote, sign out, then uninstall from Settings > Apps > Installed apps and delete any remaining `%APPDATA%\Simplenote` folder in File Explorer.
- **Survives:** All notes remain in the Simplenote cloud under the account and on other devices until deleted there. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Logseq
- **Where:** Graphs are stored as Markdown/org folders the owner chose (often under `%USERPROFILE%\Documents` or a cloud folder, with a `logseq\` subfolder and `config.edn`). App config and plugins live in `%USERPROFILE%\.logseq` (including `.logseq\graphs` cache); app data and logs (e.g. `logs\main.log`) are in `%APPDATA%\Logseq`.
- **Reveals:** The content of the owner's notes/journals (Logseq graphs are plaintext Markdown), the file paths of every graph opened, installed plugins, and — via the graph cache — fragments even of graphs no longer attached.
- **Remove (user runs):** In Logseq, note where each graph folder lives and move any to keep onto backup, then delete those graph folders; delete `%USERPROFILE%\.logseq` and `%APPDATA%\Logseq`. Uninstall from Settings > Apps > Installed apps.
- **Survives:** Graphs stored in a cloud-synced folder (OneDrive/Dropbox/Google Drive) keep a cloud copy; graphs synced with Logseq Sync have a server copy under the account. SSD remnants persist until TRIM/overwrite.
- **Admin:** No.

### Roam Research (desktop app)
- **Where:** Roam is a hosted web service; the desktop app is an Electron wrapper whose local cache/session sits in a Roam-named folder under `%APPDATA%` (e.g. `%APPDATA%\Roam Research` — confirm the exact folder on the machine). Any graph the owner exported or kept offline is a `.json`/Markdown/EDN file wherever they saved it.
- **Reveals:** The signed-in Roam account and cached graph (note) content held locally for the desktop client, plus any exported graph files on disk.
- **Remove (user runs):** In the app, sign out; uninstall from Settings > Apps > Installed apps and delete any remaining Roam-named folder under `%APPDATA%` in File Explorer; separately find and remove any exported graph files.
- **Survives:** Graphs live in Roam's cloud under the account and are reachable from any browser until deleted there. SSD remnants persist until TRIM/overwrite. (Exact desktop data-folder name is listed in uncertainties.)
- **Admin:** No.

### Microsoft To Do
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.Todos_8wekyb3d8bbwe` (MSIX package; `LocalState`/`LocalCache` hold the signed-in account and cached tasks/lists).
- **Reveals:** The Microsoft account signed in, and cached task lists and reminders — which can be highly personal (appointments, medications, shopping, plans, names) and include tasks flagged from Outlook/Planner.
- **Remove (user runs):** In Microsoft To Do, sign out, then Settings > Apps > Installed apps > Microsoft To Do > Advanced options > **Reset**, or Uninstall.
- **Survives:** Tasks and lists live in the Microsoft 365 / Exchange Online cloud under the account and sync to phone, web and Outlook until deleted there. SSD remnants of the local cache persist until TRIM/overwrite.
- **Admin:** No.

### Microsoft Journal / legacy Windows Journal
- **Where:** The modern **Microsoft Journal** (Garage) app is an MSIX package under `%LOCALAPPDATA%\Packages\` beginning `Microsoft.Journal` (confirm the exact folder); its notebooks default to `%USERPROFILE%\Documents\Journals` and are often synced to OneDrive. The **legacy Windows Journal** (removed as a Windows feature years ago) left handwritten-note files as `.jnt`/`.jtp` anywhere under `%USERPROFILE%\Documents` or the Desktop.
- **Reveals:** Handwritten and typed notes, sketches and ink — which can include signatures, account numbers jotted down, meeting notes and personal planning; file and notebook names add further hints.
- **Remove (user runs):** In Microsoft Journal, move any notebooks to keep onto backup, then delete them; Settings > Apps > Installed apps > Microsoft Journal > **Reset** or Uninstall. Separately search `%USERPROFILE%\Documents` for the `Journals` folder and for any `.jnt`/`.jtp` files and delete them in File Explorer.
- **Survives:** Journals stored in or synced to OneDrive keep a cloud copy under the Microsoft account until removed there. SSD remnants persist until TRIM/overwrite. (Exact Journal package family name is listed in uncertainties.)
- **Admin:** No.

---

## Media, capture, conferencing & Windows built-ins

### Kodi user data (watch history, sources, add-on logins)
- **Where:** `%APPDATA%\Kodi\userdata` — the `Database` subfolder (`MyVideos*.db`, `MyMusic*.db`) holds watch history and resume points, `sources.xml` lists configured media sources (local folders and network shares, whose paths can embed share credentials), `passwords.xml` stores source logins, and `addon_data\` holds per-add-on sign-ins and tokens for streaming services.
- **Reveals:** What you watched and listened to and how far through, the names and locations of your media (including network shares and any credentials written into their paths), and which streaming add-ons you were signed into.
- **Remove (user runs):** In Kodi, sign out of each add-on, then Settings > Media > Library > Clean/Reset, or close Kodi and delete the `%APPDATA%\Kodi\userdata` folder in File Explorer to reset the profile.
- **Survives:** Accounts on the streaming services themselves are untouched; any library/settings you backed up elsewhere remain; SSD remnants until overwritten.
- **Admin:** no

### PotPlayer settings and recently played list
- **Where:** `HKCU:\Software\DAUM\PotPlayer64` (64-bit build) or `HKCU:\Software\DAUM\PotPlayer` (32-bit). Playlists and bookmark (`.pbf`) files may also sit in the PotPlayer install folder or under `%APPDATA%\PotPlayer`.
- **Reveals:** Recently opened files and URLs, saved playback positions, and bookmarks — exposing the names and locations of videos you watched even after the files are gone.
- **Remove (user runs):** In PotPlayer, clear the recent list from the open/file navigator, and turn off remembering recent files/playback positions in Preferences > Playback. To wipe settings you can delete the key yourself, e.g. `reg delete "HKCU\Software\DAUM\PotPlayer64" /f`.
- **Survives:** Nothing cloud-side (PotPlayer is local); the media files are separate; SSD remnants until overwritten.
- **Admin:** no

### foobar2000 playlists, history and configuration
- **Where:** `%APPDATA%\foobar2000-v2` (version 2.x) or `%APPDATA%\foobar2000` (version 1.x) — holds saved and autosaved playlists, playback-statistics/most-played data, and configuration. (Portable installs keep this beside the executable instead.)
- **Reveals:** The names and full paths of tracks in your playlists and library, play counts and recently played items.
- **Remove (user runs):** In foobar2000, clear playlists and (if the Playback Statistics component is installed) reset its data, then delete the `%APPDATA%\foobar2000-v2` folder to wipe the profile.
- **Survives:** The audio files themselves are separate; SSD remnants until overwritten.
- **Admin:** no

### MusicBee library and recently played
- **Where:** `%APPDATA%\MusicBee` — the library database (`MusicBeeLibrary.mbl`), settings, playlists, and recently-played / most-played history. (A portable install stores these in its own folder.)
- **Reveals:** A catalogue of your music files (names and paths), ratings, play counts, and listening history.
- **Remove (user runs):** In MusicBee, Edit > Preferences > Library to remove/clear it, then delete the `%APPDATA%\MusicBee` folder. Sign out of any last.fm/scrobbling or cloud account linked in Preferences.
- **Survives:** Scrobbling history already sent to last.fm (or similar) stays in that online account; the audio files are separate.
- **Admin:** no

### AIMP playlists, bookmarks and configuration
- **Where:** `%APPDATA%\AIMP` — playlists (`*.aimppl4`), bookmarks, configuration, and recently played state. (Portable installs keep this beside the executable.)
- **Reveals:** Names and paths of tracks you played and queued, and recently opened items.
- **Remove (user runs):** In AIMP, clear playlists and the recent list, then delete the `%APPDATA%\AIMP` folder to reset.
- **Survives:** The audio files are separate; SSD remnants until overwritten.
- **Admin:** no

### Winamp settings, play history and current playlist
- **Where:** `%APPDATA%\Winamp` — settings, the current playlist (`winamp.m3u8`), bookmarks, and, when the History plug-in is active, `recent.dat` / `recent.idx` listing recently played items; the media-library database lives in the `Plugins\ml` subfolder. (Older or portable installs may keep these in the Winamp program folder.)
- **Reveals:** Recently and most-played tracks, the names/paths of files in your library and playlists.
- **Remove (user runs):** In Winamp, clear the playlist and the library/history, then delete the `%APPDATA%\Winamp` folder to reset.
- **Survives:** The audio files are separate; SSD remnants until overwritten.
- **Admin:** no

### qBittorrent torrent list and resume data
- **Where:** `%LOCALAPPDATA%\qBittorrent\BT_backup` (a `.torrent` and `.fastresume` file for every torrent, holding its name, trackers and save path) and `%APPDATA%\qBittorrent` (`qBittorrent.ini`, `qBittorrent-data.ini` — settings, the last save path, and any configured search/RSS).
- **Reveals:** The name of everything you downloaded or seeded, where on disk it was saved, and the trackers/sources used — a detailed record of torrented content even after the files are deleted.
- **Remove (user runs):** In qBittorrent, select all torrents > Delete (you can choose to also delete the downloaded data), then close qBittorrent and delete the `BT_backup` folder and the `%APPDATA%\qBittorrent` folder.
- **Survives:** The downloaded media files (if you kept them) are separate; your IP's activity recorded by trackers/peers is outside the PC; SSD remnants until overwritten.
- **Admin:** no

### uTorrent / BitTorrent resume and settings
- **Where:** `%APPDATA%\uTorrent` and/or `%APPDATA%\BitTorrent` — `resume.dat` (every torrent with its save path and up/download totals), `settings.dat`, `dht.dat`, and copies of added `.torrent` files.
- **Reveals:** The full list of torrents you added, their save locations and transfer statistics — exposing downloaded content by name even after removal.
- **Remove (user runs):** In the client, select all torrents > Remove And Delete, then close it and delete the `%APPDATA%\uTorrent` / `%APPDATA%\BitTorrent` folder.
- **Survives:** Kept media files are separate; tracker/peer records of your IP are outside the PC; SSD remnants until overwritten.
- **Admin:** no

### Internet Download Manager (IDM) download list
- **Where:** `HKCU:\Software\DownloadManager` — the stored download history/list (file names and source URLs), categories, and settings.
- **Reveals:** The names and originating URLs of files you downloaded, including sites visited — exposing download activity even after the files are gone.
- **Remove (user runs):** In IDM, delete entries from the main window (right-click > Delete, or "Delete All Completed"). To wipe the stored list you can delete the key yourself, e.g. `reg delete "HKCU\Software\DownloadManager" /f` (this also clears IDM's registration/settings).
- **Survives:** The downloaded files are separate; the download servers' own logs are outside the PC; SSD remnants until overwritten.
- **Admin:** no

### JDownloader link and download lists
- **Where:** The `cfg` subfolder of the JDownloader install directory — commonly `%LOCALAPPDATA%\JDownloader 2.0\cfg`, but the install location is chosen at setup and varies. It holds `downloadList*.zip` (queued/finished downloads) and `linkcollector*.zip` (grabbed links), plus configured hoster-account data.
- **Reveals:** The URLs and file names of everything you grabbed and downloaded, and which file-hoster accounts were configured.
- **Remove (user runs):** In JDownloader, clear the LinkGrabber and Downloads tabs and remove configured accounts under Settings > Account Manager, then delete the `downloadList*.zip` / `linkcollector*.zip` files from the `cfg` folder.
- **Survives:** The downloaded files are separate; hoster accounts remain on their servers; SSD remnants until overwritten.
- **Admin:** no

### OBS Studio profiles, scenes and recordings
- **Where:** `%APPDATA%\obs-studio` — `basic\scenes\*.json` (scene collections) and `basic\profiles\*\service.json`. Recordings default to `%USERPROFILE%\Videos` (the output path is user-set).
- **Reveals:** That you streamed/recorded and to which platform, plus scene and source details — captured window and monitor names, media-source file paths, and browser-source URLs. The profile also stores the streaming service's credential (stream key); treat the folder as sensitive and do not share it (its existence is enough — there is no need to open it).
- **Remove (user runs):** Delete your recordings from the output folder, and to clear configuration close OBS and delete the `%APPDATA%\obs-studio` folder. Sign out of any linked accounts in Settings > Stream.
- **Survives:** Anything you already streamed or uploaded stays in your account on the platform (Twitch, YouTube, etc.); SSD remnants until overwritten.
- **Admin:** no

### NVIDIA GeForce Experience / ShadowPlay recordings and gallery
- **Where:** Config and signed-in NVIDIA account under `%LOCALAPPDATA%\NVIDIA Corporation\GeForceExperience` (and the newer NVIDIA App). Recordings, Instant Replay clips, Highlights and screenshots save by default to per-game subfolders under `%USERPROFILE%\Videos`.
- **Reveals:** Gameplay and desktop captures (which can show anything that was on screen), and the NVIDIA/GeForce account you signed in with.
- **Remove (user runs):** Delete clips and screenshots from the in-overlay Gallery or the `%USERPROFILE%\Videos` subfolders, and sign out of GeForce Experience / the NVIDIA App.
- **Survives:** Clips you shared or uploaded remain online where posted; SSD remnants until overwritten.
- **Admin:** no

### Camtasia projects, recordings and recent list
- **Where:** `%USERPROFILE%\Documents\Camtasia` (project files `*.tscproj`, raw recordings `*.trec`, and produced videos), with recent-project entries and preferences under `HKCU:\Software\TechSmith\Camtasia Studio` and `%APPDATA%\TechSmith`.
- **Reveals:** Screen recordings and their content, project names, and the paths of recently edited projects.
- **Remove (user runs):** Delete the recordings/projects from `Documents\Camtasia`, clear the recent list from Camtasia's File menu, and sign out of your TechSmith account in the app.
- **Survives:** Videos you exported and uploaded elsewhere remain there; SSD remnants until overwritten.
- **Admin:** no

### Bandicam captured videos and settings
- **Where:** `%USERPROFILE%\Documents\Bandicam` (captured videos and images, by default) and settings under `HKCU:\Software\Bandicam`.
- **Reveals:** Screen/gameplay recordings and screenshots — whatever was on screen when you captured.
- **Remove (user runs):** Delete the files in `Documents\Bandicam`, and reset Bandicam's settings from within the app (or delete the `HKCU:\Software\Bandicam` key yourself).
- **Survives:** Anything you uploaded or shared remains where posted; SSD remnants until overwritten.
- **Admin:** no

### ShareX history and screenshots
- **Where:** `%USERPROFILE%\Documents\ShareX` — `History.json` and `History-backup` (a log of every capture and upload: timestamps, local file paths, and the public URLs of uploaded images), the `Screenshots` subfolder (the capture files), and `ApplicationConfig.json` (configured upload destinations/accounts).
- **Reveals:** A complete record of what you screenshotted/recorded and where any uploads were posted (live URLs), plus which image hosts/cloud destinations you connected.
- **Remove (user runs):** In ShareX, open the History window and delete entries, clear the `Screenshots` folder, and remove destinations under Destinations settings; to wipe everything, delete the `%USERPROFILE%\Documents\ShareX` folder.
- **Survives:** Images already uploaded stay live at their URLs on the image host/cloud until you delete them there; SSD remnants until overwritten.
- **Admin:** no

### Cisco Webex App and Webex Meetings data
- **Where:** Webex App (messaging/meetings): `%LOCALAPPDATA%\CiscoSpark` (cached content and local databases, including call history; older installs may name it `Cisco Spark` or `Cisco-Systems.Spark`). Webex Meetings client cache: `%LOCALAPPDATA%\WebEx` (e.g. `wbxcache`).
- **Reveals:** The signed-in Webex identity, call/meeting history, cached messages and shared content, and locally stored meeting data.
- **Remove (user runs):** Sign out of the Webex App, then use Help > Health Checker > Reset, or close the app and delete the contents of the `%LOCALAPPDATA%\CiscoSpark` folder; clear the Meetings cache by deleting the `%LOCALAPPDATA%\WebEx` contents.
- **Survives:** Messages, recordings and meeting history on the Webex cloud / your organization's site remain until removed there; SSD remnants until overwritten.
- **Admin:** no

### GoTo / GoToMeeting recordings and app data
- **Where:** Local recordings save by default to `%USERPROFILE%\Documents` (`.webm` in the current GoTo app; older GoToMeeting used `.g2m`), and the output folder is user-set. App data and logs sit under `%LOCALAPPDATA%\GoToMeeting` or `%LOCALAPPDATA%\GoTo` (the folder name varies by app version).
- **Reveals:** Recorded meetings and their content, and the signed-in GoTo account.
- **Remove (user runs):** Sign out of the app, then delete recordings from your `Documents` folder (or wherever you set the output path).
- **Survives:** Recordings stored in the cloud on your GoTo account remain until deleted there; SSD remnants until overwritten.
- **Admin:** no

### Snipping Tool / Snip & Sketch captures
- **Where:** App data under `%LOCALAPPDATA%\Packages\Microsoft.ScreenSketch_8wekyb3d8bbwe` (recent-snip and temp state). When auto-save is on, snips are written to `%USERPROFILE%\Pictures\Screenshots`.
- **Reveals:** Recent screenshots, which can contain anything that was on screen — documents, messages, account pages, personal photos.
- **Remove (user runs):** Delete the images in `%USERPROFILE%\Pictures\Screenshots`, and reset the app via Settings > Apps > Installed apps > Snipping Tool > Advanced options > Reset. (A snip you took but never saved can also still be on the clipboard — copy something harmless to replace it.)
- **Survives:** Copies you pasted into documents/chats are separate; SSD remnants until overwritten.
- **Admin:** no

### Photos app cache and viewing index
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.Windows.Photos_8wekyb3d8bbwe\LocalState` — thumbnail/image caches and an index of folders and photos the app has shown.
- **Reveals:** Thumbnails of images you viewed and a record of which photos/folders you browsed, even if the originals were moved or deleted.
- **Remove (user runs):** Reset the app via Settings > Apps > Installed apps > Photos > Advanced options > Reset.
- **Survives:** The original photos are separate; OneDrive-synced photos remain in the cloud; SSD remnants until overwritten.
- **Admin:** no

### Sound Recorder / Voice Recorder files
- **Where:** `%USERPROFILE%\Documents\Sound recordings` (current Sound Recorder app; older Voice Recorder used `Documents\Sound Recordings`), with app state under `%LOCALAPPDATA%\Packages\Microsoft.WindowsSoundRecorder_8wekyb3d8bbwe`.
- **Reveals:** Voice recordings — memos, meetings, calls — in your own voice, and whatever was said.
- **Remove (user runs):** Delete the clips in `Documents\Sound recordings` (or inside the app), and reset the app via Settings > Apps > Installed apps > Sound Recorder > Advanced options > Reset.
- **Survives:** Copies you exported or shared are separate; SSD remnants until overwritten.
- **Admin:** no

### Maps app search history and offline maps
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsMaps_8wekyb3d8bbwe\LocalState` (search history, pinned/favorite places, and downloaded offline-map regions).
- **Reveals:** Places you searched for and pinned — often home and work addresses — and which regions you downloaded, indicating where you live and travel.
- **Remove (user runs):** In Maps, Settings > clear search history and delete downloaded offline maps; then reset the app via Settings > Apps > Installed apps > Maps > Advanced options > Reset.
- **Survives:** If you were signed in, search history and favorites synced to your Microsoft account remain in the cloud until cleared there; SSD remnants until overwritten.
- **Admin:** no

### Scanned documents
- **Where:** Windows Fax and Scan saves to `%USERPROFILE%\Documents\Scanned Documents` by default. The modern Windows Scan app saves to a folder you choose (commonly `%USERPROFILE%\Pictures\Scans`).
- **Reveals:** Scanned personal paperwork — IDs, forms, letters, bank and tax documents.
- **Remove (user runs):** Delete the files in `Documents\Scanned Documents` (and in whatever folder the Scan app is set to use — check the app's "Save file to" path).
- **Survives:** Any copies you emailed or filed elsewhere remain; SSD remnants until overwritten.
- **Admin:** no

### Account picture
- **Where:** `%APPDATA%\Microsoft\Windows\AccountPictures` (the images you set as your account/user photo).
- **Reveals:** Your face or a personal photo used as the account picture.
- **Remove (user runs):** Settings > Accounts > Your info > choose a neutral/default picture, then delete the old images from the `AccountPictures` folder.
- **Survives:** If this is a Microsoft account, the profile picture is also stored in your account in the cloud and shows on other devices until changed there; SSD remnants until overwritten.
- **Admin:** no

### Themes and wallpaper cache
- **Where:** `%APPDATA%\Microsoft\Windows\Themes` — `TranscodedWallpaper` (a copy of your current desktop wallpaper), the `CachedFiles` subfolder (cached wallpaper images), and any saved custom `.theme` files. A short history of recent wallpapers is kept in `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers`.
- **Reveals:** Your desktop/lock-screen wallpaper — often a personal photo — and the file paths of recent wallpapers (and of a slideshow folder, if used).
- **Remove (user runs):** Set the wallpaper back to a stock Windows image (Settings > Personalization > Background), then delete the files in the `Themes` folder and `CachedFiles`. You can clear the recent list by deleting the `...\Explorer\Wallpapers` key yourself.
- **Survives:** If theme/wallpaper sync is on, it roams to your Microsoft account; the original photo files are separate; SSD remnants until overwritten.
- **Admin:** no

### LibreOffice recent documents and user profile
- **Where:** `%APPDATA%\LibreOffice\4\user\registrymodifications.xcu` holds the recent-documents (MRU) list and most settings; the `%APPDATA%\LibreOffice\4\user` profile also contains `backup\` and autorecovery data and your entered user name/initials.
- **Reveals:** Names and full paths of recently opened documents, and personal details set in Tools > Options > User Data.
- **Remove (user runs):** In LibreOffice, File > Recent Documents > Clear List, and clear the name under Tools > Options > User Data. To wipe fully, close LibreOffice and delete the `%APPDATA%\LibreOffice` folder (this resets the profile).
- **Survives:** The documents themselves are separate; SSD remnants until overwritten.
- **Admin:** no

### Apache OpenOffice recent documents and user profile
- **Where:** `%APPDATA%\OpenOffice\4\user\registrymodifications.xcu` (recent-documents list and settings), within the `%APPDATA%\OpenOffice\4\user` profile.
- **Reveals:** Names and full paths of recently opened documents, and user data set in Tools > Options.
- **Remove (user runs):** In OpenOffice, clear the recent list (File > Recent Documents), then close it and delete the `%APPDATA%\OpenOffice` folder to reset the profile.
- **Survives:** The documents themselves are separate; SSD remnants until overwritten.
- **Admin:** no

### WPS Office recent files and account
- **Where:** `%APPDATA%\Kingsoft\Office6` (user configuration, including the recent-documents history), with settings also under `HKCU:\Software\Kingsoft\Office`.
- **Reveals:** Names and paths of recently opened documents, and the WPS/cloud account you were signed into.
- **Remove (user runs):** In WPS Office, clear the recent-files list and sign out of your WPS account, then delete the `%APPDATA%\Kingsoft` folder to reset.
- **Survives:** Files stored in WPS Cloud remain online in your account until removed there; SSD remnants until overwritten.
- **Admin:** no

### Foxit (Reader / PDF Editor) recent files
- **Where:** `HKCU:\Software\Foxit Software\Foxit Reader\...\Recent File List` (Foxit PDF Reader) or the matching key under `Foxit PDF Editor` / `PhantomPDF`; preferences also under `%APPDATA%\Foxit Software`. (The product and version segment of the key varies by build.)
- **Reveals:** Names and full paths of recently opened PDFs — contracts, statements, scans — even after the files are deleted.
- **Remove (user runs):** In Foxit, File > Open > clear the recent list, and set the recent-files count to 0 in Preferences > History. To wipe the stored list you can delete the key yourself, e.g. `reg delete "HKCU\Software\Foxit Software\Foxit Reader" /f`.
- **Survives:** Files in Foxit's connected cloud/eSign account (if used) remain online; the PDFs themselves are separate; SSD remnants until overwritten.
- **Admin:** no

### SumatraPDF reading history
- **Where:** `%LOCALAPPDATA%\SumatraPDF\SumatraPDF-settings.txt` (installed version) or a `SumatraPDF-settings.txt` beside the executable (portable). Its `FileStates` section lists every document opened, with full path and last reading position.
- **Reveals:** A complete history of the PDFs, eBooks and comics you read, by path, with how far you got.
- **Remove (user runs):** In SumatraPDF, Settings > Options, untick "Remember opened files" and clear the Frequently Read list; to wipe fully, close it and delete `SumatraPDF-settings.txt`.
- **Survives:** The documents themselves are separate; SSD remnants until overwritten.
- **Admin:** no

### Ditto clipboard history database
- **Where:** `%APPDATA%\Ditto` — `Ditto.db`, a database of the clipboard history Ditto has captured (text, images and copied files).
- **Reveals:** Everything the previous user copied over time, which can include messages, addresses, account details and anything else that passed through the clipboard. (Its existence and item count are enough to flag it — there is no need to read the stored values.)
- **Remove (user runs):** In Ditto, right-click the tray icon and clear all clips (and turn off saving), then close Ditto and delete `%APPDATA%\Ditto\Ditto.db`.
- **Survives:** If Ditto network sync was enabled, copies on synced PCs remain; SSD remnants until overwritten.
- **Admin:** no

---

## Finance, crypto wallets & authenticators

### TurboTax desktop tax return files
- **Where:** `%USERPROFILE%\Documents\TurboTax\` holds the return data files, one per tax year, named with a year-coded extension: `.tax2021`, `.tax2022`, `.tax2023`, `.tax2024`, and so on. TurboTax usually also saves a printable PDF copy of each return in the same folder. Program state may also sit under `%PROGRAMDATA%\Intuit\TurboTax` and `%LOCALAPPDATA%\Intuit`.
- **Reveals:** Among the most sensitive files on the machine. A single `.taxYYYY` file contains full legal name, Social Security Number (plus spouse and dependents' SSNs), home address, employer and wage data, bank account and routing numbers used for refunds or payments, investment and brokerage income, and the complete financial picture for that year.
- **Remove (user runs):** In File Explorer open `%USERPROFILE%\Documents\TurboTax`, select the `.taxYYYY` files and any saved PDF copies, delete them, then empty the Recycle Bin. Uninstall the program via Settings > Apps > Installed apps if it is still present. The data files are what matter — the program holds no return data once they are gone.
- **Survives:** Deletion leaves recoverable remnants on an SSD or HDD until that free space is overwritten (a full reset with the "remove everything / clean data" option, or full-disk encryption applied before handover, is the real protection). If your Documents folder is synced by OneDrive (Known Folder Move), a cloud copy and version history persist until you also clear OneDrive's own Recycle Bin. Copies may also live in File History, a system image, or any backup drive, and in PDF copies you emailed or printed. TurboTax Online returns remain on Intuit's servers regardless of this machine.
- **Admin:** No.

### H&R Block desktop tax return files
- **Where:** `%USERPROFILE%\Documents\HRBlock\` by default, with returns named by tax year using a `.TYY` extension — `.T21`, `.T22`, `.T23`, `.T24`. Saved PDF copies commonly sit alongside them.
- **Reveals:** The same class of exposure as TurboTax: SSNs for filer, spouse and dependents, address, income, employer, bank account and routing numbers, and complete tax detail for the year.
- **Remove (user runs):** Open `%USERPROFILE%\Documents\HRBlock` in File Explorer, delete the `.TYY` files and any PDF copies, and empty the Recycle Bin. Uninstall the desktop program via Settings > Apps > Installed apps.
- **Survives:** Same remnant, cloud and backup caveats as above — SSD free space until overwritten, OneDrive copies if Documents is synced, File History or system images, backup drives, and any H&R Block Online account held on the company's servers.
- **Admin:** No.

### TaxAct desktop return files
- **Where:** TaxAct Desktop saves each year's returns in a year-named subfolder of your Documents folder — `%USERPROFILE%\Documents\TaxAct2023\`, `%USERPROFILE%\Documents\TaxAct2024\`, and so on. Individual 1040 returns use a three-character extension whose last character is the year's final digit (for example `.ta4` for 2024, `.ta3` for 2023); backup copies use a matching `.baX` extension.
- **Reveals:** Full tax detail — SSNs, address, income, employer, and bank account numbers — the same highly sensitive content as any desktop tax return.
- **Remove (user runs):** In File Explorer delete the `TaxAct<year>` folders under `%USERPROFILE%\Documents` (or search Documents for `*.ta*` and `*.ba*` files), then empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** SSD remnants until overwritten; OneDrive copies if Documents is synced; File History and backups; any TaxAct Online return held on the company's servers.
- **Admin:** No.

### Quicken data file (.QDF)
- **Where:** `%USERPROFILE%\Documents\Quicken\` holds the Quicken data file (extension `.QDF`) plus `.QDF-backup` copies. Quicken also keeps a recently-opened-files list in `QUSER.INI` under your profile's `%APPDATA%`/`%LOCALAPPDATA%`, so even a relocated data file leaves a path breadcrumb.
- **Reveals:** Linked bank, credit-card and investment account names and numbers, balances, full transaction history, payees, and often the online-banking login identifiers used to download transactions — a detailed map of the previous owner's finances.
- **Remove (user runs):** Close Quicken, then in File Explorer delete the `.QDF` and `.QDF-backup` files under `%USERPROFILE%\Documents\Quicken` and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps. If you used Quicken's cloud/mobile sync, also sign in to your Quicken account and remove the dataset from the cloud and from the Quicken Mobile/Web app.
- **Survives:** The `QUSER.INI` recent-file list and SSD remnants until overwritten; OneDrive copies if Documents is synced; any Quicken Cloud / Mobile & Web copy on Quicken's servers; backup drives.
- **Admin:** No.

### QuickBooks company file (.QBW)
- **Where:** QuickBooks Desktop stores company files by default in `%PUBLIC%\Documents\Intuit\QuickBooks\Company Files\` (that is, `C:\Users\Public\Public Documents\...`). The main file is `.QBW`; alongside it sit `.QBB` backups, `.QBM` portable copies, `.TLG` transaction logs, and `.ND`/`.DSN` network-config files.
- **Reveals:** A business's full books — customer and vendor names and contacts, employee records (often including SSNs and pay), bank and credit-card account numbers, invoices, payroll, and tax identifiers such as the EIN.
- **Remove (user runs):** Close QuickBooks, then in File Explorer delete the company-file set (`.QBW`, `.QBB`, `.QBM`, `.TLG`, `.ND`, `.DSN`) from `%PUBLIC%\Documents\Intuit\QuickBooks\Company Files` and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** SSD remnants until overwritten; backup drives and any off-site or accountant copies; if you used QuickBooks Online, the books live on Intuit's servers independently of this PC.
- **Admin:** No. (Uninstalling a machine-wide QuickBooks install may raise a UAC prompt, but deleting the files does not.)

### YNAB 4 budget file (legacy desktop)
- **Where:** The old desktop YNAB 4 (discontinued; unsupported since 2019) stores each budget as a folder bundle ending in `.ynab4`, named like `My Budget~XXXXXXXX.ynab4`, containing a `Budget.yfull` data file. There is no fixed install path — it sits wherever you first saved it, most often under `%USERPROFILE%\Documents` or inside a synced Dropbox folder (`...\Dropbox\YNAB\`). The current subscription YNAB is web-only and leaves browser traces instead (see the browsers section).
- **Reveals:** Account names and balances, full categorized transaction history, payees, and your budgeting detail — a clear view of income and spending.
- **Remove (user runs):** In File Explorer search `%USERPROFILE%` (and your Dropbox folder) for `*.ynab4`, delete the matching folders, and empty the Recycle Bin.
- **Survives:** If the budget was Dropbox-synced, a copy remains in Dropbox (and its deleted-files history) until you remove it there; SSD remnants until overwritten; backup drives.
- **Admin:** No.

### GnuCash data files and history
- **Where:** GnuCash data files use the `.gnucash` extension and live wherever you saved them (commonly `%USERPROFILE%\Documents`), usually accompanied by `.log` and `.LCK` working files and timestamped `.YYYYMMDDHHMMSS.gnucash` auto-backups. Settings and the recently-opened-file list sit under `%LOCALAPPDATA%\GnuCash\` (older installs used `%USERPROFILE%\.gnucash`).
- **Reveals:** Account names and numbers, balances, transactions, payees and invoices for whoever kept the books.
- **Remove (user runs):** In File Explorer delete the `.gnucash` file plus its `.log`, `.LCK` and `.*.gnucash` backups, then empty the Recycle Bin. To clear the recent-file history, delete the contents of `%LOCALAPPDATA%\GnuCash`. Uninstall via Settings > Apps > Installed apps.
- **Survives:** The recent-file list under `%LOCALAPPDATA%\GnuCash` if left in place; SSD remnants until overwritten; OneDrive copies if Documents is synced; backup drives.
- **Admin:** No.

### Mint / Monarch and web-based budgeting services
- **Where:** These are online services, not desktop programs (Intuit Mint shut down in 2024; Monarch Money runs on the web and mobile), so there is no local data file to find. Their traces on a Windows PC are browser artifacts: saved logins and cookies, cached pages, and autofill entries in Chrome/Edge/Firefox profiles (for example `%LOCALAPPDATA%\Google\Chrome\User Data\Default\` and `%APPDATA%\Mozilla\Firefox\Profiles\`).
- **Reveals:** A stored session or saved password can let the next user open your full budget — every linked bank, card and loan, balances and transaction history — because the data itself lives on the service's servers.
- **Remove (user runs):** In each browser, sign out of the service and clear its saved password, cookies and site data; remove any saved credential from the browser's password manager. Crucially, before handover sign in to the service itself, disconnect every linked bank or financial institution, and then close or delete the account — clearing the browser alone does not touch the data or the bank connections held on the server.
- **Survives:** The account and all linked-institution connections remain on the provider's servers until you disconnect them and close the account; browser data synced to your Google/Microsoft/Firefox account reappears on other devices and can be restored; SSD remnants until overwritten.
- **Admin:** No.

### Exodus desktop wallet
- **Where:** `%APPDATA%\Exodus\`, with the wallet material under `%APPDATA%\Exodus\exodus.wallet\` (encrypted seed and key files) and settings in `exodus.conf.json`. The installed program sits under `%LOCALAPPDATA%\exodus` / `%LOCALAPPDATA%\Programs\exodus`.
- **Reveals:** That the previous owner held cryptocurrency in Exodus, which assets, receiving addresses, and transaction history — and the encrypted wallet seed itself, whose protection depends entirely on the strength of the password that encrypts it.
- **Remove (user runs):** First, if the wallet holds funds and you have not already, move the coins to a new wallet whose seed has never touched this machine. Then open the app and sign out / remove the wallet, uninstall via Settings > Apps > Installed apps, and in File Explorer delete the leftover `%APPDATA%\Exodus` folder (uninstalling does not remove it) and empty the Recycle Bin.
- **Survives:** On-chain balances and transaction history are public and permanent regardless of local deletion. The encrypted wallet folder leaves SSD remnants until the free space is overwritten, so a deleted-but-recoverable seed file remains a risk on the physical drive until a full reset or overwrite — which is why moving funds to a fresh seed before handover matters. Backup drives or any seed you exported elsewhere also persist.
- **Admin:** No.

### Electrum wallet files
- **Where:** `%APPDATA%\Electrum\wallets\` (the default file is named `default_wallet`), plus `%APPDATA%\Electrum\config` for settings and recent servers; testnet data under `%APPDATA%\Electrum\testnet`.
- **Reveals:** Bitcoin addresses, balances and full transaction history, and wallet labels — and, critically, Electrum does not force encryption, so an unprotected wallet file can expose the seed phrase and private keys directly.
- **Remove (user runs):** If funds remain and the wallet is yours to empty, move them to a new wallet with a fresh seed first. Then in File Explorer delete the files under `%APPDATA%\Electrum\wallets` (and the rest of `%APPDATA%\Electrum`), and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** On-chain history is permanent and public. An unencrypted wallet file is especially dangerous as an SSD remnant until the free space is overwritten; backup copies and any exported seed persist elsewhere.
- **Admin:** No.

### Ledger Live
- **Where:** `%APPDATA%\Ledger Live\` (app data such as `app.json`); the program under `%LOCALAPPDATA%\Programs\ledger-live-desktop`.
- **Reveals:** Ledger Live is the companion app for a Ledger hardware wallet, so it does not store your seed or private keys — those stay on the hardware device. It does store your account list and labels, extended public keys (xpub), receiving addresses, portfolio value and transaction history, which disclose what crypto you hold and how much.
- **Remove (user runs):** In Ledger Live use Settings to clear the app cache / remove accounts, then uninstall via Settings > Apps > Installed apps and in File Explorer delete the leftover `%APPDATA%\Ledger Live` folder and empty the Recycle Bin. If you turned on Ledger Live Cloud sync, also disable it and delete the synced data from your account.
- **Survives:** On-chain data is permanent and public. Account metadata synced via Ledger Live Cloud sync persists on Ledger's servers and on your other devices until removed. Your actual funds are unaffected (they are controlled by the hardware device's seed, not this PC). SSD remnants until overwritten.
- **Admin:** No.

### Atomic Wallet
- **Where:** `%APPDATA%\atomic\` holds the locally stored wallet data, including encrypted backup-phrase and key files; the program installs under `%LOCALAPPDATA%\Programs\atomic`.
- **Reveals:** That the previous owner held crypto in Atomic, which assets and addresses, transaction history, and the encrypted seed/key material (protected only by the wallet password).
- **Remove (user runs):** Move any remaining funds to a new wallet with a fresh seed first. Then, following Atomic's own uninstall guidance, uninstall the app via Settings > Apps > Installed apps, type `%appdata%` into the File Explorer address bar, delete the `atomic` folder, and empty the Recycle Bin.
- **Survives:** On-chain history is permanent and public. The encrypted key files leave SSD remnants until overwritten, so moving funds to a fresh seed before handover is the real safeguard; exported backups persist elsewhere.
- **Admin:** No.

### Wasabi Wallet
- **Where:** `%APPDATA%\WalletWasabi\` (in current 2.x builds the client data, including wallet files, sits under `%APPDATA%\WalletWasabi\Client\`, with wallets stored as `.json` files in a `Wallets` subfolder).
- **Reveals:** That the owner used Wasabi, a privacy-focused Bitcoin wallet — wallet names and labels, addresses, balances and coinjoin activity. Wasabi wallet files are password-encrypted, but their presence alone discloses Bitcoin holdings.
- **Remove (user runs):** Move any funds to a new wallet with a fresh seed first if the wallet is still in use. Then in File Explorer delete the `%APPDATA%\WalletWasabi` folder and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** On-chain history is permanent and public. Encrypted wallet files leave SSD remnants until overwritten; any exported seed or backup persists elsewhere.
- **Admin:** No.

### Authy Desktop authenticator vault
- **Where:** `%APPDATA%\Authy Desktop\` (the installed program sits under `%LOCALAPPDATA%\Programs\authy` / `%LOCALAPPDATA%\authy`). Note that Twilio ended Authy's desktop apps for Windows, macOS and Linux in 2024 (end-of-life March 19, 2024, with a forced sign-out around August 2024), so you may be left with a stale but still data-bearing folder.
- **Reveals:** Your two-factor vault — the list of services you protect with TOTP (issuer/account names such as your bank, email or crypto exchange) and the encrypted TOTP seeds for them. The account list alone maps which high-value accounts you hold.
- **Remove (user runs):** In the app (if it still opens) sign out, then uninstall via Settings > Apps > Installed apps and in File Explorer delete the leftover `%APPDATA%\Authy Desktop` folder and empty the Recycle Bin.
- **Survives:** Authy is cloud-backed, so your TOTP tokens remain in your Authy account tied to your phone number — local deletion does not remove them from Authy's service or from your phone. SSD remnants until overwritten. For the accounts themselves, the durable fix is to reset 2FA on each important service, not just wipe this device.
- **Admin:** No.

### WinAuth authenticator file
- **Where:** `%APPDATA%\WinAuth\winauth.xml` by default. WinAuth is a portable app, so the file may instead sit next to `WinAuth.exe` in whatever folder you ran it from — for example a USB stick or your Downloads folder.
- **Reveals:** The authenticators you added — issuer/account names (Steam, exchanges, email, and so on) and their TOTP/HOTP secrets. Depending on your settings the secrets may be stored unprotected or only lightly protected, so the file can expose live 2FA seeds.
- **Remove (user runs):** In File Explorer delete `%APPDATA%\WinAuth\winauth.xml` (and any copy next to a `WinAuth.exe` you ran), then empty the Recycle Bin. There is nothing to uninstall for the portable version — deleting the `.exe` and its `winauth.xml` is enough.
- **Survives:** Any copy of `winauth.xml` you exported or kept on removable media or backups persists; SSD remnants until overwritten. As with any authenticator, the durable fix is to re-key 2FA on the affected services.
- **Admin:** No.

---

## Virtual machines, WSL & backups

Two kinds of artifact in this cluster are each larger than almost anything else on the disk, and both are easy to miss because they hide inside one or two very big files.

A **virtual-machine disk image is a whole second computer.** A `.vdi`, `.vmdk`, `.vhd`/`.vhdx`, or WSL `ext4.vhdx` is a complete guest operating system with its own browsers, saved logins, documents, SSH keys, and app data — none of which your Windows cleanup touches, because to Windows it is just one opaque file. Uninstalling the hypervisor (VirtualBox, VMware, Docker Desktop, an Android emulator) almost never deletes the disk images; they are deliberately left behind so you don't lose your VMs, and they sit there for the next owner to boot.

A **backup image is a full copy of everything you are trying to clean.** File History, a Windows system image, Macrium/Veeam/Acronis/EaseUS archives, or a Duplicati/restic/kopia repository can each contain a second copy of your documents, browser profiles, and credentials — often *on a different drive or server than the one you are wiping*. Cleaning the live system while a backup image survives on an attached external disk, a NAS, or in the cloud defeats the entire effort. The backup *target* is the thing that matters most here, and it is frequently not this PC. WipeWise only reads and reports; every removal below is done by **you**, and for encrypted VMs, vaults, and repos WipeWise checks existence and counts only — it never opens an image or prints a passphrase.

---

### VirtualBox virtual machines
- **Where:** Default machine folder `%USERPROFILE%\VirtualBox VMs\<VM name>\` holding the `.vbox` config, the disk image(s) (`.vdi`, sometimes `.vmdk`/`.vhd`), a `Snapshots\` subfolder, and `Logs\`. Global config and the VM registry (which also keeps a *recent media / recent disk* MRU list) are in `%USERPROFILE%\.VirtualBox\VirtualBox.xml`. VMs can also be registered from any custom path the user chose.
- **Reveals:** Each VM is a full guest OS — its own logged-in accounts, browser history, files, and keys. `VirtualBox.xml` additionally lists every VM ever registered and recently used disk images by path, naming guests and folders even after the disks are gone.
- **Remove (user runs):** In VirtualBox Manager, right-click each VM > **Remove** > **Delete all files** (this deletes the `.vbox` and its disks). Then confirm the `%USERPROFILE%\VirtualBox VMs` folder is empty in File Explorer and delete any leftovers, and empty the Recycle Bin. Remove stale entries via **File > Virtual Media Manager** (release/remove orphaned disks) and **File > Preferences** to clear the machine folder default if it pointed elsewhere.
- **Survives:** Disks stored on a *different* drive or in a custom path are not removed by uninstalling VirtualBox. Snapshots are separate disk-delta files and can linger. A VM exported earlier as an `.ova`/`.ovf` appliance is a separate copy wherever it was saved. SSD free space holds the deleted image until TRIM/overwrite; a very large `.vdi` on an HDD stays recoverable until the space is reused.
- **Admin:** No for your own profile.

### VMware Workstation / Player virtual machines
- **Where:** Default location `%USERPROFILE%\Documents\Virtual Machines\<VM name>\` containing `.vmx` (config), `.vmdk` (disk, often split into many files), `.nvram`, `.vmsd`/`.vmsn` (snapshots), `.vmem`/`.vmss` (saved memory state), and `.log`. Application preferences and the **recent-VM MRU** are in `%APPDATA%\VMware\preferences.ini`; Workstation's inventory is `%APPDATA%\VMware\inventory.vmls`. VMs may also live on any user-chosen drive.
- **Reveals:** A complete guest OS per VM. The saved-memory (`.vmem`/`.vmss`) and suspend state can contain whatever was in the guest's RAM — open documents, decrypted data. `preferences.ini`/`inventory.vmls` list the paths and names of every VM you opened, even deleted ones.
- **Remove (user runs):** In VMware, right-click each VM in the Library > **Manage > Delete from Disk**. Then check `%USERPROFILE%\Documents\Virtual Machines` (and any custom drive) for leftovers and delete them, and empty the Recycle Bin. Clear the recent list via the library, or delete `preferences.ini`/`inventory.vmls` entries after uninstalling.
- **Survives:** VMs stored outside the default folder are untouched by uninstalling VMware. Linked clones reference a parent disk elsewhere. Snapshots are separate files. SSD remnants persist until TRIM; large `.vmdk` files on HDD stay recoverable until overwritten. Any VM copied to external media or shared earlier is a separate copy.
- **Admin:** No for your own profile.

### Hyper-V virtual machines
- **Where:** Virtual hard disks default to `%PUBLIC%\Documents\Hyper-V\Virtual Hard Disks\*.vhdx` (and `.vhd`/`.avhdx` checkpoint deltas); the user may have placed them on any drive. VM *configuration* (`.vmcx`, `.vmrs` runtime state, `.vmgs`) defaults to `%ProgramData%\Microsoft\Windows\Hyper-V\`. Enumerate reliably with `Get-VM` / `Get-VMHardDiskDrive` (read-only) in an elevated PowerShell.
- **Reveals:** Each VM is a full guest OS with its own accounts and data. Checkpoints (`.avhdx`) and the `.vmrs`/`.vmgs` runtime/state files can hold the guest's recent memory and saved state. The default-path setting and config store list every VM defined on the host.
- **Remove (user runs):** In **Hyper-V Manager**, right-click each VM > **Delete** (this removes the configuration but *not* the virtual disks by design). Then delete the `.vhdx`/`.avhdx` files from `%PUBLIC%\Documents\Hyper-V\Virtual Hard Disks` and any custom location in File Explorer, and empty the Recycle Bin. To stop the role entirely: Settings > Apps > Optional features / **Turn Windows features on or off** > uncheck **Hyper-V**.
- **Survives:** Deleting a VM leaves its `.vhdx` behind unless you delete the disk files yourself — this is the single most-missed Hyper-V remnant. Disks on other drives or exported VMs are separate copies. SSD remnants until TRIM; large disks on HDD recoverable until overwritten. Removing the Hyper-V feature needs a reboot.
- **Admin:** Yes — Hyper-V management and reading `%ProgramData%\Microsoft\Windows\Hyper-V` require Administrator.

### WSL (Windows Subsystem for Linux) distributions
- **Where:** The authoritative list is the registry: `HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss\{GUID}` — one subkey per installed distro, each with `DistributionName` and a `BasePath` value giving the exact folder of that distro's Linux disk. For Microsoft Store distros the disk is `%LOCALAPPDATA%\Packages\<DistroPackageName>\LocalState\ext4.vhdx` (e.g. a `CanonicalGroupLimited.Ubuntu...` or `TheDebianProject...` package). `wsl --import` and newer installs can place `ext4.vhdx` at any custom path (see uncertainties).
- **Reveals:** A full Linux user environment inside `ext4.vhdx` — shell history, SSH/GPG keys, cloud CLI tokens, source code, databases, and config pointing at your servers and accounts. The `Lxss` keys name every distro you ever installed and where its disk lives.
- **Remove (user runs):** `wsl --list --verbose` to see them, then `wsl --unregister <DistroName>` for each (this deletes that distro's `ext4.vhdx` and its registry entry). Store-installed distros can also be removed via Settings > Apps > the distro app > **Uninstall**. After unregistering, confirm the `LocalState` / custom folder no longer holds an `ext4.vhdx`, and empty the Recycle Bin if anything was moved there.
- **Survives:** A distro `wsl --export`ed earlier to a `.tar`/`.vhdx` is a separate copy wherever it was saved. Custom-path disks are only removed if that path was the one unregistered. SSD free space holds the deleted `ext4.vhdx` until TRIM; these files are often tens of GB. A distro still mounted/running is not removed until `wsl --shutdown`.
- **Admin:** No for your own distros.

### Docker Desktop (WSL 2) data disks
- **Where:** `%LOCALAPPDATA%\Docker\wsl\` — the backing disk(s) for Docker's WSL distros: older layouts use `data\ext4.vhdx` plus `distro\ext4.vhdx`, newer ones a consolidated `disk\docker_data.vhdx`. The `docker-desktop` (and legacy `docker-desktop-data`) distros also appear under the `Lxss` registry key above. Docker settings/config: `%APPDATA%\Docker` and `%USERPROFILE%\.docker\`.
- **Reveals:** Every container image, named volume, and build-cache layer you pulled or built — which can embed application databases, `.env` secrets, API keys baked into images, and your private registry references. `~/.docker/config.json` records which registries you logged into.
- **Remove (user runs):** In Docker Desktop, **Troubleshoot > Clean / Purge data** or **Reset to factory defaults** removes images/volumes/containers; then **Uninstall** Docker Desktop (Settings > Apps). Confirm `%LOCALAPPDATA%\Docker\wsl` no longer holds a large `.vhdx`. Run `docker logout` yourself to drop stored registry auth.
- **Survives:** Images you pushed to Docker Hub or a private registry stay in the cloud until deleted there. The big `.vhdx` can remain on disk if Docker was removed by deleting the app folder rather than uninstalling. SSD remnants until TRIM. (Docker Hub sign-out/auth is also covered in the apps cluster.)
- **Admin:** No for your own profile.

### BlueStacks 5 Android engine
- **Where:** `%ProgramData%\BlueStacks_nxt\` — the `Engine\<instance>\` subfolders hold the Android disk images (`Root.vhd`, `Data.vhd`, `UserData.vhd`, `SDCard.vhd` and similar) for each instance, plus `bluestacks.conf` (settings, which can include account/instance hints) and `Logs\`. Per-user settings may also sit in `%LOCALAPPDATA%\BlueStacks_nxt\`. (Older BlueStacks 4 used `%ProgramData%\BlueStacks`.)
- **Reveals:** A full Android device per instance — Google account sign-ins, Play Store history, game/app logins and saves, WhatsApp or social sessions, downloaded media. The `Data.vhd`/`UserData.vhd` images carry all of it.
- **Remove (user runs):** Delete extra instances inside the **BlueStacks Multi-Instance Manager** first, sign out of Google inside Android if you want the account session dropped, then uninstall via Settings > Apps > **BlueStacks** (or run its own uninstaller, which offers to remove engine/user data). Afterwards check `%ProgramData%\BlueStacks_nxt` and `%LOCALAPPDATA%\BlueStacks_nxt` are gone and empty the Recycle Bin.
- **Survives:** A plain uninstall sometimes leaves the large engine `.vhd` images behind — verify the folder is removed. The Google/Play account itself and cloud game saves persist server-side until you remove the device/session from your Google account. SSD remnants until TRIM.
- **Admin:** No to uninstall for your own install; deleting leftovers under `%ProgramData%` may prompt for elevation.

### LDPlayer, NoxPlayer, MEmu & similar Android emulators
- **Where:** Each bundles its own hypervisor and stores a full Android disk image under its install or data directory. Confirmed install roots: MEmu at `%ProgramFiles%\Microvirt\MEmu\` (VM data in a `MemuHyperv VMs`-style subfolder); LDPlayer under its chosen install directory (e.g. `C:\LDPlayer\LDPlayer9\`, with `ldconsole.exe` and per-instance VM files beneath it); NoxPlayer under its install directory and `%APPDATA%\Nox`. Exact image sub-paths vary by version and install location (see uncertainties). All register an Add/Remove Programs uninstall entry under `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\` (or the `WOW6432Node` view).
- **Reveals:** The same as BlueStacks — a complete Android environment per instance with Google/app logins, game saves, messaging sessions, and downloaded files inside the disk image.
- **Remove (user runs):** Delete extra instances in the emulator's own **Multi-Instance Manager** first (and sign out of Google inside Android if wanted), then uninstall via Settings > Apps. After uninstalling, open the install directory (and `%APPDATA%\Nox` for Nox) in File Explorer, delete any remaining VM/image folders, and empty the Recycle Bin.
- **Survives:** These uninstallers are known to leave large VM image files behind — verify the install/data folder is actually gone. Google/Play accounts and cloud saves persist server-side until removed there. SSD remnants until TRIM.
- **Admin:** No to uninstall for a per-user install; removing leftovers under `%ProgramFiles%` needs Administrator.

### Windows Subsystem for Android (WSA)
- **Where:** `%LOCALAPPDATA%\Packages\MicrosoftCorporationII.WindowsSubsystemForAndroid_8wekyb3d8bbwe\` — `LocalCache\` holds the Android user-data image and `LocalState\` the subsystem state. (WSA was discontinued in March 2025 but remains installed on many machines.)
- **Reveals:** The Android user profile that ran under WSA — Amazon Appstore / sideloaded app logins, app data and caches, and anything saved inside the Android storage.
- **Remove (user runs):** Settings > Apps > **Windows Subsystem for Android** > **Uninstall** (this removes the package and its per-user image). Sign out of any Amazon/Google account inside the Android apps first if you want those sessions dropped. Confirm the package folder above is gone.
- **Survives:** App accounts (Amazon Appstore, any Google sign-in used by a sideloaded app) persist server-side until removed there. SSD remnants until TRIM. If WSA was installed under another Windows user, their copy is separate.
- **Admin:** No for your own account.

### Windows File History
- **Where:** Local config and catalog: `%LOCALAPPDATA%\Microsoft\Windows\FileHistory\` (`Configuration\Config*.xml` describe what is backed up and to which target; `Data\` holds the local catalog). The actual versioned copies live on the **target drive** at `<Target>:\FileHistory\<User>\<PCName>\Data\...`.
- **Reveals:** Timestamped historical copies of your Libraries/Desktop/Contacts/Favorites — effectively a second, versioned copy of your personal files, including ones you later deleted from the live system. The config names the target drive and folders.
- **Remove (user runs):** Control Panel > **File History** > **Turn off**, then **Advanced settings > Clean up versions** (or delete the `FileHistory` folder on the target drive yourself). If the target is an external/USB drive or network share, connect it and delete the `FileHistory\<User>\<PCName>` folder there, then empty the Recycle Bin.
- **Survives:** **The copies are usually on another drive** — turning File History off on this PC does nothing to the external disk or share that holds them; you must clean the target separately. Versions on a disconnected drive are untouched. SSD remnants until TRIM on whichever drive stored them.
- **Admin:** No for your own File History; cleaning a share may need its own permissions.

### Windows Backup / Windows 7 Backup (system image + file backup)
- **Where:** On the **target drive**: a system image as `<Target>:\WindowsImageBackup\<PCName>\Backup <timestamp>\*.vhd(x)`, file backups as `<Target>:\<PCName>\Backup Set <date>\...` (zipped sets), and a `MediaID.bin` marker at the backup root. Backup configuration/schedule is under `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup` and in Task Scheduler.
- **Reveals:** A system image is a complete, bootable copy of the whole machine — every document, browser profile, and credential at the time it was made. The file backup is a copy of your selected personal folders.
- **Remove (user runs):** Control Panel > **Backup and Restore (Windows 7)** > **Manage space** > delete backup periods and the system image; or connect the target drive and delete the `WindowsImageBackup\<PCName>` and `<PCName>` backup folders plus `MediaID.bin` in File Explorer, then empty the Recycle Bin. Turn off the schedule in the same Control Panel page.
- **Survives:** The images almost always live on a **separate internal or external drive or NAS** — wiping C: leaves them intact; clean the target drive itself. A system image on a disconnected disk is untouched. SSD/HDD remnants on the target until TRIM/overwrite.
- **Admin:** Yes to manage/delete system-image backups and the schedule.

### Macrium Reflect
- **Where:** Backup images on the user-chosen target: `*.mrimg` (Reflect 8 and earlier) or `*.mrbak` (Reflect X), often alongside an `.xml` backup definition. Backup definition files also live in `%USERPROFILE%\Documents\Reflect\*.xml`; app settings in the registry under `HKLM:\SOFTWARE\Macrium\`; logs under `%ProgramData%\Macrium\`. Schedules are Task Scheduler entries.
- **Reveals:** A full disk/partition image is a complete copy of the source — all files and the OS state. The definition `.xml` and registry reveal what was imaged and the backup target path, naming drives and destinations.
- **Remove (user runs):** In Macrium Reflect, delete the backup definitions and their scheduled tasks, then connect the target and delete the `.mrimg`/`.mrbak` files in File Explorer, and empty the Recycle Bin. Uninstall via Settings > Apps if you no longer need the app.
- **Survives:** Images on an external drive, NAS, or Macrium's cloud/offsite target are untouched by anything done on C: — clean the target. Encrypted images stay encrypted but still exist and are restorable by anyone with the password. SSD/HDD remnants on the target until TRIM/overwrite.
- **Admin:** Yes for imaging/restore operations and some schedule changes; deleting files on the target may not need admin.

### Veeam Agent for Microsoft Windows
- **Where:** Backup files on the target: `*.vbk` (full), `*.vib` (increment), `*.vbm` (metadata). Local config/catalog under `%ProgramData%\Veeam\Endpoint\` (job settings and a local database); settings in the registry under `HKLM:\SOFTWARE\Veeam\Veeam Endpoint Backup\`.
- **Reveals:** Volume-level backups are a complete copy of the backed-up disks. The config/database and registry reveal the backup job, target (local disk, NAS/SMB share, or Veeam repository), and schedule — naming servers and shares.
- **Remove (user runs):** In the Veeam Agent control panel, delete the backup job (optionally choosing to remove the backup files), then connect the target and delete remaining `.vbk`/`.vib`/`.vbm` files yourself, and empty the Recycle Bin. Uninstall via Settings > Apps if no longer needed.
- **Survives:** Backups on a NAS/SMB share or a Veeam Backup & Replication repository are server-side copies untouched by cleaning this PC — remove them there. Encrypted backups still exist. SSD/HDD remnants on the target until TRIM/overwrite.
- **Admin:** Yes — the Veeam Agent service and `%ProgramData%\Veeam\Endpoint` are service-owned.

### Acronis (True Image / Cyber Protect Home Office)
- **Where:** Backup archives on the target: `*.tib` (classic) or `*.tibx` (newer). Local config, logs, and database under `%ProgramData%\Acronis\`; some per-user settings under `%APPDATA%\Acronis\`. Schedules run as Acronis services/tasks.
- **Reveals:** A disk/partition `.tib(x)` is a complete copy of the source. The config/logs reveal what was backed up, the target (local, external, NAS, or **Acronis Cloud**), and schedule.
- **Remove (user runs):** In the Acronis app, delete each backup (choose to delete its files/versions), then connect any local/external target and delete leftover `.tib`/`.tibx` files in File Explorer, and empty the Recycle Bin. For **Acronis Cloud**, delete the backups in the Acronis online account and/or remove the device there. Uninstall via Settings > Apps if finished.
- **Survives:** **Acronis Cloud** copies live on Acronis servers until deleted in your account — a local uninstall does nothing to them. Archives on external/NAS targets are untouched by cleaning C:. Encrypted archives still exist. SSD/HDD remnants on the target until TRIM/overwrite.
- **Admin:** Yes — Acronis runs services and `%ProgramData%\Acronis` is service-owned.

### EaseUS Todo Backup
- **Where:** Backup images on the user-chosen target as `*.pbd` files (EaseUS's image format; can be password-protected). App config/logs under `%ProgramData%\EaseUS\` and the install directory; settings in the registry under `HKLM:\SOFTWARE\` (EaseUS key, often in the `WOW6432Node` view). Schedules run as EaseUS tasks/services.
- **Reveals:** A disk/partition/system `.pbd` is a complete copy of the source files and OS. Config/registry reveal the job, target path, and schedule — naming the destination drive or share.
- **Remove (user runs):** In EaseUS Todo Backup, delete each backup plan and its image versions, then connect the target and delete remaining `.pbd` files in File Explorer, and empty the Recycle Bin. Uninstall via Settings > Apps; if it used an EaseUS cloud destination, delete those backups in the EaseUS account.
- **Survives:** Images on external/NAS/cloud targets are untouched by cleaning this PC. A password-protected `.pbd` is still a present, restorable copy. SSD/HDD remnants on the target until TRIM/overwrite.
- **Admin:** Yes for system/disk imaging and service/schedule changes; deleting image files on the target may not need admin.

### Duplicati
- **Where:** Local server config and job databases under `%LOCALAPPDATA%\Duplicati\` — `Duplicati-server.sqlite` stores the backup configurations (source paths, destination URLs, and often a stored encryption passphrase/credentials), and per-job `*.sqlite` files hold the local index. The backup **destination** (local folder, external drive, SMB share, or cloud bucket) holds `*.dblock.zip`, `*.dindex.zip`, and `*.dlist.zip` volumes (`.aes` when encrypted).
- **Reveals:** The destination volumes are a deduplicated, usually encrypted copy of everything in the backup source. `Duplicati-server.sqlite` reveals exactly what was backed up and *where it went* — cloud accounts, buckets, and shares — and is the richest pointer to offsite copies of your data. (WipeWise reports its existence only and never reads stored secrets.)
- **Remove (user runs):** In the Duplicati web UI, delete each backup configuration (and use its option to delete the remote files), then remove any remaining destination volumes at the target yourself (local/external folder in File Explorer; cloud bucket in the provider's console). Uninstall Duplicati via Settings > Apps, and confirm `%LOCALAPPDATA%\Duplicati` is removed; empty the Recycle Bin.
- **Survives:** The real data is usually at a **remote destination** (cloud bucket, NAS, external drive) that a local uninstall never touches — delete it there. Encrypted volumes remain restorable by anyone with the passphrase. SSD remnants until TRIM.
- **Admin:** No for a per-user install.

### Restic & Kopia repositories
- **Where:** Repositories are a set of blob files that may be local, on an external/USB drive, on a network share, or in cloud object storage. A **restic** repo folder contains `config`, `keys/`, `snapshots/`, `index/`, `data/`, and `locks/`; its local cache is `%LOCALAPPDATA%\restic\`. A **kopia** repo contains a `kopia.repository.f` marker plus content blobs; its config is `%APPDATA%\kopia\repository.config` (with cache under `%LOCALAPPDATA%\kopia\`). restic repo locations are typically set via the `RESTIC_REPOSITORY` environment variable or shell history rather than a fixed config file.
- **Reveals:** Both are always-encrypted, deduplicated backups — a full copy of the backed-up files. The local config/cache and the repo's own `snapshots`/metadata reveal that backups exist, roughly how many snapshots, and the repository location (local path, share, or cloud bucket), pointing at offsite copies. WipeWise reports existence and counts only and never reads keys or the password.
- **Remove (user runs):** Decide what to keep, then at the repository location delete the repo (a local/external folder in File Explorer; a cloud bucket or prefix in the provider's console; `kopia repository delete` / removing the restic repo folder if you run those yourself). Also delete the local caches `%LOCALAPPDATA%\restic` and `%LOCALAPPDATA%\kopia` and the kopia config folder, then empty the Recycle Bin.
- **Survives:** A repo in **cloud object storage or on a NAS/external drive** is untouched by anything on this PC — remove it at the destination. The encryption protects contents but the repo still exists and is restorable with the password/key. SSD remnants until TRIM for local repos and caches.
- **Admin:** No for a per-user install.

---

## Credentials, keys & secrets

Everything on this PC that proves *you* are you, or that unlocks a service, a server, or another vault. This is the highest-value cluster for a new owner: a single leaked key or saved password can reach your cloud account, your employer's network, or your money long after the machine leaves your hands. WipeWise only ever **counts and checks existence** here — it never opens a file, reads a value, or prints a secret. You perform every removal.

Two honesty rules run through this whole section:

- **A local delete is not a revoke.** Removing a saved cloud key, SSH key, VPN profile, or registry password from this PC does nothing to the *server* that still trusts it. For anything that authenticates to something else, the real fix is to **rotate or revoke the credential at the service** (AWS IAM, Azure, GCP, your Git host, your VPN gateway, the remote server's `authorized_keys`) and change the password there. Treat every secret found here as *already compromised* and rotate it.
- **Most of these are DPAPI-encrypted and tied to your Windows account.** Deleting your user account/profile (or a full Reset-this-PC that removes the profile) cryptographically strands the lot, because the keys that decrypt them go with the account. File-by-file deletion is the targeted option; account/profile removal is the thorough one.

> **Never run `netsh wlan show profile name="…" key=clear`** or any equivalent "reveal" command. It prints the Wi-Fi password in clear text. Counting profiles is safe; revealing keys is not, and WipeWise never does it.

---

### Windows Credential Manager (Windows Credentials + Web Credentials)
- **Where:** The user-facing vault. List counts only with `cmdkey /list` (Windows Credentials: saved sign-ins for file shares, RDP hosts, apps, Git Credential Manager) and `vaultcmd /listcreds:"Web Credentials" /all` (Web Credentials: passwords Internet Explorer/Edge legacy and some apps saved). Both commands **list and count only — they do not reveal secret values.**
- **Reveals:** Which servers, network shares, websites, and apps you saved sign-ins for, the usernames used, and the fact that stored passwords exist for them. Entry *names* alone (e.g. `TERMSRV/server01`, `git:https://github.com`) map out your work and accounts.
- **Remove (user runs):** Control Panel > User Accounts > **Credential Manager** > Windows Credentials and Web Credentials > expand each entry > **Remove**. Scriptable per entry by the user with `cmdkey /delete:<TargetName>`. "Clear credentials" inside Git Credential Manager (`git credential-manager unconfigure` / clearing via the app) removes its entries too.
- **Survives:** Removing an entry does not sign you out of or revoke access at the service — change those passwords/keys separately. Entries re-created by an app or by Sync can reappear if you sign back in. The backing files on disk (next entry) and DPAPI keys remain until removed or the profile is deleted.
- **Admin:** No (for your own credentials).

### Credential Manager on-disk store (Credentials files)
- **Where:** `%LOCALAPPDATA%\Microsoft\Credentials` and `%APPDATA%\Microsoft\Credentials` (roaming). These binary files are what Credential Manager shows; each is DPAPI-encrypted.
- **Reveals:** The encrypted saved passwords and secrets behind Credential Manager (shares, RDP, apps, Git, some Wi‑Fi/EAP). Encrypted at rest, but present and decryptable by anyone who can log in as you or who has your DPAPI master key.
- **Remove (user runs):** Remove the entries through **Credential Manager** (previous block) rather than hand-deleting these files; that keeps the vault index consistent. A full account/profile removal or Reset-this-PC clears the folder.
- **Survives:** Hand-deleting files can leave orphaned vault references; use the UI. SSD remnants persist until TRIM/overwrite. The matching DPAPI master key (next block) must also go, or an attacker with both an image and your logon could still decrypt.
- **Admin:** No for your own; another user's store needs admin.

### Web Credential vault (Vault store)
- **Where:** `%LOCALAPPDATA%\Microsoft\Vault` and `%APPDATA%\Microsoft\Vault` (per-user Web Credentials). A system vault also exists at `%ProgramData%\Microsoft\Vault` and `%WINDIR%\System32\config\systemprofile\AppData\Local\Microsoft\Vault`.
- **Reveals:** Saved web/app credentials surfaced under "Web Credentials" in Credential Manager — sites and the fact that passwords were stored for them.
- **Remove (user runs):** Credential Manager > **Web Credentials** > Remove each. Modern Edge/Chrome passwords are *not* here (see the Browsers cluster) — this is the legacy/app web vault.
- **Survives:** Same as above — server-side accounts are untouched; SSD remnants until TRIM; system vault needs admin.
- **Admin:** No for the per-user vault; the system vault needs admin.

### DPAPI master keys
- **Where:** `%APPDATA%\Microsoft\Protect\<your-SID>\` (per-user master keys). A machine/system set lives at `%WINDIR%\System32\Microsoft\Protect\S-1-5-18\`.
- **Reveals:** Nothing readable on their own — but these are the keys that decrypt nearly every other secret in this cluster (Credential Manager, Vault, saved Wi‑Fi keys, many browsers' and apps' stored passwords, `.ovpn`/WireGuard tunnels, RDP saved passwords). They are the master lock.
- **Remove (user runs):** Do not hand-delete these on a profile you still use — it will make your own saved passwords unrecoverable and can break sign-in. The clean, thorough removal is to **delete the entire Windows user account and its profile** (Settings > Accounts > Other users > Remove, done from a *different* admin account) or do a Reset-this-PC that removes the profile; that takes the master keys with it and strands everything they protected.
- **Survives:** If any disk image or backup captured both the Protect folder and the data it guards, those remain decryptable until overwritten. SSD remnants persist until TRIM/overwrite. The system (S-1-5-18) keys are cleared only by reset/reinstall and need admin.
- **Admin:** No to read your own; removing another account's profile needs admin.

### Windows Hello PIN & passkeys (NGC)
- **Where:** `%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc` (the "Next Generation Credentials" store; SYSTEM/TrustedInstaller-owned, not a per-user folder). Related protector material under `%SystemRoot%\ServiceProfiles\LocalService\AppData\Roaming\Microsoft\Crypto`. Device-bound **passkeys** (FIDO2 platform authenticator) created with Hello are bound here and to the TPM.
- **Reveals:** That a PIN / Hello sign-in / passkeys are enrolled for your account on this device, and the existence of site-bound passkeys you created. The private keys never leave the TPM.
- **Remove (user runs):** **Set up another working sign-in first** (a password on the account) or you can lock yourself out. Then Settings > Accounts > **Sign-in options** > **PIN (Windows Hello)** > **Remove**; remove **Facial recognition** and **Fingerprint** the same way. Remove saved **passkeys** under Settings > Accounts > **Passkeys** (Windows 11 23H2+) — delete per site; also delete the matching passkey at each website/account. Do **not** hand-delete the Ngc folder.
- **Survives:** Deleting the PIN does not delete passkeys, and vice-versa — handle both. Passkeys also have a server-side registration at each site that must be removed there. The TPM still holds key material until the TPM is cleared (Windows Security > Device security > Security processor > Clear TPM — **have your BitLocker recovery key first**) or the device is reset. Needs reboot/reset to fully clear the store.
- **Admin:** No to remove via Settings for your own account; reading the Ngc folder needs SYSTEM/admin.

### Windows Hello biometric templates
- **Where:** `%WINDIR%\System32\WinBioDatabase\` (`*.DAT` enrolment templates, for sensors that store templates on the PC rather than on the sensor chip).
- **Reveals:** That fingerprint/face biometrics are enrolled, and holds the template data for on-PC storage sensors. A new owner should never receive your biometric templates.
- **Remove (user runs):** Settings > Accounts > **Sign-in options** > remove **Fingerprint** and **Facial recognition** (this is what clears enrolments the supported way). For a stubborn database, the user can stop the **Windows Biometric Service** and clear it, but prefer the Settings removal.
- **Survives:** **Match-on-chip** fingerprint readers keep templates on the sensor module, *not* in this database — removing Windows Hello in Settings clears those; deleting files does not. A full OS reset does not wipe on-sensor templates either. SSD remnants until TRIM for the on-PC database.
- **Admin:** No via Settings; reading/clearing the database folder needs admin.

### Saved Wi-Fi profiles & network keys
- **Where:** `%ProgramData%\Microsoft\Wlansvc\Profiles\Interfaces\{interface-GUID}\*.xml` (one XML per saved network; the pre-shared key sits in a DPAPI/system-encrypted `<keyMaterial>` element). Count safely with `netsh wlan show profiles` — **never** add `key=clear`.
- **Reveals:** Every network you've joined — home, workplaces, friends' houses, hotels, airports, cafés, phone hotspots. The **SSID list alone is a travel and relationship map**, and each profile stores the key to rejoin.
- **Remove (user runs):** Settings > Network & internet > Wi‑Fi > **Manage known networks** > **Forget** each. Or the user runs `netsh wlan delete profile name="NAME"` (delete only — never the `key=clear` reveal). Enterprise/EAP profiles may also have a saved credential in Credential Manager to remove.
- **Survives:** Forgetting affects **every user of this PC**, not just you — warn on shared machines. The access point still exists; nothing here changes the network itself. SSD remnants until TRIM. The system DPAPI key that protected the keys is separate (see DPAPI block).
- **Admin:** No to forget via Settings or `netsh delete` for the current machine profiles; reading the `Interfaces` folder directly needs admin.

### SSH private keys, known_hosts & config
- **Where:** `%USERPROFILE%\.ssh\` — private keys (`id_rsa`, `id_ed25519`, `*.pem`, `*.ppk`-adjacent), public keys, `known_hosts` (servers you connected to), `config` (host aliases, usernames, jump hosts), and `authorized_keys` if this box is also a server.
- **Reveals:** Private keys grant login to every server/Git host that trusts them. `known_hosts` and `config` enumerate the servers, usernames, and network layout you work with.
- **Remove (user runs):** Back up any key you still need (to a USB/vault) first, then delete `%USERPROFILE%\.ssh`. Also clear the OpenSSH **ssh-agent** (`ssh-add -D`, and consider stopping/disabling the `ssh-agent` service, which caches keys in `HKCU\Software\OpenSSH\Agent\Keys`).
- **Survives:** The matching **public key still sits in `authorized_keys` on every remote server/Git host** — the only real fix is to **remove the key there and treat it as compromised**. Agent-cached copies and SSD remnants persist until cleared/TRIM.
- **Admin:** No.

### GnuPG keyring
- **Where:** `%USERPROFILE%\.gnupg\` — `private-keys-v1.d\` (secret keys), `pubring.kbx`, `trustdb.gpg`, `random_seed`.
- **Reveals:** Your PGP/GPG **private keys** (decrypts your encrypted mail/files and signs as you) and your web of trust / contacts.
- **Remove (user runs):** Export anything you must keep to offline backup, then delete `%USERPROFILE%\.gnupg`. If the key is published to a keyserver, consider issuing/ publishing a **revocation certificate**.
- **Survives:** Published or shared public keys and any encrypted-to-you ciphertext others hold are unaffected. SSD remnants until TRIM.
- **Admin:** No.

### AWS CLI / SDK credentials
- **Where:** `%USERPROFILE%\.aws\credentials` and `%USERPROFILE%\.aws\config`; token caches in `%USERPROFILE%\.aws\sso\cache\` and `%USERPROFILE%\.aws\cli\cache\`.
- **Reveals:** Long-lived **access key IDs and secret access keys**, account IDs, role ARNs, region, and SSO session tokens — potentially full programmatic access to cloud resources and billing.
- **Remove (user runs):** Delete the `%USERPROFILE%\.aws` folder. **Then, in the AWS console, deactivate/delete the access key** under IAM (a local delete does not revoke it) and sign out of IAM Identity Center/SSO sessions.
- **Survives:** The key keeps working at AWS until you deactivate it there. CloudTrail logs, SSD remnants until TRIM.
- **Admin:** No.

### Azure CLI / Azure PowerShell tokens
- **Where:** `%USERPROFILE%\.azure\` — `msal_token_cache.bin`/`.json` (access/refresh tokens), `azureProfile.json` (subscriptions, account emails), `clouds.config`, and any `service_principal` entries. Azure PowerShell adds `%USERPROFILE%\.Azure\AzureRmContext.json` / `TokenCache.dat`.
- **Reveals:** Signed-in **account email, tenant and subscription IDs**, and cached tokens that can act as you in Azure until they expire.
- **Remove (user runs):** Run `az logout` and `Disconnect-AzAccount`, then delete the `%USERPROFILE%\.azure` (and `%USERPROFILE%\.Azure`) folder. Rotate any **service principal** secret found, in Entra ID.
- **Survives:** Refresh tokens are revoked server-side only by signing out / revoking sessions in Entra ID; service-principal secrets live until rotated there. SSD remnants until TRIM.
- **Admin:** No.

### Google Cloud SDK (gcloud) credentials
- **Where:** `%APPDATA%\gcloud\` — `credentials.db`, `access_tokens.db`, `legacy_credentials\<account>\`, `configurations\`, `application_default_credentials.json` (ADC).
- **Reveals:** Your Google Cloud **account email, refresh/access tokens, and ADC service-account keys** — programmatic access to GCP projects.
- **Remove (user runs):** `gcloud auth revoke --all` and `gcloud auth application-default revoke`, then delete `%APPDATA%\gcloud`. Delete/disable any downloaded **service-account key** in the GCP console.
- **Survives:** Service-account keys remain valid in GCP until deleted/disabled there; SSD remnants until TRIM.
- **Admin:** No.

### Kubernetes config
- **Where:** `%USERPROFILE%\.kube\config` (and `%USERPROFILE%\.kube\cache\`). Tools like `oc`, `k9s`, Lens may keep copies elsewhere under `%APPDATA%`/`%LOCALAPPDATA%`.
- **Reveals:** Cluster **API endpoints, client certificates, bearer tokens, and context names** — often direct admin access to production clusters.
- **Remove (user runs):** Delete `%USERPROFILE%\.kube`. **Rotate/revoke the tokens and client certs at the cluster** (they stay valid otherwise).
- **Survives:** Cluster-side credentials keep working until rotated/revoked there; SSD remnants until TRIM.
- **Admin:** No.

### Docker / container registry auth
- **Where:** `%USERPROFILE%\.docker\config.json` (registry `auths`, or a `credsStore`/`credHelpers` pointer), `%USERPROFILE%\.docker\contexts\`.
- **Reveals:** Base64-encoded **registry logins** (Docker Hub, GHCR, private registries) and server names, or a pointer showing which credential store holds them.
- **Remove (user runs):** `docker logout` for each registry, then delete `%USERPROFILE%\.docker\config.json`. **Important:** with Docker Desktop on Windows the token is usually in **Windows Credential Manager** (`credsStore: "desktop"`/`wincred`), *not* in `config.json` — clear it in Credential Manager too.
- **Survives:** Registry access tokens remain valid until rotated at the registry; SSD remnants until TRIM.
- **Admin:** No.

### Package-manager / registry tokens (npm, PyPI, NuGet)
- **Where:** `%USERPROFILE%\.npmrc` (`//registry.../:_authToken=…`), `%USERPROFILE%\.pypirc` (PyPI/Test-PyPI upload creds), `%APPDATA%\NuGet\NuGet.Config` (`packageSourceCredentials` for private feeds). Yarn: `%USERPROFILE%\.yarnrc.yml`/`.yarnrc`.
- **Reveals:** **Publish/read tokens** for package registries and private feed URLs — enough to push malicious packages or read private code.
- **Remove (user runs):** Delete these files (or the sensitive lines). **Revoke the tokens** in the registry's account settings (npmjs.com, PyPI, your feed) — a local delete does not invalidate them.
- **Survives:** Tokens stay live at the registry until revoked there; SSD remnants until TRIM.
- **Admin:** No.

### Git saved credentials
- **Where:** `%USERPROFILE%\.git-credentials` (plaintext `store` helper: `https://user:token@host`), `%USERPROFILE%\.gitconfig` (helper config, user name/email). Git Credential Manager (the Windows default) stores in **Windows Credential Manager** instead.
- **Reveals:** Plaintext **personal access tokens / passwords** for GitHub/GitLab/Azure DevOps/Bitbucket, and your committer identity (name/email).
- **Remove (user runs):** Delete `%USERPROFILE%\.git-credentials`; clear GCM entries in **Credential Manager** (or `git credential-manager unconfigure`). **Revoke the PAT** at the Git host.
- **Survives:** The token works at the host until revoked there; SSD remnants until TRIM.
- **Admin:** No.

### Generic network credentials (.netrc)
- **Where:** `%USERPROFILE%\_netrc` (Windows convention) or `%USERPROFILE%\.netrc` — used by `curl`, Git, and many CLI tools.
- **Reveals:** `machine / login / password` entries in **plaintext** for arbitrary hosts (FTP, APIs, internal services).
- **Remove (user runs):** Delete the file and **change those passwords** on each host.
- **Survives:** Passwords stay valid at the hosts until changed; SSD remnants until TRIM.
- **Admin:** No.

### Maven settings
- **Where:** `%USERPROFILE%\.m2\settings.xml` (and `settings-security.xml`).
- **Reveals:** `<servers>` **repository passwords/tokens** (Nexus, Artifactory, internal mirrors); the "encrypted" form is reversible with the master in `settings-security.xml`.
- **Remove (user runs):** Delete `%USERPROFILE%\.m2\settings.xml` and `settings-security.xml`; **rotate the repository credentials**.
- **Survives:** Repository credentials remain valid until rotated; SSD remnants until TRIM.
- **Admin:** No.

### PuTTY saved sessions & host keys
- **Where:** `HKCU:\Software\SimonTatham\PuTTY\Sessions\` (one subkey per saved session: hostnames, usernames, and any saved **proxy password in plaintext**), `HKCU:\Software\SimonTatham\PuTTY\SshHostKeys\` (every server you accepted a key from). Private keys are separate `.ppk` files wherever you saved them; Pageant caches loaded keys in memory.
- **Reveals:** The servers you administer, the usernames and ports, proxy passwords, and — via `SshHostKeys` — a list of every host you've connected to.
- **Remove (user runs):** In PuTTY, delete each saved session; to clear everything the user can run `reg delete "HKCU\Software\SimonTatham\PuTTY" /f` (user runs this themselves). Delete `.ppk` files and close Pageant.
- **Survives:** Server-side access via your keys/passwords persists until changed there; SSD remnants until TRIM; registry hive copies in restore points.
- **Admin:** No.

### WinSCP saved sessions
- **Where:** Default is the registry: `HKCU:\Software\Martin Prikryl\WinSCP 2\Sessions\` and `\Configuration\`. Portable/INI installs use `%APPDATA%\WinSCP.ini` or a `WinSCP.ini` beside the executable.
- **Reveals:** Saved **SFTP/FTP/SCP sites** — hostnames, usernames, ports, and **saved passwords that WinSCP stores with weak, reversible obfuscation** (recoverable unless a master password is set).
- **Remove (user runs):** In WinSCP: Tools > **Clean Up / Clear** (removes saved sessions, host keys, configuration), or delete the registry key / `WinSCP.ini`. **Change the passwords on those servers.**
- **Survives:** Server-side access until passwords changed; SSD/registry remnants until overwritten/TRIM.
- **Admin:** No.

### FileZilla site manager
- **Where:** `%APPDATA%\FileZilla\` — `sitemanager.xml` (saved sites), `recentservers.xml` (recent), `filezilla.xml`, `queue.xml`.
- **Reveals:** FTP/SFTP **hostnames, usernames, and passwords stored in plaintext (base64)** by default unless a master password is configured — one of the easiest wins for a new owner.
- **Remove (user runs):** FileZilla > Edit > **Clear private data** (tick all), or delete the `%APPDATA%\FileZilla` folder. **Change the passwords on each server.**
- **Survives:** Server-side access until passwords changed; SSD remnants until TRIM.
- **Admin:** No.

### OpenVPN client profiles
- **Where:** OpenVPN GUI (community): `%USERPROFILE%\OpenVPN\config\*.ovpn` and `%ProgramFiles%\OpenVPN\config\`. OpenVPN Connect (official v3) keeps imported profiles in its own app data under `%USERPROFILE%\AppData\Roaming\OpenVPN Connect\`. `.ovpn` files may **embed CA/client certs and private keys inline**, or reference `auth-user-pass` files holding a username/password.
- **Reveals:** The **VPN gateway (often a corporate or home network entry point)**, embedded certificates/keys, and sometimes saved credentials.
- **Remove (user runs):** Delete the `.ovpn` profiles and any `auth-user-pass` file; uninstall the client if done. Ask the VPN admin to **revoke the client certificate**.
- **Survives:** The certificate keeps working at the gateway until revoked there; SSD remnants until TRIM; `%ProgramFiles%` configs need admin.
- **Admin:** No for `%USERPROFILE%` profiles; `%ProgramFiles%\OpenVPN\config` needs admin.

### WireGuard tunnels
- **Where:** `%ProgramFiles%\WireGuard\Data\Configurations\<tunnel>.conf.dpapi` (the manager encrypts imported configs with DPAPI under the **Local System** account and deletes the plaintext). Any original `.conf` files you imported may still sit wherever you saved them.
- **Reveals:** VPN **endpoint, allowed IPs, and your private key / preshared key** — i.e. access to the peer network.
- **Remove (user runs):** In the WireGuard app, **Remove** each tunnel; delete any leftover `.conf` you saved elsewhere. Remove this device's **public key from the peer/server** config.
- **Survives:** The peer keeps the tunnel usable until your key is removed there; SSD remnants until TRIM; reading/removing the encrypted store needs admin/Local System.
- **Admin:** Yes to read the `Data\Configurations` store (removal via the app runs elevated); no to delete your own stray `.conf` files.

### Cisco Secure Client / AnyConnect profiles
- **Where:** Current naming: `%ProgramData%\Cisco\Cisco Secure Client\VPN\Profile\*.xml`. Older: `%ProgramData%\Cisco\Cisco AnyConnect Secure Mobility Client\Profile\*.xml`. Per-user "last used" hints under `%LOCALAPPDATA%\Cisco\…\preferences.xml`.
- **Reveals:** **Corporate VPN gateway hostnames, group/profile names**, and your last-used server and username — a direct pointer to an employer's network. The password itself is typically entered live or held in Credential Manager, not the profile.
- **Remove (user runs):** This is usually a **work device concern** — if so, return it through the organization's IT rather than stripping it yourself. Otherwise, uninstall Cisco Secure Client (removes the profile folder) and clear any related Credential Manager entry; delete `preferences.xml`.
- **Survives:** Your corporate account/cert is managed server-side by IT. SSD remnants until TRIM.
- **Admin:** No to read the profile XML (ProgramData is user-readable); uninstalling needs admin.

### Windows built-in VPN & dial-up (RAS phonebook)
- **Where:** `%APPDATA%\Microsoft\Network\Connections\Pbk\rasphone.pbk` (per-user). A system phonebook exists at `%ProgramData%\Microsoft\Network\Connections\Pbk\rasphone.pbk`.
- **Reveals:** Configured **VPN/dial connections** — connection names, server addresses, and protocol. Saved sign-in credentials for them live in Credential Manager.
- **Remove (user runs):** Settings > Network & internet > **VPN** > remove each connection; then clear any matching Credential Manager entry.
- **Survives:** The VPN account at the gateway is unaffected. SSD remnants until TRIM; the system phonebook needs admin.
- **Admin:** No for the per-user phonebook/Settings; the system phonebook needs admin.

### KeePass / KeePassXC databases
- **Where:** `.kdbx` database files wherever you keep them (often `%USERPROFILE%\Documents`, OneDrive, or a USB). Recent-file lists and settings: KeePass `%APPDATA%\KeePass\KeePass.config.xml`; KeePassXC `%APPDATA%\keepassxc\keepassxc.ini`. A key-file (second factor) may sit alongside.
- **Reveals:** The `.kdbx` holds **all your passwords**, strongly encrypted under your master password/key-file. Even if the new owner can't open it, the **config's recent-files list reveals the database name and path** (and that you use one), and a weak master password can be brute-forced offline from the file.
- **Remove (user runs):** Move any database you're keeping to backup, then delete the `.kdbx`, any key-file, and clear the recent-files list (KeePass: Tools > Options, or delete `KeePass.config.xml`; KeePassXC: delete `keepassxc.ini`).
- **Survives:** Cloud-synced copies (OneDrive/Dropbox/Google Drive) remain until deleted there and sync is stopped. SSD remnants until TRIM. An unchanged master password means any leaked copy stays as strong (or weak) as that password.
- **Admin:** No.

### Bitwarden desktop vault cache
- **Where:** `%APPDATA%\Bitwarden\data.json` (and the `%APPDATA%\Bitwarden\` folder).
- **Reveals:** Your **account email in plaintext**, server/region, sync timestamps, and an **encrypted copy of the vault**; if "unlock with PIN/biometrics" was enabled, a protected key that lets the vault be unlocked on this device.
- **Remove (user runs):** In the app, **Log out** (this clears the local vault and PIN/biometric unlock), then Settings > Account > optionally remove the device session; uninstall and delete `%APPDATA%\Bitwarden`.
- **Survives:** Your Bitwarden **account and its vault live on the server** and are untouched by local removal (that's intended — it's your vault). SSD remnants until TRIM.
- **Admin:** No.

### 1Password desktop data
- **Where:** `%LOCALAPPDATA%\1Password\` — `1password.sqlite` (encrypted local cache), `settings.json`, logs. (1Password 8 has no standalone local vault file; this is a cache of your account.)
- **Reveals:** Your **account email / sign-in address** and an encrypted cache of items; which accounts were signed in.
- **Remove (user runs):** In the app, sign out of / **remove each account**, then quit and delete `%LOCALAPPDATA%\1Password`. Remove this device from your 1Password account (my.1password.com > Devices). Your Secret Key + master password remain your real protection.
- **Survives:** The 1Password **account/vault on the server** is unaffected (intended). SSD remnants until TRIM.
- **Admin:** No.

### Other local vaults (Enpass, etc.) & Remote Desktop credentials
- **Where:** Enpass: `%APPDATA%\Enpass\` plus vault files (e.g. `vault.enpassdb`/`.walletx`) often in `%USERPROFILE%\Documents\Enpass\` or a synced folder. **Remote Desktop:** saved `.rdp` files (the hidden `%USERPROFILE%\Documents\Default.rdp` and any you saved), the recent-server list in `HKCU:\Software\Microsoft\Terminal Server Client\Default` and `HKCU:\Software\Microsoft\Terminal Server Client\Servers\` (hosts + `UsernameHint`); saved RDP passwords are in **Credential Manager** as `TERMSRV/<host>`.
- **Reveals:** Enpass — an encrypted vault plus account/email and its path. RDP — **every machine you remoted into, the usernames, and saved passwords** (via Credential Manager), i.e. a map of servers you can reach.
- **Remove (user runs):** Enpass: sign out / delete the vault in-app, then delete `%APPDATA%\Enpass` and the vault file; handle any cloud-synced copy. RDP: delete `.rdp` files; remove `TERMSRV/*` entries in **Credential Manager**; the registry MRU/`Servers` list is cleared by the user via the Remote Desktop app's drop-down history or a Reset-this-PC (hand-editing the registry is advanced).
- **Survives:** Cloud copies of Enpass vaults remain until removed there. RDP: the remote hosts still trust those passwords until you change them; registry hive copies live in restore points; SSD remnants until TRIM.
- **Admin:** No.

---

**What this cluster cannot reach by itself:** server-side validity of every key, token, and password listed above (rotate/revoke at the service), cloud copies of password-manager vaults and synced `.kdbx` files, SSD/NVMe spare-cell remnants until TRIM or a full overwrite/sanitize, TPM-held key material (clear the TPM, BitLocker key in hand), on-sensor fingerprint templates, and anything already captured in a disk image, backup, or restore point. The thorough end-state is to rotate the secrets at their services **and** remove the Windows account/profile (or Reset-this-PC) so the DPAPI keys that protected everything are gone too.

---

## More credentials: remote, database, CLI, managers & VPN

### MobaXterm saved sessions & passwords
- **Where:** Installer edition: `%APPDATA%\MobaXterm\MobaXterm.ini` (since v4.5 saved passwords default to this INI) and the registry `HKCU:\Software\Mobatek\MobaXterm` (older installs keep passwords here — subkey `C` = credentials, `P` = passwords, `M` = the DPAPI-protected master password). Portable edition: `MobaXterm.ini` beside `MobaXterm.exe`. The local-terminal home / "slash" root with your files, downloads and macros is `%USERPROFILE%\Documents\MobaXterm`.
- **Reveals:** Every saved SSH/RDP/VNC/SFTP/serial session — hostnames, usernames, ports, jump hosts — plus the saved passwords/credentials themselves. The home folder can hold downloaded files and scripts you pulled from those servers.
- **Remove (user runs):** In MobaXterm: delete each session, then Settings to clear/reset, or just uninstall and delete `%APPDATA%\MobaXterm` and `%USERPROFILE%\Documents\MobaXterm`; for an old registry install the user can run `reg delete "HKCU\Software\Mobatek\MobaXterm" /f`.
- **Survives:** The master password is only a partial safeguard — a user who can log in as you (or has your DPAPI key) can decrypt the saved passwords, so treat them as compromised and **change them on each server**. SSD remnants until TRIM; registry hive copies in restore points.
- **Admin:** No.

### SecureCRT / SecureFX sessions
- **Where:** `%APPDATA%\VanDyke\Config\Sessions\*.ini` (one INI per saved session), plus `%APPDATA%\VanDyke\Config\` for `Identity`, global config, and the `Keys` folder (SSH keys SecureCRT manages).
- **Reveals:** Saved SSH/Telnet/SFTP sessions — hostnames, usernames, ports, firewall/jump settings — and, unless you set a "config passphrase," saved passwords stored with reversible protection. Session file *names* alone map your servers.
- **Remove (user runs):** In SecureCRT delete each session (Session Manager), or close the app and delete `%APPDATA%\VanDyke`. Delete any private keys in `%APPDATA%\VanDyke\Config\Keys` you no longer need.
- **Survives:** Server-side access persists until you change those passwords/rotate those keys there. SSD remnants until TRIM.
- **Admin:** No.

### Royal TS connection documents & settings
- **Where:** Application settings/preferences: `%APPDATA%\code4ward` (v6 default; file names vary by version, e.g. `code4ward.RoyalTS.UserPreferences.config` / `appsettings.json`). Your actual connections live in **document files you saved** — `.rtsz` (compressed) or `.rtsx` (XML) — wherever you chose, most often `%USERPROFILE%\Documents` or a synced folder.
- **Reveals:** A full inventory of remote systems — RDP/SSH/VNC/web/database connections, hostnames, usernames, and any credentials stored inside the document (Royal TS can embed them, optionally under a document password).
- **Remove (user runs):** Locate and delete the `.rtsz`/`.rtsx` documents (back up any you keep), then uninstall and delete `%APPDATA%\code4ward`. Check any cloud-synced copy of the document.
- **Survives:** A document protected only by a weak password can be brute-forced offline from a leaked copy — **rotate credentials on the systems it listed**. Cloud-synced document copies remain until removed there; SSD remnants until TRIM.
- **Admin:** No.

### KiTTY saved sessions & host keys
- **Where:** Default (like its PuTTY parent) in the registry: `HKCU:\Software\9bis.com\KiTTY\Sessions\` (one subkey per session) and `HKCU:\Software\9bis.com\KiTTY\SshHostKeys\`. Portable mode (`savemode=dir` in a `kitty.ini` beside the exe) stores sessions in a `Sessions\` folder next to the program instead.
- **Reveals:** Servers you administer — hostnames, usernames, ports, any saved proxy password — and, via `SshHostKeys`, a list of every host you connected to. KiTTY adds auto-login/command fields that may hold more.
- **Remove (user runs):** In KiTTY delete each session; to clear everything the user can run `reg delete "HKCU\Software\9bis.com\KiTTY" /f`, or delete the portable `Sessions\` folder and `kitty.ini`. Delete any `.ppk` private keys separately.
- **Survives:** Server-side access persists until passwords/keys are changed there; registry hive copies in restore points; SSD remnants until TRIM.
- **Admin:** No.

### Termius data
- **Where:** `%APPDATA%\Termius` (the Electron app's data — local cache of hosts, groups, and sync state; the account email appears here).
- **Reveals:** Your Termius account identity and a local cache of SSH/SFTP/port-forward hosts, usernames, and group structure. With a Termius subscription, credentials/keys sync into this encrypted cache.
- **Remove (user runs):** In Termius, log out (clears the local cache), then uninstall and delete `%APPDATA%\Termius`. Remove this device from your account at the Termius web console.
- **Survives:** Your Termius **account vault lives on their servers** and is untouched by local removal — that is intended; sign out and drop the device. Hosts still trust your keys/passwords until changed there. SSD remnants until TRIM.
- **Admin:** No.

### mRemoteNG connections file
- **Where:** `%APPDATA%\mRemoteNG\confCons.xml` (saved connections), plus `mRemoteNG.settings` and backups `confCons.xml.backup*` in the same folder.
- **Reveals:** RDP/SSH/VNC/HTTP connections with hostnames, usernames, domains — and **passwords stored in the file**. By default mRemoteNG encrypts them with a built-in/known passphrase unless you set a custom one, so default-protected passwords are effectively recoverable from the file.
- **Remove (user runs):** Close mRemoteNG and delete `%APPDATA%\mRemoteNG` (including the `*.backup` copies), or uninstall. If you keep a connection file, set a strong custom password on it first.
- **Survives:** Default-encrypted passwords should be treated as exposed — **change them on each target system**. Backup copies of `confCons.xml` elsewhere and SSD remnants persist until removed/TRIM.
- **Admin:** No.

### OpenSSH ssh-agent persisted keys (registry)
- **Where:** `HKCU:\Software\OpenSSH\Agent\Keys` — when the Windows OpenSSH `ssh-agent` service is running and you `ssh-add` a key, the agent stores it here (DPAPI-encrypted) so it survives reboots and re-offers it without you re-loading the file.
- **Reveals:** That private keys were loaded into the agent and persist on this machine; subkey/comment names can indicate which identities. (The private key *files* themselves are the `.ssh` folder, covered in the Credentials, keys & secrets cluster.)
- **Remove (user runs):** `ssh-add -D` clears keys from the running agent; to wipe the persisted cache the user can run `reg delete "HKCU\Software\OpenSSH\Agent\Keys" /f`. Consider stopping and disabling the `ssh-agent` service.
- **Survives:** The matching **public key still sits in `authorized_keys` on every server/Git host** that trusts it — remove it there and treat the key as compromised. Stopping/disabling the service needs admin. Registry hive copies in restore points; SSD remnants until TRIM.
- **Admin:** No to clear your own keys; disabling the service needs admin.

### DBeaver connections & credentials
- **Where:** `%APPDATA%\DBeaverData\workspace6\General\.dbeaver\` — `data-sources.json` (connection definitions) and `credentials-config.json` (saved passwords, encrypted). (`workspace6` is the DBeaver 6+ folder; older builds vary.)
- **Reveals:** Every saved database connection — host, port, database name, username, driver — for Postgres/MySQL/Oracle/SQL Server/etc., and the saved passwords. Historically DBeaver's credential encryption used a fixed key, so stored passwords are recoverable unless you enabled a master password.
- **Remove (user runs):** In DBeaver delete each connection, or close the app and delete `%APPDATA%\DBeaverData`. 
- **Survives:** The database servers still accept those credentials until you **change them there**. SSD remnants until TRIM; any exported connection/workspace backups elsewhere.
- **Admin:** No.

### pgAdmin saved servers
- **Where:** `%APPDATA%\pgAdmin\pgadmin4.db` (SQLite: server/group definitions; if you ticked "Save password," the password is stored encrypted here). Logs/session files sit alongside in `%APPDATA%\pgAdmin\`.
- **Reveals:** Your PostgreSQL servers — host, port, database, username, and saved passwords for them.
- **Remove (user runs):** In pgAdmin remove each saved server (and clear saved passwords), or close pgAdmin and delete `%APPDATA%\pgAdmin`.
- **Survives:** Servers still accept the credentials until **changed on the server**. SSD remnants until TRIM.
- **Admin:** No.

### HeidiSQL sessions (registry)
- **Where:** `HKCU:\Software\HeidiSQL\Servers\` (one subkey per saved session) and `HKCU:\Software\HeidiSQL` for settings.
- **Reveals:** Saved MySQL/MariaDB/MSSQL/Postgres sessions — host, port, user, database, SSH-tunnel settings — and the saved password stored with weak, reversible obfuscation.
- **Remove (user runs):** In HeidiSQL's Session manager delete each session, or the user can run `reg delete "HKCU\Software\HeidiSQL" /f`. (HeidiSQL portable can export to a file instead — delete that too.)
- **Survives:** Treat saved passwords as recoverable and **change them on the server**. Registry hive copies in restore points; SSD remnants until TRIM.
- **Admin:** No.

### MySQL Workbench connections
- **Where:** `%APPDATA%\MySQL\Workbench\connections.xml` (saved connections). Saved passwords are kept separately in Workbench's "vault" under `%APPDATA%\MySQL\Workbench\` / the Windows secret store, not in `connections.xml` itself.
- **Reveals:** MySQL servers — host, port, username, schema, SSH-tunnel details — and, via the vault, the saved passwords.
- **Remove (user runs):** In Workbench remove each stored connection and its saved password, or close Workbench and delete `%APPDATA%\MySQL\Workbench`.
- **Survives:** Servers still accept the credentials until **changed there**. SSD remnants until TRIM.
- **Admin:** No.

### SSMS connection history
- **Where:** `%APPDATA%\Microsoft\SQL Server Management Studio\<version>\` — `UserSettings.xml` on SSMS 18 and later (19/20/21), or `SqlStudio.bin` on SSMS 17 and earlier. Holds the "Connect to Server" most-recently-used list.
- **Reveals:** The SQL Server instances you connected to (server names/IPs), the login names used, and whether SQL vs. Windows auth — a map of your database estate. (SSMS does not store the actual passwords here; those, if saved, are in Windows Credential Manager.)
- **Remove (user runs):** In the Connect dialog, highlight an entry and press **Delete** to drop it (SSMS 2012+). To clear all history, close SSMS and delete/rename `UserSettings.xml` (or `SqlStudio.bin`) — note this also resets other SSMS preferences. Clear any saved SQL passwords in Credential Manager.
- **Survives:** The servers themselves are untouched; SSD remnants until TRIM; any saved passwords in Credential Manager must be removed there.
- **Admin:** No.

### JetBrains DataGrip / IDE data sources
- **Where:** Global config: `%APPDATA%\JetBrains\DataGrip<version>\` (and the same pattern for IntelliJ IDEA, PyCharm, etc., which embed the database tool). Per-project definitions live in the project's `.idea\dataSources.xml` and `.idea\dataSources.local.xml`. Saved DB passwords go to the OS credential store or to a KeePass-format `c.kdbx` in the IDE config folder.
- **Reveals:** Database connections — host, port, database, user, driver — across your projects, and (via the keystore) saved passwords. `.idea` folders inside project checkouts leak the same per repo.
- **Remove (user runs):** In the IDE's Database tool remove each data source and clear saved passwords (File | Settings | Appearance & Behavior | System Settings | Passwords), then delete the project `.idea\dataSources*.xml`. Uninstalling and deleting `%APPDATA%\JetBrains\DataGrip<version>` clears the global config and keystore.
- **Survives:** Databases still accept the credentials until **changed there**. Copies of `.idea` files in any repo clone/backup remain; SSD remnants until TRIM.
- **Admin:** No.

### GitHub CLI token
- **Where:** `%APPDATA%\GitHub CLI\hosts.yml` (OAuth token / PAT per host) and `config.yml` in the same folder. (If configured with a credential helper, the token may be in Windows Credential Manager instead.)
- **Reveals:** Your GitHub/GitHub Enterprise **account login and an active access token** — enough to read/write your repos and act as you — plus which hosts you authenticated to.
- **Remove (user runs):** `gh auth logout` (per host), then delete `%APPDATA%\GitHub CLI`. **Revoke the token/authorization** at github.com > Settings > Applications / Developer settings.
- **Survives:** The token keeps working at GitHub until revoked there; SSD remnants until TRIM.
- **Admin:** No.

### HashiCorp Vault token
- **Where:** `%USERPROFILE%\.vault-token` (the `vault` CLI writes the current token here after login).
- **Reveals:** A live Vault **authentication token** — whatever secrets/policies your identity can read in that Vault server.
- **Remove (user runs):** `vault token revoke -self` (revokes it server-side), then delete `%USERPROFILE%\.vault-token`.
- **Survives:** If you only delete the file, the token stays valid at the Vault server until it expires or is revoked — revoke it. SSD remnants until TRIM.
- **Admin:** No.

### Terraform Cloud / Enterprise credentials
- **Where:** `%APPDATA%\terraform.d\credentials.tfrc.json` (API tokens per Terraform Cloud/Enterprise host). A `.terraformrc` in `%APPDATA%\terraform.d` may also reference credentials.
- **Reveals:** API **token(s) for Terraform Cloud/Enterprise** — access to your workspaces, state, and variables (which often themselves contain cloud secrets), plus the org/host names.
- **Remove (user runs):** `terraform logout` (removes the stored token), then delete `%APPDATA%\terraform.d\credentials.tfrc.json`. **Revoke the token** in Terraform Cloud > User Settings > Tokens.
- **Survives:** The token works until revoked server-side; remote state in Terraform Cloud is untouched. SSD remnants until TRIM.
- **Admin:** No.

### Heroku CLI credentials
- **Where:** `%USERPROFILE%\_netrc` (Windows naming; `machine api.heroku.com` and `machine git.heroku.com` entries hold the API token in plaintext). Newer Heroku CLI versions prefer the Windows Credential Manager (PasswordVault) instead. *(This is the same `_netrc`/`.netrc` file noted generically in the Credentials, keys & secrets cluster — the Heroku-specific angle is the `api.heroku.com` token line.)*
- **Reveals:** A live **Heroku API token** — control of your apps, config vars (which hold other secrets), add-ons, and billing — and your account email.
- **Remove (user runs):** `heroku logout` (clears the stored token), then remove the Heroku lines from `%USERPROFILE%\_netrc` (or delete the file if nothing else uses it) and clear any Heroku entry in Credential Manager. **Revoke the token** at Heroku Account Settings > Applications, or with `heroku authorizations:revoke`.
- **Survives:** The token works at Heroku until revoked there; other `machine` entries in `_netrc` belong to other services. SSD remnants until TRIM.
- **Admin:** No.

### Databricks CLI configuration
- **Where:** `%USERPROFILE%\.databrickscfg` (per-profile `host` + `token` / OAuth or PAT).
- **Reveals:** Databricks **workspace URL(s) and personal access token(s)** — access to your notebooks, jobs, clusters, and data, plus which workspaces you use.
- **Remove (user runs):** Delete `%USERPROFILE%\.databrickscfg`. **Revoke the PAT** in the Databricks workspace > Settings > Developer > Access tokens.
- **Survives:** The token works until revoked in the workspace; SSD remnants until TRIM.
- **Admin:** No.

### Snowflake SnowSQL / CLI configuration
- **Where:** SnowSQL: `%USERPROFILE%\.snowsql\config` (named connections — account, user, and optionally password/private-key path). Newer Snowflake CLI (`snow`): `%USERPROFILE%\.snowflake\config.toml`. Connection/token caches may also sit under `%USERPROFILE%\.snowsql\` / `%USERPROFILE%\.snowflake\`.
- **Reveals:** Your Snowflake **account identifier, username, role/warehouse**, and any stored password or pointer to a private key — access to your data warehouse.
- **Remove (user runs):** Remove the stored credentials from `.snowsql\config` (or delete `%USERPROFILE%\.snowsql`) and delete `%USERPROFILE%\.snowflake`. **Rotate the password / key-pair** in Snowflake if it was stored.
- **Survives:** Snowflake still accepts the credential until **rotated there**; any referenced private-key file persists until deleted; SSD remnants until TRIM.
- **Admin:** No.

### DigitalOcean doctl configuration
- **Where:** `%APPDATA%\doctl\config.yaml` (API access token(s) and context).
- **Reveals:** A DigitalOcean **API token** — control of your droplets, databases, Spaces, DNS, and billing.
- **Remove (user runs):** Delete `%APPDATA%\doctl`. **Revoke the token** in the DigitalOcean control panel > API > Tokens.
- **Survives:** The token works until revoked there; SSD remnants until TRIM.
- **Admin:** No.

### Cloudflare cloudflared & Wrangler credentials
- **Where:** cloudflared: `%USERPROFILE%\.cloudflared\cert.pem` (the account "origin certificate" that authorizes managing tunnels/DNS) and `<tunnel-UUID>.json` (per-tunnel secret) in the same folder; a service install copies the cert under `%WINDIR%\System32\config\systemprofile\.cloudflared`. Wrangler (Workers): an OAuth access/refresh token in a plaintext TOML under its global config dir — commonly `%APPDATA%\xdg.config\.wrangler\config\default.toml` (the exact path has changed across Wrangler versions).
- **Reveals:** cloudflared `cert.pem` is effectively **account-level access** to create tunnels and edit DNS for your zones; Wrangler's token grants **Workers/account access** and exposes your account email. Tunnel JSONs expose your tunnel IDs/routes.
- **Remove (user runs):** Delete `%USERPROFILE%\.cloudflared`; run `wrangler logout` and delete its config. **Revoke the credentials in the Cloudflare dashboard** (My Profile > API Tokens; and rotate the Argo tunnel cert). Confirm the exact Wrangler path with `wrangler whoami`.
- **Survives:** Tokens/certs keep working at Cloudflare until revoked there; the service-profile copy needs admin to remove; SSD remnants until TRIM.
- **Admin:** No for the per-user files; the `systemprofile\.cloudflared` service copy needs admin.

### LastPass local vault cache
- **Where:** The **browser extension** keeps an encrypted vault cache inside the browser profile, e.g. `...\User Data\Default\databases\chrome-extension_<extension-id>_0\` (Chrome/Edge). The **LastPass for Desktop** app keeps its cache under `%LOCALAPPDATA%\LastPass` (folder name can vary by build).
- **Reveals:** Your **LastPass account email** and an encrypted copy of the vault; that you use LastPass and were signed in on this device. The cache is encrypted under your master password, but a leaked copy can be attacked offline.
- **Remove (user runs):** Log out of the extension/app (clears the local cache), remove the browser extension, and for the desktop app choose Help > Troubleshoot > "Clear cache and reload" then uninstall. Sign out all devices at lastpass.com > Account Settings.
- **Survives:** Your LastPass **account/vault on the server** is untouched (intended) — change your master password if the machine is leaving your hands. Browser-profile copies live with the browser data until that profile is removed; SSD remnants until TRIM.
- **Admin:** No.

### Dashlane local data
- **Where:** `%LOCALAPPDATA%\Dashlane` for the desktop app's local data (current Dashlane is extension-first, so the encrypted cache may instead live inside the browser profile's extension storage).
- **Reveals:** Your **Dashlane account email** and an encrypted local copy of the vault; that you used Dashlane on this device.
- **Remove (user runs):** Log out in the app/extension (clears the local cache), remove the extension, uninstall the desktop app, and delete `%LOCALAPPDATA%\Dashlane`. Remove this device at the Dashlane web console.
- **Survives:** The Dashlane **account/vault on the server** is untouched (intended); change your master password if selling the machine. SSD remnants until TRIM.
- **Admin:** No.

### NordPass local data
- **Where:** `%APPDATA%\NordPass` (and/or `%LOCALAPPDATA%\NordPass`) — the desktop app's local cache and signed-in session.
- **Reveals:** Your **NordPass/Nord Account email** and an encrypted local copy of the vault; that you used NordPass here.
- **Remove (user runs):** Log out in the app (clears the local cache), uninstall, and delete `%APPDATA%\NordPass` / `%LOCALAPPDATA%\NordPass`. Remove the device in your Nord Account.
- **Survives:** The **account/vault on Nord's servers** is untouched (intended); change your master password if handing over the PC. SSD remnants until TRIM.
- **Admin:** No.

### RoboForm local data
- **Where:** `%LOCALAPPDATA%\RoboForm\Profiles\Default Profile` (and the parent `%LOCALAPPDATA%\RoboForm`) — logins, identities, and safenotes cache for the desktop app. The data folder is user-configurable in the app (Account & Data > Advanced > Select Data Folder).
- **Reveals:** Your **RoboForm account email** and an encrypted local copy of your logins/identities; that you used RoboForm here.
- **Remove (user runs):** Log out / sign out in RoboForm (clears the local data), uninstall, and delete `%LOCALAPPDATA%\RoboForm` (and any custom data folder you set). Remove the device in your RoboForm Online account.
- **Survives:** The **account/vault on RoboForm's servers** is untouched (intended); change your master password if selling. SSD remnants until TRIM.
- **Admin:** No.

### Proton Pass local data
- **Where:** `%APPDATA%\Proton Pass` and `%LOCALAPPDATA%\Proton Pass` — the Windows app's data and offline cache (per Proton, both are removed when uninstalling).
- **Reveals:** Your **Proton account email** and an encrypted offline copy of the vault; that you used Proton Pass here.
- **Remove (user runs):** Sign out in the app (clears the local cache), uninstall, and delete `%APPDATA%\Proton Pass` and `%LOCALAPPDATA%\Proton Pass`. Remove the session/device at account.proton.me.
- **Survives:** The **account/vault on Proton's servers** is untouched (intended); change your password if handing over the machine. SSD remnants until TRIM.
- **Admin:** No.

### KeeWeb configuration & recent-database list
- **Where:** `%APPDATA%\KeeWeb` (the Electron app's config and state, including the **list of recently opened `.kdbx` databases** and their paths). The `.kdbx` files themselves sit wherever you keep them (Documents, OneDrive, USB).
- **Reveals:** That you use a KeePass-format vault, and — via the recent-files list — the **name and full path of each database** (and that it exists), even if the encrypted file itself can't be opened without the master password.
- **Remove (user runs):** In KeeWeb clear the recent-files list and close open files, then uninstall and delete `%APPDATA%\KeeWeb`. Move any `.kdbx` you keep to offline backup and delete it from this PC.
- **Survives:** Cloud-synced `.kdbx` copies remain until removed there and sync is stopped; a weak master password means a leaked database can be attacked offline; SSD remnants until TRIM. *(The KeePass/KeePassXC desktop apps are covered in the Credentials, keys & secrets cluster.)*
- **Admin:** No.

### NordVPN account & device state
- **Where:** `%LOCALAPPDATA%\NordVPN` (user config / signed-in session, typically in versioned subfolders) and `%ProgramData%\NordVPN`; the app and diagnostics are under `C:\Program Files\NordVPN`.
- **Reveals:** That you had a NordVPN subscription and were signed in on this device — your account session, chosen servers/favorites, and settings. (NordLynx uses a WireGuard key tied to this device.)
- **Remove (user runs):** Open NordVPN and **Log out**, then uninstall (choose to remove settings) and delete `%LOCALAPPDATA%\NordVPN` / `%ProgramData%\NordVPN`. Change your Nord Account password if the PC is leaving your hands.
- **Survives:** Your **Nord Account on the server** is untouched by local removal; the account still exists until you close/secure it. SSD remnants until TRIM; the ProgramData/Program Files parts need admin to remove.
- **Admin:** No to log out; uninstalling / removing machine-wide folders needs admin.

### ExpressVPN account & device state
- **Where:** `%LOCALAPPDATA%\ExpressVPN` (and/or `%APPDATA%\ExpressVPN`) — the app's local data and signed-in session (holds files such as the server list); the app installs under `C:\Program Files (x86)\ExpressVPN`.
- **Reveals:** That you had an ExpressVPN subscription and were signed in here — your activation/session state, preferences, and recent locations.
- **Remove (user runs):** In ExpressVPN **Sign out**, then uninstall and delete `%LOCALAPPDATA%\ExpressVPN` / `%APPDATA%\ExpressVPN`. Change your ExpressVPN account password if selling the PC.
- **Survives:** The **account on ExpressVPN's servers** is untouched locally; SSD remnants until TRIM; machine-wide files need admin.
- **Admin:** No to sign out; uninstalling needs admin.

### Proton VPN logs & settings
- **Where:** `%LOCALAPPDATA%\ProtonVPN\Logs` (app logs), settings under `%APPDATA%\ProtonVPN` / `%APPDATA%\ProtonVPN AG`, and service/updater logs under `%ProgramData%\ProtonVPN\`. (App installs under `C:\Program Files\Proton\VPN`.)
- **Reveals:** Your **Proton account** was signed in here; logs and settings reveal servers used, connection times, and the device's WireGuard/IKEv2 config. 
- **Remove (user runs):** Sign out in the app, uninstall, and delete `%LOCALAPPDATA%\ProtonVPN`, `%APPDATA%\ProtonVPN*`, and `%ProgramData%\ProtonVPN`. Remove the session at account.proton.me and change your password if handing over the PC.
- **Survives:** The **Proton account on the server** is untouched locally; the device's VPN key stays valid at Proton until the session is removed there. SSD remnants until TRIM; ProgramData needs admin.
- **Admin:** No to sign out; removing the ProgramData logs and uninstalling need admin.

### Surfshark account & device state
- **Where:** `%LOCALAPPDATA%\Surfshark` (app data and signed-in session); the app installs under `C:\Program Files\Surfshark`.
- **Reveals:** That you had a Surfshark subscription and were signed in here — session/activation state, preferences, and recent servers.
- **Remove (user runs):** In Surfshark **Log out**, then uninstall and delete `%LOCALAPPDATA%\Surfshark`. Change your Surfshark account password if the PC is leaving you.
- **Survives:** The **account on Surfshark's servers** is untouched locally; SSD remnants until TRIM; machine-wide files need admin.
- **Admin:** No to log out; uninstalling needs admin.

### Mullvad VPN settings & device key
- **Where:** `%ProgramData%\Mullvad VPN\settings.json` (the daemon's settings — your **WireGuard private key / device registration** and relay choices) plus logs and `cache\` in `%ProgramData%\Mullvad VPN\`; the GUI keeps data in `%LOCALAPPDATA%\Mullvad VPN\`.
- **Reveals:** That Mullvad was used here, the device's WireGuard key material, and your relay/protocol settings. Mullvad accounts are a numeric **account number** (no email) that the app held while logged in.
- **Remove (user runs):** In the app log out and then uninstall (or run a factory reset / `mullvad account logout`), which removes the device key and settings; delete any leftover `%ProgramData%\Mullvad VPN` and `%LOCALAPPDATA%\Mullvad VPN`. **Remove this device** in your Mullvad account and note the account number has credit/identity value — don't leave it behind.
- **Survives:** The **account (number) and any registered device** persist at Mullvad until you remove the device/close the account; SSD remnants until TRIM.
- **Admin:** Reading/clearing the `%ProgramData%\Mullvad VPN` daemon store needs admin (it holds private keys); logging out via the app is user-level.

### Tailscale node state
- **Where:** `%ProgramData%\Tailscale\` — the daemon state file (`server-state.conf`, or `tailscaled.state` on some versions) holding this node's **private key and auth to your tailnet** (access-restricted). The GUI/user data and logs are under `%LOCALAPPDATA%\Tailscale\`; older builds kept state under `%LOCALAPPDATA%` too.
- **Reveals:** That this machine was a node in your tailnet — its node identity/key, your tailnet (often tied to a Google/Microsoft/GitHub identity), and, via logs, the peers it reached.
- **Remove (user runs):** `tailscale logout` (or Log out in the GUI) to deregister, then uninstall; delete any leftover `%ProgramData%\Tailscale` and `%LOCALAPPDATA%\Tailscale`. **Remove the machine** from the Tailscale admin console (Machines > this device > Remove).
- **Survives:** The device may remain listed in your tailnet until you remove it in the admin console; the identity provider account is untouched. Reading the ProgramData state needs admin; SSD remnants until TRIM.
- **Admin:** Reading/clearing the `%ProgramData%\Tailscale` state needs admin; logout/uninstall is user-level (uninstall needs admin).

---

## Activity history & forensic traces

### Recent Items folder
- **Where:** `%APPDATA%\Microsoft\Windows\Recent` — one `.lnk` shortcut per recently opened file or folder, each embedding the original full path, and often the file's size and timestamps.
- **Reveals:** names and full paths of documents, media, and folders the previous user opened, including items on USB sticks, external drives, and network shares that are no longer attached. The targets can be gone while the shortcuts remain.
- **Remove (user runs):** turn off the feed first — Settings > Personalization > Start > off for "Show recently opened items in Jump Lists on Start or the taskbar and in File Explorer"; then empty the folder, e.g. the user runs `Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\*" -Recurse -Force`.
- **Survives:** on an SSD the freed bytes linger until TRIM/garbage collection or overwrite, so carving can recover deleted `.lnk` files; shortcuts reappear as soon as files are opened again (clean this last); copies may sit in restore points, `Windows.old`, and backups.
- **Admin:** no.

### Jump Lists — Automatic Destinations
- **Where:** `%APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*.automaticDestinations-ms` — one file per application, named by a fixed AppID; each is an OLE compound file holding that app's recent-items list.
- **Reveals:** per-application history of files opened (Word, Excel, PDF readers, media players, File Explorer, etc.) with full paths and access times — effectively a per-app "recently used" log that outlives the apps' own clear-history buttons.
- **Remove (user runs):** same Start toggle as above turns the feed off; then the user empties the folder, e.g. `Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\AutomaticDestinations\*" -Force`. Right-clicking individual taskbar jump-list entries and choosing "Remove from this list" clears them one at a time.
- **Survives:** SSD remnants until overwrite; files rebuild as apps are used again; cloud/office apps keep their own server-side recent lists (see browser/app sections); restore points and backups.
- **Admin:** no.

### Jump Lists — Custom Destinations
- **Where:** `%APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*.customDestinations-ms` — one file per application, holding the app-defined/"pinned" and task entries a program adds to its jump list.
- **Reveals:** pinned files and shortcuts a user deliberately kept on an app's jump list — often their most-used documents, projects, or sites.
- **Remove (user runs):** unpin entries from the taskbar jump list ("Unpin from this list"), or empty the folder: `Remove-Item "$env:APPDATA\Microsoft\Windows\Recent\CustomDestinations\*" -Force`.
- **Survives:** SSD remnants until overwrite; files regenerate when the app rebuilds its jump list; backups and restore points.
- **Admin:** no.

### Quick Access (File Explorer)
- **Where:** the "Recent files" and "Frequent folders" shown when File Explorer opens. It is a view built from `%APPDATA%\Microsoft\Windows\Recent` and the File Explorer entries inside `AutomaticDestinations` (AppIDs `f01b4d95cf55d32a` and `5f7b5f1e01b83767`); there is no separate database.
- **Reveals:** at-a-glance list of the folders a user worked in most and the files they touched most recently — the single most immediately visible trace a buyer sees on first login.
- **Remove (user runs):** File Explorer > "..." > Options > General > Privacy > click **Clear** ("Clear File Explorer history"), and uncheck "Show recently used files" and "Show frequently used folders".
- **Survives:** because it is a view over the Recent folder and jump lists, it returns if those sources are not also cleared; it repopulates as soon as files/folders are opened again.
- **Admin:** no.

### RecentDocs
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RecentDocs` — a parent key plus one subkey per file extension (`.docx`, `.jpg`, ...) and a `Folder` subkey, each with an ordered MRUListEx.
- **Reveals:** the file names (not just paths) most recently opened per type, and the order they were used; a compact index of "what kinds of files this person worked with, and the latest ones."
- **Remove (user runs):** clearing recent items (the Start toggle above) empties most of this; a full account/Windows reset clears it reliably. Direct registry editing is advanced and optional.
- **Survives:** repopulates on next file open; old values persist in the hive's `.LOG1`/`.LOG2` transaction logs and in restore points/`Windows.old` until those are cleared; SSD remnants of the hive.
- **Admin:** no.

### Run dialog history (RunMRU)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU` — the command history of the Win+R "Run" box, stored as lettered values with an MRUList order.
- **Reveals:** commands, program names, UNC paths (`\\server\share`), and URLs the user typed into Run — sometimes admin tools, remote hosts, or install paths that hint at what the machine was used for.
- **Remove (user runs):** there is no Settings toggle; the reliable owner-handover method is a full Windows reset. A user who wants it gone now can clear the values in Registry Editor (advanced, optional).
- **Survives:** reappears as Run is used again; hive transaction logs, restore points, and `Windows.old` retain prior entries; SSD remnants.
- **Admin:** no.

### Explorer address-bar history (TypedPaths)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\TypedPaths` — values `url1`, `url2`, ... holding paths typed directly into the File Explorer address bar.
- **Reveals:** folders, drive letters, UNC network paths, and FTP/URL locations the user navigated to by typing — including external and network locations not otherwise recorded.
- **Remove (user runs):** clearing File Explorer history (Folder Options > Privacy > Clear) empties this list; a full reset clears it reliably.
- **Survives:** repopulates as new paths are typed; hive logs, restore points, `Windows.old`; SSD remnants.
- **Admin:** no.

### Explorer search-box history (WordWheelQuery)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\WordWheelQuery` — search terms typed into the File Explorer search box, as binary values with an MRUListEx order. The key is created only after Explorer search has been used (absent on machines that never searched).
- **Reveals:** keywords the user searched their own files for — names of people, projects, account numbers, or topics they were looking for on this PC.
- **Remove (user runs):** Folder Options > Privacy > Clear File Explorer history; or a full reset.
- **Survives:** repopulates with new searches; hive logs, restore points, `Windows.old`; SSD remnants.
- **Admin:** no.

### Open / Save common-dialog history (ComDlg32)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ComDlg32` and its subkeys: `OpenSavePidlMRU` (files chosen in Open/Save dialogs, grouped by extension), `LastVisitedPidlMRU` (the executable used and the last folder it opened a dialog in), `CIDSizeMRU` (dialog window sizes per app), and `FirstFolder` (the initial folder each app's dialog showed).
- **Reveals:** which programs opened or saved which files and from which folders — a cross-reference of app to file to location, often exposing attachments saved from mail, downloads, and external media.
- **Remove (user runs):** clearing File Explorer/recent history reduces this; a full account/Windows reset is the reliable method. Direct registry editing is advanced and optional.
- **Survives:** rebuilds as dialogs are used; hive logs, restore points, `Windows.old`; SSD remnants.
- **Admin:** no.

### Internet Explorer typed URLs (TypedURLs)
- **Where:** `HKCU:\Software\Microsoft\Internet Explorer\TypedURLs` (with companion `TypedURLsTime`) — addresses typed into the legacy IE/WebOC address bar. Still present on Windows 10/11 and populated by components and apps that host the old web control, even where the IE app itself is gone.
- **Reveals:** web addresses the user typed, including intranet sites and URLs with identifiers — residual browsing history outside the modern browser's own store.
- **Remove (user runs):** no Settings toggle; a full reset clears it. Advanced users can clear the values in Registry Editor.
- **Survives:** hive logs, restore points, `Windows.old`; SSD remnants; separate from (and not cleared by) Edge/Chrome "clear browsing data".
- **Admin:** no.

### UserAssist
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist` — GUID subkeys each with a `Count` subkey; value names are the program paths/names ROT13-encoded, with binary data holding run count, focus time, and last-execution timestamp.
- **Reveals:** which GUI programs and shortcuts the user actually launched, how many times, and when they last ran them — a reliable "what did they use this PC for" record even after the programs are uninstalled.
- **Remove (user runs):** there is no supported UI to clear it; the reliable owner-handover method is a full Windows reset. Clearing it selectively is advanced and not part of WipeWise's recommended path.
- **Survives:** rebuilds through normal use; hive transaction logs, restore points, and `Windows.old` retain prior data; SSD remnants.
- **Admin:** no.

### ShellBags (BagMRU / Bags)
- **Where:** per-user folder-view data in two locations: `HKCU:\Software\Microsoft\Windows\Shell\BagMRU` and `...\Shell\Bags`, and (primarily, in the USRCLASS hive) `HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\BagMRU` and `...\Shell\Bags`.
- **Reveals:** the hierarchy of folders the user browsed — including removable drives, network shares, mounted encrypted volumes, and folders that have since been deleted — plus view settings and timestamps. One of the strongest records that a now-gone folder or drive ever existed.
- **Remove (user runs):** no clean UI exists; shellbags rebuild as folders are browsed. The reliable owner-handover method is a full Windows reset. Selective registry deletion is advanced and rebuilds on next browse.
- **Survives:** regenerates with continued use; hive logs, restore points, `Windows.old`; SSD remnants.
- **Admin:** no.

### MUICache
- **Where:** `HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\MuiCache` (USRCLASS hive) — caches the friendly display names and paths of executables that have been run.
- **Reveals:** the full paths and product/description strings of programs that were executed on the account, including ones run once from a download folder or USB and since removed.
- **Remove (user runs):** no supported clear UI; a full Windows reset is the reliable method. Advanced users may delete entries in the registry (they rebuild on next launch).
- **Survives:** rebuilds through use; hive logs, restore points, `Windows.old`; SSD remnants.
- **Admin:** no.

### FeatureUsage
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage` with subkeys such as `AppLaunch`, `AppSwitched`, `AppBadgeUpdated`, `ShowJumpView`, and `TrayButtonClicked` (Windows 10 1903 and later).
- **Reveals:** which taskbar applications the user launched, switched to, and interacted with, and how often — a usage-frequency picture of pinned and running apps.
- **Remove (user runs):** no supported clear UI; a full Windows reset is the reliable method.
- **Survives:** repopulates as the taskbar is used; hive logs, restore points, `Windows.old`; SSD remnants.
- **Admin:** no.

### Prefetch
- **Where:** `%WINDIR%\Prefetch\*.pf` — one trace file per executable (named `NAME-HASH.pf`), plus layout files.
- **Reveals:** which programs ran, how many times, the first and last (and up to eight recent) run times, and the files and directories each program referenced at startup — a durable execution timeline, including programs run from USB or since uninstalled.
- **Remove (user runs):** reading or clearing requires an elevated session; the reliable owner-handover method is a full Windows reset (Settings > System > Recovery > Reset this PC > Remove everything), which replaces the folder. Disk Cleanup does not target it.
- **Survives:** partial `.pf` data persists in free space until overwrite on SSD; restore points and `Windows.old`; rebuilds as programs run if the system is kept in use.
- **Admin:** yes (to read or clear).

### Amcache.hve
- **Where:** `%WINDIR%\AppCompat\Programs\Amcache.hve` (with `.LOG` companions) — a registry hive the Application Experience service maintains.
- **Reveals:** executed and installed program entries with full file paths, SHA-1 hashes of the binaries, publisher/version, and first-run/install timestamps — including programs long since uninstalled or run from external media. A thorough inventory of "what was ever run here."
- **Remove (user runs):** protected; needs an elevated session even to read. The reliable method is a full Windows reset. WipeWise does not tamper with it selectively.
- **Survives:** a full reset replaces it; short of that it is rebuilt and retained; restore points and `Windows.old`; SSD remnants.
- **Admin:** yes.

### SRUM (System Resource Usage Monitor)
- **Where:** `%WINDIR%\System32\sru\SRUDB.dat` (ESE database), with configuration under `HKLM:\SYSTEM\CurrentControlSet\Services\SRUSvc`.
- **Reveals:** roughly 30–60 days of per-application usage — which user ran each app, CPU and disk use, and bytes sent/received per app and per network, plus which networks were connected. Shows app activity and data volumes even for apps later removed.
- **Remove (user runs):** protected database; needs an elevated session. The reliable owner-handover method is a full Windows reset. Not selectively edited by WipeWise.
- **Survives:** reset replaces it; otherwise retained and rolling; restore points and `Windows.old`; SSD remnants.
- **Admin:** yes.

### Background / Desktop Activity Moderator (BAM / DAM)
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Services\bam\State\UserSettings\<SID>` (and the parallel `dam` service on some systems) — one subkey per user SID listing executables with last-execution timestamps.
- **Reveals:** the full path of programs each user account ran and the last time each ran — a concise per-user execution record tied to the account's SID.
- **Remove (user runs):** lives in the protected SYSTEM hive; needs an elevated session. The reliable method is a full Windows reset. WipeWise reports it, it does not edit it.
- **Survives:** reset replaces it; otherwise maintained by the service; restore points and `Windows.old`; SSD remnants.
- **Admin:** yes.

### Application Compatibility Cache (ShimCache)
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\AppCompatCache`, value `AppCompatCache` — a single binary blob written from memory to the registry at shutdown.
- **Reveals:** file paths and last-modified times of executables the system encountered, evidencing that a program existed and (on many builds) was run — again covering binaries since deleted.
- **Remove (user runs):** it is a system-maintained SYSTEM-hive value flushed at shutdown; there is no clean user removal short of a full Windows reset, which WipeWise recommends for this artifact.
- **Survives:** rebuilt from memory at each shutdown; restore points, `Windows.old`, and the hive's logs retain prior content; SSD remnants.
- **Admin:** yes.

### Activity History / Timeline (ActivitiesCache.db)
- **Where:** `%LOCALAPPDATA%\ConnectedDevicesPlatform\<profile folder, e.g. L.<username>>\ActivitiesCache.db` (ESE database, with `.jfm`/`.log` companions). One profile folder per signed-in identity.
- **Reveals:** the Windows Timeline — apps used and documents/files opened (with paths), some web activity, and time ranges. If "Send my activity history to Microsoft" was ever on, copies were uploaded to the Microsoft account and could appear on the user's other devices.
- **Remove (user runs):** Settings > Privacy & security > Activity history > turn off "Store my activity history on this device" and click **Clear**. Then clear the cloud copy at the Microsoft account privacy dashboard (account.microsoft.com) and under the same Settings page's "Clear" for the account feed.
- **Survives:** the local clear does not remove cloud copies already uploaded — those must be cleared online; DB remnants persist in free space until overwrite; backups and restore points.
- **Admin:** no.

### Clipboard history & cloud clipboard
- **Where:** in-memory clipboard history (Win+V), up to ~25 recent entries; the registry key `HKCU:\Software\Microsoft\Clipboard` holds settings and pinned-item state; when clipboard history is enabled, persisted/pinned items are kept under `%LOCALAPPDATA%\Microsoft\Windows\Clipboard` (this folder is absent until the feature is turned on). With "Sync across devices" on, entries sync through the Microsoft account.
- **Reveals:** whatever was copied — passwords, one-time codes, card and account numbers, message text, addresses. Pinned entries deliberately persist across reboots.
- **Remove (user runs):** Settings > System > Clipboard > click **Clear** under "Clear clipboard data"; unpin any pinned items in the Win+V flyout (Clear does not remove pinned items); turn off "Clipboard history" and "Sync across devices"; sign-out/reboot clears the unpinned in-memory history.
- **Survives:** cloud-synced entries persist in the Microsoft account until cleared there; pinned items survive a plain Clear; SSD remnants of the on-disk store.
- **Admin:** no.

### Windows Search box / device search history
- **Where:** the typed-query history of the Start menu / taskbar search box (device search history), surfaced through the Windows Search experience; when a Microsoft account with cloud search is used, recent searches may also be stored in the account.
- **Reveals:** terms the user typed to search their PC and the web from Start — names, apps, files, and topics they looked for.
- **Remove (user runs):** Settings > Privacy & security > Search permissions > under "History", click **Clear device search history**; for cloud/Bing search history, clear it in the Microsoft account privacy dashboard.
- **Survives:** cloud search history persists in the account until cleared online; the content index (below) separately holds indexed file data.
- **Admin:** no.

### Windows Search index (Windows.edb)
- **Where:** `%ProgramData%\Microsoft\Search\Data\Applications\Windows\Windows.edb` (ESE database; some builds use additional search databases alongside it), with `GatherLogs` nearby.
- **Reveals:** indexed file names, paths, properties, and extracted text/content of documents and (if configured) Outlook mail — can expose the names and contents of files, even some already deleted, until the index is rebuilt.
- **Remove (user runs):** Settings > Privacy & security > Searching Windows > scroll to "Advanced indexing options" > Advanced > **Rebuild** (deletes and recreates the index); a full Windows reset clears it. The file itself is protected.
- **Survives:** reading or touching the file directly needs an elevated session; remnants persist until the index finishes rebuilding and the old database space is overwritten; backups and restore points.
- **Admin:** yes (to access the file directly; the Settings rebuild runs as the user).

### Cortana data (legacy)
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.Windows.Cortana_cw5n1h2txyewy\` (LocalState and related subfolders). Cortana is deprecated and removed from current Windows 11; this package is normally present only on older Windows 10 installs or upgrade leftovers.
- **Reveals:** on systems where it existed, past Cortana queries, reminders, and notebook entries, plus account linkage.
- **Remove (user runs):** on systems that still have it, sign out of Cortana and clear Cortana/search data via the Microsoft account privacy dashboard; a full reset removes the package. On current Windows 11 there is nothing to remove.
- **Survives:** any cloud-side history persists in the Microsoft account until cleared online; package remnants in `Windows.old` on upgraded machines.
- **Admin:** no.

### Notification history (wpndatabase.db)
- **Where:** `%LOCALAPPDATA%\Microsoft\Windows\Notifications\wpndatabase.db` (SQLite, with `wpnidm` folder for images).
- **Reveals:** the Action Center notification history — message and email previews, chat snippets, one-time passcodes, calendar and app toasts — often containing sensitive text that was never opened in an app.
- **Remove (user runs):** clear all notifications in the Notification Center; Settings > System > Notifications > turn notifications off; a full reset clears the database. The file is held open by the notifications service during a session.
- **Survives:** the database is rebuilt during use; SSD remnants until overwrite; restore points and backups.
- **Admin:** no.

### Thumbnail cache (thumbcache_*.db)
- **Where:** `%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache_*.db` (e.g. `thumbcache_256.db`, `thumbcache_1024.db`, with `thumbcache_idx.db`).
- **Reveals:** cached thumbnail images of pictures, documents, and videos that were viewed in Explorer — including previews of files since deleted or stored on drives that are no longer attached, letting someone see what images and documents existed.
- **Remove (user runs):** Settings > System > Storage > Temporary files, or Disk Cleanup > tick **Thumbnails** > OK (the file is locked by Explorer, so use the cleanup tools rather than deleting it live). A full reset clears it.
- **Survives:** rebuilds as folders with media are browsed; image data persists in free space until overwrite on SSD; restore points and backups.
- **Admin:** no.

### Icon cache (iconcache_*.db)
- **Where:** `%LOCALAPPDATA%\Microsoft\Windows\Explorer\iconcache_*.db` (and the legacy `%LOCALAPPDATA%\IconCache.db`).
- **Reveals:** cached application icons, which indirectly show which programs were installed on the machine.
- **Remove (user runs):** Disk Cleanup (Temporary files), or let it rebuild after a reset. The file is held open by Explorer during a session.
- **Survives:** rebuilds automatically; SSD remnants; lower sensitivity than the thumbnail cache.
- **Admin:** no.

### PowerShell console history (PSReadLine)
- **Where:** `%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt` — a plain-text file logging commands typed in PowerShell, one per line, across sessions.
- **Reveals:** every PowerShell command the user ran, verbatim — frequently including server and share names, file paths, user names, and secrets typed on the command line (tokens, connection strings, passwords passed as arguments).
- **Remove (user runs):** the user deletes the file, e.g. `Remove-Item (Get-PSReadlineOption).HistorySavePath`. (This is also listed under Saved credentials and keys because of the secret-exposure risk.)
- **Survives:** plain-text remnants persist in free space until overwrite on SSD; any copy in `Windows.old`, backups, or cloud-synced AppData; new history accrues if PowerShell is used again.
- **Admin:** no.

### Windows Terminal state
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\` (`settings.json`, `state.json`; the unpackaged/preview builds use a different package name).
- **Reveals:** window and tab layout and generated profiles — which shells, WSL distributions, and SSH-style profiles were configured, and starting directories. It does not store the typed command text itself (that is the PSReadLine file above).
- **Remove (user runs):** Settings > Apps > Installed apps > Windows Terminal > Advanced options > **Reset**; or uninstall. A full Windows reset removes it.
- **Survives:** remnants in free space until overwrite; backups; the real command history lives in PSReadLine and must be cleared separately.
- **Admin:** no.

### Remote Desktop connection history (Terminal Server Client MRU)
- **Where:** `HKCU:\Software\Microsoft\Terminal Server Client\Default` (MRU values `MRU0`, `MRU1`, ...) and `...\Terminal Server Client\Servers\<hostname>` (which records a `UsernameHint`); plus `%USERPROFILE%\Documents\Default.rdp`. These keys exist only after the built-in Remote Desktop Connection client has been used.
- **Reveals:** the remote computers the user connected to and the user names they signed in with — a map of the machines and accounts this PC reached over RDP.
- **Remove (user runs):** no Settings toggle; a full reset clears it. Advanced users can delete these keys in Registry Editor and delete `Default.rdp`.
- **Survives:** hive logs, restore points, `Windows.old`; SSD remnants; repopulates if RDP is used again.
- **Admin:** no.

### Remote Desktop bitmap cache
- **Where:** `%LOCALAPPDATA%\Microsoft\Terminal Server Client\Cache\` (`Cache####.bin` and `bcache##.bmc`).
- **Reveals:** cached tiles of the remote screens the user viewed over RDP; these fragments can be reassembled into partial images of the remote sessions, exposing what was on screen on other machines.
- **Remove (user runs):** the user deletes the cache files, e.g. `Remove-Item "$env:LOCALAPPDATA\Microsoft\Terminal Server Client\Cache\*" -Force`; a full reset clears it.
- **Survives:** image fragments persist in free space until overwrite on SSD; backups and restore points; rebuilds if RDP is used again.
- **Admin:** no.

### Windows event logs
- **Where:** `%WINDIR%\System32\winevt\Logs\*.evtx` — the Security, System, and Application logs plus many `Microsoft-Windows-*/Operational` logs (for example TerminalServices, RemoteDesktopServices, PowerShell/Operational, and USB/PnP logs).
- **Reveals:** account names and SIDs, logon/logoff and unlock times, computer and domain names, external-device and USB connections, service and crash events, and some network activity — a broad timeline of who used the machine and when.
- **Remove (user runs):** for a device you are handing over, the reliable method is a full Windows reset (Settings > System > Recovery > Reset this PC > Remove everything), which replaces these logs with a fresh install's. Individual logs can be cleared in Event Viewer (run as Administrator), but note that clearing the **Security** log itself writes event **1102**, and clearing other logs writes event **104** — so selective clearing leaves its own record. WipeWise reports the logs and recommends the reset rather than selective clearing.
- **Survives:** reset replaces them; short of that, cleared logs leave the 1102/104 markers and prior `.evtx` content may persist in free space until overwrite; archived/forwarded logs, restore points, and backups are untouched.
- **Admin:** yes (to read or clear).

---

**Reads across this whole cluster:** (1) Many of these rebuild the moment the matching feature is used again, so clean them after you stop using the PC and do it as the last pass before handover. (2) On an SSD, deleting a file or hive entry only marks the space free — the old bytes can survive until TRIM or overwrite, so a personal-data reset is not the same as guaranteed-unrecoverable; see `limitations.md` and `standards.md`. (3) Registry-based traces also linger in hive `.LOG1`/`.LOG2` transaction logs, System Restore points, shadow copies, and `Windows.old`. (4) Anything that was synced (Activity history/Timeline, cloud clipboard, cloud search) keeps a server-side copy in the Microsoft account until removed online. (5) For the admin-only forensic artifacts (Prefetch, Amcache, SRUM, BAM/DAM, ShimCache, Windows.edb, event logs), WipeWise's recommended removal is a full "Reset this PC > Remove everything", not piecemeal editing of system hives.

---

## System, devices, network, identity & AI

### User temporary files (%TEMP%)
- **Where:** `%TEMP%` (resolves to `%LOCALAPPDATA%\Temp`, i.e. `C:\Users\<name>\AppData\Local\Temp`). A second per-user temp can exist at `%USERPROFILE%\AppData\Local\Temp`.
- **Reveals:** Whatever apps wrote while running — extracted documents and attachments, installer payloads, draft exports, screenshots, downloaded-then-opened files, and occasionally tokens or logs that name accounts and file paths.
- **Remove (user runs):** Settings > System > Storage > Temporary files, tick **Temporary files** and choose Remove; or run Disk Cleanup (`cleanmgr`). You can also empty the folder in File Explorer (some in-use files will refuse to delete and can be skipped).
- **Survives:** Files locked by running apps stay until reboot. Deleted entries remain recoverable in SSD unallocated space until TRIM or an overwrite. Clearing one user's temp does not touch other profiles' temp folders.
- **Admin:** No.

### Windows system temp (C:\Windows\Temp)
- **Where:** `%SystemRoot%\Temp` (`C:\Windows\Temp`).
- **Reveals:** Scratch files from services, installers and update/servicing operations run machine-wide. Less personal than the user temp, but can hold log fragments and installer data that name software and paths.
- **Remove (user runs):** Run Disk Cleanup (`cleanmgr`) elevated and choose **Temporary files**, or delete the folder contents from an elevated File Explorer / admin session.
- **Survives:** In-use files persist until reboot. SSD remnants persist until TRIM/overwrite.
- **Admin:** Yes (the folder is machine-level; full cleanup needs elevation).

### Windows Error Reporting (WER) reports
- **Where:** Per-user: `%LOCALAPPDATA%\Microsoft\Windows\WER\ReportArchive` and `...\WER\ReportQueue`. Machine-wide: `%ProgramData%\Microsoft\Windows\WER\ReportArchive` and `...\ReportQueue`.
- **Reveals:** Which applications crashed, their executable and document paths (often under the user profile and naming the owner), loaded modules, command lines, and sometimes small in-memory data fragments captured at the moment of failure.
- **Remove (user runs):** Disk Cleanup (`cleanmgr`) > **System queued/archived Windows Error Reporting** and **per-user ... Error Reporting**; or delete the ReportArchive/ReportQueue contents in File Explorer (per-user without elevation, machine-wide elevated).
- **Survives:** Reports already uploaded to Microsoft's error-reporting service remain server-side. Machine-wide reports need admin to clear. SSD remnants persist until TRIM/overwrite.
- **Admin:** Yes for the `%ProgramData%` set; No for the per-user set.

### Application crash dumps (LocalDumps / CrashDumps)
- **Where:** `%LOCALAPPDATA%\CrashDumps` (the default user-mode dump folder). The location and behaviour are controlled by `HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps` (the `DumpFolder` value); some apps set their own dump folders.
- **Reveals:** `.dmp` files are snapshots of a crashed program's memory. Depending on dump type they can contain document text, messages, URLs, or other data the app held in RAM, plus the executable and file paths involved.
- **Remove (user runs):** Delete the files in `%LOCALAPPDATA%\CrashDumps` in File Explorer; check any custom `DumpFolder` location and app-specific dump folders too.
- **Survives:** If an app also uploads dumps to its own vendor, those copies remain. SSD remnants persist until TRIM/overwrite.
- **Admin:** No (for the default per-user folder).

### Kernel crash dumps (Minidump / MEMORY.DMP)
- **Where:** `%SystemRoot%\Minidump\*.dmp` (small BSOD dumps) and `%SystemRoot%\MEMORY.DMP` (kernel or complete memory dump).
- **Reveals:** Kernel-side state at a crash. Minidumps are mostly driver/stack data, but a complete memory dump (`MEMORY.DMP`) is a large image of system RAM that can contain whatever was in memory, including personal data.
- **Remove (user runs):** Run Disk Cleanup (`cleanmgr`) elevated and tick **System error memory dump files** and **System error minidump files**, or delete the files from an elevated session.
- **Survives:** New dumps are written on the next crash if dump collection stays enabled (System > About > Advanced system settings > Startup and Recovery). SSD remnants persist until TRIM/overwrite.
- **Admin:** Yes.

### Previous installation (Windows.old)
- **Where:** `%SystemDrive%\Windows.old` (`C:\Windows.old`), created by a feature update or in-place upgrade/repair.
- **Reveals:** A near-complete copy of the previous Windows install, **including the old `Users\<name>` profiles** — documents, desktop, downloads, browser profiles and app data as they were before the upgrade. One of the highest-value leftovers for a seller to miss.
- **Remove (user runs):** Settings > System > Storage > Temporary files > tick **Previous Windows installation(s)** and Remove; or Disk Cleanup (`cleanmgr`) elevated > **Previous Windows installation(s)**. Windows also auto-deletes it ~10 days after an upgrade, but do not rely on that.
- **Survives:** Nothing of it should remain after the above, but the freed space is unallocated and the old files linger on an SSD until TRIM/overwrite. If disk space blocked the cleanup it may be left in place.
- **Admin:** Yes (cleanup needs elevation).

### Volume Shadow Copies & System Restore points
- **Where:** Stored in the protected `%SystemDrive%\System Volume Information` (System-only). Configuration under `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore`. Enumerated read-only with `vssadmin list shadows` (elevated).
- **Reveals:** Point-in-time copies of files and the registry. Shadow copies can hold **previous versions of personal files that were since edited or deleted**, recoverable via "Restore previous versions."
- **Remove (user runs):** Control Panel > System > System Protection > select the drive > **Configure** > **Delete**; or Disk Cleanup (`cleanmgr`) > More Options > **System Restore and Shadow Copies** > Clean up (keeps the newest). To stop new ones, turn protection off for the drive.
- **Survives:** If protection stays on, Windows creates new restore points again. The space freed holds file remnants until TRIM/overwrite. A full "Reset this PC > Remove everything" clears these.
- **Admin:** Yes.

### Hibernation file (hiberfil.sys)
- **Where:** `%SystemDrive%\hiberfil.sys` (hidden, System).
- **Reveals:** A compressed image of system RAM saved at hibernation / fast-startup — it can contain anything that was in memory: open documents, messages, decrypted data, keys.
- **Remove (user runs):** In an elevated prompt the owner runs `powercfg /h off`, which disables hibernation and deletes the file (this also disables Fast Startup). Re-enable later with `powercfg /h on` if wanted.
- **Survives:** The freed space holds the old RAM image until TRIM/overwrite. Re-enabling hibernation recreates the file.
- **Admin:** Yes.

### Page file & swap file (pagefile.sys / swapfile.sys)
- **Where:** `%SystemDrive%\pagefile.sys` and `%SystemDrive%\swapfile.sys` (hidden, System). Behaviour at `HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management`.
- **Reveals:** Virtual-memory spillover from RAM. The page file can contain fragments of any data that was paged out — document text, credentials, keys. `swapfile.sys` backs suspended Store apps.
- **Remove (user runs):** The file cannot simply be deleted while in use. The owner can enable **Clear virtual memory pagefile at shutdown** (set `ClearPageFileAtShutdown` = 1, elevated) so it is zeroed on each shutdown, or move/resize it via System > Advanced system settings > Performance > Settings > Advanced > Virtual memory. A full reset handles it definitively.
- **Survives:** Until a clearing shutdown or overwrite, old page contents remain on disk; remnants persist in SSD unallocated space until TRIM/overwrite.
- **Admin:** Yes.

### Delivery Optimization cache
- **Where:** Managed via Settings. The on-disk cache has lived under `%SystemRoot%\SoftwareDistribution\DeliveryOptimization` and, on newer builds, under the Delivery Optimization service profile (`...\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache`).
- **Reveals:** Little personal data — it holds chunks of Windows Update and Microsoft Store content that this PC downloaded and may have shared to LAN/internet peers. Included for completeness and space reclaim.
- **Remove (user runs):** Settings > System > Storage > Temporary files > tick **Delivery Optimization Files** and Remove; or Disk Cleanup (`cleanmgr`) > **Delivery Optimization Files**.
- **Survives:** Regenerates as updates download. Minimal privacy relevance either way.
- **Admin:** Yes (service-owned cache).

### Microsoft Defender detection history & quarantine
- **Where:** `%ProgramData%\Microsoft\Windows Defender\Scans\History\Service\DetectionHistory` (detection records) and `%ProgramData%\Microsoft\Windows Defender\Quarantine` (quarantined files).
- **Reveals:** Names and full paths of files Defender flagged as threats, with timestamps — which indirectly reveals what the owner downloaded, ran or kept (e.g. a cracked installer, an email attachment), plus the quarantined items themselves.
- **Remove (user runs):** Windows Security > Virus & threat protection > Protection history to review; quarantined items can be removed there. To clear detection history on disk, delete the `DetectionHistory` contents from an elevated session. Defender also prunes history on a schedule.
- **Survives:** If cloud-delivered protection / sample submission (MAPS) was on, metadata or samples may have been sent to Microsoft and remain server-side. The protected folders need admin. SSD remnants persist until TRIM/overwrite.
- **Admin:** Yes.

### Diagnostic / telemetry data (EventTranscript.db & DiagTrack)
- **Where:** `%ProgramData%\Microsoft\Diagnosis\EventTranscript\EventTranscript.db` (the diagnostic-data SQLite database, populated when diagnostic data is enabled) and `%ProgramData%\Microsoft\Diagnosis\ETLLogs\AutoLogger\*.etl` (the DiagTrack "Connected User Experiences and Telemetry" trace logs).
- **Reveals:** A rich local record of device activity — apps launched and how long, some settings and inventory, network and error events, and occasionally app/URL identifiers — tied to this device and user.
- **Remove (user runs):** Settings > Privacy & security > Diagnostics & feedback > **Delete diagnostic data**, and turn **Optional diagnostic data** off. This clears the local store Microsoft maintains.
- **Survives:** Diagnostic data already uploaded to Microsoft stays in their cloud (manageable via the privacy dashboard). The `%ProgramData%\Microsoft\Diagnosis` files are admin-protected. SSD remnants persist until TRIM/overwrite.
- **Admin:** Yes (to read/clear the on-disk files directly).

### Windows Update download cache
- **Where:** `%SystemRoot%\SoftwareDistribution\Download`.
- **Reveals:** Which update and driver packages were downloaded. Minimal personal data, but the driver set can hint at the exact hardware. Included for completeness and space reclaim.
- **Remove (user runs):** Disk Cleanup (`cleanmgr`) elevated > **Windows Update Cleanup**; or stop the Windows Update service and clear the `Download` folder from an elevated session.
- **Survives:** Rebuilds as updates are fetched. Little privacy relevance.
- **Admin:** Yes.

### Installer / package cache
- **Where:** `%ProgramData%\Package Cache` (bootstrapper/Burn installer cache used by Visual C++ redistributables, .NET, etc.) and `%SystemRoot%\Installer` (cached MSI/MSP for Windows Installer apps).
- **Reveals:** Which software and versions were installed — cached installer files and product names let someone infer the applications the owner used.
- **Remove (user runs):** Do **not** hand-delete `%SystemRoot%\Installer` (it breaks repair/uninstall of installed apps). Instead uninstall unwanted programs normally (Settings > Apps > Installed apps), which prunes their cached installers; a full reset clears the rest. `%ProgramData%\Package Cache` entries are tidied by uninstalling the related redistributables.
- **Survives:** Caches for apps you keep remain by design. SSD remnants of removed entries persist until TRIM/overwrite.
- **Admin:** Yes.

### Font cache
- **Where:** `%SystemRoot%\ServiceProfiles\LocalService\AppData\Local\FontCache` and `%SystemRoot%\System32\FNTCACHE.DAT`.
- **Reveals:** Essentially no personal data — it caches installed-font glyph data for rendering. Listed only for completeness; it is not a privacy concern and is rebuilt automatically.
- **Remove (user runs):** No action needed for privacy. (It regenerates if cleared via the Windows Font Cache Service.)
- **Survives:** Rebuilds on demand. Not personally identifying.
- **Admin:** Yes (if one chose to clear it, which is unnecessary here).

### USB & removable-storage device history
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Enum\USBSTOR` and `...\Enum\USB` (every USB device ever attached, by vendor/model/serial), and `HKLM:\SYSTEM\MountedDevices` (maps drive letters and volume GUIDs to the disks/partitions seen).
- **Reveals:** A durable history of USB sticks, external drives, phones and other storage the owner connected — brand, model and often a unique serial per device — which can link this PC to specific removable media.
- **Remove (user runs):** There is no supported Settings page to clear these, and hand-editing `HKLM:\SYSTEM` keys is risky and requires elevation. The clean, authoritative removal for a device being sold is **Reset this PC > Remove everything** (ideally with "Clean data" on) or a fresh Windows install, which rebuilds these hives empty.
- **Survives:** Manual registry edits leave related keys (`MountedDevices`, driver store entries, `setupapi.dev.log`) behind unless all are addressed — another reason a reset is the honest answer. Entries are not cloud-synced.
- **Admin:** Yes (reading `MountedDevices` and removing any of these needs elevation; `Enum\USBSTOR` subkey names are often readable without it).

### Per-user mounted volumes & drive letters (MountPoints2)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2`.
- **Reveals:** Volumes this user mounted — USB drive letters, and `##server#share`-style entries for network locations the user opened — exposing both removable media and network/server names.
- **Remove (user runs):** Cleared by a Windows reset with the profile. For a non-reset handover, the entries live under the current user's hive; because they mix with legitimate state, prefer signing in as the new owner on a freshly reset PC rather than hand-editing.
- **Survives:** If "sync your settings" / Windows Backup captured Explorer state, some entries may re-arrive from the Microsoft account on a new sign-in. SSD remnants until TRIM/overwrite.
- **Admin:** No (per-user hive).

### Portable devices (phones, cameras, media players)
- **Where:** `HKLM:\SOFTWARE\Microsoft\Windows Portable Devices\Devices`.
- **Reveals:** Friendly names of MTP/PTP devices connected — phones, cameras, music players — which frequently embed the owner's name (e.g. a device named after a person).
- **Remove (user runs):** No Settings UI clears this; it is cleared by **Reset this PC > Remove everything** / clean install. Avoid manual `HKLM` edits.
- **Survives:** Not cloud-synced; persists across normal use until a reset. SSD remnants until TRIM/overwrite.
- **Admin:** Yes to remove (names are generally readable without elevation).

### Device installation log & connected-device history
- **Where:** `%SystemRoot%\INF\setupapi.dev.log` (chronological log of every device driver installed) and `HKLM:\SYSTEM\CurrentControlSet\Control\DeviceContainers` (container records with device friendly names).
- **Reveals:** A timeline of hardware the owner attached — monitors, docks, phones, printers, drives — with timestamps and identifiers, painting a picture of the owner's peripherals and habits.
- **Remove (user runs):** The log and container records are system-managed; the supported way to clear them is a Windows reset / clean install. `setupapi.dev.log` regenerates as devices install.
- **Survives:** Regenerates with new hardware. Not cloud-synced. SSD remnants until TRIM/overwrite.
- **Admin:** Yes to remove (`setupapi.dev.log` is usually readable without elevation).

### Bluetooth paired devices
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Devices` (one subkey per paired device; pairing key material is System-only).
- **Reveals:** Names and MAC addresses of paired Bluetooth devices — headphones, earbuds, keyboards, phones, cars — which often carry the owner's name or reveal their other gear and vehicles.
- **Remove (user runs):** Settings > Bluetooth & devices > tap each device > **Remove device**. For anything missed, a reset clears the hive.
- **Survives:** Removing in Settings unpairs this PC but does not touch the paired accessory's own memory of this PC. The protected key needs admin for direct inspection. SSD remnants until TRIM/overwrite.
- **Admin:** Yes to read the key directly (removing via Settings does not need elevation).

### Installed printers & print spooler queue
- **Where:** `HKCU:\Printers\Connections` and `HKLM:\SYSTEM\CurrentControlSet\Control\Print\Printers` (installed printers and ports); `%SystemRoot%\System32\spool\PRINTERS\*.SPL` / `*.SHD` (spooled jobs).
- **Reveals:** Printer names and network printer hostnames/IPs (exposing home or workplace network and locations), and — if any print job was left spooled — the **content of documents that were printed**.
- **Remove (user runs):** Settings > Bluetooth & devices > Printers & scanners > remove each printer. For stuck jobs, open the print queue and Cancel all; if files linger, stop the Print Spooler service and clear `spool\PRINTERS` from an elevated session.
- **Survives:** Network-printer definitions can reappear if pushed by a work network on the next domain/Entra sign-in. Spool remnants and removed printers persist in SSD unallocated space until TRIM/overwrite.
- **Admin:** Yes to clear the spool folder; No to remove printers via Settings.

### Camera, microphone & location app-access history
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam`, `...\microphone`, and `...\location` (per-app subkeys with `LastUsedTimeStart` / `LastUsedTimeStop`). A machine/`NonPackaged` view exists under the matching `HKLM:` path.
- **Reveals:** Which apps used the camera, microphone or location and exactly when — exposing behaviour such as video calls, voice recording or navigation, app by app, with timestamps.
- **Remove (user runs):** Settings > Privacy & security > Camera / Microphone / Location shows and lets the owner toggle per-app access. The usage timestamps themselves are cleared by resetting the profile / the PC.
- **Survives:** Toggling access off does not erase the historical `LastUsedTime` records; those clear on reset. Per-user hive, not cloud-synced. SSD remnants until TRIM/overwrite.
- **Admin:** No (per-user `HKCU`).

### Saved Wi-Fi networks (names & count)
- **Where:** `%ProgramData%\Microsoft\Wlansvc\Profiles\Interfaces\{interface-GUID}\*.xml` (one XML per saved network). Names are also listable read-only with `netsh wlan show profiles`.
- **Reveals:** The SSIDs (network names) the PC has joined — home, workplace, friends', hotels, cafés — which can map the owner's movements and affiliations. **The pre-shared keys live in these profiles but are cross-referenced in the credentials/Wi-Fi-keys category; WipeWise counts and names networks only and never displays a key (never use `key=clear`).**
- **Remove (user runs):** Settings > Network & internet > Wi-Fi > **Manage known networks** > Forget each; or `netsh wlan delete profile name="<SSID>"` per network.
- **Survives:** If Windows Backup / "sync your settings" synced Wi-Fi, the networks and keys also sit in the Microsoft account and can return on a new sign-in until synced settings are cleared and the device is removed from the account. The profile folder is admin-protected. SSD remnants until TRIM/overwrite.
- **Admin:** Yes to read the profile files directly; No to forget networks via Settings.

### VPN & dial-up connections (rasphone.pbk)
- **Where:** Per-user: `%APPDATA%\Microsoft\Network\Connections\Pbk\rasphone.pbk`. All-users: `%ProgramData%\Microsoft\Network\Connections\Pbk\rasphone.pbk`.
- **Reveals:** Configured VPN and dial-up connections — connection names, server hostnames/IP addresses, and sometimes the saved username — exposing employers, VPN providers and remote networks the owner used.
- **Remove (user runs):** Settings > Network & internet > VPN > select each > **Remove**. For leftover entries, delete the matching lines/connection via the Network Connections panel (`ncpa.cpl`).
- **Survives:** The VPN provider's own server-side account/config is untouched. Any saved secret in the profile is DPAPI-protected but still present until removed. SSD remnants until TRIM/overwrite.
- **Admin:** No for the per-user file; Yes for the all-users file.

### Mapped network drives
- **Where:** `HKCU:\Network\<DriveLetter>` (persistent mappings, each with a `RemotePath` like `\\server\share`). Also reflected in `MountPoints2`.
- **Reveals:** `\\server\share` paths of mapped drives — naming file servers, NAS devices and share names on the owner's home or work network.
- **Remove (user runs):** In File Explorer, right-click the mapped drive > **Disconnect**; or `net use <X:> /delete` (or `net use * /delete` for all).
- **Survives:** Credentials saved for a share live in Credential Manager (credentials category) and must be cleared there separately. Mappings can reappear via logon scripts/Group Policy on a work network. SSD remnants until TRIM/overwrite.
- **Admin:** No.

### Remote Desktop history & bitmap cache
- **Where:** `HKCU:\Software\Microsoft\Terminal Server Client\Servers\<host>` (one subkey per RDP target, with a `UsernameHint`) and `HKCU:\Software\Microsoft\Terminal Server Client\Default` (the MRU list). Cache tiles: `%LOCALAPPDATA%\Microsoft\Terminal Server Client\Cache\*.bmc` / `*.bin`.
- **Reveals:** Which remote machines the owner connected to (hostnames/IPs) and the usernames used, plus a **bitmap cache that can contain small rendered fragments of the remote screens** viewed over RDP.
- **Remove (user runs):** Remove saved connections by deleting the `Servers` and `Default` MRU entries (via Registry Editor, per-user), and delete the files in the RDP `Cache` folder. Any saved RDP credentials are in Credential Manager. A reset clears all of it.
- **Survives:** Saved `.rdp` files the owner created elsewhere (e.g. Documents) are separate. Credential Manager entries persist until cleared there. SSD remnants until TRIM/overwrite.
- **Admin:** No (per-user).

### Shared folders (this PC's SMB shares)
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Shares`.
- **Reveals:** Folders this PC published on the network and their share names and local paths — exposing what the owner shared and how their drive was organised.
- **Remove (user runs):** `net share` to list, then `net share <name> /delete` for each; or Computer Management > Shared Folders > Shares > Stop sharing. (Default administrative shares like `C$` return by design and are not personal.)
- **Survives:** Admin shares are recreated automatically. SSD remnants until TRIM/overwrite.
- **Admin:** Yes.

### Hosts file
- **Where:** `%SystemRoot%\System32\drivers\etc\hosts`.
- **Reveals:** Any custom host mappings the owner (or software) added — sites blocked/redirected, internal corporate hostnames, dev shortcuts — which can hint at employers, projects and browsing habits.
- **Remove (user runs):** Open the file in an elevated editor (e.g. Notepad as administrator) and remove custom lines, keeping the default localhost entries/comments.
- **Survives:** Nothing once edited, but editing needs elevation. A reset restores the default file.
- **Admin:** Yes (to edit; reading is possible without elevation).

### Proxy configuration
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings` (`ProxyEnable`, `ProxyServer`, `AutoConfigURL`). WinHTTP's system proxy is separate (`HKLM:\...\Connections`, viewable with `netsh winhttp show proxy`).
- **Reveals:** A configured proxy server or PAC URL — commonly a corporate or filtering gateway — which exposes the owner's employer or network environment.
- **Remove (user runs):** Settings > Network & internet > Proxy > turn off **Use a proxy server** / **automatic proxy setup** and clear the fields.
- **Survives:** Work-network proxy settings can be re-applied by policy on the next managed sign-in. SSD remnants until TRIM/overwrite.
- **Admin:** No for the per-user proxy; Yes to change the WinHTTP system proxy.

### Microsoft account & Entra/Azure AD (work or school) linkage
- **Where:** Device-join state in `HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\JoinInfo\{GUID}` (for Entra-joined devices) and reported read-only by `dsregcmd /status` (AzureAdJoined / DomainJoined / WorkplaceJoined, tenant name, and the user's UPN/email). Local vs Microsoft-account sign-in state lives in the account subsystem.
- **Reveals:** The owner's Microsoft-account email and/or **work-or-school identity and employer tenant** — a direct, strong identifier of who used the device and for which organisation.
- **Remove (user runs):** Settings > Accounts > **Access work or school** > disconnect the work/school account; and Settings > Accounts > Your info > **Sign in with a local account instead** to unlink the Microsoft account. For a sale, **Reset this PC > Remove everything** is the authoritative step and unenrolls the device locally.
- **Survives:** This is critical honesty — **the device object stays in the organisation's Entra/Intune tenant until an IT admin removes it**, and the PC stays listed under the owner's `account.microsoft.com/devices` until they remove it there. Local reset does not delete those server-side records. Work/school devices may be under employer control or legal hold and should go through IT.
- **Admin:** No to run `dsregcmd /status` or disconnect via Settings; reading the `CloudDomainJoin` key directly can require elevation on some builds.

### Email & app accounts registered in Windows (WAM)
- **Where:** Settings > Accounts > **Email & accounts**. Backing stores include the Web Account Manager token broker at `%LOCALAPPDATA%\Microsoft\TokenBroker\Cache\*.tbres` and the AAD broker package `%LOCALAPPDATA%\Packages\Microsoft.AAD.BrokerPlugin_cw5n1h2txyewy`, plus the identity cache under `HKLM:\SOFTWARE\Microsoft\IdentityStore`.
- **Reveals:** Which Microsoft, work/school and third-party accounts were added to Windows and apps (names and email addresses), and cached authentication tokens that keep those sessions alive on this PC.
- **Remove (user runs):** Settings > Accounts > Email & accounts > select each added account > **Remove**; and in Outlook/Mail remove the profiles. A reset clears the token caches with the profile.
- **Survives:** The accounts themselves are unaffected (they live with the provider); removing them here only unlinks this PC. Cached token files are cleared on reset but otherwise remain. SSD remnants until TRIM/overwrite.
- **Admin:** No (per-user).

### Edge Wallet — saved cards & addresses
- **Where:** `%LOCALAPPDATA%\Microsoft\Edge\User Data\<Profile>\Web Data` (SQLite; autofill addresses and payment cards). `<Profile>` is `Default`, `Profile 1`, `Profile 2`, … — **check every profile**. (Cross-referenced with the browsers/credentials categories; here we treat it as identity/PII.)
- **Reveals:** Saved payment cards (cardholder name, expiry, last four — the full number/CVV are DPAPI-encrypted and never displayed) and full postal addresses, phone numbers and names used for autofill.
- **Remove (user runs):** Edge > Settings > Profiles > **Payment info** and **Addresses and more** > delete each entry; or Settings > Privacy, search, and services > Clear browsing data > include **Autofill form data (including forms and cards)**. Repeat for every Edge profile.
- **Survives:** If the Edge profile is signed in and syncing, cards/addresses also sit in the Microsoft account and resync to other devices until removed from the account. SSD remnants until TRIM/overwrite.
- **Admin:** No.

### Contacts (People / Windows Contacts)
- **Where:** `%USERPROFILE%\Contacts\*.contact` (the classic Windows Contacts store) and the People app package `%LOCALAPPDATA%\Packages\Microsoft.People_8wekyb3d8bbwe`.
- **Reveals:** Saved contacts — names, email addresses, phone numbers and sometimes postal addresses — exposing the owner's personal and professional network.
- **Remove (user runs):** Delete the `.contact` files in `%USERPROFILE%\Contacts` in File Explorer; for the People app, remove the linked accounts (Email & accounts) that feed it and reset the app via Settings > Apps if wanted.
- **Survives:** Contacts that come from a linked account (Microsoft 365, Outlook.com, Google) live in that account's cloud and resync — they must be addressed at the source, not just locally. SSD remnants until TRIM/overwrite.
- **Admin:** No.

### Windows Recall snapshots (Copilot+ PCs)
- **Where:** `%LOCALAPPDATA%\CoreAIPlatform.00\UKP\{GUID}` — an index database (`ukg.db`) and an `ImageStore` of captured screenshots. Present only on **Copilot+ PCs with Recall enabled**; most current PCs do not have it.
- **Reveals:** Potentially the most sensitive store on the machine — periodic screenshots of nearly everything shown on screen, with OCR-searchable text: messages, emails, documents, visited sites, and anything (including passwords or data) that was visible at capture time.
- **Remove (user runs):** Settings > Privacy & security > **Recall & snapshots** > **Delete all snapshots**, and turn Recall off. The owner can also exclude apps/sites, but for a handover deleting all snapshots (or a full reset) is the right step.
- **Survives:** Recall is designed to be local-only (no cloud copy), but the encrypted snapshot store remains on disk until deleted, and freed space holds image/database remnants in SSD unallocated space until TRIM/overwrite. Encryption protects it only while no one is signed in as that user.
- **Admin:** No (the user's own data; protected by device/user encryption).

### Copilot chat history
- **Where:** Local app data under `%LOCALAPPDATA%\Packages\Microsoft.Copilot_8wekyb3d8bbwe` (the Copilot app) and/or the Edge-hosted Copilot cache. The substantive conversation history is held **in the Microsoft account cloud**, not primarily on disk.
- **Reveals:** The questions and prompts the owner typed to Copilot — which can be highly personal (health, finances, relationships, work) — plus any content they pasted in.
- **Remove (user runs):** In the Copilot app, open the conversation list and delete chats; the authoritative copy is cleared by signing in at the Microsoft Copilot / account privacy dashboard and deleting activity there. Clearing the local app cache alone is not enough.
- **Survives:** The **cloud-side history tied to the Microsoft account persists** after local removal and is visible when signing in elsewhere — it must be deleted from the account, not just the PC. SSD remnants of local cache until TRIM/overwrite.
- **Admin:** No.

### Click to Do (Copilot+ PCs)
- **Where:** A Copilot+ on-screen AI action feature governed with the same AI components settings and the Recall/`%LOCALAPPDATA%\CoreAIPlatform.00` stack; it operates over on-screen and Recall content rather than keeping a separate, well-documented personal-data store of its own.
- **Reveals:** That the owner used on-screen AI actions; any persistent content it touches is the same screen/snapshot material covered by Recall.
- **Remove (user runs):** Manage and turn it off under Settings > Privacy & security (the AI components / Recall & snapshots area); deleting Recall snapshots and turning the AI features off covers its on-disk footprint.
- **Survives:** Governed by the same local-only, encrypted Recall storage caveats; no separate cloud copy is documented. SSD remnants until TRIM/overwrite.
- **Admin:** No.

### Windows Studio Effects
- **Where:** NPU-based camera/microphone effects (background blur, eye contact, auto-framing, voice focus) configured under Settings > Bluetooth & devices > Cameras and the camera/audio settings.
- **Reveals:** Essentially no personal data — it is real-time processing applied to the live camera/mic feed and does **not** record or retain captured video or audio. Only on/off feature preferences are stored. Included to reassure the owner that the camera AI did not save footage.
- **Remove (user runs):** Nothing to clear for privacy; feature toggles reset with the profile/PC on a reset.
- **Survives:** No stored captures to survive. Not a data-leak concern.
- **Admin:** No.

---

## More browsers, messaging & email clients

Additional browsers and communication apps beyond the core set above - each keeps its own profile, history and account data.

### Chrome and Edge pre-release channels (Beta, Dev, Canary)
- **Where:** Each channel keeps its own separate profile tree, independent of the stable browser:
  - Chrome Beta `%LOCALAPPDATA%\Google\Chrome Beta\User Data`
  - Chrome Dev `%LOCALAPPDATA%\Google\Chrome Dev\User Data`
  - Chrome Canary `%LOCALAPPDATA%\Google\Chrome SxS\User Data`
  - Edge Beta `%LOCALAPPDATA%\Microsoft\Edge Beta\User Data`
  - Edge Dev `%LOCALAPPDATA%\Microsoft\Edge Dev\User Data`
  - Edge Canary `%LOCALAPPDATA%\Microsoft\Edge SxS\User Data`
- **Reveals:** A full second (or third) browsing life that people forget they ran: history, typed URLs, autofill and saved addresses, cookies and live sign-in sessions, bookmarks, downloads list, open/recent tabs, and installed extensions that name which web accounts were used. Cleaning only the stable browser leaves these untouched.
- **Remove (user runs):** In each channel: sign out of the browser's Google/Microsoft profile, then uninstall it from Settings > Apps > Installed apps, then delete any leftover `...\User Data` folder listed above.
- **Survives:** Anything synced to the Google or Microsoft account is still in the cloud and re-downloads on next sign-in; server-side logins stay valid until revoked; deleted files persist as recoverable remnants on SSD/HDD until overwritten, and you must empty the Recycle Bin.
- **Admin:** no.

### Ungoogled Chromium
- **Where:** `%LOCALAPPDATA%\Chromium\User Data` (uses the plain "Chromium" vendor folder, not a branded one).
- **Reveals:** Standard Chromium profile contents - history, autofill, cookies/sessions, bookmarks, downloads, open tabs, extensions. Because it sits under the generic `Chromium` folder it is easy to miss, and it collides with any vanilla Chromium build on the same account.
- **Remove (user runs):** Uninstall or remove the Ungoogled Chromium build, then delete `%LOCALAPPDATA%\Chromium\User Data`. Confirm no other Chromium-based build you want to keep shares that folder first.
- **Survives:** Ungoogled Chromium has no first-party sync, so there is usually no cloud copy - but any site you stayed logged into keeps a valid server session, and on-disk data is recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Thorium
- **Where:** `%LOCALAPPDATA%\Thorium\User Data`.
- **Reveals:** Browsing and download history, autofill and addresses, cookies and active sign-in sessions, bookmarks, typed URLs, open/recent tabs, and installed extensions that hint at which accounts were used.
- **Remove (user runs):** Uninstall Thorium from Settings > Apps, then delete the leftover `%LOCALAPPDATA%\Thorium\User Data` folder.
- **Survives:** If you enabled any Google sign-in/sync in Thorium, that data is still in the cloud; server sessions stay valid until revoked; deleted on-disk data is recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Cent Browser
- **Where:** `%APPDATA%\CentBrowser\User Data` for installed builds (Cent defaults to Roaming AppData). Portable builds keep the profile beside the executable instead.
- **Reveals:** History, autofill/addresses, cookies and live sessions, bookmarks, downloads, open tabs, and Cent's own extras (saved tab-group sessions, mouse-gesture and super-drag configs can reference recent sites).
- **Remove (user runs):** Uninstall from Settings > Apps, then delete `%APPDATA%\CentBrowser\User Data`. For a portable copy, delete the whole Cent folder you unzipped.
- **Survives:** Any site session stays valid server-side until you log out there; deleted on-disk data is recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### SRWare Iron
- **Where:** Chromium-based privacy fork. On the builds I can confirm it stores its profile under the generic `%LOCALAPPDATA%\Chromium\User Data` folder - the same path used by vanilla and Ungoogled Chromium. The exact folder has varied between versions (see uncertainties).
- **Reveals:** History, autofill, cookies/sessions, bookmarks, downloads, open tabs, extensions. Shares its folder with other Chromium builds, so it is both easy to overlook and easy to confuse with another browser's data.
- **Remove (user runs):** Uninstall SRWare Iron, then check which build owns `%LOCALAPPDATA%\Chromium\User Data` and delete it only if no Chromium build you want to keep uses it.
- **Survives:** Iron has no first-party sync, so typically no cloud copy; site sessions stay valid server-side until logout; on-disk remnants recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Comodo Dragon and IceDragon
- **Where:**
  - Dragon (Chromium-based) `%LOCALAPPDATA%\Comodo\Dragon\User Data`
  - IceDragon (Firefox-based) profile `%APPDATA%\Comodo\IceDragon\Profiles\<random>.default`, cache `%LOCALAPPDATA%\Comodo\IceDragon\Profiles\<random>.default`
- **Reveals:** Dragon exposes the usual Chromium set (history, autofill, cookies/sessions, bookmarks, downloads, extensions). IceDragon (a Firefox fork) exposes places.sqlite history and bookmarks, cookies.sqlite sessions, formhistory, saved logins, and cache.
- **Remove (user runs):** Uninstall each from Settings > Apps, then delete the `Comodo\Dragon` and `Comodo\IceDragon` folders under both `%LOCALAPPDATA%` and `%APPDATA%`.
- **Survives:** Any site you stayed signed into keeps a valid server session; deleted on-disk data is recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Epic Privacy Browser
- **Where:** `%LOCALAPPDATA%\Epic Privacy Browser\User Data`.
- **Reveals:** Despite the name, the local profile still records browsing history, autofill, cookies and live sessions, bookmarks, downloads and extensions for this Windows account - Epic's privacy claims are about blocking trackers, not about leaving no local trace for the next owner.
- **Remove (user runs):** Uninstall from Settings > Apps, then delete `%LOCALAPPDATA%\Epic Privacy Browser\User Data`.
- **Survives:** Site sessions stay valid server-side until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Avast Secure Browser
- **Where:** `%LOCALAPPDATA%\AVAST Software\Browser\User Data`.
- **Reveals:** History, autofill/addresses, cookies and active sessions, bookmarks, downloads, open tabs, and extensions - a full browsing record often installed as a bundle alongside Avast antivirus and then ignored.
- **Remove (user runs):** Uninstall "Avast Secure Browser" from Settings > Apps, then delete the leftover `%LOCALAPPDATA%\AVAST Software\Browser\User Data` folder.
- **Survives:** If any Avast account sign-in/sync was enabled, a cloud copy remains; site sessions stay valid server-side; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### AVG Secure Browser
- **Where:** `%LOCALAPPDATA%\AVG\Browser\User Data`.
- **Reveals:** Same Chromium profile set as Avast's (shared codebase): history, autofill, cookies/sessions, bookmarks, downloads, open tabs, extensions. Frequently bundled with AVG antivirus.
- **Remove (user runs):** Uninstall "AVG Secure Browser" from Settings > Apps, then delete `%LOCALAPPDATA%\AVG\Browser\User Data`.
- **Survives:** Any account sync copy remains in the cloud; server sessions stay valid until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Naver Whale
- **Where:** `%LOCALAPPDATA%\Naver\Naver Whale\User Data`.
- **Reveals:** History, autofill/addresses, cookies and live sessions, bookmarks, downloads, open tabs, extensions, plus Whale's sidebar/space features that can hold site logins and notes.
- **Remove (user runs):** Sign out of your Naver account in Whale, uninstall from Settings > Apps, then delete `%LOCALAPPDATA%\Naver\Naver Whale\User Data`.
- **Survives:** Anything synced to the Naver account stays in the cloud and re-downloads on sign-in; server sessions stay valid until revoked; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### 360 Browser
- **Where:** Chinese Chromium-based family. Common paths are `%APPDATA%\360se6\User Data` (360 Secure Browser v6+) and `%LOCALAPPDATA%\360Chrome\Chrome\User Data` (360 Extreme Explorer / Chrome). The exact folder varies by product and version (see uncertainties).
- **Reveals:** History, autofill, cookies and live sessions, bookmarks, downloads, open tabs, extensions, and any saved sign-ins to the 360 account.
- **Remove (user runs):** Sign out of the 360 account in the browser, uninstall from Settings > Apps, then delete the `360se6` / `360Chrome` folder under `%APPDATA%` and `%LOCALAPPDATA%`.
- **Survives:** Data synced to the 360 cloud account remains server-side; site sessions stay valid until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### CocCoc Browser
- **Where:** `%LOCALAPPDATA%\CocCoc\Browser\User Data`.
- **Reveals:** History, autofill/addresses, cookies and active sessions, bookmarks, downloads (CocCoc has a built-in download manager whose list is telling), open tabs, and extensions.
- **Remove (user runs):** Sign out of any CocCoc sync, uninstall from Settings > Apps, then delete `%LOCALAPPDATA%\CocCoc\Browser\User Data`.
- **Survives:** Synced data stays in the CocCoc account cloud; site sessions valid until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Falkon
- **Where:** `%APPDATA%\falkon\profiles\<profile>` (default profile holds browsedata.db for history/bookmarks, cookies, and cache).
- **Reveals:** Browsing history, bookmarks, cookies and sessions, form autofill, and any saved passwords stored by the AutoFill plugin.
- **Remove (user runs):** Close Falkon, uninstall it, then delete `%APPDATA%\falkon`.
- **Survives:** Falkon has no cloud sync, so no server copy of the profile - but site logins stay valid server-side until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Midori
- **Where:** `%APPDATA%\Midori` (current Midori builds are Electron-based and store the profile, history, cookies and cache here).
- **Reveals:** History, cookies and sessions, bookmarks, downloads, and form data for this Windows account.
- **Remove (user runs):** Uninstall Midori from Settings > Apps, then delete `%APPDATA%\Midori`.
- **Survives:** No first-party sync in typical builds; site sessions stay valid server-side until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### qutebrowser
- **Where:** config `%APPDATA%\qutebrowser\config`, data `%LOCALAPPDATA%\qutebrowser\data` (history.sqlite, cookies, sessions), cache `%LOCALAPPDATA%\qutebrowser\cache`.
- **Reveals:** Full visited-URL history (history.sqlite), cookies and logged-in sessions, quickmarks/bookmarks, saved session files listing open tabs, and the config which can reference accounts and search engines.
- **Remove (user runs):** Close qutebrowser, uninstall it, then delete both `%APPDATA%\qutebrowser` and `%LOCALAPPDATA%\qutebrowser`.
- **Survives:** No cloud sync; site sessions stay valid server-side until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Min
- **Where:** `%APPDATA%\Min` (Electron app; holds history, bookmarks, tasks/tab groups, and site data).
- **Reveals:** Browsing history and full-text page index, saved tasks/tab groups that list visited sites, bookmarks, and cookies/sessions.
- **Remove (user runs):** Uninstall Min from Settings > Apps, then delete `%APPDATA%\Min`.
- **Survives:** No first-party sync; site sessions stay valid server-side until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Opera Crypto Browser
- **Where:** profile `%APPDATA%\Opera Software\Opera Crypto`, cache `%LOCALAPPDATA%\Opera Software\Opera Crypto`. (Opera One uses the existing `Opera Software\Opera Stable` folder already listed under browsers, not a new one.)
- **Reveals:** History, autofill, cookies and sessions, bookmarks, downloads, open tabs, extensions, plus the built-in crypto wallet's references to connected wallet addresses and dapp sites visited.
- **Remove (user runs):** Sign out of the Opera account and the built-in wallet, uninstall from Settings > Apps, then delete the `Opera Software\Opera Crypto` folders under both `%APPDATA%` and `%LOCALAPPDATA%`.
- **Survives:** Data synced to the Opera account stays in the cloud; on-chain wallet activity is public and permanent regardless of local deletion; site sessions valid until logout; on-disk data recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Skype for Business (Lync)
- **Where:** `%LOCALAPPDATA%\Microsoft\Office\16.0\Lync\sip_<your-address>` (the folder is still named "Lync"; 15.0 for the 2013 client). Holds the cached address book (galcontacts.db), presence/contact cache, and local conversation-history cache.
- **Reveals:** Your organization's contact list and the previous user's SIP/work address, cached colleague details, and fragments of IM conversation history.
- **Remove (user runs):** Sign out of Skype for Business, then delete the `sip_<address>` folder under `%LOCALAPPDATA%\Microsoft\Office\<version>\Lync`. If the PC is leaving the organization, also remove the Office/work account from Settings > Accounts > Access work or school.
- **Survives:** The real conversation history lives in the Exchange mailbox (Conversation History folder) and on the server - deleting the local cache does not touch it; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Discord PTB and Canary
- **Where:** Discord's test builds keep profiles separate from the stable client: PTB `%APPDATA%\discordptb`, Canary `%APPDATA%\discordcanary` (each with Local Storage, IndexedDB, and a Cache of message content and images).
- **Reveals:** Which Discord account was signed in, cached server/channel names and message text, attachments and images, and a login token in Local Storage that can resume the session. Cleaning only the stable `discord` folder leaves these behind.
- **Remove (user runs):** Log out in each test client (User Settings > Log Out), fully quit it from the tray, uninstall from Settings > Apps, then delete `%APPDATA%\discordptb` and `%APPDATA%\discordcanary`.
- **Survives:** All messages live on Discord's servers and remain in your account; changing your Discord password invalidates cached tokens; on-disk cache recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Jami
- **Where:** `%LOCALAPPDATA%\jami` (account archive, contact list, and local call/message history).
- **Reveals:** The previous user's Jami account(s) and their cryptographic identity archive, contact list, and locally stored conversation and call history.
- **Remove (user runs):** In Jami, delete the account (Account settings > Delete account) if you do not want to keep it elsewhere, then uninstall Jami and delete `%LOCALAPPDATA%\jami`.
- **Survives:** Jami is peer-to-peer/distributed, so messages already delivered sit on your other linked devices; the account identity exists wherever else you imported it; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### qTox (Tox)
- **Where:** `%APPDATA%\tox` (profile `<name>.tox` holding your Tox ID, private key and contacts; settings.ini; optional history.db and avatars).
- **Reveals:** The previous user's Tox ID and friend list, saved avatars, and - if history was enabled - stored chat logs. The `.tox` profile is the account's private key.
- **Remove (user runs):** Close qTox, uninstall it, then delete `%APPDATA%\tox` (this removes the profile/private key and any local history).
- **Survives:** Tox is peer-to-peer with no central server, so there is no server copy to clear - but any messages already received by contacts remain on their devices; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Pidgin
- **Where:** `%APPDATA%\.purple` (accounts.xml with account names and sometimes plaintext passwords, blist.xml buddy list, and the logs\ folder of chat transcripts).
- **Reveals:** Every IM/chat account the previous user configured (XMPP, IRC, and others), their full buddy lists, and complete plaintext chat logs per contact.
- **Remove (user runs):** In Pidgin remove each account (Accounts > Manage Accounts), then uninstall Pidgin and delete `%APPDATA%\.purple` to clear accounts and logs.
- **Survives:** Messages held by the chat servers/contacts are unaffected; any password stored plaintext here was also usable anywhere until you change it; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Trillian
- **Where:** `%APPDATA%\Trillian` (per-account profile, contact lists, logs, and cached media).
- **Reveals:** The messaging accounts the previous user linked, contact lists, and locally stored chat logs and shared files.
- **Remove (user runs):** Sign out and remove accounts in Trillian, then uninstall it and delete `%APPDATA%\Trillian`.
- **Survives:** Trillian history synced to the Trillian/Astra account stays in that cloud; messages on each linked service's servers are unaffected; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Miranda NG
- **Where:** `%APPDATA%\Miranda NG\<profile>\<profile>.dat` for installer builds (a single database file holding accounts, contacts and history). Portable builds keep the profile beside the executable instead.
- **Reveals:** All configured messaging accounts, contact lists, and the full local message history - everything is in the one `.dat` database.
- **Remove (user runs):** Close Miranda NG, then delete the profile `.dat` (or the whole `%APPDATA%\Miranda NG` folder), and for a portable copy delete the Miranda folder you unzipped.
- **Survives:** Messages on each service's servers are unaffected; on-disk remnants recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Jitsi (Desktop and Meet)
- **Where:** Legacy Jitsi Desktop (SIP/XMPP softphone) `%APPDATA%\Jitsi` (sip-communicator.properties with account details, contactlist, and a history\ folder). Jitsi Meet desktop (Electron video app) `%APPDATA%\Jitsi Meet`.
- **Reveals:** Jitsi Desktop exposes configured SIP/XMPP accounts, contact list and stored chat history. Jitsi Meet exposes recently joined meeting rooms/URLs and your display name, plus cached settings.
- **Remove (user runs):** In Jitsi Desktop remove accounts then delete `%APPDATA%\Jitsi`; for Jitsi Meet uninstall it and delete `%APPDATA%\Jitsi Meet`.
- **Survives:** Messages/meetings on the servers you used are unaffected; on-disk remnants recoverable until overwritten; empty the Recycle Bin.
- **Admin:** no.

### Gajim
- **Where:** `%APPDATA%\Gajim` (logs.db chat history, config with account details, and cache).
- **Reveals:** The XMPP/Jabber account(s) the previous user configured, their roster/contacts, and the full local message archive in logs.db.
- **Remove (user runs):** In Gajim remove the accounts, then uninstall Gajim and delete `%APPDATA%\Gajim`.
- **Survives:** Server-side message archives (XMPP MAM) on the account's server are unaffected; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### HexChat
- **Where:** `%APPDATA%\HexChat` (hexchat.conf and servlist.conf with networks, nicks and sometimes NickServ passwords; the logs\ folder of channel and private-message transcripts).
- **Reveals:** The IRC networks and nicknames the previous user used, auto-join channels, and complete plaintext logs of channel and private conversations.
- **Remove (user runs):** Uninstall HexChat, then delete `%APPDATA%\HexChat` to clear the server list, saved nick passwords and all logs.
- **Survives:** Anything said in channels persists on others' clients and network logs; a saved NickServ password stays usable until changed; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### mIRC
- **Where:** `%APPDATA%\mIRC` (mirc.ini with servers, nick and identd settings; the logs\ folder; and config files). Portable installs keep these beside the executable.
- **Reveals:** IRC servers and nicknames used, saved server passwords, and the logs\ folder of channel/query transcripts.
- **Remove (user runs):** Uninstall mIRC, then delete `%APPDATA%\mIRC` (or the portable mIRC folder) to clear the ini, passwords and logs.
- **Survives:** Channel activity persists on others' clients; saved server passwords stay usable until changed; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### WeCom / WeChat Work
- **Where:** `%APPDATA%\Tencent\WXWork` (account and login state, local cache). Received files default to a `WXWork` folder under Documents.
- **Reveals:** The previous user's work/enterprise WeChat identity and organization, cached contacts and conversation fragments, and any files received into the Documents WXWork folder.
- **Remove (user runs):** Log out in WeCom, uninstall it, then delete `%APPDATA%\Tencent\WXWork` and the `Documents\WXWork` received-files folder.
- **Survives:** Messages and files live on Tencent's enterprise servers and remain in the account; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### DingTalk
- **Where:** `%APPDATA%\DingTalk` (account/login state and local cache; some data is kept in account-id subfolders).
- **Reveals:** The previous user's DingTalk account and organization, cached contacts and conversation fragments, and cached received files/images.
- **Remove (user runs):** Log out in DingTalk, uninstall it, then delete `%APPDATA%\DingTalk`.
- **Survives:** Messages and files are stored on DingTalk/Alibaba servers and remain in the account; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Lark / Feishu
- **Where:** Electron clients: Lark (international) `%APPDATA%\Lark`, Feishu (China edition, 飞书) `%APPDATA%\Feishu`. Each holds account state, a local message/cache store, and downloaded files.
- **Reveals:** The previous user's Lark/Feishu account and workspace, cached contacts and chat content, documents and files opened or received, and calendar fragments.
- **Remove (user runs):** Log out in the app, uninstall it, then delete `%APPDATA%\Lark` and/or `%APPDATA%\Feishu`.
- **Survives:** Messages, docs and files live on the Lark/Feishu servers and remain in the account; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### KakaoTalk
- **Where:** `%APPDATA%\Kakao\KakaoTalk` (account/login state and local cache). Received files default to a `KakaoTalk Downloads` folder under Documents.
- **Reveals:** The previous user's Kakao account, cached contacts/friends and profile images, chat-list fragments, and any files saved to the Documents KakaoTalk Downloads folder.
- **Remove (user runs):** Log out in KakaoTalk, uninstall it, then delete `%APPDATA%\Kakao\KakaoTalk` and the `Documents\KakaoTalk Downloads` folder.
- **Survives:** Chat history is held on Kakao's servers and re-syncs on next login; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Zalo
- **Where:** `%APPDATA%\ZaloPC` (account/login state and local cache). Received files default to a `Zalo Received Files` folder under Documents.
- **Reveals:** The previous user's Zalo account/phone number, cached contacts, conversation fragments, and received media/files in the Documents folder.
- **Remove (user runs):** Log out in Zalo, uninstall it, then delete `%APPDATA%\ZaloPC` and the `Documents\Zalo Received Files` folder.
- **Survives:** Messages and files on Zalo's servers remain in the account; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Caprine
- **Where:** `%APPDATA%\Caprine` (Electron wrapper for Facebook Messenger; stores the logged-in Facebook session, cookies and cache).
- **Reveals:** That the previous user was signed into Facebook Messenger here, cached conversation content and images, and a session cookie that can resume the account.
- **Remove (user runs):** Sign out of Facebook inside Caprine, uninstall it, then delete `%APPDATA%\Caprine`.
- **Survives:** All Messenger conversations live on Facebook's servers; changing the Facebook password invalidates the cached session; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Ferdi
- **Where:** `%APPDATA%\Ferdi` (the Ferdi fork keeps its own folder, distinct from the Ferdium/Franz/Rambox folders noted elsewhere). Holds per-service logins, cookies and cache for every messaging service added.
- **Reveals:** Which messaging/email services the previous user bundled into Ferdi and that they were signed in, plus cached content and session cookies for each.
- **Remove (user runs):** Sign out of each service inside Ferdi, uninstall Ferdi, then delete `%APPDATA%\Ferdi`.
- **Survives:** Each bundled service's data stays on its own servers; a Ferdi account (if used) keeps workspace settings in its cloud; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Mailspring
- **Where:** `%APPDATA%\Mailspring` (config.json with account addresses, edgehill.db, and a local SQLite cache of downloaded mail and contacts).
- **Reveals:** The email accounts the previous user linked, cached message bodies and attachments, contacts, and signatures.
- **Remove (user runs):** In Mailspring remove each account (Preferences > Accounts), sign out of the Mailspring ID, then uninstall and delete `%APPDATA%\Mailspring`.
- **Survives:** Mail stays on the IMAP/provider servers; Mailspring's sync service (Foundry376) may hold account metadata tied to the Mailspring ID until that account is deleted; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Postbox
- **Where:** `%APPDATA%\Postbox\Profiles\<profile>` (Thunderbird-style profile: local mail stores, address book, saved logins) and cache under `%LOCALAPPDATA%\Postbox\Profiles\<profile>`.
- **Reveals:** Configured email accounts, locally stored messages and attachments (including any POP mail pulled off the server), address book, and saved passwords.
- **Remove (user runs):** Close Postbox, uninstall it, then delete `%APPDATA%\Postbox` and `%LOCALAPPDATA%\Postbox`.
- **Survives:** IMAP mail remains on the provider's servers; POP mail already downloaded exists only locally (back it up first if needed); on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Claws Mail
- **Where:** On the Windows port, `%APPDATA%\Claws-mail` (accountrc with account details, folderlist, and the Mail\ store in MH format). Some builds use `%USERPROFILE%\.claws-mail` instead (see uncertainties).
- **Reveals:** Configured email accounts, locally stored messages (MH format, one file per message), address book, and saved passwords if the user stored them.
- **Remove (user runs):** Close Claws Mail, uninstall it, then delete the `Claws-mail` / `.claws-mail` folder, whichever exists.
- **Survives:** IMAP mail remains on the server; already-downloaded POP mail exists only locally; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### The Bat!
- **Where:** `%APPDATA%\The Bat!` by default (per-account folders with .TBB message bases, address book, and account.cfg). Users frequently relocate this mail store to another drive/folder chosen at setup.
- **Reveals:** Configured accounts, the full local message store (The Bat! stores mail locally by design), address book, and account configuration.
- **Remove (user runs):** Close The Bat!, uninstall it, then delete `%APPDATA%\The Bat!` - and check for a relocated mail directory if the previous user moved it elsewhere.
- **Survives:** IMAP copies remain on the server; mail kept only in The Bat!'s local base is lost if deleted (back up first if needed); on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Spark
- **Where:** `%APPDATA%\Spark Desktop` (Readdle Spark for Windows; account state and a local cache of mail/contacts). The exact folder name is approximate (see uncertainties).
- **Reveals:** The email accounts the previous user linked, cached message content, contacts, and that they used a Spark account.
- **Remove (user runs):** Remove accounts and sign out of the Spark account inside the app, uninstall it, then delete the Spark folder under `%APPDATA%`.
- **Survives:** Spark routes and stores account data through Readdle's cloud servers, so a server-side copy persists until you delete the Spark account; mail stays on the provider servers too; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Canary Mail
- **Where:** `%APPDATA%\Canary Mail` (account state and local cache for the Windows client). The exact folder name is approximate (see uncertainties).
- **Reveals:** The email accounts the previous user linked, cached messages and contacts, and any PGP keys/identities if they used Canary's encryption features.
- **Remove (user runs):** Remove accounts and sign out of any Canary account inside the app, uninstall it, then delete the Canary Mail folder under `%APPDATA%`.
- **Survives:** Mail remains on the provider servers; if Canary cloud sync was enabled, a server-side copy persists until the Canary account is deleted; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Windows Live Mail (legacy)
- **Where:** `%LOCALAPPDATA%\Microsoft\Windows Live Mail` (per-account .eml message store, .oeaccount account files, and local folders).
- **Reveals:** Configured email and newsgroup accounts, and the full local store of messages as individual .eml files - including POP mail that exists only here.
- **Remove (user runs):** Close Windows Live Mail, uninstall it (part of Windows Essentials), then delete `%LOCALAPPDATA%\Microsoft\Windows Live Mail`.
- **Survives:** IMAP mail remains on the server; POP mail kept only locally is lost if deleted (back up first if needed); on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Opera Mail
- **Where:** `%APPDATA%\Opera Mail\Opera Mail` (the standalone mail client split off from old Opera; holds the Mail\ store and index, accounts, and wand.dat saved passwords).
- **Reveals:** Configured email accounts, the local message store and index, and saved passwords in wand.dat.
- **Remove (user runs):** Close Opera Mail, uninstall it, then delete `%APPDATA%\Opera Mail`.
- **Survives:** IMAP mail remains on the server; locally stored mail is lost if deleted (back up first if needed); on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Vivaldi Mail
- **Where:** Built into the Vivaldi browser, stored inside the profile at `%LOCALAPPDATA%\Vivaldi\User Data\Default\Mail` (local message store), with contacts and feeds alongside in the same Default profile. (The browser's own data is the separately listed "Vivaldi User Data root".)
- **Reveals:** Configured email accounts and the full local mail store Vivaldi downloads to disk (it keeps all messages locally for search), contacts, and feed subscriptions.
- **Remove (user runs):** In Vivaldi remove the mail accounts (Settings > Mail), or delete the whole `%LOCALAPPDATA%\Vivaldi\User Data` profile when wiping the browser; deleting the `Default\Mail` folder clears the mail store.
- **Survives:** IMAP mail remains on the provider servers; anything synced via a Vivaldi account stays in that cloud; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Spike
- **Where:** `%APPDATA%\Spike` (Electron email client; account state and a local cache of conversations/contacts).
- **Reveals:** The email accounts the previous user linked, cached conversation content (Spike presents mail as chat), contacts, and that they used a Spike account.
- **Remove (user runs):** Sign out and remove accounts inside Spike, uninstall it, then delete `%APPDATA%\Spike`.
- **Survives:** Spike is cloud-backed, so account data and settings persist on Spike's servers until the Spike account is deleted; mail stays on the provider servers; on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Sylpheed
- **Where:** `%APPDATA%\Sylpheed` on the Windows build (accountrc and config, plus a Mailbox\ store in MH format; the mail folder can be set elsewhere at setup).
- **Reveals:** Configured email accounts, the local MH message store (one file per message), and address book.
- **Remove (user runs):** Close Sylpheed, uninstall it, then delete `%APPDATA%\Sylpheed` - and check for a relocated mailbox folder if the previous user moved it.
- **Survives:** IMAP mail remains on the server; locally stored POP mail is lost if deleted (back up first if needed); on-disk remnants recoverable until overwritten.
- **Admin:** no.

### Zimbra Desktop
- **Where:** Legacy/EOL client. Account state is commonly under `%APPDATA%\Zimbra`, but the bulk mail data store is set at install time and often lives in the install directory or a user-chosen data folder (see uncertainties).
- **Reveals:** Configured email accounts, and a large local store of mail, contacts and calendar synced down for offline use.
- **Remove (user runs):** Close Zimbra Desktop, uninstall it, then delete `%APPDATA%\Zimbra` and the data/store directory chosen at install.
- **Survives:** Mail, contacts and calendar remain on the Zimbra/provider server; on-disk remnants recoverable until overwritten.
- **Admin:** no.

---

## More media, creative, games & built-in apps

Additional media players, creative and production tools, game launchers and emulators, Phone Link, and Windows' own built-in apps.

### mpv

- **Where:** `%APPDATA%\mpv\` (config: `mpv.conf`, `input.conf`) and `%APPDATA%\mpv\watch_later\` (one file per media item, containing the full path and resume position). Portable builds keep a `portable_config\` folder next to `mpv.exe` instead.
- **Reveals:** which video/audio files you watched and where you paused them (each watch_later file names a media path); any custom config.
- **Remove (user runs):** delete `%APPDATA%\mpv\watch_later\` to drop resume history, or delete the whole `%APPDATA%\mpv\` folder. mpv has no GUI "clear history" button.
- **Survives:** the media files themselves. If `save-position-on-quit` was never enabled, watch_later may be empty or small.
- **Admin:** no.

### Audacious

- **Where:** `%APPDATA%\audacious\` (confirmed on this machine) — `config`, and `playlists\` with `*.audpl` files plus `playlist_state`.
- **Reveals:** your saved and active playlists, which reference the full paths of your music files, i.e. a map of your audio library.
- **Remove (user runs):** delete the `%APPDATA%\audacious\` folder, or remove playlists inside Audacious first.
- **Survives:** the audio files themselves.
- **Admin:** no.

### SMPlayer

- **Where:** `%APPDATA%\smplayer\smplayer.ini` (recent files under `[recents]`, favorites) and `%APPDATA%\smplayer\file_settings\` (per-file saved playback positions). Portable builds store this beside the executable.
- **Reveals:** recently played video/audio file paths and where you stopped in each.
- **Remove (user runs):** in SMPlayer use the recent-files submenu's "Clear" entry, or delete the `%APPDATA%\smplayer\` folder.
- **Survives:** the media files themselves.
- **Admin:** no.

### QMPlay2

- **Where:** `%APPDATA%\QMPlay2\` — `QMPlay2.ini` (settings, recently played) and the saved playlist.
- **Reveals:** recently played media and playlist entries, which reference your media file paths.
- **Remove (user runs):** clear the recents inside QMPlay2, or delete the `%APPDATA%\QMPlay2\` folder.
- **Survives:** the media files themselves.
- **Admin:** no.

### Media Player Classic - Black Edition (MPC-BE)

- **Where:** `HKCU:\Software\MPC-BE\MPC-BE\` (recent-file list and favorites, typically under a `Settings` / `Recent File List` subkey). A portable install writes an `.ini` next to the executable instead.
- **Reveals:** recently opened video/audio file paths and favorites, plus last-used open/save folders.
- **Remove (user runs):** View > Options > Player to limit/clear recent files, or delete the `HKCU:\Software\MPC-BE` key (or the portable `.ini`).
- **Survives:** the media files themselves.
- **Admin:** no.

### Clementine

- **Where:** `%LOCALAPPDATA%\Clementine\Clementine\` holding `clementine.db` (the music library database) plus caches; application settings are stored separately (registry/INI — see uncertainties).
- **Reveals:** your whole scanned music library (file paths, tags, ratings, play counts, last-played times), internet-radio stations, and any music-service accounts you linked.
- **Remove (user runs):** delete the `%LOCALAPPDATA%\Clementine\` folder; there is no one-click wipe inside the app.
- **Survives:** the music files themselves; any linked service (e.g. Last.fm scrobbles, Spotify) keeps its own server-side record.
- **Admin:** no.

### Strawberry Music Player

- **Where:** `%LOCALAPPDATA%\Strawberry\Strawberry\` holding `strawberry.db` (library database) plus caches; application settings are stored separately (registry/INI — see uncertainties).
- **Reveals:** your scanned music library (file paths, tags, ratings, play counts, last-played), and any music-service or scrobbling accounts you linked.
- **Remove (user runs):** delete the `%LOCALAPPDATA%\Strawberry\` folder.
- **Survives:** the music files themselves; linked services keep their own server-side history.
- **Admin:** no.

### Plex Media Server

- **Where:** `%LOCALAPPDATA%\Plex Media Server\` — library database under `Plug-in Support\Databases\com.plexapp.plugins.library.db`, plus `Metadata\`, `Media\` (artwork/thumbnails) and `Cache\`. Also `HKCU:\Software\Plex, Inc.\Plex Media Server`.
- **Reveals:** the full path of every media file the server indexed, watch history and timestamps, and the Plex account the server is claimed to.
- **Remove (user runs):** uninstall Plex Media Server, then delete `%LOCALAPPDATA%\Plex Media Server\`; at plex.tv remove this server from your account's devices.
- **Survives:** your Plex account on plex.tv keeps the record of this server, your watch state and friends until you remove it online; the media files themselves.
- **Admin:** no for the default per-user install.

### Plex HTPC

- **Where:** `%LOCALAPPDATA%\Plex HTPC\` (client config and cache; exact folder name — see uncertainties).
- **Reveals:** the Plex account you signed in with and the servers/libraries you connected to.
- **Remove (user runs):** sign out inside the app, uninstall it, then delete the folder.
- **Survives:** your Plex account and watch state live on plex.tv, not locally; nothing local is authoritative.
- **Admin:** no.

### Jellyfin Media Player

- **Where:** `%LOCALAPPDATA%\JellyfinMediaPlayer\` (and in some builds `%APPDATA%\JellyfinMediaPlayer\`) — client settings and session, including the Jellyfin server address and your username.
- **Reveals:** the Jellyfin server(s) you connected to and the account you used.
- **Remove (user runs):** sign out in the app, uninstall it, then delete the folder.
- **Survives:** your account and viewing history live on the Jellyfin server, not on this PC.
- **Admin:** no.

### Emby Theater

- **Where:** `%APPDATA%\Emby Theater\` (client config/cache; exact folder name — see uncertainties).
- **Reveals:** the Emby server you connected to and the account you signed in with.
- **Remove (user runs):** sign out, uninstall, then delete the folder.
- **Survives:** your account and watch history live on the Emby server, not locally.
- **Admin:** no.

### GIMP

- **Where:** `%APPDATA%\GIMP\<version>\` (e.g. `2.10\` or `3.0\`) — settings plus the document history (recently opened image paths).
- **Reveals:** paths of images you recently opened or exported, and last-used folders.
- **Remove (user runs):** in the File > Open Recent menu choose "Clear Document History", or delete the `%APPDATA%\GIMP\<version>\` folder.
- **Survives:** your image files; the Windows thumbnail cache is a separate artifact.
- **Admin:** no.

### Inkscape

- **Where:** `%APPDATA%\inkscape\` — `preferences.xml`, which stores the recent-file list and last-used open/save directories.
- **Reveals:** paths of SVG/vector files you recently opened or saved.
- **Remove (user runs):** delete `%APPDATA%\inkscape\preferences.xml` (or the whole folder); Inkscape rebuilds defaults on next launch.
- **Survives:** your vector files.
- **Admin:** no.

### Blender

- **Where:** `%APPDATA%\Blender Foundation\Blender\<version>\config\` — `recent-files.txt` (full paths of recently opened `.blend` files), `bookmarks.txt` (saved folders), `userpref.blend`, `startup.blend`.
- **Reveals:** paths of your recent projects and any folders you bookmarked in the file browser.
- **Remove (user runs):** File > Defaults, or delete `recent-files.txt` / the `config\` folder.
- **Survives:** your `.blend` project files and any renders.
- **Admin:** no.

### Krita

- **Where:** `%APPDATA%\krita\` — the resource folder and `kritarc` config (recent-document list with full paths, recent folders). On some builds `kritarc` lives under `%LOCALAPPDATA%\krita\` instead (see uncertainties).
- **Reveals:** paths of images/documents you recently opened or saved.
- **Remove (user runs):** in the File menu clear recent documents, or delete `kritarc` / the `%APPDATA%\krita\` folder.
- **Survives:** your artwork files.
- **Admin:** no.

### DaVinci Resolve

- **Where:** `%APPDATA%\Blackmagic Design\DaVinci Resolve\` (preferences, window layouts, logs, gallery stills, caches). The local project "disk database" that holds your projects lives under the Blackmagic Design support folders (default location — see uncertainties).
- **Reveals:** project names, timelines/edits, and the media file paths each project references; gallery stills and cached media.
- **Remove (user runs):** in the Project Manager delete projects, then delete `%APPDATA%\Blackmagic Design\DaVinci Resolve\` and the disk-database folder.
- **Survives:** your source footage and render outputs; any projects you stored in Blackmagic Cloud.
- **Admin:** no for the user config; removing a shared project database stored under `%PROGRAMDATA%` may need admin.

### Audacity

- **Where:** `%APPDATA%\audacity\` (confirmed on this machine) — `audacity.cfg` with a `[RecentFiles]` list of full paths and last import/export folders, plus auto-save/recovery data for unsaved recordings.
- **Reveals:** paths of audio files/projects you recently opened, last-used folders, and possibly recoverable unsaved recordings.
- **Remove (user runs):** delete `%APPDATA%\audacity\audacity.cfg` (or the whole folder); this clears recents and recovery data.
- **Survives:** your saved audio projects and exported files.
- **Admin:** no.

### Kdenlive

- **Where:** `%LOCALAPPDATA%\kdenlive\` (cache: proxy clips, audio thumbnails, video thumbnails). The `kdenliverc` config holds the recent-projects list (exact config-file location on Windows — see uncertainties).
- **Reveals:** cached proxy copies and thumbnails of your footage, plus paths of recent projects.
- **Remove (user runs):** inside Kdenlive use Settings to clear the cache, or delete the `%LOCALAPPDATA%\kdenlive\` folder and the `kdenliverc` config.
- **Survives:** your source footage and `.kdenlive` project files.
- **Admin:** no.

### Shotcut

- **Where:** `%APPDATA%\Meltytech\Shotcut.ini` (recent-file list with full paths, last export folder) and `%APPDATA%\Meltytech\` for related data.
- **Reveals:** paths of recently opened/saved `.mlt` projects and the media they point to.
- **Remove (user runs):** clear recents in Shotcut's recent panel, or delete `%APPDATA%\Meltytech\Shotcut.ini`.
- **Survives:** your project and media files.
- **Admin:** no.

### HandBrake

- **Where:** `%APPDATA%\HandBrake\` — `settings.json` (last source and destination paths, "when done" options), `presets.json` (custom presets), and `*.log` files.
- **Reveals:** the last video you loaded and where you saved output, plus any custom presets.
- **Remove (user runs):** delete the `%APPDATA%\HandBrake\` folder.
- **Survives:** your source and output video files.
- **Admin:** no.

### Paint.NET

- **Where:** classic install: settings under `%LOCALAPPDATA%\paint.net\` (and some keys under `HKCU:\Software\paint.net`) including the recent-files list. Microsoft Store build: `%LOCALAPPDATA%\Packages\` in a folder beginning `dotPDNLLC.paintdotnet`. (Exact MRU storage — see uncertainties.)
- **Reveals:** paths of images you recently opened or saved.
- **Remove (user runs):** clear the recent list in Paint.NET, or (classic) delete `%LOCALAPPDATA%\paint.net\`; (Store) uninstall via Settings > Apps.
- **Survives:** your image files.
- **Admin:** no.

### Clip Studio Paint

- **Where:** `%USERPROFILE%\Documents\CELSYS\` (document catalog/management database and version folders) and `%APPDATA%\CELSYSUserData\` / `%APPDATA%\CELSYS\` (settings).
- **Reveals:** your artwork catalog, recently opened `.clip` files, and the Clip Studio account if you signed in.
- **Remove (user runs):** delete the `CELSYS` / `CELSYSUserData` folders; sign out of your Clip Studio account in the app.
- **Survives:** your `.clip` artwork files; cloud-synced materials and your account on Celsys servers.
- **Admin:** no.

### Affinity Photo / Designer / Publisher (Serif)

- **Where:** standalone (v2) builds: `%APPDATA%\Affinity\Photo\<version>\`, `%APPDATA%\Affinity\Designer\<version>\`, `%APPDATA%\Affinity\Publisher\<version>\` (settings and recent-documents list). Microsoft Store builds live under `%LOCALAPPDATA%\Packages\` in Serif/Affinity folders.
- **Reveals:** paths of recently opened/saved `.afphoto`, `.afdesign`, `.afpub` files; the Affinity account used for licensing.
- **Remove (user runs):** clear the recent list on the app's welcome screen, then delete the relevant `%APPDATA%\Affinity\` folders; (Store) uninstall via Settings > Apps.
- **Survives:** your document files; your Affinity/Serif account.
- **Admin:** no.

### FL Studio

- **Where:** `%USERPROFILE%\Documents\Image-Line\FL Studio\` (default Projects/Presets/Data and user settings) and `HKCU:\Software\Image-Line\` (app config and recent files).
- **Reveals:** paths of your `.flp` projects, recent-project list, and the account/email registered for licensing.
- **Remove (user runs):** clear the recent list in FL Studio, delete the `Documents\Image-Line\` folder, and sign out of your Image-Line account.
- **Survives:** your `.flp` projects and rendered audio; your Image-Line account.
- **Admin:** no.

### Ableton Live

- **Where:** `%APPDATA%\Ableton\Live <version>\Preferences\` (`Preferences.cfg`, recent-set references, `Log.txt`) and `%USERPROFILE%\Documents\Ableton\` (User Library and default Live Set location).
- **Reveals:** paths of recently opened `.als` Live Sets, your User Library contents, and the authorized account.
- **Remove (user runs):** delete the `%APPDATA%\Ableton\` preferences folder; deauthorize the computer from your Ableton account.
- **Survives:** your `.als` projects and recordings; the authorization record on Ableton's servers.
- **Admin:** no.

### REAPER

- **Where:** `%APPDATA%\REAPER\` — `reaper.ini` (recent-project list with full paths, last render/import folders) and related `reaper-*.ini` files. A portable install keeps these next to `reaper.exe`.
- **Reveals:** paths of recently opened `.rpp` projects, FX chains, and render destinations.
- **Remove (user runs):** clear the recent list in the File menu, or delete the `%APPDATA%\REAPER\` folder (or the portable folder).
- **Survives:** your `.rpp` projects and rendered audio.
- **Admin:** no.

### Cakewalk (by BandLab)

- **Where:** `%APPDATA%\Cakewalk\Cakewalk Core\` (configuration) and `HKCU:\Software\Cakewalk Music Software\Cakewalk\` (recent-project MRU and settings); default projects in `%USERPROFILE%\Documents\Cakewalk\`.
- **Reveals:** paths of recently opened `.cwp` projects, your audio-data folder, and the BandLab account if signed in.
- **Remove (user runs):** clear the recent list, delete the config folder and the `HKCU:\Software\Cakewalk Music Software` key, and sign out of BandLab.
- **Survives:** your projects and audio data; your BandLab account and any cloud projects.
- **Admin:** no.

### Calibre

- **Where:** config `%APPDATA%\calibre\` (settings, viewer reading-position state, and the stored library location paths). Library: default `%USERPROFILE%\Calibre Library\` (or a folder you chose) containing `metadata.db` and your book files in author/title subfolders.
- **Reveals:** every ebook in your library (titles, authors, tags, your own comments), reading progress in the viewer, and configured news sources.
- **Remove (user runs):** delete the library folder and `%APPDATA%\calibre\`.
- **Survives:** copies of the ebook files you placed elsewhere; nothing is cloud-synced by default.
- **Admin:** no.

### Kindle for PC

- **Where:** downloaded books in `%USERPROFILE%\Documents\My Kindle Content\`; account/app data in `%LOCALAPPDATA%\Amazon\Kindle\` (and `%APPDATA%\Amazon\Kindle\` in newer builds) holding the signed-in Amazon account and device registration.
- **Reveals:** your Amazon account (the device is registered to it), your downloaded book library, and reading data.
- **Remove (user runs):** in the app deregister this device (account/tools menu), then uninstall and delete the folders.
- **Survives:** your entire Kindle library, purchases and furthest-read position stay in your Amazon account in the cloud; only local copies are removed.
- **Admin:** no.

### Adobe Digital Editions

- **Where:** library in `%USERPROFILE%\Documents\My Digital Editions\` (EPUB/PDF files and the library database); activation data in `%LOCALAPPDATA%\Adobe\Digital Editions\` (and `%APPDATA%\Adobe\Digital Editions\`) holding the authorized Adobe ID.
- **Reveals:** your ebook library and the Adobe ID the app is authorized with.
- **Remove (user runs):** in ADE press Ctrl+Shift+D (Help > Erase Authorization) to deauthorize, then delete the folders.
- **Survives:** DRM-protected books stay tied to your Adobe ID server-side; your Adobe account.
- **Admin:** no.

### Icecream Ebook Reader

- **Where:** `%APPDATA%\Icecream Ebook Reader\` (library database, recently read, bookmarks); some settings may be in `HKCU:\Software\Icecream Apps\`.
- **Reveals:** your ebook collection, reading progress, and bookmarks.
- **Remove (user runs):** remove books inside the app, then delete the `%APPDATA%\Icecream Ebook Reader\` folder.
- **Survives:** the ebook files themselves.
- **Admin:** no.

### ONLYOFFICE Desktop Editors

- **Where:** `%APPDATA%\ONLYOFFICE\DesktopEditors\` — recent-files list, settings, and a cache of recently opened documents; also records of any cloud portals you connected.
- **Reveals:** paths of recently opened documents, spreadsheets and presentations, and any connected ONLYOFFICE/Nextcloud portal accounts.
- **Remove (user runs):** clear the recent list in the app and disconnect cloud accounts, then delete the `%APPDATA%\ONLYOFFICE\` folder.
- **Survives:** your document files; any connected cloud/portal keeps its own server-side copy.
- **Admin:** no.

### SoftMaker Office / FreeOffice (TextMaker, PlanMaker, Presentations)

- **Where:** `HKCU:\Software\SoftMaker\` (per-product, version-specific subkeys holding recent-file MRU and settings) and `%APPDATA%\SoftMaker\` (user dictionaries, templates, settings).
- **Reveals:** paths of recently opened documents, spreadsheets and presentations.
- **Remove (user runs):** clear recents in each app, then delete the `HKCU:\Software\SoftMaker` MRU and the `%APPDATA%\SoftMaker\` folder.
- **Survives:** your document files.
- **Admin:** no.

### AbiWord

- **Where:** `%APPDATA%\AbiSuite\` — `AbiWord.Profile` (recent-file MRU and settings) and an `AbiWord\` folder for templates/dictionaries.
- **Reveals:** paths of documents you recently opened or saved.
- **Remove (user runs):** delete `%APPDATA%\AbiSuite\AbiWord.Profile` (or the whole `AbiSuite` folder).
- **Survives:** your document files.
- **Admin:** no.

### PDF-XChange Editor

- **Where:** `HKCU:\Software\Tracker Software\PDFXEditor\` (version subkey: recent-file MRU and settings) and `%APPDATA%\Tracker Software\` / `%LOCALAPPDATA%\Tracker Software\` (config and cache).
- **Reveals:** paths of recently opened PDF files and last-used folders.
- **Remove (user runs):** clear the recent list in the app, then delete the registry key and the `Tracker Software` folders.
- **Survives:** your PDF files.
- **Admin:** no.

### Drawboard PDF

- **Where:** Microsoft Store (UWP) app, under `%LOCALAPPDATA%\Packages\` in a folder beginning `Drawboard` (its `LocalState\` and `Settings\settings.dat` hold recent documents and annotation data). Exact package-family name — see uncertainties.
- **Reveals:** paths of recently opened PDFs and annotation/markup data.
- **Remove (user runs):** clear the recent list in the app, or uninstall it via Settings > Apps (which removes the package folder).
- **Survives:** your PDF files; anything synced to a Drawboard/OneDrive account.
- **Admin:** no.

### Xodo PDF

- **Where:** Microsoft Store (UWP) app, under `%LOCALAPPDATA%\Packages\` in the Xodo package folder (`LocalState\` holds recent files and connected-account state). Exact package-family name — see uncertainties.
- **Reveals:** paths of recently opened PDFs and any connected cloud accounts (Xodo Drive, Google Drive, Dropbox).
- **Remove (user runs):** sign out and clear recents in the app, or uninstall via Settings > Apps.
- **Survives:** your PDF files; Xodo/Apryse account and any Xodo Drive cloud copies.
- **Admin:** no.

### itch.io app
- **Where:** `%APPDATA%\itch` (the `db\butler.db` library and login profile, plus config); app binaries sit in `%LOCALAPPDATA%\itch`. Downloaded games install where the previous user chose, often under `%APPDATA%\itch\apps`.
- **Reveals:** The signed-in itch.io account, the list of owned and installed indie games, and the folders games were installed to.
- **Remove (user runs):** In the itch app use the account menu to Log Out, then uninstall via Settings > Apps > Installed apps. Delete the leftover `%APPDATA%\itch` and `%LOCALAPPDATA%\itch` folders afterward.
- **Survives:** The itch.io account and purchase history live on itch.io's servers. Game folders placed outside these paths are not touched. Deleted files stay recoverable on an SSD until overwritten.
- **Admin:** no.

### Amazon Games
- **Where:** `%LOCALAPPDATA%\Amazon Games` (app data, logs, and the signed-in account/session); games install to `C:\Amazon Games` or a folder the user chose.
- **Reveals:** The Amazon account session and which titles (including Prime Gaming claims) were installed or played.
- **Remove (user runs):** In the Amazon Games app sign out from the account menu, uninstall via Settings > Apps, then delete the leftover `%LOCALAPPDATA%\Amazon Games` folder and any game install folder.
- **Survives:** The Amazon account, entitlements, and Prime Gaming history stay on Amazon's servers. Cloud-synced saves are not local to remove. SSD remnants persist until overwritten.
- **Admin:** no.

### Rockstar Games Launcher
- **Where:** `%LOCALAPPDATA%\Rockstar Games\Launcher` (settings and the offline Social Club sign-in cache), `%LOCALAPPDATA%\Rockstar Games\Social Club`, and `%USERPROFILE%\Documents\Rockstar Games` (per-game profiles and settings for GTA V, Red Dead Redemption 2, etc.).
- **Reveals:** The Rockstar / Social Club account signed in, which Rockstar titles were installed, and local game profile settings.
- **Remove (user runs):** Open the launcher, sign out of the Social Club account in Settings, uninstall the launcher via Settings > Apps, then delete the leftover `%LOCALAPPDATA%\Rockstar Games` and `Documents\Rockstar Games` folders.
- **Survives:** The Rockstar account and cloud save slots remain on Rockstar's servers. Saves synced to Social Club cloud are not local. SSD remnants persist until overwritten.
- **Admin:** no.

### Paradox Launcher
- **Where:** `%USERPROFILE%\Documents\Paradox Interactive` (per-game saves, settings, and mods for Stellaris, Crusader Kings III, Europa Universalis IV, Hearts of Iron IV, etc.) and `%LOCALAPPDATA%\Paradox Interactive` (launcher data and the signed-in Paradox account).
- **Reveals:** The Paradox account, which Paradox titles were played, and all local save games and custom mods.
- **Remove (user runs):** Sign out of the Paradox account in the launcher, then delete `%USERPROFILE%\Documents\Paradox Interactive` and `%LOCALAPPDATA%\Paradox Interactive`. Uninstall each game through its own store (Steam/Xbox) separately.
- **Survives:** The Paradox account and any cloud-synced saves stay server-side. Saves also synced through Steam Cloud remain there. SSD remnants persist until overwritten.
- **Admin:** no.

### Humble App
- **Where:** `%APPDATA%\Humble App` (the signed-in Humble account, library, and configuration); games install to a folder the user chose.
- **Reveals:** The Humble Bundle account signed in, owned and installed titles, and the download/install location.
- **Remove (user runs):** In the Humble App sign out, uninstall via Settings > Apps, then delete the leftover `%APPDATA%\Humble App` folder plus any game install folder.
- **Survives:** The Humble account, purchases, and Humble Choice history remain on Humble's servers. SSD remnants persist until overwritten.
- **Admin:** no.

### Playnite
- **Where:** `%APPDATA%\Playnite` (the `library.db` catalog of every game across all linked stores, configuration, the activity/play-time log, and extension data that can hold linked-store credentials or API tokens). A portable install keeps this beside the executable instead.
- **Reveals:** The complete cross-store game library, play time and last-played dates, and accounts/tokens for the store integrations (Steam, Epic, GOG, Xbox, etc.) the user linked.
- **Remove (user runs):** Uninstall Playnite via Settings > Apps (or delete the portable folder), then delete `%APPDATA%\Playnite`. Disconnect any linked accounts from each store first if they should stop being accessible.
- **Survives:** The underlying store accounts and their libraries are unaffected server-side. SSD remnants persist until overwritten.
- **Admin:** no.

### Legacy Games Launcher
- **Where:** `%APPDATA%\legacy-games-launcher` (Electron app data: configuration and the signed-in Legacy Games account/email); games install under `%LOCALAPPDATA%\Legacy Games` or a chosen folder. This launcher is often pre-installed on new OEM PCs.
- **Reveals:** The Legacy Games account email and the casual-game bundles tied to it. On a pre-installed copy the previous user may still be signed in.
- **Remove (user runs):** Sign out in the app, uninstall via Settings > Apps, then delete the leftover `%APPDATA%\legacy-games-launcher` folder.
- **Survives:** The Legacy Games account and entitlements stay on their servers. SSD remnants persist until overwritten.
- **Admin:** no.

### Dolphin Emulator (GameCube / Wii)
- **Where:** `%USERPROFILE%\Documents\Dolphin Emulator` by default (Config, memory cards, save states, and the Wii NAND under `Wii\`); a portable build keeps these beside the executable.
- **Reveals:** Which games were played, GameCube memory-card and Wii save data, and any Wii user profile / Mii and (for online titles) linked account data in the NAND.
- **Remove (user runs):** Close Dolphin and delete `%USERPROFILE%\Documents\Dolphin Emulator` (and the portable folder if used). ROM/ISO disc images stored elsewhere must be deleted separately.
- **Survives:** ROM/ISO files kept in other folders are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### PCSX2 (PlayStation 2)
- **Where:** `%USERPROFILE%\Documents\PCSX2` by default (`memcards` with PS2 memory-card saves, `sstates` save states, `inis` settings and game list, logs); a portable build keeps these beside the executable.
- **Reveals:** PS2 memory-card save data and which PS2 titles were played.
- **Remove (user runs):** Close PCSX2 and delete `%USERPROFILE%\Documents\PCSX2` (and the portable folder if used). ISOs and any BIOS dump stored elsewhere must be deleted separately.
- **Survives:** ISO files and BIOS dumps kept elsewhere are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### DuckStation (PlayStation 1)
- **Where:** `%USERPROFILE%\Documents\DuckStation` by default (`memcards`, `savestates`, settings, and a cached game list); a portable build keeps these beside the executable.
- **Reveals:** PS1 memory-card save data and which PS1 titles were played — the game-list cache shows ROM names and paths.
- **Remove (user runs):** Close DuckStation and delete `%USERPROFILE%\Documents\DuckStation` (and the portable folder if used). ROM images and BIOS files stored elsewhere must be deleted separately.
- **Survives:** ROM and BIOS files kept elsewhere are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### Ryujinx (Nintendo Switch)
- **Where:** `%APPDATA%\Ryujinx` (config, the `bis` save-data store, firmware and keys under `system`, and the games list); a portable build uses a `portable` subfolder beside the executable.
- **Reveals:** Switch user profiles and save data, which titles were played, and the presence of console keys/firmware (an account identity may be embedded in saves).
- **Remove (user runs):** Close Ryujinx and delete `%APPDATA%\Ryujinx` (or the portable folder). Game dumps stored elsewhere must be deleted separately.
- **Survives:** Game dumps kept elsewhere are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### yuzu (Nintendo Switch; project discontinued)
- **Where:** `%APPDATA%\yuzu` (config, `keys`, and `nand` holding user profiles and save data). The project shut down in 2024, but installed data folders remain on disk.
- **Reveals:** Switch user profiles, save data, and console keys left behind by the previous user.
- **Remove (user runs):** Delete `%APPDATA%\yuzu` (and `%LOCALAPPDATA%\yuzu` if present). Game dumps stored elsewhere must be deleted separately.
- **Survives:** Game dumps kept elsewhere are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### Citra (Nintendo 3DS; project discontinued)
- **Where:** `%APPDATA%\Citra` (config, `sdmc` holding game save data, and `nand`). The project shut down in 2024, but installed data folders remain on disk.
- **Reveals:** 3DS save data, Mii/profile data, and which titles were played.
- **Remove (user runs):** Delete `%APPDATA%\Citra`. ROMs stored elsewhere must be deleted separately.
- **Survives:** ROM files kept elsewhere are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### PPSSPP (PlayStation Portable)
- **Where:** `%USERPROFILE%\Documents\PPSSPP` for the installer build (the "memstick" folder: `PSP\SAVEDATA` game saves, `PSP\SYSTEM\ppsspp.ini` config and recent-games list, plus save states). The portable/zip build keeps a `memstick` folder beside the executable instead.
- **Reveals:** PSP game save data and a recent-games list showing ROM names and paths.
- **Remove (user runs):** Close PPSSPP and delete the memstick folder (`%USERPROFILE%\Documents\PPSSPP` or the one beside the executable). ROMs stored elsewhere must be deleted separately.
- **Survives:** ROM files kept elsewhere are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### Standalone portable emulators (RetroArch, RPCS3, Cemu, Snes9x, Project64, melonDS, mGBA)
- **Where:** These run "portable" by default — configuration, save files, save states, and playlists live in the folder the previous user extracted the emulator to (anywhere: Desktop, Downloads, a games drive), not in a fixed system path. Notable stores inside that folder: RetroArch `playlists\` (ROM names and full file paths) plus `saves\`/`states\` and a RetroAchievements login; RPCS3 `dev_hdd0\` (PSN account name, game saves, trophies); Cemu `mlc01\` (Wii U save data and account); Snes9x / Project64 / melonDS keep `.srm` saves, state files, and a recent-ROM list. Some builds instead use `%APPDATA%\Cemu` or `%APPDATA%\mGBA`.
- **Reveals:** ROM libraries (names and paths), save data and save states, and for RetroArch / RPCS3 a signed-in RetroAchievements or PSN account.
- **Remove (user runs):** Delete the emulator's own folder wherever it was placed. Because the location is user-chosen, also clear the Windows traces that point to it (Recent items, jump lists, File Explorer address history) — these are catalogued separately.
- **Survives:** ROM dumps stored outside the emulator folder are untouched. RetroAchievements / PSN accounts stay server-side. SSD remnants persist until overwritten. There is no fixed path to scan, so these can only be flagged through the recent-file and jump-list traces unless the user points the tool at the folder.
- **Admin:** no.

### Phone Link / Your Phone
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.YourPhone_8wekyb3d8bbwe` (LocalCache and Settings holding data mirrored from the linked phone).
- **Reveals:** Text messages (SMS/MMS), recent photos, call history, contacts, and notifications mirrored from the previous user's phone, plus the Microsoft account the link used.
- **Remove (user runs):** Unlink the phone first at account.microsoft.com/devices (or Settings > Bluetooth & devices > Mobile devices > Manage), then reset the app via Settings > Apps > Phone Link > Advanced options > Reset. Removing the Microsoft account from Windows (Settings > Accounts) clears the package folder entirely.
- **Survives:** The messages, photos, and call logs still live on the phone itself and in the user's Microsoft/phone cloud. Resetting the app does not unlink the phone — do that step first. Mirrored data may remain until the account is removed from Windows. SSD remnants persist until overwritten.
- **Admin:** no.

### Clipchamp video editor
- **Where:** `%LOCALAPPDATA%\Packages\Clipchamp.Clipchamp_yxz26nhyzhsrt` (LocalState/LocalCache with project data and cached media, and the signed-in Clipchamp/Microsoft account).
- **Reveals:** Video projects (their names and references to the personal video/photo footage used), cached media thumbnails, and the signed-in account.
- **Remove (user runs):** Open Clipchamp, sign out, then reset it via Settings > Apps > Clipchamp > Advanced options > Reset. Exported videos saved to Videos/Downloads must be deleted separately.
- **Survives:** Projects saved to the Clipchamp/Microsoft cloud remain online. Exported video files in other folders are untouched. SSD remnants persist until overwritten.
- **Admin:** no.

### Paint and Paint 3D
- **Where:** New Windows Paint: `%LOCALAPPDATA%\Packages\Microsoft.Paint_8wekyb3d8bbwe`. Paint 3D (where still installed): `%LOCALAPPDATA%\Packages\Microsoft.MSPaint_8wekyb3d8bbwe`. Classic desktop Paint settings: `HKCU\Software\Microsoft\Windows\CurrentVersion\Applets\Paint`. Recently opened image paths also surface in Recent items / RecentDocs (catalogued separately).
- **Reveals:** Recently edited image file names and paths, and any Paint 3D project creations and 3D library content.
- **Remove (user runs):** Reset the app via Settings > Apps > Paint (and Paint 3D) > Advanced options > Reset. Saved images in Pictures/Desktop and the recent-files traces must be cleared separately.
- **Survives:** The image files themselves, wherever saved, are untouched by a reset. SSD remnants persist until overwritten.
- **Admin:** no.

### Calculator history
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsCalculator_8wekyb3d8bbwe\LocalState` (calculation history and stored memory entries).
- **Reveals:** Recent calculations and memory values — usually trivial, but can include figures the user worked out (amounts, measurements).
- **Remove (user runs):** In Calculator open History and select Clear (the trash icon), or reset the app via Settings > Apps > Calculator > Advanced options > Reset.
- **Survives:** Nothing syncs server-side. SSD remnants of the LocalState file persist until overwritten.
- **Admin:** no.

### Weather app saved locations
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.BingWeather_8wekyb3d8bbwe\LocalState` (favorite/saved locations, home city, and launch location).
- **Reveals:** Where the previous user lives and travels — home town, work city, and other saved places.
- **Remove (user runs):** In the Weather app remove each saved location and clear the launch/home location, or reset the app via Settings > Apps > Weather > Advanced options > Reset.
- **Survives:** Locations tied to a signed-in Microsoft account may resync from the cloud on next sign-in. SSD remnants persist until overwritten.
- **Admin:** no.

### News app interests and locations
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.BingNews_8wekyb3d8bbwe\LocalState` (followed topics/interests and saved locations).
- **Reveals:** The previous user's interests and followed topics (which can imply politics, health, or hobbies) and their location preferences.
- **Remove (user runs):** In the News app clear followed interests, or reset the app via Settings > Apps > Microsoft News > Advanced options > Reset.
- **Survives:** Interests tied to a Microsoft account resync from the cloud on next sign-in. SSD remnants persist until overwritten.
- **Admin:** no.

### Feedback Hub
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsFeedbackHub_8wekyb3d8bbwe\LocalState` (present only if the app was used), holding draft and submitted feedback and attached diagnostics.
- **Reveals:** Feedback the user wrote (which can contain personal context), any screenshots or diagnostic logs they attached, and the Microsoft account used to submit.
- **Remove (user runs):** Reset the app via Settings > Apps > Feedback Hub > Advanced options > Reset.
- **Survives:** Feedback already submitted stays on Microsoft's servers under the account. SSD remnants persist until overwritten.
- **Admin:** no.

### Widgets board (Web Experience)
- **Where:** `%LOCALAPPDATA%\Packages\MicrosoftWindows.Client.WebExperience_cw5n1h2txyewy` (widget board personalization, pinned widgets, MSN feed personalization, and the signed-in Microsoft account).
- **Reveals:** The signed-in Microsoft account, the location used by the weather widget, feed interests, and data surfaced by pinned widgets (calendar, To Do, Outlook, sports/finance picks).
- **Remove (user runs):** Sign out of the Widgets board, then reset via Settings > Apps > Windows Web Experience Pack > Advanced options > Reset where available. Removing the Microsoft account from Windows clears most of it.
- **Survives:** Personalization tied to the Microsoft account resyncs from the cloud on next sign-in. SSD remnants persist until overwritten.
- **Admin:** no.

### Clock app (alarms, timers, world clock, focus)
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.WindowsAlarms_8wekyb3d8bbwe\LocalState` (alarms and their labels, timers, saved world-clock cities, and focus-session data).
- **Reveals:** Alarm labels (which can hint at routines, medication, or appointments), world-clock cities (places or contacts' time zones the user tracks), and focus-session history (which may link a Spotify or To Do account).
- **Remove (user runs):** Delete each alarm, timer, and world-clock city in the app, or reset it via Settings > Apps > Clock > Advanced options > Reset.
- **Survives:** Focus data linked to a Microsoft account, and any linked Spotify/To Do connection, stay server-side. SSD remnants persist until overwritten.
- **Admin:** no.

---

## More developer, cloud & database tools

Additional developer and operations tools that store credentials, tokens or connection details.

### Oracle Cloud Infrastructure (OCI) CLI
- **Where:** `%USERPROFILE%\.oci\` — the `config` file plus the API signing key files it references (commonly `oci_api_key.pem`).
- **Reveals:** your tenancy and user OCIDs, home region, key fingerprint, configured profile names, and the paths to (often co-located) private API signing keys that authenticate to your Oracle Cloud account.
- **Remove (user runs):** delete the `%USERPROFILE%\.oci` folder in File Explorer; then sign in to the OCI Console and delete the matching API key under your user's API Keys.
- **Survives:** the API key stays valid on Oracle's side until you delete it in the Console. On an SSD the deleted files linger in unallocated space until TRIM/overwrite.
- **Admin:** no.

### IBM Cloud CLI
- **Where:** `%USERPROFILE%\.bluemix\` — `config.json` and `plugins\` (some builds use `%USERPROFILE%\.ibmcloud\`).
- **Reveals:** your IBM Cloud account, email, selected region and resource group, and cached IAM access/refresh tokens from your last login.
- **Remove (user runs):** run `ibmcloud logout`, then delete the `%USERPROFILE%\.bluemix` folder.
- **Survives:** server-side sessions last until the token expires; any API keys you created remain valid until you revoke them in IBM Cloud IAM. SSD remnants persist until overwrite.
- **Admin:** no.

### Alibaba Cloud CLI (aliyun)
- **Where:** `%USERPROFILE%\.aliyun\` — chiefly `config.json`.
- **Reveals:** your Alibaba Cloud AccessKey ID and AccessKey Secret (stored in clear), default region, and profile names.
- **Remove (user runs):** delete the `%USERPROFILE%\.aliyun` folder; then disable or delete that AccessKey in the Alibaba Cloud RAM console.
- **Survives:** the AccessKey authenticates to your account until you delete it in RAM. SSD remnants persist until overwrite.
- **Admin:** no.

### Linode CLI
- **Where:** `%USERPROFILE%\.config\linode-cli` (a single config file).
- **Reveals:** your Linode personal access token (stored in clear), default region/type/image, and the configured username.
- **Remove (user runs):** delete the `linode-cli` config file; then revoke the token under Linode Cloud Manager > API Tokens.
- **Survives:** the token keeps working until you revoke it in Linode. SSD remnants persist until overwrite.
- **Admin:** no.

### Scaleway CLI (scw)
- **Where:** `%USERPROFILE%\.config\scw\config.yaml`.
- **Reveals:** your Scaleway access key and secret key, organization and project IDs, and default region/zone.
- **Remove (user runs):** delete the `%USERPROFILE%\.config\scw` folder; then delete that API key in the Scaleway console.
- **Survives:** the API key stays valid until deleted in the console. SSD remnants persist until overwrite.
- **Admin:** no.

### Fly.io CLI (flyctl)
- **Where:** `%APPDATA%\flyctl\config.yml` (older installs used `%USERPROFILE%\.fly\`).
- **Reveals:** your Fly.io access token and the signed-in account email.
- **Remove (user runs):** run `fly auth logout`, then delete `%APPDATA%\flyctl`.
- **Survives:** the token is valid server-side until it expires or you revoke it in your Fly.io account. SSD remnants persist until overwrite.
- **Admin:** no.

### Vercel CLI
- **Where:** a `com.vercel.cli` folder under your AppData — `auth.json` (token) and `config.json`.
- **Reveals:** your Vercel authentication token and the signed-in account/email, plus recently used scope (team) IDs.
- **Remove (user runs):** run `vercel logout`, then delete the `com.vercel.cli` folder.
- **Survives:** the token works until revoked in Vercel account settings. SSD remnants persist until overwrite.
- **Admin:** no.

### Netlify CLI
- **Where:** global login in `%USERPROFILE%\.config\configstore\netlify.json`; a per-project `.netlify\state.json` inside each linked site folder.
- **Reveals:** your Netlify auth token and user ID (global config), and the site IDs/slugs of projects you linked (per-project state).
- **Remove (user runs):** run `netlify logout`, delete `%USERPROFILE%\.config\configstore\netlify.json`, and delete the `.netlify` folder in each project; then revoke the token under Netlify User settings > Applications.
- **Survives:** the token stays valid until revoked in Netlify. SSD remnants persist until overwrite.
- **Admin:** no.

### Supabase CLI
- **Where:** the access token is kept in Windows Credential Manager (a generic credential the CLI creates); a `%USERPROFILE%\.supabase` config/fallback folder may also exist, and linked projects leave a `supabase\.temp\` folder in the project directory.
- **Reveals:** that you were signed in to Supabase (the stored access token), and the project refs of databases you linked.
- **Remove (user runs):** run `supabase logout` (clears the Credential Manager entry), delete any `%USERPROFILE%\.supabase` folder and per-project `supabase\.temp`; then revoke the token at supabase.com > Account > Access Tokens.
- **Survives:** the token works until revoked on Supabase. Project refs are identifiers, not secrets. SSD remnants persist until overwrite.
- **Admin:** no.

### PlanetScale CLI (pscale)
- **Where:** `%USERPROFILE%\.config\planetscale\` (config and cached OAuth token).
- **Reveals:** your PlanetScale OAuth/access token, signed-in account, and default organization/database.
- **Remove (user runs):** run `pscale auth logout`, then delete `%USERPROFILE%\.config\planetscale`.
- **Survives:** the token is valid server-side until it expires or is revoked in your PlanetScale account. SSD remnants persist until overwrite.
- **Admin:** no.

### Fastly CLI
- **Where:** `%APPDATA%\fastly\config.toml`.
- **Reveals:** your Fastly API token(s) and profile names, and the associated account/user.
- **Remove (user runs):** delete `%APPDATA%\fastly`; then revoke the token under Fastly account > Personal API tokens.
- **Survives:** the token stays valid until revoked in Fastly. SSD remnants persist until overwrite.
- **Admin:** no.

### Akamai EdgeGrid credentials (.edgerc)
- **Where:** `%USERPROFILE%\.edgerc`.
- **Reveals:** your Akamai API credentials — client token, client secret, access token, and the account host — for each named section.
- **Remove (user runs):** delete `%USERPROFILE%\.edgerc`; then invalidate those API credentials in Akamai Control Center (Identity & Access).
- **Survives:** the credentials authenticate to your Akamai account until you revoke them in Control Center. SSD remnants persist until overwrite.
- **Admin:** no.

### Heroku CLI
- **Where:** `%LOCALAPPDATA%\heroku\` (config.json, cache); the API token itself is written to your netrc file (`%USERPROFILE%\_netrc` / `.netrc`).
- **Reveals:** the Heroku folder shows your account email and cached app/analytics data; the netrc entry holds the API token that logs in to your Heroku account.
- **Remove (user runs):** run `heroku logout` (clears the netrc entry), then delete `%LOCALAPPDATA%\heroku`.
- **Survives:** the token works until it expires or you regenerate it in Heroku account settings. The netrc file itself is shared with other tools (see the netrc entry). SSD remnants persist until overwrite.
- **Admin:** no.

### rclone
- **Where:** `%APPDATA%\rclone\rclone.conf`.
- **Reveals:** every cloud remote you configured, in one file — provider type, account identifiers, bucket/drive names, and saved tokens or passwords (obscured but reversible) for services like Google Drive, Dropbox, S3, OneDrive and many more.
- **Remove (user runs):** delete `%APPDATA%\rclone\rclone.conf` (or run `rclone config delete` per remote); then, for OAuth remotes, revoke rclone's access in each provider's connected-apps settings.
- **Survives:** stored tokens keep working until revoked at each provider. SSD remnants persist until overwrite.
- **Admin:** no.

### GitHub Desktop
- **Where:** `%APPDATA%\GitHub Desktop\` (config, logs, recent repositories); the GitHub access token is kept in Windows Credential Manager.
- **Reveals:** your signed-in GitHub account and email, the list and local paths of repositories you opened, and your recent commit author identity.
- **Remove (user runs):** in GitHub Desktop sign out (File > Options > Accounts), then delete `%APPDATA%\GitHub Desktop`; remove the GitHub entry from Windows Credential Manager if it remains.
- **Survives:** the OAuth token works until revoked under GitHub > Settings > Applications. Cloned repositories stay on disk. SSD remnants persist until overwrite.
- **Admin:** no.

### GitKraken
- **Where:** `%APPDATA%\.gitkraken\` (config, profiles, logs).
- **Reveals:** your GitKraken account, the linked GitHub/GitLab/Bitbucket integrations, your Git author identity, and the list and paths of repositories you opened.
- **Remove (user runs):** sign out in GitKraken (Preferences > Authentication), then delete `%APPDATA%\.gitkraken`; revoke the GitKraken integration in each hosting provider's settings.
- **Survives:** hosting-provider tokens work until revoked there. Cloned repos stay on disk. SSD remnants persist until overwrite.
- **Admin:** no.

### Sourcetree
- **Where:** `%LOCALAPPDATA%\Atlassian\SourceTree\` (accounts.json, bookmarks.xml) and `%APPDATA%\Atlassian\SourceTree\`.
- **Reveals:** your configured hosting accounts (Bitbucket/GitHub/GitLab) and usernames, and the names and local paths of bookmarked repositories.
- **Remove (user runs):** remove accounts in Sourcetree (Tools > Options > Authentication), then delete the `Atlassian\SourceTree` folders under both `%LOCALAPPDATA%` and `%APPDATA%`; clear any Sourcetree entries from Windows Credential Manager.
- **Survives:** saved OAuth/app passwords work until revoked at the hosting provider. Cloned repos stay on disk. SSD remnants persist until overwrite.
- **Admin:** no.

### Fork (Git client)
- **Where:** `%APPDATA%\Fork\` (settings and repository list).
- **Reveals:** the repositories you opened and their local paths, your configured hosting accounts, and your Git author identity.
- **Remove (user runs):** sign out of accounts in Fork, then delete `%APPDATA%\Fork`; revoke any hosting tokens in the provider's settings.
- **Survives:** hosting tokens work until revoked. Cloned repos stay on disk. SSD remnants persist until overwrite.
- **Admin:** no.

### Tower (Git client)
- **Where:** a `Tower` folder under `%APPDATA%` (services/accounts, repository bookmarks, recent list).
- **Reveals:** your configured hosting accounts and usernames, and the names and local paths of repositories you worked with.
- **Remove (user runs):** remove accounts in Tower's preferences, then delete the Tower folder under `%APPDATA%`; clear related Windows Credential Manager entries and revoke hosting tokens.
- **Survives:** hosting tokens work until revoked. Cloned repos stay on disk. SSD remnants persist until overwrite.
- **Admin:** no.

### Sublime Merge
- **Where:** `%APPDATA%\Sublime Merge\` (notably `Local\Session.sublime_session` and `Packages\User\`).
- **Reveals:** the repositories you opened and their local paths, your recent window layout, and your Git author identity; credential helpers it used may have cached tokens in Windows Credential Manager.
- **Remove (user runs):** delete `%APPDATA%\Sublime Merge`; clear any Git credential entries from Windows Credential Manager.
- **Survives:** cached Git tokens work until revoked at the hosting provider. Cloned repos stay on disk. SSD remnants persist until overwrite.
- **Admin:** no.

### GitLab CLI (glab)
- **Where:** `%APPDATA%\glab-cli\config.yml` (some setups use `%USERPROFILE%\.config\glab-cli\config.yml`).
- **Reveals:** your GitLab host(s), the access token (stored in the config unless a credential helper/keyring is used), and the default/preferred GitLab account.
- **Remove (user runs):** run `glab auth logout`, then delete the `glab-cli` config folder; revoke the token under GitLab > Preferences > Access Tokens.
- **Survives:** the token works until revoked in GitLab. SSD remnants persist until overwrite.
- **Admin:** no.

### Bitvise SSH Client
- **Where:** settings and the known-host-key database in the registry under `HKCU:\Software\Bitvise`; saved profile files (`*.bscp` / `*.tlp`) wherever you exported them (often Documents).
- **Reveals:** SSH servers you connected to (host, port, username), your authentication method, references to client key files, and the trusted host-key record of each server.
- **Remove (user runs):** in Bitvise clear the host-key database and saved profiles, then delete the `HKCU:\Software\Bitvise` key and any exported `.bscp`/`.tlp` files; delete your SSH private key files separately if stored locally.
- **Survives:** the remote servers and any keys you authorized there are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Xshell (NetSarang)
- **Where:** session files under `%USERPROFILE%\Documents\NetSarang Computer\<version>\Xshell\Sessions\*.xsh` (older builds: `%APPDATA%\NetSarang\Xshell\Sessions\`).
- **Reveals:** each saved session's host, port and username, and — if you chose to save it — an encrypted password; plus your connection history.
- **Remove (user runs):** delete the `Sessions` folder (and the parent `NetSarang Computer` / `%APPDATA%\NetSarang` folder) and clear Xshell's recent-session list.
- **Survives:** the remote hosts and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### ZOC Terminal
- **Where:** host-directory and settings files under `%USERPROFILE%\Documents\ZOC8 Files\` (or an `%APPDATA%\ZOC8` settings folder).
- **Reveals:** the hosts you saved (name, address, port, username) and connection options; saved passwords are stored encrypted if you enabled that.
- **Remove (user runs):** delete the ZOC host directory and settings files, and clear the recent-connections list in ZOC.
- **Survives:** the remote hosts and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Devolutions Remote Desktop Manager
- **Where:** `%LOCALAPPDATA%\Devolutions\RemoteDesktopManager\` and `%APPDATA%\Devolutions\` (settings, cache, and any local data source file).
- **Reveals:** saved RDP/SSH/VNC/web sessions — hostnames, usernames, and (for a local data source) encrypted credentials — plus your connection history and any configured remote data sources.
- **Remove (user runs):** in RDM remove local data sources and saved sessions, then delete the `Devolutions` folders under `%LOCALAPPDATA%` and `%APPDATA%`; sign out of any online/shared data source.
- **Survives:** sessions and credentials held in an online/shared data source live on the server, not this PC. SSD remnants persist until overwrite.
- **Admin:** no.

### MongoDB Compass
- **Where:** `%APPDATA%\MongoDB Compass\` (saved/favorite connections and recents; connection secrets are stored via the OS credential vault).
- **Reveals:** the MongoDB servers and clusters you connected to — hostnames, ports, usernames, database names — and your connection history.
- **Remove (user runs):** in Compass delete the saved connections, then delete `%APPDATA%\MongoDB Compass`; clear related entries from Windows Credential Manager.
- **Survives:** the remote databases and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### RedisInsight
- **Where:** `%APPDATA%\RedisInsight-v2\` (older editions: `%USERPROFILE%\.redisinsight`) — a local database of saved connections.
- **Reveals:** your Redis endpoints (host, port, username), stored connection passwords (encrypted locally), and command/workbench history.
- **Remove (user runs):** in RedisInsight delete the database connections, then delete the `RedisInsight-v2` (or `.redisinsight`) folder.
- **Survives:** the remote Redis instances and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### TablePlus
- **Where:** a `TablePlus` folder under `%APPDATA%` (saved connection groups and recents); connection passwords are stored via the OS credential vault.
- **Reveals:** the databases you connected to — type, host, port, username, database name — and recent queries.
- **Remove (user runs):** in TablePlus delete the saved connections, then delete the `TablePlus` folder under `%APPDATA%`; clear related Windows Credential Manager entries.
- **Survives:** the remote databases and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Navicat
- **Where:** connection definitions in the registry under `HKCU:\Software\PremiumSoft\` (e.g. `Navicat\Servers`), plus a `%APPDATA%\PremiumSoft\` data folder.
- **Reveals:** each saved database server — host, port, username, database — and its saved password (stored encrypted), along with your query/history files.
- **Remove (user runs):** in Navicat delete the saved connections, then delete the `HKCU:\Software\PremiumSoft` key and the `%APPDATA%\PremiumSoft` folder.
- **Survives:** the remote databases and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Azure Data Studio
- **Where:** `%APPDATA%\azuredatastudio\` (User\settings.json, connection profiles, history) and `%USERPROFILE%\.azuredatastudio\extensions`; connection secrets use the OS credential vault.
- **Reveals:** the SQL Server/Azure SQL/PostgreSQL servers you connected to — server names, logins, database names — your recently opened files, and any signed-in Azure account.
- **Remove (user runs):** in Azure Data Studio delete saved connections and sign out of Azure, then delete `%APPDATA%\azuredatastudio` and `%USERPROFILE%\.azuredatastudio`; clear related Windows Credential Manager entries.
- **Survives:** the remote databases and Azure account are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Beekeeper Studio
- **Where:** `%APPDATA%\beekeeper-studio\` — a local SQLite database of saved connections and query history.
- **Reveals:** the databases you connected to — type, host, port, username, database name — stored connection passwords (encrypted locally), and saved/recent queries.
- **Remove (user runs):** in Beekeeper Studio delete the saved connections, then delete the `beekeeper-studio` folder under `%APPDATA%`.
- **Survives:** the remote databases and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### DbVisualizer
- **Where:** `%USERPROFILE%\.dbvis\` (notably the `config*/dbvis.xml` settings file).
- **Reveals:** your saved database connections — driver, host, port, username, database — and connection passwords (saved encrypted; recoverable unless you set a master password).
- **Remove (user runs):** in DbVisualizer delete the connections, then delete the `%USERPROFILE%\.dbvis` folder.
- **Survives:** the remote databases and accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Visual Studio
- **Where:** `%LOCALAPPDATA%\Microsoft\VisualStudio\<version>\` (settings and the `privateregistry.bin` hive holding the recent-projects MRU), the signed-in account cache at `%LOCALAPPDATA%\.IdentityService\`, and your `%USERPROFILE%\Documents\Visual Studio <year>\` projects folder.
- **Reveals:** recently opened solutions and their paths, your signed-in Microsoft/Azure DevOps account and cached tokens, configured NuGet sources, and connected-service settings.
- **Remove (user runs):** in Visual Studio sign out (top-right account menu) and clear the recent list, then delete the version folder under `%LOCALAPPDATA%\Microsoft\VisualStudio` and the `%LOCALAPPDATA%\.IdentityService` folder; move your actual project files separately.
- **Survives:** the signed-in cloud account and Azure DevOps access are untouched until you sign out/revoke. SSD remnants persist until overwrite.
- **Admin:** no.

### Android Studio
- **Where:** `%APPDATA%\Google\AndroidStudio<version>\` (settings, recent projects), `%LOCALAPPDATA%\Google\AndroidStudio<version>\` (caches, logs), and `%USERPROFILE%\.android\` (AVD emulator images, `adbkey`, debug keystore).
- **Reveals:** recently opened projects and their paths, SDK locations, signed-in accounts for IDE plugins, and — in `.android` — emulator data and your debug signing key.
- **Remove (user runs):** in Android Studio clear the recent-projects list and sign out of plugin accounts, then delete the `Google\AndroidStudio*` folders under `%APPDATA%` and `%LOCALAPPDATA%` and the `%USERPROFILE%\.android` folder; move real project files separately.
- **Survives:** any cloud accounts signed into plugins are untouched until you sign out. SSD remnants persist until overwrite.
- **Admin:** no.

### Eclipse IDE
- **Where:** the workspace `.metadata\` under your workspace (default `%USERPROFILE%\eclipse-workspace\`), and the Equinox secure storage at `%USERPROFILE%\.eclipse\org.eclipse.equinox.security\secure_storage`.
- **Reveals:** recently opened projects and files, your workspace location, and — in secure storage — saved passwords for Git repositories, servers and other plug-ins (encrypted).
- **Remove (user runs):** delete the secure storage file (or clear it via Window > Preferences > General > Security > Secure Storage > Delete), then delete the `.metadata` folder and `%USERPROFILE%\.eclipse`; move real project files separately.
- **Survives:** the remote repositories/servers and their accounts are untouched. SSD remnants persist until overwrite.
- **Admin:** no.

### Sublime Text
- **Where:** `%APPDATA%\Sublime Text\` (v4; older: `Sublime Text 3`) — notably `Local\Session.sublime_session` and `Packages\User\`.
- **Reveals:** your recently opened files, folders and projects (paths can expose personal document and project names), open workspaces, and the contents of unsaved ("hot exit") buffers.
- **Remove (user runs):** delete the `%APPDATA%\Sublime Text` folder (or at least `Local\Session.sublime_session` and the `Packages\User` autosave/session files).
- **Survives:** nothing remote — this is local editor state. SSD remnants persist until overwrite.
- **Admin:** no.

### Cursor
- **Where:** `%APPDATA%\Cursor\` (User\settings.json, `workspaceStorage`, `History`, logs) and `%USERPROFILE%\.cursor\extensions`.
- **Reveals:** recently opened folders/workspaces and their paths, your signed-in Cursor account, local AI chat/prompt history, and tokens cached by installed extensions.
- **Remove (user runs):** in Cursor sign out and clear recents, then delete `%APPDATA%\Cursor` and `%USERPROFILE%\.cursor`; clear related Windows Credential Manager entries.
- **Survives:** the Cursor account and any extension cloud sessions are untouched until signed out/revoked. SSD remnants persist until overwrite.
- **Admin:** no.

### VSCodium
- **Where:** `%APPDATA%\VSCodium\` (User\settings.json, `workspaceStorage`, `History`) and `%USERPROFILE%\.vscode-oss\extensions`.
- **Reveals:** recently opened folders/workspaces and their paths, editor settings, installed extensions, and any tokens those extensions cached.
- **Remove (user runs):** clear recents and sign out of extensions, then delete `%APPDATA%\VSCodium` and `%USERPROFILE%\.vscode-oss`; clear related Windows Credential Manager entries.
- **Survives:** any extension cloud sessions are untouched until revoked. SSD remnants persist until overwrite.
- **Admin:** no.

### Cargo (Rust) credentials
- **Where:** `%USERPROFILE%\.cargo\credentials.toml` (older: `%USERPROFILE%\.cargo\credentials`).
- **Reveals:** your crates.io API token, and tokens for any alternate/private registries you configured.
- **Remove (user runs):** run `cargo logout` (and `cargo logout --registry <name>` for others), or delete the file; then revoke the token on crates.io > Account.
- **Survives:** the token stays valid until revoked on crates.io. SSD remnants persist until overwrite.
- **Admin:** no.

### Composer (PHP) auth
- **Where:** `%APPDATA%\Composer\auth.json`.
- **Reveals:** credentials for private Composer/Packagist repositories — HTTP basic auth usernames/passwords and GitHub/GitLab/Bitbucket OAuth tokens — stored in clear.
- **Remove (user runs):** delete `%APPDATA%\Composer\auth.json` (or unset entries with `composer config --global --unset`); then revoke the affected tokens at each provider.
- **Survives:** the tokens work until revoked at the provider. SSD remnants persist until overwrite.
- **Admin:** no.

### Gradle properties
- **Where:** `%USERPROFILE%\.gradle\gradle.properties` (and the `%USERPROFILE%\.gradle\caches` tree).
- **Reveals:** repository and publishing credentials people commonly store here in clear — artifact-repo usernames/passwords, signing-key passwords, and API keys referenced by builds.
- **Remove (user runs):** edit or delete `%USERPROFILE%\.gradle\gradle.properties`; then rotate any credentials it exposed at their source.
- **Survives:** the credentials stay valid until you rotate them. SSD remnants persist until overwrite.
- **Admin:** no.

### conda configuration
- **Where:** `%USERPROFILE%\.condarc`, the `%USERPROFILE%\.conda\` folder, and the Anaconda.org token store `%USERPROFILE%\.continuum\anaconda-client\tokens\`.
- **Reveals:** your configured channels (which can expose private or enterprise repository URLs), any tokens embedded in channel URLs, proxy settings that may include credentials, and saved Anaconda.org API tokens.
- **Remove (user runs):** edit/delete `.condarc` (or use `conda config --remove`), run `anaconda logout`, and delete the `.conda` and `.continuum` folders; then revoke the token in your Anaconda.org account.
- **Survives:** tokens work until revoked at Anaconda.org. SSD remnants persist until overwrite.
- **Admin:** no.

---

## More password managers, wallets, cloud & VPN

Additional password managers, cryptocurrency wallets and authenticators, cloud-sync providers and VPN clients.

### Keeper Password Manager (desktop cache)
- **Where:** `%APPDATA%\Keeper Password Manager\` holds the Electron desktop app's data — a local encrypted cache of the vault, `config`/settings, and logs; the program itself installs under `%LOCALAPPDATA%\Programs\KeeperPasswordManager`. Some builds use a plain `%APPDATA%\Keeper` folder name instead.
- **Reveals:** That the previous owner used Keeper, the account email / sign-in shown in settings, and an encrypted local copy of the vault (logins, secure notes, payment cards, files). Vault contents are end-to-end encrypted, but the account email and the existence of a vault are exposed, and a saved "stay logged in" / biometric unlock can let the vault open on this device.
- **Remove (user runs):** In the app choose **Logout** (this clears the local cache and any device unlock), uninstall via Settings > Apps > Installed apps, then in File Explorer delete the leftover `%APPDATA%\Keeper Password Manager` folder and empty the Recycle Bin. Remove this device under your Keeper account's security settings.
- **Survives:** Your Keeper **vault lives on Keeper's servers** and is untouched by local removal (intended — it is your vault); it persists until you change the master password or close the account. SSD remnants until TRIM/overwrite.
- **Admin:** No.

### Sticky Password (local database)
- **Where:** `%APPDATA%\Sticky Password\` holds the app's settings and local encrypted database; the program installs under `%PROGRAMFILES(X86)%\Sticky Password`. If the user turned on local Wi-Fi/cloud sync, a synced copy also exists.
- **Reveals:** That Sticky Password was used, the account identity, and an encrypted store of saved logins, identities and secure items. The database is encrypted under the master password, but its presence maps that a credential vault exists and which account owns it.
- **Remove (user runs):** In the app, sign out and (if offered) delete the local database, then uninstall via Settings > Apps > Installed apps and delete the leftover `%APPDATA%\Sticky Password` folder in File Explorer and empty the Recycle Bin.
- **Survives:** If Sticky Password cloud sync was enabled, the vault remains on the vendor's servers until you remove it there and change the master password. Any device you synced to keeps its own copy. SSD remnants until TRIM.
- **Admin:** No to remove your per-user data; uninstalling the program may raise a UAC prompt.

### Password Safe (pwsafe)
- **Where:** The vault is a `.psafe3` file wherever you saved it (often `%USERPROFILE%\Documents` or a USB/synced folder). Settings and the recently-opened-safe (MRU) list live in the registry at `HKCU:\Software\Password Safe\Password Safe`. A key-file second factor may sit alongside the `.psafe3`.
- **Reveals:** The `.psafe3` holds **all your passwords**, strongly encrypted under the master password. Even if the new owner cannot open it, the registry MRU reveals the safe's name and path (and that you use one), and a weak master password can be attacked offline from any copy of the file.
- **Remove (user runs):** Move any safe you are keeping to backup, then delete the `.psafe3` file (and any key-file) in File Explorer and empty the Recycle Bin. Clear the recent-safe list in the app (Manage > Options) or with `reg delete "HKCU\Software\Password Safe\Password Safe" /f` (you run this yourself).
- **Survives:** Cloud- or USB-synced copies of the `.psafe3` remain until deleted at those locations. SSD remnants until TRIM. An unchanged master password means any leaked copy stays exactly as strong (or weak) as that password.
- **Admin:** No.

### Padloc
- **Where:** `%APPDATA%\Padloc\` holds the Electron desktop app's encrypted local store and settings; the program installs under `%LOCALAPPDATA%\Programs\padloc` / `%LOCALAPPDATA%\Programs\Padloc`.
- **Reveals:** That Padloc was used, the signed-in account email, and an encrypted local copy of the vault (logins, notes). Contents are encrypted under your master password; the account email and vault existence are exposed.
- **Remove (user runs):** In the app, lock and **log out** (clears the local store), uninstall via Settings > Apps > Installed apps, then delete the leftover `%APPDATA%\Padloc` folder in File Explorer and empty the Recycle Bin.
- **Survives:** If the vault syncs to the Padloc cloud (or a self-hosted Padloc server), that server copy remains until you remove it and change the master password; other synced devices keep their copies. SSD remnants until TRIM.
- **Admin:** No.

### Buttercup
- **Where:** `%APPDATA%\Buttercup\` holds the desktop app's config and app data; the program installs under `%LOCALAPPDATA%\Programs\buttercup`. Vaults are separate `.bcup` files kept locally (often in `%USERPROFILE%\Documents`) or in a linked cloud folder (Dropbox, Google Drive, WebDAV), and the config records their paths.
- **Reveals:** That Buttercup was used and — via the config's vault list — the name and location of each `.bcup` vault (and that one exists). Each `.bcup` holds your passwords, encrypted under its master password.
- **Remove (user runs):** Move any vault you are keeping to backup, then in the app remove each vault source; delete the `.bcup` files and the `%APPDATA%\Buttercup` folder in File Explorer and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** Cloud-linked `.bcup` vaults remain at the provider (Dropbox/Google Drive/WebDAV) until deleted there and the link is removed. SSD remnants until TRIM; an unchanged master password keeps any leaked copy as strong as that password.
- **Admin:** No.

### Bitcoin Core
- **Where:** `%APPDATA%\Bitcoin\` is the data directory: `wallet.dat` directly (legacy) or under `wallets\<name>\wallet.dat` (modern multi-wallet), plus `bitcoin.conf`, `settings.json`, `debug.log`, `peers.dat`, and the full blockchain in `blocks\` and `chainstate\` (hundreds of GB). Testnet/regtest data sit in `testnet3\`/`regtest\` subfolders.
- **Reveals:** That the owner ran a full Bitcoin node, plus the wallet itself — addresses, balances and transaction history, and the private keys in `wallet.dat` (encrypted only if you set a wallet passphrase; otherwise the keys are in the clear).
- **Remove (user runs):** If the wallet holds funds, move them to a new wallet with a fresh seed first. Close Bitcoin Core, then in File Explorer delete the `%APPDATA%\Bitcoin` folder and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps. (Deleting the whole folder also reclaims the large blockchain.)
- **Survives:** On-chain balances and history are public and permanent regardless of local deletion — anyone who still holds the seed/keys controls the coins. An unencrypted `wallet.dat` is especially dangerous as an SSD remnant until the free space is overwritten; exported backups and `wallet.dat` copies persist elsewhere.
- **Admin:** No.

### Monero GUI wallet
- **Where:** `%APPDATA%\monero-project\` holds GUI settings (`monero-core.conf`); when you run the bundled node the blockchain (LMDB `data.mdb`, tens of GB) sits under `%APPDATA%\bitmonero\`. The wallet files themselves — `<name>` plus `<name>.keys` (the encrypted spend/view keys) and `<name>.address.txt` — are stored wherever you chose, often `%USERPROFILE%\Documents\Monero\`.
- **Reveals:** That Monero (a privacy coin) was used. The `.keys` file holds the encrypted spend/view keys and the `.address.txt` exposes your primary address; the GUI config and bitmonero data confirm wallet use even if the key files were moved.
- **Remove (user runs):** Move any funds to a new wallet with a fresh seed first. Close the app, then in File Explorer delete the wallet files (`<name>`, `.keys`, `.address.txt`), the `%APPDATA%\monero-project` folder, and `%APPDATA%\bitmonero` if present, and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** Monero's chain is private but permanent; whoever holds the 25-word seed can restore the wallet. Encrypted `.keys` files leave SSD remnants until TRIM; any exported seed or backup persists elsewhere.
- **Admin:** No.

### Sparrow Wallet
- **Where:** `%APPDATA%\Sparrow\` with wallet files under `%APPDATA%\Sparrow\wallets\` (`.mv.db` H2 databases, password-encrypted), plus `config`, a `wallets-backup\` folder, and cache/log files that hold labels and server details.
- **Reveals:** That Sparrow (a Bitcoin wallet) was used — wallet names and labels, addresses, balances and transaction history, and extended public keys (xpub) in the config/cache. Wallet files are password-encrypted, but the xpub and labels alone map your holdings and the wallet type (incl. hardware-wallet pairings).
- **Remove (user runs):** If a hot wallet holds funds, move them to a fresh seed first. Close Sparrow, delete the `%APPDATA%\Sparrow` folder in File Explorer (including `wallets` and `wallets-backup`), and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** On-chain history is public and permanent; an exported xpub lets anyone watch all your addresses forever. Encrypted wallet files and the `wallets-backup` copies leave SSD remnants until TRIM; any seed you backed up elsewhere persists.
- **Admin:** No.

### Trezor Suite (desktop)
- **Where:** `%APPDATA%\@trezor\` (the Electron app's data lives under `%APPDATA%\@trezor\suite-desktop\`), holding settings, logs, and a local metadata cache; the program installs under `%LOCALAPPDATA%\Programs\@trezor`.
- **Reveals:** Trezor Suite is the companion app for a Trezor hardware wallet, so it does **not** hold your seed or private keys — those stay on the device. It does cache your account list, account labels, receiving addresses, extended public keys (xpub) and portfolio/transaction history, which disclose what crypto you hold and roughly how much.
- **Remove (user runs):** In Trezor Suite, Settings > clear/forget the connected device and wipe the app's local data, then uninstall via Settings > Apps > Installed apps and delete the leftover `%APPDATA%\@trezor` folder in File Explorer; empty the Recycle Bin.
- **Survives:** On-chain data is public and permanent. If you used Suite's **labeling** feature, your encrypted labels are backed up to your Dropbox or Google Drive and remain until removed there. Your funds are unaffected (controlled by the hardware device's seed, not this PC). SSD remnants until TRIM.
- **Admin:** No.

### Guarda desktop wallet
- **Where:** `%APPDATA%\Guarda\` holds the Electron app's encrypted wallet data and settings; the program installs under `%LOCALAPPDATA%\Programs\guarda` / `%LOCALAPPDATA%\Programs\Guarda`.
- **Reveals:** That the owner held crypto in Guarda (a multi-currency wallet), which assets and addresses, transaction history, and the encrypted backup/key material — protected only by the wallet password.
- **Remove (user runs):** Move any remaining funds to a new wallet with a fresh seed first. In the app, log out / remove the wallet, uninstall via Settings > Apps > Installed apps, delete the leftover `%APPDATA%\Guarda` folder in File Explorer, and empty the Recycle Bin.
- **Survives:** On-chain balances and history are public and permanent; whoever holds the seed controls the funds. Encrypted key files leave SSD remnants until TRIM, so moving funds to a fresh seed before handover is the real safeguard; any exported backup persists elsewhere.
- **Admin:** No.

### Coinomi desktop wallet
- **Where:** `%LOCALAPPDATA%\Coinomi\` — wallet files are commonly kept under `%LOCALAPPDATA%\Coinomi\Coinomi\wallets\`, with settings alongside. (Exact nested layout can vary by version.)
- **Reveals:** That the owner held crypto in Coinomi (a multi-coin wallet), which coins and addresses, and transaction history. Wallet files are encrypted under the wallet password, but their presence discloses the holdings and that a seed exists.
- **Remove (user runs):** Move any remaining funds to a new wallet with a fresh seed first. In the app, remove the wallet, uninstall via Settings > Apps > Installed apps, delete the leftover `%LOCALAPPDATA%\Coinomi` folder in File Explorer, and empty the Recycle Bin.
- **Survives:** On-chain history is public and permanent; whoever holds the recovery phrase controls the funds. Encrypted wallet files leave SSD remnants until TRIM; any exported seed or backup persists elsewhere.
- **Admin:** No.

### Jaxx Liberty wallet
- **Where:** `%APPDATA%\Jaxx Liberty\` (the Electron desktop app's data). The older "Jaxx" (Classic) build used `%APPDATA%\Jaxx`. Jaxx Liberty was discontinued in 2021, so this is typically a stale but still data-bearing folder.
- **Reveals:** That the owner held crypto in Jaxx, which assets and addresses, transaction history, and the encrypted wallet/backup material (protected by the wallet password — Jaxx's encryption was notably weak, so treat any leftover copy as at risk).
- **Remove (user runs):** If any funds remain and are recoverable, move them to a new wallet with a fresh seed first. Uninstall via Settings > Apps > Installed apps, delete the leftover `%APPDATA%\Jaxx Liberty` (and `%APPDATA%\Jaxx`) folder in File Explorer, and empty the Recycle Bin.
- **Survives:** On-chain history is public and permanent; whoever holds the 12-word phrase controls the funds. Given Jaxx's weak local encryption, an undeleted/recoverable wallet file is a real exposure until the free space is overwritten; any exported backup persists elsewhere.
- **Admin:** No.

### BitPay wallet
- **Where:** `%APPDATA%\BitPay\` holds the Electron wallet app's data (encrypted wallet/key store and settings); the program installs under `%LOCALAPPDATA%\Programs\bitpay`. Wallets migrated from its predecessor Copay may also leave `%APPDATA%\Copay`.
- **Reveals:** That the owner used the BitPay (ex-Copay) wallet, which coins and addresses, transaction history, and the encrypted key material protected by the wallet password.
- **Remove (user runs):** Move any remaining funds to a new wallet with a fresh seed first. In the app, delete each wallet, uninstall via Settings > Apps > Installed apps, delete the leftover `%APPDATA%\BitPay` (and `%APPDATA%\Copay`) folder in File Explorer, and empty the Recycle Bin.
- **Survives:** On-chain balances and history are public and permanent; whoever holds the recovery phrase controls the funds. Encrypted key files leave SSD remnants until TRIM; any exported backup persists elsewhere.
- **Admin:** No.

### Daedalus (Cardano full-node wallet)
- **Where:** `%APPDATA%\Daedalus Mainnet\` — wallet secret keys (encrypted under your spending password) in a `wallets\` store, the full Cardano chain under `chain\` (very large), plus `Logs\` and config. Test networks use sibling folders such as `Daedalus Testnet` / `Daedalus Preprod`.
- **Reveals:** That the owner ran Daedalus and held ADA — wallet addresses, balances and transaction history, and the encrypted spending keys. The chain folder alone confirms full-node use even if the wallet was restored elsewhere.
- **Remove (user runs):** Move any funds to a new wallet with a fresh recovery phrase first. Close Daedalus, delete the `%APPDATA%\Daedalus Mainnet` folder (and any Testnet/Preprod siblings) in File Explorer, and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps (this reclaims the large chain data).
- **Survives:** Cardano's chain is public and permanent; whoever holds the 24-word phrase controls the ADA. Encrypted key files leave SSD remnants until TRIM; any exported recovery phrase or backup persists elsewhere.
- **Admin:** No.

### Electrum altcoin forks (Electron Cash, Electrum-LTC, etc.)
- **Where:** Electrum's codebase is reused by several coins, each with its own data folder: Electron Cash (BCH) `%APPDATA%\ElectronCash\`, Electrum-LTC (Litecoin) `%APPDATA%\Electrum-LTC\`, and similar forks. Each mirrors Electrum's layout — a `wallets\` folder (default file `default_wallet`) plus a `config` file for settings and recent servers.
- **Reveals:** That the owner used that coin's Electrum fork — addresses, balances, transaction history and wallet labels. As with Electrum, these forks do not force encryption, so an unprotected wallet file can expose the seed phrase and private keys directly.
- **Remove (user runs):** If funds remain, move them to a new wallet with a fresh seed first. Close the app, then in File Explorer delete the relevant folder (`%APPDATA%\ElectronCash`, `%APPDATA%\Electrum-LTC`, etc.) and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps.
- **Survives:** On-chain history is public and permanent. An unencrypted wallet file is especially dangerous as an SSD remnant until the free space is overwritten; any exported seed or backup persists elsewhere.
- **Admin:** No.

### Moneydance
- **Where:** `%APPDATA%\Moneydance\` holds the app's preferences, the default dataset and automatic backups; datasets opened from elsewhere (the `.moneydance` document, often under `%USERPROFILE%\Documents`) are referenced by a recent-files list. The program installs under `%PROGRAMFILES%\Moneydance` / `%LOCALAPPDATA%\Programs`.
- **Reveals:** Linked bank, credit-card and investment account names and balances, full transaction history, payees, and the online-banking identifiers used to download transactions — a detailed picture of the owner's finances. The recent-files list exposes dataset names/paths even if a dataset was moved.
- **Remove (user runs):** Close Moneydance, then in File Explorer delete the `.moneydance` dataset(s) and the `%APPDATA%\Moneydance` folder (preferences + backups) and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps. If you used Moneydance's sync/cloud, remove the dataset there too.
- **Survives:** OneDrive copies if your Documents folder is synced; any sync/cloud dataset on the service; File History, system images and backup drives; SSD remnants until TRIM.
- **Admin:** No.

### MoneyWiz (Windows build)
- **Where:** The Windows version of MoneyWiz shipped as a Microsoft Store app, so its data lives in a package folder under `%LOCALAPPDATA%\Packages\` (look for a MoneyWiz-named package family, with the database and settings inside its `LocalState`/`LocalCache`). The Store app itself appears in Settings > Apps.
- **Reveals:** Account names and balances, categorized transaction history, payees and budgets — the owner's income and spending. MoneyWiz also syncs across devices, so the local store mirrors the synced data.
- **Remove (user runs):** In MoneyWiz, sign out of sync, then uninstall the app via Settings > Apps > Installed apps (removing a Store app deletes its package `LocalState`). Confirm the MoneyWiz folder under `%LOCALAPPDATA%\Packages` is gone and empty the Recycle Bin.
- **Survives:** If MoneyWiz Sync (the vendor's cloud) was used, your data remains on their servers and on other synced devices until you delete it there. SSD remnants until TRIM; any backup persists.
- **Admin:** No.

### Microsoft Money (legacy)
- **Where:** Microsoft Money (discontinued 2009; "Money Plus Sunset" still installs) stores each file as a `.mny` document wherever you saved it, usually `%USERPROFILE%\Documents`, with `.mbf` backups alongside. Settings and the recently-opened-file (MRU) list live in the registry at `HKCU:\Software\Microsoft\Microsoft Money`.
- **Reveals:** Linked bank, credit-card, loan and investment accounts and balances, full transaction history, payees, and any online-banking identifiers stored for downloads — a complete financial history for whoever kept the file.
- **Remove (user runs):** In File Explorer delete the `.mny` file and its `.mbf` backups and empty the Recycle Bin. Clear the recent-file list with `reg delete "HKCU\Software\Microsoft\Microsoft Money" /f` (you run this yourself) or uninstall the program via Settings > Apps > Installed apps.
- **Survives:** OneDrive copies if Documents is synced; the registry MRU if left in place (and its copies in restore points); File History and backup drives; SSD remnants until TRIM.
- **Admin:** No.

### Sage 50 Accounts (company data)
- **Where:** Sage 50 Accounts (UK) stores each company as a data folder whose name ends in **`.saj`** (with a matching `.sai` index), by default under `%PROGRAMDATA%\Sage\Accounts\<year>\`. Sage 50 US (formerly Peachtree) instead keeps company data under a chosen folder or `%PUBLIC%\Documents\Sage Software\`. Per-user settings/recent-company hints also sit under `HKCU:\Software\Sage`.
- **Reveals:** A business's full books — customer and supplier names and contacts, employee and payroll records, bank and card account numbers, invoices, VAT/tax identifiers, and transaction history.
- **Remove (user runs):** Close Sage, then in File Explorer delete the company `.saj`/`.sai` data set(s) from `%PROGRAMDATA%\Sage\Accounts` (or the US data location) and empty the Recycle Bin. Uninstall via Settings > Apps > Installed apps. If this is a business/work machine, hand it back through the organization rather than stripping it yourself — accounting data often has legal retention duties.
- **Survives:** Off-site accountant copies, Sage Drive / cloud-backup copies, and local Sage backups (`.001`/`.ptb`) persist until removed at those locations; File History, system images and backup drives; SSD remnants until TRIM.
- **Admin:** No to delete a company folder under your own Documents; clearing `%PROGRAMDATA%\Sage` and uninstalling the program need admin.

### Drake Tax (preparer client files)
- **Where:** Drake Tax installs to `%SYSTEMDRIVE%\DrakeSoftware\Drake<YY>\` in current versions (older installs used `C:\Drake<YY>` directly), where `<YY>` is the two-digit tax year. Client returns and the client database live in its `DT`/`DrakeYY` data folders under that path.
- **Reveals:** Among the most sensitive data a PC can hold — professional tax preparer client files: full legal names, Social Security Numbers (filers, spouses, dependents), addresses, employer and income data, and bank account/routing numbers, for every client and year prepared.
- **Remove (user runs):** This is almost always a **work/business device** — return it through the firm and let them handle client-data retention and secure disposal rather than deleting yourself. If it is genuinely yours to clear: close Drake, delete the `%SYSTEMDRIVE%\DrakeSoftware` (or `C:\Drake<YY>`) folders in File Explorer, empty the Recycle Bin, and uninstall via Settings > Apps > Installed apps.
- **Survives:** E-filed returns are held by the IRS/state and in Drake's e-file/online records; prior-year installs each keep their own data; firm network shares, document-management systems and backups persist independently. SSD remnants until TRIM.
- **Admin:** Yes (program and its data folders are machine-wide on the C: root; removing them and uninstalling need admin).

### Intuit ProSeries (preparer client files)
- **Where:** Intuit ProSeries installs per tax year to `%SYSTEMDRIVE%\ProWin<YY>\` (standalone) or `%SYSTEMDRIVE%\ProNet<YY>\` (network), with client returns in a `<YY>Data` subfolder. (Its Intuit registry presence under `HKCU:\Software\Intuit` is already cataloged separately.)
- **Reveals:** Professional tax client files — full names, SSNs for filers/spouses/dependents, addresses, income and employer detail, and bank account/routing numbers, for every client and year prepared.
- **Remove (user runs):** Treat as a **work/business device** and return it through the firm for proper client-data disposal. If it is genuinely yours: close ProSeries, delete the `ProWin<YY>`/`ProNet<YY>` folders under `%SYSTEMDRIVE%` in File Explorer, empty the Recycle Bin, and uninstall via Settings > Apps > Installed apps.
- **Survives:** E-filed returns live with the IRS/state and in Intuit's e-file/online records; each tax year's install keeps its own data; firm shares and backups persist. SSD remnants until TRIM.
- **Admin:** Yes (machine-wide install on the C: root; removal and uninstall need admin).

### Intuit Lacerte (preparer client files)
- **Where:** Intuit Lacerte installs under `%SYSTEMDRIVE%\Lacerte\` with a per-year subfolder (`<YY>tax`) and client data in its `CLData`/`IData`-style folders. (Lacerte's Intuit registry presence under `HKCU:\Software\Intuit` is already cataloged separately.)
- **Reveals:** Professional tax client files — names, SSNs, addresses, income and bank details for every client and year — the same highly sensitive preparer data as ProSeries/Drake.
- **Remove (user runs):** Treat as a **work/business device** and return it through the firm. If it is genuinely yours: close Lacerte, delete the `%SYSTEMDRIVE%\Lacerte\<YY>tax` data folders in File Explorer, empty the Recycle Bin, and uninstall via Settings > Apps > Installed apps.
- **Survives:** E-filed returns are held by the IRS/state and Intuit's e-file records; prior-year data folders persist; firm network shares and backups persist. SSD remnants until TRIM.
- **Admin:** Yes (machine-wide install on the C: root; removal and uninstall need admin).

### TaxSlayer Pro (desktop)
- **Where:** TaxSlayer Pro (the desktop product for tax preparers) installs to `%SYSTEMDRIVE%\TaxSlayerPro\` and stores client returns in its data folders there. The **consumer** TaxSlayer product is web-only, so on a PC it leaves browser traces (saved login, cookies, cache) rather than a local data folder.
- **Reveals:** For TaxSlayer Pro, professional client files — names, SSNs, addresses, income and bank account detail per client/year. For the consumer web version, a stored browser session can open the owner's online account and returns.
- **Remove (user runs):** Pro: treat as a **work/business device** and return it through the firm; if yours, close the app, delete `%SYSTEMDRIVE%\TaxSlayerPro` in File Explorer, empty the Recycle Bin, and uninstall via Settings > Apps > Installed apps. Consumer: sign out in the browser and clear the saved password, cookies and site data for the TaxSlayer site, and sign in to the account to review it.
- **Survives:** E-filed returns are held by the IRS/state and in TaxSlayer's online records; consumer returns live entirely on TaxSlayer's servers regardless of this PC; firm shares and backups persist for Pro. SSD remnants until TRIM.
- **Admin:** Yes for the Pro desktop install (machine-wide on the C: root); No for the consumer web/browser cleanup.

### IDrive
- **Where:** Installs machine-wide (default `%ProgramFiles(x86)%\IDrive`, or `%ProgramFiles%\IDrive`) and runs a background scheduler service. The account details, the backup-set definition (the list of folders chosen for backup) and logs are kept in IDrive's own program/app-data folders. (Exact per-user / `%ProgramData%` config path not fully confirmed — see return.)
- **Reveals:** The IDrive account email, which local folders the owner backed up (the backup set), and backup/restore logs with file paths and timestamps.
- **Remove (user runs):** Open IDrive and sign out of the account; uninstall via Settings > Apps > Installed apps (this removes the service); delete any leftover IDrive folder under Program Files/ProgramData; empty the Recycle Bin. Remove the online backup at idrive.com (and its account-side archive/trash) if the account is not being handed over.
- **Survives:** **The cloud backup on the IDrive account persists until it is removed server-side** — uninstalling only stops this PC. IDrive keeps previous file versions by design until pruned in the account. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (uninstalling the service and clearing Program Files/ProgramData needs elevation).

### Backblaze Personal Backup
- **Where:** `%ProgramData%\Backblaze` — the `bzdata` subfolder holds the backup state, the file lists of everything backed up (`bzdata\bzfilelists`), reports and logs; account/config live here too. Runs as a SYSTEM service.
- **Reveals:** The Backblaze account email and — through the file lists and logs — the full paths and names of every file and folder the owner backed up, which effectively maps their whole data layout.
- **Remove (user runs):** Open the Backblaze control panel and sign out; uninstall via Settings > Apps (there is also an "uninstall and delete state" option); delete any remaining `%ProgramData%\Backblaze` from an elevated session; empty the Recycle Bin. Delete the online backup (and close/transfer the account) at the Backblaze website if it is not being handed over.
- **Survives:** **The cloud backup stays on Backblaze's servers** until the account is emptied/closed (version history is kept for the retention window). The `bzdata` folder is SYSTEM-owned, so clearing it on disk needs admin. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (`bzdata` is ACL-restricted to SYSTEM; uninstalling the service needs elevation).

### CrashPlan (Code42)
- **Where:** `%ProgramData%\CrashPlan` — `conf\` (service/user config including the backup selection), `cache\`, and `log\`. Installs under `%ProgramFiles%\CrashPlan` and runs a service. (Branded CrashPlan or Code42; same layout.)
- **Reveals:** The account/login, the backup selection (which folders and files were backed up), and logs naming file paths and timestamps.
- **Remove (user runs):** Sign out in the CrashPlan app; uninstall via Settings > Apps (removes the service); delete any leftover `%ProgramData%\CrashPlan` from an elevated session; empty the Recycle Bin. Remove the archive server-side via the CrashPlan/Code42 console if the account is not transferring with the PC.
- **Survives:** **The backup archive persists on the CrashPlan/Code42 cloud (or the organisation's server)** until it is removed there; version history is retained by policy. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service uninstall and `%ProgramData%` cleanup need elevation).

### Carbonite Safe
- **Where:** Installs under `%ProgramFiles%\Carbonite\Carbonite Backup` and keeps config, state and logs under `%ProgramData%\Carbonite` (subfolder commonly `Carbonite Backup`). Runs a background service. (Exact `%ProgramData%` subfolder not fully confirmed — see return.)
- **Reveals:** The Carbonite account, which folders were selected for backup, and backup logs.
- **Remove (user runs):** Sign out / deactivate this computer in the Carbonite app; uninstall via Settings > Apps; delete any leftover `%ProgramData%\Carbonite` from an elevated session; empty the Recycle Bin. Manage or remove the online backup in the Carbonite account, and deactivate the subscription's computer if it is not transferring with the PC.
- **Survives:** **The cloud backup remains on Carbonite's servers** until the subscription/computer is removed there. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service uninstall and `%ProgramData%` cleanup need elevation).

### Degoo
- **Where:** On Windows, Degoo ships mainly as a Microsoft Store app, so its state lives under `%LOCALAPPDATA%\Packages\` in a Degoo-named package folder. A standalone desktop build, if installed, keeps config under `%APPDATA%\Degoo`. (Degoo's exact package family name and desktop-folder name are not confirmed — see return.)
- **Reveals:** The Degoo account (often the linked Google/email login) and cached thumbnails/metadata of backed-up photos and files.
- **Remove (user runs):** Sign out in the Degoo app; uninstall via Settings > Apps (a Store app's per-user data is removed with it); for a desktop build delete the `%APPDATA%\Degoo` folder; empty the Recycle Bin. Delete the backup in the Degoo account if it is not being handed over.
- **Survives:** **The Degoo cloud copy persists until deleted in the account.** SSD/HDD remnants of any local cache until TRIM/overwrite.
- **Admin:** No.

### Icedrive
- **Where:** `%APPDATA%\Icedrive` (account/config, cache, logs). Icedrive can also mount a virtual drive via an installed driver/service. (Folder may be cased `icedrive`.)
- **Reveals:** The Icedrive account email, cached opened files, and the mount/sync configuration.
- **Remove (user runs):** In Icedrive, log out / unlink; quit and uninstall via Settings > Apps (removes the mount driver); delete any leftover `%APPDATA%\Icedrive`; empty the Recycle Bin. Remove the cloud copy at the Icedrive website (check its trash).
- **Survives:** **The Icedrive cloud copy persists until deleted server-side.** Streamed / online-only items were never fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user data; uninstalling the virtual-drive driver needs elevation.

### Filen
- **Where:** `%APPDATA%\Filen` (account/config, sync-location list, cache, logs) for the Filen desktop client; plus the user-chosen local sync folder(s). (The appdata folder may be `filen_desktop` / `filen-desktop` depending on version — see return.)
- **Reveals:** The Filen account email, which local folders were set to sync, and cached files.
- **Remove (user runs):** In Filen, log out; quit and uninstall via Settings > Apps; delete the local sync folder(s) and any leftover `%APPDATA%\Filen`; empty the Recycle Bin. Remove the cloud copy at the Filen website (check its trash).
- **Survives:** **The Filen cloud copy persists until deleted server-side** (Filen is end-to-end encrypted, so the provider cannot read it, but it stays until the owner deletes it). SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Internxt Drive
- **Where:** `%APPDATA%\Internxt Drive` (account/config, cache, logs); plus the local sync/virtual folder under the user profile. (The appdata folder may be `internxt-drive` — see return.)
- **Reveals:** The Internxt account email, the synced-folder configuration, and cached files.
- **Remove (user runs):** In Internxt, log out; quit and uninstall via Settings > Apps; delete the local sync folder and any leftover `%APPDATA%\Internxt Drive`; empty the Recycle Bin. Remove the cloud copy in the Internxt web app (check its trash).
- **Survives:** **The Internxt cloud copy persists until deleted server-side** (end-to-end encrypted, but still present until removed). SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Cryptomator (vault list)
- **Where:** `%APPDATA%\Cryptomator` — its `settings.json` records the paths and names of the vaults the owner added, plus the recent-vault list. The encrypted vault folders themselves live wherever the owner created them, often inside a cloud-sync folder.
- **Reveals:** That Cryptomator was used, and **where the encrypted vaults are and what they are named** — not their contents (vault data and the vault passwords are encrypted and are never displayed).
- **Remove (user runs):** In Cryptomator, remove each vault from the list; quit and uninstall via Settings > Apps; delete `%APPDATA%\Cryptomator`. Then delete the actual encrypted vault folders at their real locations (and remove their cloud copies), and empty the Recycle Bin.
- **Survives:** The encrypted vault data itself — deleting the vault *list* does not touch the vault folders, and any cloud copy of a vault persists until removed from that provider. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Yandex.Disk
- **Where:** Sync folder default `%USERPROFILE%\YandexDisk`. Config/state: `%APPDATA%\Yandex\YandexDisk` and (the 2.0 / streaming client) `%LOCALAPPDATA%\Yandex\YandexDisk2`.
- **Reveals:** The Yandex account, which files were synced, and cached/streamed file metadata.
- **Remove (user runs):** In Yandex.Disk, unlink / log out; quit and uninstall via Settings > Apps; delete the local `YandexDisk` folder and the `%APPDATA%\Yandex\YandexDisk` / `%LOCALAPPDATA%\Yandex\YandexDisk2` config; empty the Recycle Bin. Remove the cloud copy at the Yandex.Disk website (check its trash).
- **Survives:** **The Yandex cloud copy persists until deleted server-side.** Streamed items were not fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Cloud Mail.ru (Disk-O:)
- **Where:** Vendor folder `%APPDATA%\Mail.Ru` and/or `%LOCALAPPDATA%\Mail.Ru` (the Mail.ru cloud client / "Disk-O:" mounts the cloud as a drive). (Exact subfolder — e.g. `Disk-O` or `Cloud` — not confirmed; see return.)
- **Reveals:** The Mail.ru account, the mounted/synced cloud-storage configuration, and cached file metadata.
- **Remove (user runs):** In the client, log out / unlink; quit and uninstall via Settings > Apps; delete the `%APPDATA%\Mail.Ru` / `%LOCALAPPDATA%\Mail.Ru` folder; empty the Recycle Bin. Remove the cloud copy at the Mail.ru cloud website (check its trash).
- **Survives:** **The Mail.ru cloud copy persists until deleted server-side.** Mounted (streamed) items were not fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Zoho WorkDrive (TrueSync)
- **Where:** `%LOCALAPPDATA%\Zoho WorkDrive TrueSync` (account/config, cache, logs); TrueSync also mounts a virtual drive. (Exact folder name/casing not fully confirmed — see return.)
- **Reveals:** The Zoho account and organisation/team, which WorkDrive folders were synced, and cached files — usually work/enterprise data.
- **Remove (user runs):** In WorkDrive TrueSync, sign out; quit and uninstall via Settings > Apps (removes the virtual drive); delete any leftover `%LOCALAPPDATA%\Zoho WorkDrive TrueSync`; empty the Recycle Bin. If this is organisational data, prefer handing the device to IT; otherwise remove the cloud copy in the Zoho WorkDrive web app.
- **Survives:** **The WorkDrive cloud copy and any organisation retention policy persist until removed server-side.** Streamed items were not fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user data; uninstalling the drive component needs elevation.

### Egnyte Desktop
- **Where:** Classic "Egnyte Connect": `%LOCALAPPDATA%\Egnyte Connect`. Newer "Egnyte Desktop App": under `%LOCALAPPDATA%\Egnyte` and `%ProgramData%\Egnyte`; it mounts a drive and runs a service. (Which path exists depends on version — see return.)
- **Reveals:** The Egnyte domain (`company.egnyte.com`), the account, which folders were synced, and cached files — typically enterprise data.
- **Remove (user runs):** In the Egnyte app, sign out; quit and uninstall via Settings > Apps (removes the drive/service); delete any leftover `%LOCALAPPDATA%\Egnyte Connect` / `%LOCALAPPDATA%\Egnyte` and `%ProgramData%\Egnyte`; empty the Recycle Bin. This is usually company data — prefer handing the device to IT.
- **Survives:** **The Egnyte cloud copy and organisation retention/policy persist until removed server-side.** Streamed items were not fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user cache; uninstalling the drive/service needs elevation.

### Citrix ShareFile
- **Where:** `%LOCALAPPDATA%\Citrix\ShareFile` and/or `%APPDATA%\Citrix\ShareFile` (the ShareFile Drive / "Citrix Files for Windows" client; may sit under a `Citrix Files` subfolder). Mounts a virtual drive. (Exact subfolder name not fully confirmed — see return.)
- **Reveals:** The ShareFile subdomain (`company.sharefile.com`), the account, and cached opened files — typically business data.
- **Remove (user runs):** In ShareFile / Citrix Files, sign out; quit and uninstall via Settings > Apps; delete any leftover `%LOCALAPPDATA%\Citrix\ShareFile` / `%APPDATA%\Citrix\ShareFile`; empty the Recycle Bin. Usually business data — prefer handing the device to IT.
- **Survives:** **The ShareFile cloud copy and organisation retention persist until removed server-side.** Streamed items were not fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user cache; uninstalling the drive component needs elevation.

### odrive
- **Where:** `%USERPROFILE%\.odrive` (agent config and the map of linked cloud accounts, under `.odrive\common`); default sync folder `%USERPROFILE%\odrive`.
- **Reveals:** **Every cloud account the owner linked through odrive** (odrive aggregates Google Drive, Dropbox, OneDrive and others), plus the local sync folder and placeholder files.
- **Remove (user runs):** In odrive, deauthorize/unsync and sign out; quit and uninstall via Settings > Apps; delete the `%USERPROFILE%\.odrive` config and the `%USERPROFILE%\odrive` sync folder; empty the Recycle Bin. Unlink odrive from each underlying cloud account, and remove any copies in those accounts.
- **Survives:** The files in each **underlying cloud account persist** until removed there; odrive is only the connector. "Unsynced" placeholders were never fully local. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No.

### Private Internet Access (PIA)
- **Where:** `%ProgramData%\pia` (the daemon's account token, chosen regions/settings, and `daemon.log`). Older PIA used `%LOCALAPPDATA%\pia_manager`. Runs a background service. (Which path holds account/settings varies by version — see return.)
- **Reveals:** The PIA account/username, preferred servers and connection settings, and connection logs.
- **Remove (user runs):** In PIA, log out; quit and uninstall via Settings > Apps (removes the service and split-tunnel driver); delete any leftover `%ProgramData%\pia` / `%LOCALAPPDATA%\pia_manager` from an elevated session; empty the Recycle Bin.
- **Survives:** The PIA subscription/account on their servers is untouched (manage it on the PIA website). SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service and driver removal and `%ProgramData%` cleanup need elevation).

### CyberGhost VPN
- **Where:** `%LOCALAPPDATA%\CyberGhost 8` and `%ProgramData%\CyberGhost 8` (account/config, settings, logs). Runs a service. (Version-named folder; older versions differ — see return.)
- **Reveals:** The CyberGhost account, favourite servers and settings, and connection logs.
- **Remove (user runs):** In CyberGhost, log out; quit and uninstall via Settings > Apps; delete any leftover `%LOCALAPPDATA%\CyberGhost 8` / `%ProgramData%\CyberGhost 8` from an elevated session; empty the Recycle Bin.
- **Survives:** The CyberGhost account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service removal and `%ProgramData%` cleanup need elevation).

### IPVanish
- **Where:** `%LOCALAPPDATA%\IPVanish` (account/config, settings, logs); some builds use `%APPDATA%\IPVanish`. Installs an OpenVPN helper service. (Exact folder not fully confirmed — see return.)
- **Reveals:** The IPVanish account/username, server preferences, and connection logs.
- **Remove (user runs):** In IPVanish, log out; quit and uninstall via Settings > Apps; delete any leftover `%LOCALAPPDATA%\IPVanish` / `%APPDATA%\IPVanish`; empty the Recycle Bin.
- **Survives:** The IPVanish account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the helper service needs elevation.

### Windscribe
- **Where:** `%APPDATA%\Windscribe\Windscribe2` (account/config, preferences, logs). Installs a helper service.
- **Reveals:** The Windscribe account/username, server and firewall preferences, and logs.
- **Remove (user runs):** In Windscribe, log out; quit and uninstall via Settings > Apps; delete any leftover `%APPDATA%\Windscribe`; empty the Recycle Bin.
- **Survives:** The Windscribe account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the helper service needs elevation.

### hide.me VPN
- **Where:** `%APPDATA%\hide.me VPN` (or `%LOCALAPPDATA%\hide.me VPN`) — account/config, settings, logs. Installs a helper service. (Exact folder not fully confirmed — see return.)
- **Reveals:** The hide.me account/username, server preferences, and connection logs.
- **Remove (user runs):** In hide.me, log out; quit and uninstall via Settings > Apps; delete any leftover `%APPDATA%\hide.me VPN` / `%LOCALAPPDATA%\hide.me VPN`; empty the Recycle Bin.
- **Survives:** The hide.me account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the helper service needs elevation.

### TunnelBear
- **Where:** `%LOCALAPPDATA%\TunnelBear` (account/config, settings, logs). Installs a helper service. (Some state may also sit under `%APPDATA%\TunnelBear` — see return.)
- **Reveals:** The TunnelBear account email, server preferences, and connection logs.
- **Remove (user runs):** In TunnelBear, log out; quit and uninstall via Settings > Apps; delete any leftover `%LOCALAPPDATA%\TunnelBear`; empty the Recycle Bin.
- **Survives:** The TunnelBear account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the helper service needs elevation.

### PrivadoVPN
- **Where:** `%APPDATA%\PrivadoVPN` (or `%LOCALAPPDATA%\PrivadoVPN`) — account/config, settings, logs. Installs a helper service. (Exact folder not fully confirmed — see return.)
- **Reveals:** The PrivadoVPN account, server preferences, and connection logs.
- **Remove (user runs):** In PrivadoVPN, log out; quit and uninstall via Settings > Apps; delete any leftover `%APPDATA%\PrivadoVPN` / `%LOCALAPPDATA%\PrivadoVPN`; empty the Recycle Bin.
- **Survives:** The PrivadoVPN account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the helper service needs elevation.

### Hola VPN
- **Where:** Desktop client config `%APPDATA%\hola` (and `%LOCALAPPDATA%\Hola`); runs a `hola_svc` service. Hola is also commonly a browser extension, whose data sits in the browser profile (browsers cluster). (Exact desktop-client folder not fully confirmed — see return.)
- **Reveals:** The Hola account/install and its settings. (Hola has historically routed other users' traffic through this peer — worth flagging to the owner, but that is behaviour, not a stored artifact.)
- **Remove (user runs):** In Hola, log out; quit and uninstall via Settings > Apps (removes the service); delete any leftover `%APPDATA%\hola` / `%LOCALAPPDATA%\Hola`; remove the Hola browser extension if present; empty the Recycle Bin.
- **Survives:** Any Hola account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the service needs elevation.

### AdGuard VPN
- **Where:** `%LOCALAPPDATA%\AdGuardVPN` (account/config, settings, logs) — distinct from the AdGuard ad-blocker product (`%LOCALAPPDATA%\AdGuard` / `%ProgramData%\AdGuard`). Installs a service/driver. (Exact folder not fully confirmed — see return.)
- **Reveals:** The AdGuard account email, server and exclusion-list preferences, and logs.
- **Remove (user runs):** In AdGuard VPN, log out; quit and uninstall via Settings > Apps; delete any leftover `%LOCALAPPDATA%\AdGuardVPN`; empty the Recycle Bin.
- **Survives:** The AdGuard account on their servers is untouched. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user config; uninstalling the service/driver needs elevation.

### Cloudflare WARP (1.1.1.1)
- **Where:** `%APPDATA%\Cloudflare` (client settings, logs) and `%ProgramData%\Cloudflare` (service config, including Zero Trust enrollment / `mdm.xml` when used). Runs a service.
- **Reveals:** That WARP was used, and its settings; **if enrolled in Cloudflare Zero Trust, the organisation/team name** and enrollment — a corporate identifier. Consumer WARP reveals little personal data.
- **Remove (user runs):** In the 1.1.1.1 / WARP app, disconnect and (if enrolled) log out of Zero Trust; quit and uninstall via Settings > Apps; delete any leftover `%APPDATA%\Cloudflare` / `%ProgramData%\Cloudflare` from an elevated session; empty the Recycle Bin.
- **Survives:** A Zero Trust **device enrollment stays in the organisation's Cloudflare dashboard** until an admin removes it. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service removal and `%ProgramData%` cleanup need elevation; managed enrollments may be IT-locked).

### ZeroTier One
- **Where:** `%ProgramData%\ZeroTier One` — `networks.d\` (one file per joined virtual network, named by network ID), this node's `identity.public`, and the service config. (`identity.secret` and `authtoken.secret` are private key/token files — never opened or displayed.) Runs a service.
- **Reveals:** The virtual network IDs this machine joined and this node's ZeroTier address — mapping the owner's overlay/mesh networks. Count and name networks only; never read the secret key files.
- **Remove (user runs):** In the ZeroTier tray app (or CLI), leave each network; quit and uninstall ZeroTier One via Settings > Apps; delete any leftover `%ProgramData%\ZeroTier One` from an elevated session; empty the Recycle Bin.
- **Survives:** This node's membership is also recorded on the **network controller (server-side)** until the network's admin deauthorizes/removes the member. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service removal and `%ProgramData%` cleanup need elevation; the secret files are SYSTEM-owned).

### OpenVPN Connect (v3)
- **Where:** `%APPDATA%\OpenVPN Connect` — imported `profiles\`, `config.json`, and logs. Installs a TAP/Wintun driver and service. (This is the official OpenVPN Connect client; the community OpenVPN GUI's `%USERPROFILE%\OpenVPN\config` profiles are a separate catalog entry.)
- **Reveals:** Imported VPN profiles (server hostnames/addresses, the provider or employer), any saved username, and connection logs.
- **Remove (user runs):** In OpenVPN Connect, remove each imported profile and sign out of any subscription; quit and uninstall via Settings > Apps; delete any leftover `%APPDATA%\OpenVPN Connect`; empty the Recycle Bin.
- **Survives:** The VPN server/account itself (provider or employer) is untouched. A saved credential inside a profile is DPAPI-protected but present until removed. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the user profiles; uninstalling the driver/service needs elevation.

### SoftEther VPN Client
- **Where:** `%ProgramFiles%\SoftEther VPN Client\vpn_client.config` (saved connection settings: server hostnames/ports, virtual hub and account names). Runs a service and a virtual network adapter.
- **Reveals:** The VPN servers the owner connected to and the account names configured — exposing employers or remote networks.
- **Remove (user runs):** In SoftEther VPN Client Manager, delete each connection setting and the virtual adapter; quit and uninstall via Settings > Apps; delete any leftover `%ProgramFiles%\SoftEther VPN Client` from an elevated session; empty the Recycle Bin.
- **Survives:** The remote SoftEther server/account is untouched. Saved passwords in the config are obfuscated but present until removed. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service/adapter removal and Program Files cleanup need elevation).

### LogMeIn Hamachi
- **Where:** `%ProgramData%\LogMeIn Hamachi` (`client.cfg` with this node's Hamachi virtual address/ID, plus databases of joined networks and peers). Runs a service and a virtual adapter.
- **Reveals:** The Hamachi networks the owner joined, this client's Hamachi ID/virtual IP, and peer information — mapping the owner's VPN mesh and its other members.
- **Remove (user runs):** In Hamachi, leave each network and sign out; quit and uninstall via Settings > Apps; delete any leftover `%ProgramData%\LogMeIn Hamachi` from an elevated session; empty the Recycle Bin.
- **Survives:** Network membership is also recorded in the **LogMeIn/GoTo account (server-side)** until removed there. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service/adapter removal and `%ProgramData%` cleanup need elevation).

### Palo Alto GlobalProtect
- **Where:** `%APPDATA%\Palo Alto Networks\GlobalProtect` (per-user config/logs); `%ProgramData%\Palo Alto Networks\GlobalProtect` (`PanGPS` service logs); `HKLM:\SOFTWARE\Palo Alto Networks\GlobalProtect` (portal address and settings). A corporate-managed VPN.
- **Reveals:** The corporate VPN **portal address(es)**, the owner's corporate username, and connection history/logs — a strong employer identifier.
- **Remove (user runs):** This is almost always employer software — **prefer returning the device to the organisation's IT.** If authorized and permitted: in GlobalProtect disconnect and remove the portal, then uninstall via Settings > Apps (often requires an uninstall passcode set by IT), delete any leftover `%APPDATA%` / `%ProgramData%` Palo Alto folders from an elevated session, and empty the Recycle Bin.
- **Survives:** The corporate portal/gateway records and any device posture/enrollment on the organisation's side remain — only IT can remove those. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service removal and `%ProgramData%` cleanup need elevation; uninstall may be IT-locked).

### FortiClient VPN
- **Where:** Saved SSL-VPN tunnels in `HKCU:\Software\Fortinet\FortiClient\Sslvpn\Tunnels\<name>` (each with the gateway `Server` and often a saved username); machine config under `%ProgramData%\Fortinet\FortiClient`. Often corporate-managed.
- **Reveals:** The corporate SSL-VPN **gateway address(es)**, the tunnel names, and saved usernames — exposing the employer / remote network.
- **Remove (user runs):** In FortiClient, delete each saved VPN tunnel; if allowed, uninstall via Settings > Apps (may be locked by FortiClient EMS / IT). The per-user tunnels live under the `HKCU` key above and clear with the profile on a reset. Empty the Recycle Bin.
- **Survives:** The corporate gateway and any EMS enrollment on the organisation's side are untouched — handle through IT. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the `HKCU` tunnels; uninstalling (and clearing `%ProgramData%`) needs elevation and may be IT-locked.

### SonicWall NetExtender
- **Where:** Saved connection profiles in `HKCU:\Software\SonicWall\NetExtender` (server address, username, domain) and/or `%APPDATA%\SonicWall\NetExtender`. Often corporate-managed. (Key name casing — historically `SonicWALL` — and whether a newer NetExtender rewrite stores elsewhere vary by version; see return.)
- **Reveals:** The corporate SSL-VPN **server address**, username and domain used — an employer / remote-network identifier.
- **Remove (user runs):** In NetExtender, delete each saved profile; uninstall via Settings > Apps if allowed. The per-user profiles live under the `HKCU` key / `%APPDATA%\SonicWall` and clear with the profile on a reset. Empty the Recycle Bin.
- **Survives:** The SonicWall appliance/account on the organisation's side is untouched — handle through IT. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the per-user profiles; uninstalling needs elevation and may be IT-locked.

### Ivanti / Pulse Secure
- **Where:** `%APPDATA%\Pulse Secure` (the user connection store, e.g. `ConnectionStore\connstore.dat`, listing saved connections, URLs and realms) and `%ProgramData%\Pulse Secure`; the rebranded "Ivanti Secure Access Client" may use an `Ivanti`-named folder. A corporate-managed VPN. (Exact path/filename varies by version — see return.)
- **Reveals:** The corporate VPN **sign-in URLs**, realms and the saved username / connection names — an employer / remote-network identifier.
- **Remove (user runs):** Almost always employer software — **prefer returning the device to IT.** If authorized: in the client delete each saved connection, uninstall via Settings > Apps (may be IT-locked), delete any leftover `%APPDATA%\Pulse Secure` / `%ProgramData%\Pulse Secure` (or the Ivanti-named folders), and empty the Recycle Bin.
- **Survives:** The corporate gateway records and any enrollment on the organisation's side remain — only IT can remove them. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** No to delete the per-user connection store; service removal / `%ProgramData%` cleanup need elevation and may be IT-locked.

### Twingate
- **Where:** `%ProgramData%\Twingate` (service config and logs, including the Twingate network name) and `%LOCALAPPDATA%\Twingate` (client state/logs). Runs a service. (Exact split of config vs logs between the two not fully confirmed — see return.)
- **Reveals:** The Twingate network (`company.twingate.com`), the signed-in account email, and the resources/connectors the owner reached — a corporate / zero-trust identifier.
- **Remove (user runs):** In the Twingate client, sign out; quit and uninstall via Settings > Apps (removes the service); delete any leftover `%ProgramData%\Twingate` / `%LOCALAPPDATA%\Twingate` from an elevated session; empty the Recycle Bin.
- **Survives:** The **device and account stay in the organisation's Twingate admin console (server-side)** until an admin removes them. SSD/HDD remnants until TRIM/overwrite.
- **Admin:** Yes (service removal and `%ProgramData%` cleanup need elevation; managed setups are controlled by IT).

---

## Version-specific hives & deeper forensic/system traces

Older Office and Acrobat version hives, plus deeper forensic, device, system and identity artifacts.

### Microsoft Office 2013 recent files (File MRU and Place MRU)
- **Where:** `HKCU:\Software\Microsoft\Office\15.0\Word\File MRU`, `...\Excel\File MRU`, `...\PowerPoint\File MRU`, and the matching `\Place MRU` key under each app (Office 2013 / version 15.0).
- **Reveals:** Full paths and filenames of the last documents, workbooks and presentations the previous user opened or saved in Office 2013, plus the folders (including network and cloud paths) listed in Place MRU - exposing project names, client names and folder layout even after the files themselves are gone.
- **Remove (user runs):** In each app open the File > Open (Recent) list, right-click an entry and choose "Clear unpinned items"; or delete the `Software\Microsoft\Office\15.0\<app>\File MRU` and `\Place MRU` keys in `regedit`.
- **Survives:** The referenced documents themselves, wherever they are stored, and any recent-file list synced to the signed-in account's cloud "Recent" view. The 16.0 hive (if a newer Office is also installed) is a separate catalog entry.
- **Admin:** no.

### Microsoft Office 2010 recent files (File MRU)
- **Where:** `HKCU:\Software\Microsoft\Office\14.0\Word\File MRU`, `...\Excel\File MRU`, `...\PowerPoint\File MRU` (Office 2010 / version 14.0).
- **Reveals:** Paths and filenames of the last documents, workbooks and presentations opened in Office 2010 - the same personal trail of document names and locations as newer versions.
- **Remove (user runs):** Clear the Recent list inside each app (File > Recent > right-click > clear, or File > Options > Advanced where you can set the number of recent documents to 0 and back); or delete the `Office\14.0\<app>\File MRU` keys in `regedit`.
- **Survives:** The documents themselves. Note Office 2010 has no "Place MRU" (recent-folders list); that was added in Office 2013, so only File MRU applies to 14.0.
- **Admin:** no.

### Adobe Acrobat / Reader recent files (2020, 2017 and XI tracks)
- **Where:** `HKCU:\Software\Adobe\Acrobat Reader\<track>\AVGeneral\cRecentFiles` and `HKCU:\Software\Adobe\Adobe Acrobat\<track>\AVGeneral\cRecentFiles`, where `<track>` is `2020`, `2017` or `11.0` (Acrobat/Reader 2020, 2017 and XI). Each `c1`, `c2` ... subkey holds one recent PDF path in its `tDIText` value.
- **Reveals:** Names and full paths of the last PDFs the previous user opened in these older Acrobat/Reader versions - often statements, contracts, scans, tax or medical documents.
- **Remove (user runs):** In the app open Edit > Preferences > Documents and set "Documents in recently used list" to 0 (or clear the Home/Recent list), then restore the setting; or delete the relevant `...\AVGeneral\cRecentFiles` key in `regedit`.
- **Survives:** The PDF files themselves, and any copies in the app's Document Cloud / online recent list.
- **Admin:** no.

### Office 2013 signed-in identity
- **Where:** `HKCU:\Software\Microsoft\Office\15.0\Common\Identity` (the `Identities` and `Profiles` subkeys).
- **Reveals:** The Microsoft account or work/school (Microsoft 365) email address the previous user signed into Office 2013 with, and the associated display name.
- **Remove (user runs):** In any Office 2013 app choose File > Account > Sign out; and remove the work or school account under Settings > Accounts > Access work or school. Deleting the `Office\15.0\Common\Identity` key in `regedit` clears the local copy.
- **Survives:** The account on Microsoft's servers is untouched; token caches such as OneAuth and the WAM token broker (separate catalog entries) may keep remnants until cleared or a reboot. Office 2010 (14.0) had no built-in sign-in, so there is no 14.0 identity key.
- **Admin:** no.

### Outlook 2013 / 2010 mail profiles (older Office hives)
- **Where:** Outlook 2013: `HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles\<profile>`. Outlook 2010: the account/profile store lives at `HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles\<profile>`, while `HKCU:\Software\Microsoft\Office\14.0\Outlook` holds that version's settings and recent lists.
- **Reveals:** Configured email accounts - addresses, display names, incoming/outgoing server names, and the paths to the OST/PST data files - for these older Outlook versions.
- **Remove (user runs):** Control Panel > Mail (Microsoft Outlook) > Show Profiles > select the profile > Remove, which deletes the account configuration. Delete the OST/PST data files separately (a separate catalog entry).
- **Survives:** The PST/OST data files on disk until deleted; the mailbox on the mail server is unchanged.
- **Admin:** no.

### RecentApps (Windows 10 launch history)
- **Where:** `HKCU:\Software\Microsoft\Windows\CurrentVersion\Search\RecentApps` and its `<AppId>\RecentItems` subkeys.
- **Reveals:** Which applications the previous user launched, how many times and when (last-access time), and recently opened files per app - a compact activity trail where the key is present.
- **Remove (user runs):** Delete the `...\Search\RecentApps` key in `regedit`.
- **Survives:** The same launch information also lives in Prefetch, Amcache, UserAssist and other execution artifacts (separate catalog entries), so clearing this one key does not erase the trail. This key is primarily a Windows 10 artifact and is usually absent on Windows 11.
- **Admin:** no.

### Program Compatibility Assistant (PCA) execution logs
- **Where:** `C:\Windows\appcompat\pca\PcaAppLaunchDic.txt`, `PcaGeneralDb0.txt` and `PcaGeneralDb1.txt`.
- **Reveals:** Full paths, names and first/last run times of executables run on the machine - including programs launched from user folders, external drives or download locations - which can expose software the previous user installed or ran. Introduced in Windows 11, version 22H2.
- **Remove (user runs):** Delete the files in `C:\Windows\appcompat\pca` from an elevated prompt; they regenerate as programs run.
- **Survives:** The same execution history is mirrored in Prefetch and Amcache; the files repopulate with further use, and removal needs admin rights.
- **Admin:** yes.

### Compatibility Assistant Store (AppCompatFlags)
- **Where:** `HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store` and `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store`.
- **Reveals:** Paths of executables that triggered the compatibility assistant - another record of programs that ran on the PC, keyed by on-disk path (which can include the previous user's account name in the path).
- **Remove (user runs):** Delete the `Compatibility Assistant\Store` subkey under HKCU in `regedit` (no admin); the HKLM copy needs an elevated `regedit`.
- **Survives:** Other execution artifacts (ShimCache, Amcache, PCA, Prefetch) retain equivalent evidence; the HKLM half needs admin to remove.
- **Admin:** no for HKCU, yes for HKLM.

### Game controllers and joysticks (DirectInput)
- **Where:** `HKCU:\System\CurrentControlSet\Control\MediaProperties\PrivateProperties\Joystick\OEM` (and the related `DirectInput` subkey).
- **Reveals:** Friendly names of game controllers, gamepads, flight sticks and racing wheels the previous user connected - indirectly exposing gaming habits and specific hardware owned.
- **Remove (user runs):** Delete the `...\Joystick\OEM` subkeys in `regedit`; the "Set up USB game controllers" dialog also drops stale entries once devices are unplugged.
- **Survives:** Nothing on a server (local-only data); related USB enumeration keys (a separate catalog entry) may still name the same controllers.
- **Admin:** no.

### Imaging devices - scanners and cameras (WIA class)
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Control\Class\{6bdd1fc6-810f-11d0-bec7-08002be2092f}` - the Imaging Devices setup class; each numbered subkey carries a `FriendlyName`.
- **Reveals:** Make and model of scanners, webcams and still cameras installed on the PC, showing hardware the previous user owned or connected.
- **Remove (user runs):** Uninstall each device in Device Manager (use View > Show hidden devices to reveal disconnected ones), choosing "Delete the driver software" where offered - requires admin.
- **Survives:** Files produced by those devices - the Scanned Documents and Camera Roll / Pictures folders (separate catalog entries) - remain; USB and portable-device enumeration keys may still reference the same hardware.
- **Admin:** yes.

### Portable device (MTP) enumeration - WpdBusEnumRoot
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Enum\WpdBusEnumRoot`.
- **Reveals:** Phones, cameras, music players and other MTP/PTP devices that were connected to the PC - friendly names and identifiers that can tie a specific personal device to this machine.
- **Remove (user runs):** In Device Manager enable View > Show hidden devices, then uninstall the greyed-out portable devices (admin); or use a disk/privacy cleanup tool that clears PnP device history.
- **Survives:** Thumbnails, jump lists and shellbags (separate catalog entries) may still reference media copied from those devices. This is the bus-level enumeration, deeper than the user-facing Windows Portable Devices list.
- **Admin:** yes.

### Bluetooth radio device store and pairing keys (BTHPORT)
- **Where:** `HKLM:\SYSTEM\CurrentControlSet\Services\BTHPORT\Parameters\Devices` (each subkey is a paired device's address, with a `Name` value); pairing link keys sit under `...\Parameters\Keys` and are readable only by SYSTEM.
- **Reveals:** Hardware addresses and names of Bluetooth devices the previous user paired - headphones, keyboards, phones, wearables - at the radio level, beneath the Settings paired-device list.
- **Remove (user runs):** Remove each device under Settings > Bluetooth & devices (which clears its subkey and link key); a leftover radio entry can be deleted with an elevated `regedit`.
- **Survives:** Entries can linger until a reboot; the `Keys` subkey needs SYSTEM/admin access to inspect, and a full reset is the surest clear.
- **Admin:** yes.

### Reliability Monitor history (RAC)
- **Where:** `C:\ProgramData\Microsoft\RAC\StateData` and `C:\ProgramData\Microsoft\RAC\PublishedData` (including `RacWmiDatabase.sdf`).
- **Reveals:** The Reliability Monitor timeline - application installs and uninstalls, app crashes and hangs, and update events by name and date - which indirectly lists software the previous user ran and when.
- **Remove (user runs):** The data is rebuilt from the event logs; to clear it, disable the Reliability scheduled task and delete the files under `C:\ProgramData\Microsoft\RAC` from an elevated prompt.
- **Survives:** The underlying Application and System event logs (a separate catalog entry) still hold the source events, so Reliability Monitor repopulates from them; needs admin.
- **Admin:** yes.

### Windows Setup logs (Panther)
- **Where:** `C:\Windows\Panther\` (for example `setupact.log`, `setuperr.log`, `UnattendGC\`), plus any `C:\$WINDOWS.~BT\Sources\Panther` left from an in-place upgrade.
- **Reveals:** Installation and upgrade details - computer name, the account/username created at setup, edition and product-key-related entries, and timestamps - captured when Windows was installed or upgraded.
- **Remove (user runs):** Run Disk Cleanup and tick "Windows upgrade log files" (and "Windows ESD installation files"); or delete the `C:\Windows\Panther` contents from an elevated prompt.
- **Survives:** Copies may also exist inside `Windows.old` (a separate catalog entry); removal needs admin.
- **Admin:** yes.

### Component-Based Servicing (CBS) logs
- **Where:** `C:\Windows\Logs\CBS\` (`CBS.log` and its archived `.cab` copies).
- **Reveals:** A servicing history of installed, updated and removed Windows packages and features, by name and date. This is mostly system-configuration history rather than strongly personal data, but it still shows how the machine was maintained and used.
- **Remove (user runs):** Run Disk Cleanup, or delete the contents of `C:\Windows\Logs\CBS` from an elevated prompt; the folder is recreated by Windows servicing.
- **Survives:** Regenerates as updates install; needs admin to clear.
- **Admin:** yes.

### Live kernel reports (LiveKernelReports)
- **Where:** `C:\Windows\LiveKernelReports\` (`*.dmp` files).
- **Reveals:** Live kernel dumps captured after driver or hardware faults; these memory snapshots can contain fragments of whatever was in memory at the time, and the filenames and dates show when problems occurred on the previous user's system.
- **Remove (user runs):** Run Disk Cleanup (System error memory dump / minidump files), or delete the `*.dmp` files under `C:\Windows\LiveKernelReports` from an elevated prompt.
- **Survives:** New dumps are written on future faults; removal needs admin.
- **Admin:** yes.

### PowerShell transcripts
- **Where:** `%USERPROFILE%\Documents\PowerShell\transcripts\`, and loose `PowerShell_transcript.*.txt` files in `%USERPROFILE%\Documents` (or whatever folder was configured). Present only if PowerShell transcription was turned on.
- **Reveals:** A full typed record of PowerShell sessions - every command and its output - which can expose paths, machine and account names, scripts and anything the commands printed.
- **Remove (user runs):** Delete the transcript `.txt` files; turn transcription off (Group Policy "Turn on PowerShell Transcription", or the corresponding `...\PowerShell\Transcription` registry value) to stop new ones.
- **Survives:** This is separate from PSReadLine command history (a separate catalog entry), which must be cleared on its own; transcripts exist only where transcription was enabled.
- **Admin:** no.

### Work Folders
- **Where:** `%USERPROFILE%\Work Folders` (default local path) and the configuration under `HKCU:\Software\Microsoft\Windows\CurrentVersion\WorkFolders` / `HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WorkFolders`.
- **Reveals:** Enterprise/work files synced to this PC through the Work Folders feature, plus the work account and the server URL they came from - exposing an employer relationship and work documents.
- **Remove (user runs):** Control Panel > Work Folders > "Stop using Work Folders", then delete the local `Work Folders` directory; remove the associated work account under Settings > Accounts if one is present.
- **Survives:** The copy on the employer's Work Folders server is unaffected; local files remain until the folder is deleted.
- **Admin:** no.

### Outlook Autodiscover cache
- **Where:** `HKCU:\Software\Microsoft\Office\16.0\Outlook\AutoDiscover` (the value names are the email addresses that were looked up) and cached autodiscover XML under `%LOCALAPPDATA%\Microsoft\Outlook`.
- **Reveals:** Email address(es) the previous user configured and the mail server or organization they resolved to - a direct link to their identity and their employer or provider.
- **Remove (user runs):** Delete the values under the `Outlook\AutoDiscover` key and any cached autodiscover XML files; removing the Outlook mail profile (a separate catalog entry) also clears these.
- **Survives:** The mailbox and account on the mail server are unchanged; the same email address also appears in autocomplete and profile artifacts.
- **Admin:** no.

### Cloud Experience Host account cache
- **Where:** `%LOCALAPPDATA%\Packages\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy\` (its `AC\INetCache`, `LocalState` and `LocalCache` subfolders).
- **Reveals:** Web-view remnants from adding Microsoft or work/school accounts - cached sign-in pages, cookies, and the account email or tenant used during "Add account" and out-of-box flows. This is transient UI cache; the durable tokens live in the AAD broker and WAM stores (separate catalog entries).
- **Remove (user runs):** Remove the work/school or Microsoft account under Settings > Accounts; clear the package data via Settings > Apps if the host is listed, or delete the contents of the package's `AC\INetCache`, `LocalState` and `LocalCache` folders.
- **Survives:** The account on Microsoft's servers, and the durable token caches (AAD broker / WAM); resetting the package just recreates empty folders.
- **Admin:** no.

---

## Scope: other accounts, other volumes & recoverability

This cluster is about *scope and honesty* rather than any single app. The first catalog pass documents each trace "for your own profile, on the system drive." A handover machine is usually bigger than that: it can hold several user accounts, more than one volume, backup copies made elsewhere, and copies of the registry inside restore points and a previous Windows install. It also has to be honest that, in WipeWise's read-only Light mode, **removing a file or a registry value only unlinks it** — the bytes survive until overwritten. The blocks below extend the earlier clusters to every account and every volume, and state plainly what a per-file clean cannot reach. Paths use `%SystemDrive%`, `%SystemRoot%`, `%USERPROFILE%`, `%LOCALAPPDATA%`, `%PUBLIC%`. WipeWise only reads and reports; every removal is performed by the **user**.

---

### Other local user accounts (every profile under C:\Users)
- **Where:** one profile folder per account at `%SystemDrive%\Users\<name>`, enumerated against `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList` (each subkey is a user SID whose `ProfileImagePath` value is that profile's on-disk path). The local account list itself lives in the SYSTEM-only SAM hive (`%SystemRoot%\System32\config\SAM`) and is shown in Settings > Accounts > Other users.
- **Reveals:** a whole second (or third) person's data set. **Every** profile has the full set of known folders (Desktop, Documents, Downloads, Pictures), its own browser profiles, its own app data, and its own `NTUSER.DAT` registry hive — i.e. every trace the other clusters describe, duplicated per account. A clean of only the signed-in profile leaves all of this untouched, and it is the single most common scope miss on a handover PC.
- **Remove (user runs):** Settings > Accounts > Other users (and Family) > pick the account > **Remove** > "Delete account and data." To review another profile's files first, sign in as (or elevate to) an Administrator. For a clean handover the reliable path is Reset this PC > **Remove everything**, which removes all profiles at once.
- **Survives:** if an account removal is interrupted, its profile folder and/or `ProfileList` entry can be left behind (an "orphaned" profile); the account's `NTUSER.DAT` is also copied inside restore points and `Windows.old`; SSD/HDD remnants persist until TRIM/overwrite. Removing a local account does not revoke that person's Microsoft/Entra sign-in on the server side.
- **Admin:** Yes (to enumerate, read, or remove accounts other than the one signed in).

### Default and Public profiles
- **Where:** `%SystemDrive%\Users\Default` (a hidden template profile copied into every newly created account) and `%PUBLIC%` = `%SystemDrive%\Users\Public` (the shared Public Desktop/Documents/Downloads/Pictures/Music/Videos that all accounts can write to).
- **Reveals:** anything the owner saved into the shared Public folders; and anything seeded into the Default profile (for example a file left on the Default profile's desktop) is **copied into each new account that is later created**, so it can silently reappear for the next owner.
- **Remove (user runs):** show hidden items in File Explorer, then review and empty the `%PUBLIC%` subfolders; inspect `%SystemDrive%\Users\Default` (hidden; needs Administrator) and remove any stray personal files. Reset this PC > Remove everything clears both.
- **Survives:** files already copied out of Default into existing accounts stay in those accounts; SSD/HDD remnants until overwrite; copies in restore points and `Windows.old`.
- **Admin:** No for `%PUBLIC%`; Yes for the hidden `Default` profile.

### Shadow copies & restore data on secondary and removable volumes
- **Where:** every NTFS volume carries its own `System Volume Information` folder at its root — `%SystemDrive%\System Volume Information`, `D:\System Volume Information`, `E:\…`, and on USB/SD drives. The system-cluster block covers this on `%SystemDrive%` only; **it exists on every volume.** The folder is protected by a SYSTEM-only ACL.
- **Reveals:** where shadow copies exist on a volume, they hold **previous versions of that volume's files** — copies of documents and media that were since edited or deleted, reachable through the "Restore previous versions" tab. System Restore protects only the system drive by default, but backup software, `wbadmin`, or manual snapshots can create shadow copies on data drives too; the folder also holds the volume's change journal and indexing/link-tracking data that reference file names and paths.
- **Remove (user runs):** on the system drive, Control Panel > System > System Protection > select the drive > **Configure > Delete** (or `cleanmgr` > More Options > System Restore and Shadow Copies). For a data drive that has shadow copies, delete them with the backup tool that made them or with elevated `vssadmin delete shadows /for=D:`. Reset this PC > Remove everything clears the system volume's copies. See the system cluster's Volume Shadow Copies block for the full procedure.
- **Survives:** if protection or the backup job stays on, new copies are created again; freed space holds file remnants until TRIM/overwrite; copies on **other** volumes and on any detached/offline drive are not touched by cleaning the system drive.
- **Admin:** Yes.

### Registry hive transaction logs and slack
- **Where:** each profile's user hive at `%USERPROFILE%\NTUSER.DAT` with its write-ahead logs `NTUSER.DAT.LOG1` / `NTUSER.DAT.LOG2` (and `.regtrans-ms` files); the per-user class hive `%LOCALAPPDATA%\Microsoft\Windows\UsrClass.dat` with `UsrClass.dat.LOG1` / `UsrClass.dat.LOG2`; and the machine hives plus their logs in `%SystemRoot%\System32\config` (`SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`, `DEFAULT`).
- **Reveals:** clearing a registry value in the live hive does not necessarily scrub the old bytes. Recently changed or deleted values — MRU lists, TypedPaths, UserAssist, ShellBags, device and network history (the activity-traces and system clusters) — can linger in the hive's unallocated "slack" and in these transaction logs until the hive is compacted or replaced.
- **Remove (user runs):** these are managed by Windows and must **not** be hand-edited while loaded. A normal shutdown flushes applied transactions; the reliable owner-handover reset is Reset this PC > Remove everything (which replaces every hive), and removing an account takes its `NTUSER.DAT` and `UsrClass.dat` with the profile.
- **Survives:** a live clean of a single key leaves the logs/slack intact; full copies of the hives sit in restore points and `Windows.old`; SSD remnants until overwrite; another user's hive files need Administrator to read.
- **Admin:** No to see your own hive files exist; Yes to read other users' hives or touch the machine hives (which is not advised live).

### RegBack — registry backup hives
- **Where:** `%SystemRoot%\System32\config\RegBack` — Windows' backup copies of the machine hives (`SYSTEM`, `SOFTWARE`, `SAM`, `SECURITY`, `DEFAULT`). The folder is protected and requires elevation even to list.
- **Reveals:** where populated, it holds an older copy of the machine registry with device, USB, network, installed-software, and account traces — a second copy that a live clean of the running hives does not reach. **Honesty note:** since Windows 10 version 1803, RegBack is *not* populated by default (the files are left at 0 bytes) unless `…\Configuration Manager\EnablePeriodicBackup` was re-enabled. On most modern systems it is therefore empty; on older or upgraded installs, or where the policy was turned back on, it is a real residue.
- **Remove (user runs):** not individually user-serviceable; Reset this PC > Remove everything replaces the config set.
- **Survives:** copies inside restore points and `Windows.old`; SSD remnants until overwrite.
- **Admin:** Yes.

### Registry hive copies inside restore points and Windows.old
- **Where:** `%SystemDrive%\System Volume Information` (shadow copies include whole registry hives) and, after a feature update or in-place upgrade, `%SystemDrive%\Windows.old\Windows\System32\config` (machine hives) plus `%SystemDrive%\Windows.old\Users\<name>\NTUSER.DAT` (each old profile's user hive).
- **Reveals:** a complete older **snapshot** of the registry and of every profile's hive — all the MRU, activity, device, network and account traces exactly as they were at that point in time, entirely independent of whatever the live clean removed. This is why clearing keys in the running registry is not enough on its own.
- **Remove (user runs):** delete restore points (System Protection > Configure > Delete, or `cleanmgr` > System Restore and Shadow Copies) **and** delete `Windows.old` (Settings > System > Storage > Temporary files > tick **Previous Windows installation(s)**, or elevated `cleanmgr`). See the system cluster's Windows.old and Volume Shadow Copies blocks.
- **Survives:** freed space holds the old hive bytes until TRIM/overwrite; any backup images elsewhere; new restore points if protection stays on.
- **Admin:** Yes.

### Deletion only unlinks — SSD remnants and the Clear-vs-Purge reality
- **Where:** not a file or a key. This is the unallocated/free space of every volume (`%SystemDrive%` and each data volume) and, on SSD/NVMe, the controller's spare and over-provisioned cells that Windows cannot directly address.
- **Reveals:** deleting a file, emptying the Recycle Bin, or clearing a registry value only removes the pointer — the actual content stays in unallocated space (and in SSD cells the OS cannot reach) and is recoverable by file-carving tools until a later write reuses that space, or until the SSD's TRIM/garbage-collection runs. A per-file clean is therefore **not** a secure erase.
- **Remove (user runs):** WipeWise Light mode does not overwrite free space. The honest options are (i) on an SSD, let TRIM settle after deletion — which greatly reduces, but does not guarantee, recoverability; (ii) run a free-space overwrite / `cipher /w:` pass (HDDs especially); or (iii) a full-device sanitize — the planned **Maximum mode** (NIST SP 800-88 *Purge*: ATA Secure Erase / NVMe Format / crypto-erase). See `standards.md` and `limitations.md`.
- **Survives:** on an SSD, a plain delete-plus-TRIM is NIST "Clear," not "Purge" — a determined lab can still recover remnants from spare cells; and intact copies may persist independently in shadow copies, File History, and backup images regardless of the free-space state.
- **Admin:** No for the free-space overwrite of your own data; a full-device Purge is a firmware operation (Maximum mode), separate from this read-only pass.

### File History and other backup copies held elsewhere
- **Where:** File History configuration at `%LOCALAPPDATA%\Microsoft\Windows\FileHistory` (present only if the feature was ever turned on); the **actual versioned copies are written to the configured target drive** (an external USB or network share) under a `FileHistory\<user>\<pc>` tree, not on `%SystemDrive%`. System image / "Backup and Restore (Windows 7)" (`wbadmin`) images may also sit on an external or network target.
- **Reveals:** File History keeps repeated, timestamped copies of the user's libraries (Desktop, Documents, Pictures, Music, Videos, Contacts, Favorites) and their change history — often a fuller record than the live profile, including versions of files later deleted from the PC. A system image is a block-level copy of the whole drive.
- **Remove (user runs):** Control Panel > File History > **Turn off**, then **Advanced settings > Clean up versions** (or delete the `FileHistory` folder on the backup drive itself); delete any system images from their target. Handle the backup drive or share as its own device.
- **Survives:** copies on a **detached or offline** backup drive, or on a network share, obviously remain after the PC is cleaned; cloud backups stay until removed in the service; the local config folder is only a pointer, not the data.
- **Admin:** No for your own File History; the backup target drive/share must be cleaned separately.
