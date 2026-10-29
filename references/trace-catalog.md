# WipeWise trace catalog

What each category covers, where it lives, what it reveals, how the **user** removes it, and what survives which action. Paths use environment variables (`%USERPROFILE%`, `%LOCALAPPDATA%`, `%APPDATA%`). This is reference material; Claude only reads, the user removes.

Legend for "Removal": the recommended **user-run** method. Prefer the app's own UI or Windows Settings over manual file deletion where one exists.

---

## 1. Personal files

| Location | Reveals | Removal |
|---|---|---|
| `%USERPROFILE%\Desktop,Documents,Downloads,Pictures,Videos,Music,Favorites` | Everything the user created or saved | Move anything to keep onto backup/USB first, then delete in File Explorer and empty the Recycle Bin |
| `%USERPROFILE%\OneDrive` (and other cloud folders) | Synced documents | **Unlink/pause the cloud account first** (OneDrive: Settings > Account > Unlink this PC), then delete local copies. Otherwise deletion syncs to the cloud. |

Notes: With OneDrive "Known Folder Move", Desktop/Documents/Pictures *are* the OneDrive folders. With Files On-Demand, some items are online-only placeholders. Check OneDrive state before deleting.

## 2. Browser data

| Browser | Profile path | Removal |
|---|---|---|
| Edge | `%LOCALAPPDATA%\Microsoft\Edge\User Data` | In the browser: Settings > Privacy > Clear browsing data > **All time**, all boxes. Then **turn off and clear Sync** (sign out) so it does not return on next sign-in. |
| Chrome | `%LOCALAPPDATA%\Google\Chrome\User Data` | Same pattern; also `chrome://settings/syncSetup` > "Turn off" and clear data from the Google account dashboard. |
| Brave | `%LOCALAPPDATA%\BraveSoftware\Brave-Browser\User Data` | Same pattern. |
| Firefox | `%APPDATA%\Mozilla\Firefox\Profiles` | Settings > Privacy & Security > Clear Data and Saved Logins; sign out of Firefox Sync. |

Reveals: history, cookies, **saved passwords**, autofill (addresses, cards), cache. Saved passwords are the highest-value item here.

## 3. App data and messages

| App | Path | Removal |
|---|---|---|
| Teams (new) | `%LOCALAPPDATA%\Packages\MSTeams_8wekyb3d8bbwe` | Sign out in-app; then Settings > Apps > reset or uninstall |
| Slack / Discord / Telegram / Signal / Zoom | `%APPDATA%\<App>` | **Sign out and revoke this device** inside the app, then uninstall |
| WhatsApp | `%LOCALAPPDATA%\Packages\5319275A.WhatsAppDesktop...` | On the phone: Linked devices > log this PC out; then uninstall |
| Outlook (classic) data | `%LOCALAPPDATA%\Microsoft\Outlook` (OST/PST) | Remove the account in Outlook; back up any PST first |

Important: deleting local caches does **not** end the server-side session. The user must revoke the linked device/session in each app (see also the de-link checklist).

## 4. Saved credentials and keys

| Item | Location | Removal |
|---|---|---|
| Windows credentials | Credential Manager | Control Panel > Credential Manager > Windows Credentials / Web Credentials > remove each |
| Wi-Fi keys | per-profile | `netsh wlan delete profile name="NAME"` (user runs), or Settings > Network > Wi-Fi > Manage known networks > Forget |
| Windows Hello (PIN/face/fingerprint) | this PC | Settings > Accounts > Sign-in options. **Set up another sign-in on the account first.** Fingerprint templates on a match-on-chip sensor clear only via "Remove"/BIOS, not by deleting files. |
| SSH / AWS / Azure / Kube / Git creds | `%USERPROFILE%\.ssh,.aws,.azure,.kube`, Git Credential Manager | Delete the folders/entries after backing up anything needed |
| PowerShell history | `%APPDATA%\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt` | Delete the file |

## 5. Activity history

| Item | Location | Removal |
|---|---|---|
| Recent items, Jump Lists | `%APPDATA%\Microsoft\Windows\Recent` (+ `AutomaticDestinations`, `CustomDestinations`) | Delete contents; Settings > Personalization > Start > turn off recent items |
| Clipboard history | `%LOCALAPPDATA%\Microsoft\Windows\Clipboard` | Settings > System > Clipboard > **Clear** |
| Activity history | `%LOCALAPPDATA%\ConnectedDevicesPlatform\...\ActivitiesCache.db` | Settings > Privacy & security > Activity history > Clear |
| Explorer MRUs | registry under `HKCU\...\Explorer\{RecentDocs,RunMRU,TypedPaths,WordWheelQuery}` | Clearing recent items and File Explorer history covers most; manual registry edits are advanced and out of scope for v0.1 |

## 6. Recall and Copilot (Copilot+ PCs only)

| Item | Location | Removal |
|---|---|---|
| Recall snapshots + index | `%LOCALAPPDATA%\CoreAIPlatform.00\...` | Settings > Privacy & security > **Recall & snapshots** > Delete all; optionally turn off "Save snapshots" |
| Copilot history | account/app | Sign out of Copilot; clear history in the app |

Snapshots are encrypted to the user's Windows Hello, so prefer the official Delete-all path over touching files.

## 7. Network and stored credentials (counts)

The scanner reports **counts only** here (number of Wi-Fi profiles via `netsh wlan show profiles`, number of stored credentials via `cmdkey /list`); neither command reveals secrets. Removal is covered in sections 4 (credentials) and above (Wi-Fi). Forgetting Wi-Fi/Bluetooth affects every user of the PC — warn on shared machines.

## 8. System traces

| Item | Location | Removal (user) | Survives? |
|---|---|---|---|
| Temp files | `%TEMP%`, `%WINDIR%\Temp` | Settings > System > Storage > Temporary files, or Disk Cleanup | — |
| Prefetch, Amcache, SRUM, event logs | `%WINDIR%\Prefetch`, system hives/logs | Mostly cleared by a later full reset; v0.1 reports them. Clearing the Security log writes an audit event (1102). | Across normal use |
| Windows.old | `%SystemDrive%\Windows.old` | Disk Cleanup > "Previous Windows installation(s)" | Until cleaned |
| Restore points / shadow copies | VSS | System Protection > Configure > Delete (removes rollback ability) | Up to 72h on newer builds |
| Error reports / crash dumps | `%LOCALAPPDATA%\Microsoft\Windows\WER`, `%WINDIR%\MEMORY.DMP` | Disk Cleanup | — |

## 9. Installed programs

The scanner lists installed programs (from the Uninstall registry keys and AppX). For each the user chooses keep or remove. **Before uninstalling**, sign out and deactivate licenses (see the de-link checklist) — uninstalling does not release a license or end an account session.

---

### What a personal-data reset cannot reach
Even after all of the above: data on an SSD may persist in spare/over-provisioned cells; copies may exist in the cloud or on backups; and firmware/hardware items (TPM, BIOS password, asset tag, Intel AMT, Absolute, on-sensor fingerprint templates) are untouched by file deletion. See `limitations.md` and `standards.md`.
