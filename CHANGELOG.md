# Changelog

All notable changes to WipeWise are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/), and this project uses
[Semantic Versioning](https://semver.org/).

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

[0.1.0]: https://github.com/keraattin/wipewise/releases/tag/v0.1.0
