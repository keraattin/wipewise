# Changelog

All notable changes to WipeWise are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/), and this project uses
[Semantic Versioning](https://semver.org/).

## [0.3.0] - 2026-10-30

Wider **Reset** coverage. The scan stays read-only; the reset stays **opt-in, dry-run by
default, and experimental.**

### Added
- Reset registry clearing expanded from 10 to 20 keys. The exact-path HKCU allowlist now also
  covers the per-user forensic history keys — **UserAssist**, **FeatureUsage**, **MUICache**,
  **ShellBags** (BagMRU + Bags, in both the NTUSER and USRCLASS hives), the **Remote Desktop**
  connection MRUs (Default + Servers), and **Map Network Drive MRU** — alongside the existing
  Explorer Recent/Run/Typed/Search MRUs, ComDlg32 and IE TypedURLs. Each is cleared by exact
  path (values + subkeys removed, the key itself kept), then verified empty.
- Scanner: three new read-only probes (Map Network Drive MRU, and the ShellBags `Bags`
  view-settings keys for both hives) — now ~754 probes.

### Safety
- Clearing mechanism unchanged: exact-path allowlist only (no prefix/suffix widening), HKCU
  only (including `HKCU\Software\Classes` = the per-user USRCLASS hive), per-key fail-closed.
  ShellBags clearing also resets Explorer folder-view preferences (cosmetic, rebuilt on use).
- Validated by a four-lens adversarial review (breakage / mechanism / exact-match / scope —
  no findings) and host-isolated unit tests of the actual clearing code against throwaway keys
  mirroring every new key shape, plus a 20/20 scanner-probe-to-allowlist normalization check.

### Changed
- Scanner report version and reset version bumped to 0.3.0.

## [0.2.0] - 2026-10-30

First **Reset** increment. The scan stays read-only; the new reset is **opt-in, dry-run by default, and experimental.**

### Added
- `scripts/Invoke-WipeWiseReset.ps1` — a guided, confirmed reset that removes the
  files/folders the scan found and clears a fixed allowlist of known Windows
  history keys, for the categories you approve. Dry-run unless `-Execute`;
  Recycle Bin by default (`-Mode Delete` for permanent); requires
  `-Confirm <computer name>`.

### Safety
- Containment: every file target must resolve under your own profile; system
  folders, other users, other drives, drive roots, cloud-sync (unless
  `-IncludeCloud`), and any path with a junction/symlink in its leaf or ancestry
  are refused (fail-closed). Delete uses a reparse-skipping walk; Recycle skips
  targets too large for the Recycle Bin, containing a junction, or on a volume
  with Recycle disabled, rather than silently permanent-deleting them.
- Registry: only the ten known HKCU history keys (RecentDocs, RunMRU, TypedPaths,
  WordWheelQuery, ComDlg32 MRUs, TypedURLs, RecentApps) are cleared, by exact
  path — removing values/subkeys and keeping the key; everything else is guidance.
- Validated by two adversarial reviews (file paths) and one (registry) with every
  finding fixed, a real `-Execute` test in a disposable VM, and live unit tests.
- Not auto-done (guidance only): other user accounts, other volumes, system/admin
  locations outside the profile, and registry beyond the history-key allowlist.

### Changed
- Scanner report version bumped to 0.2.0 (no scanner behavior change).

## [0.1.4] - 2026-10-30

More longer-tail application coverage. Still **read-only and guidance-only.**

### Added
- ~110 more read-only probes (now ~751) and ~200 more catalog entries (now
  700+ artifacts), covering regional messengers/email/browsers (QQ, TIM, Wickr,
  Zulip, Nheko, BlueMail, UC/Sogou/Sleipnir/Lunascape, …), creative/CAD/
  scientific tools (AutoCAD, SolidWorks, Maya, Revit, SketchUp, MATLAB, …),
  enterprise developer tooling (Pulumi, Helm, Lens, Perforce, SAP GUI,
  Salesforce CLI, …), more finance/tax/crypto and VPN clients, and deeper
  Windows OS traces (Spotlight/lock-screen media, search and personalization
  caches).

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

[0.3.0]: https://github.com/keraattin/wipewise/releases/tag/v0.3.0
[0.2.0]: https://github.com/keraattin/wipewise/releases/tag/v0.2.0
[0.1.4]: https://github.com/keraattin/wipewise/releases/tag/v0.1.4
[0.1.3]: https://github.com/keraattin/wipewise/releases/tag/v0.1.3
[0.1.2]: https://github.com/keraattin/wipewise/releases/tag/v0.1.2
[0.1.1]: https://github.com/keraattin/wipewise/releases/tag/v0.1.1
[0.1.0]: https://github.com/keraattin/wipewise/releases/tag/v0.1.0
