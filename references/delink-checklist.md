# Account, license and cloud de-link checklist

Run through this with the user. Mark each step: **done / skipped / not applicable**. Most steps happen on a website or inside an app, so the user performs them; Claude guides and tracks. Ordering matters where noted.

## Order that prevents lockouts and data loss
1. **Back up first.** Move anything to keep to a USB drive or another account.
2. **Stop cloud sync before deleting local files.** OneDrive: Settings > Account > **Unlink this PC**. Dropbox/Google Drive/iCloud: sign out / unlink. (Otherwise local deletions propagate to the cloud.)
3. **Add an alternate sign-in to each account before removing this device's Hello/passkeys**, or 2FA/passkeys bound to this PC's TPM can lock the user out.
4. Sign out / deactivate apps and licenses (below).
5. Clean personal data and traces (the main WipeWise flow).
6. **After** the machine is clean: remove the device from the Microsoft account and delete stale BitLocker recovery keys.

## Microsoft / Windows
- **Microsoft account device list:** account.microsoft.com/devices > this PC > Remove; then unlink from the Store device limit.
- **BitLocker recovery keys (after cleaning):** account.microsoft.com/devices/recoverykey > delete entries for this PC once no longer needed.
- **Find my device:** Settings > Privacy & security > Find my device > Off.
- **Windows activation:** the digital license is tied to the hardware; a clean install of the same edition reactivates automatically. Do **not** run `slmgr` key-removal commands — that can leave the next owner unactivated.
- **Windows Backup / "remember my apps":** if enabled, settings and app lists may restore to a new sign-in; turn it off if a truly fresh start is wanted.

## Work / school devices (if applicable)
- These may be enrolled in **Entra ID / Intune / Autopilot** or under **legal hold**. Check `dsregcmd /status`.
- If enrolled, the organization's IT must deregister the device (Intune first, then Autopilot). A disk clean does **not** remove Autopilot registration — the next owner would see the old org's sign-in. Do not attempt this without authorization.

## Licensed apps (sign out / deactivate BEFORE uninstalling)
- **Microsoft 365 / Office:** account.microsoft.com > Services & subscriptions / Devices > sign out (5-device limit).
- **Adobe Creative Cloud:** Help > Sign out **in-app** before uninstalling (uninstalling alone does not deactivate).
- **Apple (iTunes/Music):** Account > Authorizations > Deauthorize This Computer.
- **Steam:** Steam Guard > Manage > Deauthorize all devices. **Epic / EA / Battle.net / GOG / Ubisoft:** sign out.
- **Password managers:** remove this device as a trusted device from the vault's web console.

## Browsers and sync
- Edge/Chrome/Firefox/Brave: sign out and **turn off Sync**, then clear browsing data for **All time**. Also clear server-side sync from the account dashboard (Google/Microsoft/Mozilla).

## Messaging and linked devices
- WhatsApp: phone > Linked devices > log this PC out.
- Telegram / Signal / Slack / Discord / Teams / Zoom: sign out and revoke this device/session in-app.

## Email clients
- Outlook / Thunderbird / Mail: remove each account; back up any local PST/mail store first.

## Developer and power-user accounts
- Git Credential Manager, GitHub/GitLab tokens, `.ssh` keys, `.aws` / `.azure` / `.kube` / `.docker` credentials, npm/VS Code tokens: revoke tokens server-side and remove local credential files.

## Peripherals
- Bluetooth pairings and saved Wi-Fi networks: forget them (note this affects all users of the PC).
