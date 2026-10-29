# Limitations — be honest with the user

WipeWise v0.1 helps remove personal data and traces so the day-to-day signs of the previous user are gone. It is **not** a forensic-grade erasure, and Claude must say so plainly when relevant.

## "Is my data really gone?"

**On an SSD/NVMe drive (most modern PCs):** deleting files and clearing traces removes them from normal view, and after the drive's TRIM runs, ordinary recovery tools generally cannot bring them back. But this is **not** the same as NIST SP 800-88 "Purge." SSDs keep spare and over-provisioned cells the operating system cannot address, so a determined lab attack could still recover remnants. If the data is highly sensitive or the buyer is untrusted, a full-device sanitize is needed — that is the future **Maximum mode**, not this skill. See `standards.md`.

**On a hard disk (HDD):** deleted files can be recovered until their space is overwritten. A personal-data reset does not overwrite free space on its own; a free-space overwrite (a future feature / a separate tool) or full encryption from first use addresses this.

## Things a file-level clean cannot reach

- **Cloud and backup copies.** Anything synced (OneDrive, Google Drive, iCloud, browser sync) or backed up elsewhere must be handled in those services. Wiping the PC does not touch them.
- **Other devices / linked sessions.** Messaging and account sessions on the server side stay active until the user revokes this device (see the de-link checklist).
- **Firmware and hardware, which survive even a full disk wipe:**
  - TPM contents (keys, PIN); clear via Windows Security, with the BitLocker recovery key in hand first.
  - BIOS/UEFI admin password, asset tag, custom owner strings.
  - Intel AMT/vPro provisioning; Absolute/Computrace anti-theft firmware.
  - **Match-on-chip fingerprint templates** stored on the sensor module — removing Windows Hello in Settings is what clears these; deleting files does not.
- **Autopilot / Intune / Entra registration** (work devices) lives in the cloud and must be removed by the organization.

## Side effects to warn about

- **Clearing the Security event log writes an audit event (1102)** — the clearing itself is recorded.
- **Tamper Protection** can block changes to Microsoft Defender's history.
- **Removing restore points / shadow copies** removes the ability to roll back.
- **Forgetting Wi-Fi / Bluetooth** affects every user of the PC.
- **Deleting local cloud folders while sync is active** deletes the cloud copy too — stop sync first.

## What WipeWise deliberately will not do
- It will not spoof hardware identifiers (e.g. MachineGuid), forge or selectively erase logs to hide activity, or disable security features for concealment. Those are anti-forensic behaviors and are out of scope. WipeWise is for preparing a device you own for a new owner.
