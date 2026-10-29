# Limitations — be honest with the user

WipeWise's goal is that the previous owner's data is not left behind — ideally beyond practical recovery. But **v0.1 by itself is not yet a forensic-grade erasure** (that is the planned Maximum mode), so Claude must be honest about the current limits below.

## "Is my data really gone?"

**On an SSD/NVMe drive (most modern PCs):** deleting files and clearing traces removes them from normal view, and after the drive's TRIM runs, ordinary recovery tools generally cannot bring them back. But this is **not** the same as NIST SP 800-88 "Purge." SSDs keep spare and over-provisioned cells the operating system cannot address, so a determined lab attack could still recover remnants. If the data is highly sensitive or the buyer is untrusted, a full-device sanitize is needed — that is the planned **Maximum mode**. See `standards.md`.

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

## Scope and responsible use
WipeWise is for devices and data you own or are authorized to erase, so you can transfer a machine without leaving your personal data behind. Its aim is thorough, recovery-resistant removal.

It is **not** a tool for falsifying records or obstructing lawful process: it does not fabricate or alter logs or timestamps, spoof hardware identifiers, or help defeat a legal hold or investigation. Do not use it to destroy data you are legally required to keep.
