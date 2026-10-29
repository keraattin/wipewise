# Changelog

All notable changes to WipeWise are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/), and this project uses
[Semantic Versioning](https://semver.org/).

## [0.1.3] - 2026-10-30

More application and artifact coverage. Still **read-only and guidance-only.**

### Added
- ~240 more read-only probes (now ~645) and ~230 more catalog entries (now
  600+ artifacts), covering: pre-release browser channels and many more
  browsers; more messengers and email clients; **Phone Link** (mirrored SMS,
  photos and call history); more media players, creative tools, game launchers
  and emulators; more cloud CLIs, VCS/CI and database tools (including the
  `rclone` token store); more password managers, crypto wallets and desktop
  authenticators; more cloud-sync and VPN clients; older Office/Acrobat version
  hives; and deeper forensic traces (BAM/DAM, Shimcache).

## [0.1.2] - 2026-10-29

Structural coverage and an accuracy fix. Still **read-only and guidance-only.**

### Added
- Two dynamic categories so the scan is no longer limited to the signed-in user
  on `C:`: **other user accounts** (enumerates every real local profile under
  `C:\Users`) and **other drives & volumes** (each non-system/removable volume's
  Recycle Bin, System Volume Information, and top-level data).

### Fixed
- Broad container folders (`C:\Users`, the Store `Packages` folder, per-volume
  `System Volume Information`) are now reported as a top-level count instead of
  being deep-sized — previously they hugely double-counted data already measured
  by other categories (a live scan dropped from ~623 GB to ~284 GB).

## [0.1.1] - 2026-10-29

Catalog and scanner coverage expansion. Still **read-only and guidance-only.**

### Added
- Greatly expanded `references/trace-catalog.md`: 370+ distinct Windows 10/11
  artifacts across 18 categories — now including cloud-storage clients, finance
  and tax files, cryptocurrency wallets and desktop authenticators, virtual
  machines / WSL / backup images, database and remote-session clients, more
  browsers, messengers, media and capture apps, forensic execution artifacts,
  attached-device history, and a cross-cutting section on other user accounts,
  other volumes, and SSD recoverability.

### Changed
- `scripts/Invoke-WipeWiseScan.ps1` rewritten around a unified probe table of
  **403 read-only probes** across those categories, plus live installed-program
  enumeration. It now reads **only** file/folder existence and sizes and
  registry key counts and **runs no external commands** (previous `netsh` /
  `cmdkey` calls were replaced with equivalent read-only folder/registry
  probes).

## [0.1.0] - 2026-10-29

Initial public release. **Read-only and guidance-only.**

### Added
- `SKILL.md`: the WipeWise Agent Skill — a read-only audit and user-guided
  cleanup procedure for preparing a Windows 10/11 PC for a new owner.
- `scripts/Invoke-WipeWiseScan.ps1`: a strictly read-only PowerShell scanner
  (Windows PowerShell 5.1+) that reports the current user's personal data and
  usage traces across nine categories as JSON. Supports `-Quick`, `-OutFile`
  and `-ListProbes`.
- References:
  - `references/trace-catalog.md` — where each category lives, what it reveals,
    and how the user removes it.
  - `references/delink-checklist.md` — account, license and cloud sign-out steps
    with the ordering that avoids lockouts and accidental cloud deletion.
  - `references/limitations.md` — honest limits ("is it really gone?").
  - `references/standards.md` — NIST SP 800-88 r2 / IEEE 2883 in plain language.

### Notes
- This version never deletes, overwrites, formats, or edits the registry. The
  user confirms and performs every removal.
- It keeps Windows installed; it does not reinstall the OS or sanitize whole
  disks at the firmware level (planned for a later "Maximum mode").

[0.1.3]: https://github.com/keraattin/wipewise/releases/tag/v0.1.3
[0.1.2]: https://github.com/keraattin/wipewise/releases/tag/v0.1.2
[0.1.1]: https://github.com/keraattin/wipewise/releases/tag/v0.1.1
[0.1.0]: https://github.com/keraattin/wipewise/releases/tag/v0.1.0
