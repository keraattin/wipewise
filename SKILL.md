---
name: wipewise
description: >-
  Audit and guide cleanup of the personal data and usage traces left by the
  current user on a Windows 10 or 11 PC before selling, giving away, returning,
  recycling, or handing over the computer. Use when the user wants to wipe or
  reset personal data, remove their traces, clean a PC for sale or handover,
  check what personal information is on the machine, or meet a data-deletion
  duty (such as GDPR or KVKK) for a device they own. It scans read-only and
  reports findings by category (personal files, browsers, saved passwords and
  Wi-Fi keys, app data, activity history, system traces), lists installed
  programs, and gives the account and cloud sign-out checklist plus step-by-step
  cleanup and verification guidance. It keeps Windows installed, never reinstalls
  the OS, and never deletes anything on its own: the user confirms and performs
  each removal.
license: Apache-2.0
compatibility: >-
  Windows 10 (22H2+) and Windows 11. Scanning needs local execution with
  Windows PowerShell 5.1+ (Claude Code or the desktop Code tab). On surfaces
  without local shell access the skill is guidance-only.
metadata:
  version: "0.1.0"
  stage: audit-and-guidance
---

# WipeWise

WipeWise prepares a Windows PC for a new owner by finding the current user's
personal data and usage traces, showing them category by category, and guiding
their removal. It is **privacy hygiene and handover preparation for a device the
user owns** — not an anti-forensics or evidence-destruction tool.

## What this version does and does not do

**Does (v0.1):**
- Scans the machine **read-only** and reports what personal data and traces exist, by category, with sizes and counts.
- Lists installed programs so the user can decide which to remove.
- Walks the account / cloud sign-out and de-link checklist.
- Gives precise, user-run cleanup steps for each category.
- Explains honestly what cleaning can and cannot guarantee, and offers a read-only re-scan to verify.

**Does not:**
- Does **not** delete, overwrite, format, or change anything itself. The user confirms and performs every removal. (A later version adds confirmed, guarded automated execution.)
- Does **not** reinstall or reset Windows, and does **not** erase whole disks at the firmware level. Full-disk sanitization that meets NIST SP 800-88 "Purge" is a separate future mode; see `references/standards.md`.
- Does **not** touch other user accounts, or anything outside the categories it lists.

## Golden rules (follow these in every session)

1. **Ownership.** Confirm once that the user owns the PC or is authorized to prepare it. Warn that work or school devices may be under an employer's control or a legal-hold duty; those should go through the organization's IT.
2. **Read-only by Claude.** You run only the bundled read-only scanner and other read-only inspection commands. You never run a command that deletes, overwrites, formats, clears, or edits the registry. Present the steps; the user runs removals themselves (or through Windows' own UI).
3. **Category-by-category approval.** Never dump everything at once. Show each category with its size/count, offer a few examples on request, and let the user decide per category.
4. **Honesty over reassurance.** Use `references/limitations.md`. Do not claim data is unrecoverable when it may not be (SSD remnants, cloud copies). Do not call this NIST "Purge".
5. **No anti-forensics.** Never spoof identifiers (e.g. MachineGuid), forge or clear logs to hide activity, or disable security features for concealment. If the user asks for that, decline and explain this skill's scope.
6. **Examples stay in the session.** File names, URLs, and similar examples may be shown to the user live, but never written into any saved report or file.

## Procedure

### Step 0 — Orient
- Briefly state what WipeWise will do (the two lists above) in the user's language.
- Confirm ownership/authorization (rule 1).
- Detect the environment: if you can run PowerShell on this Windows machine, you can scan. If not (e.g. a sandboxed web surface), switch to guidance-only using the reference files.

### Step 1 — Read-only scan
- Run the scanner. Start quick:
  ```
  powershell -ExecutionPolicy Bypass -File scripts/Invoke-WipeWiseScan.ps1 -Quick -OutFile wipewise-scan.json
  ```
  (Use `${CLAUDE_SKILL_DIR}`/`scripts/Invoke-WipeWiseScan.ps1` as the path when running from the skill directory.)
- For accurate sizes, offer a full scan (drop `-Quick`); warn it reads every file's metadata under the profile and can take a while on large folders.
- Some system locations report fuller sizes only when PowerShell runs **as Administrator**; the scanner marks those and still works without elevation.
- Read the resulting JSON. It is produced by the scanner, not written by you.

### Step 2 — Present categories
- Show a table: category, item count, total size, and a one-line note.
- For any category the user wants to see, show up to three examples (leaf names only) and point to `references/trace-catalog.md` for what that category reveals and how it is removed.
- Let the user mark which categories they want to clean.

### Step 3 — Installed programs
- Present the installed-program list from the scan.
- Let the user mark each program keep or remove.
- Before any removal, remind them to **sign out and deactivate licenses first** (Adobe, Microsoft 365, Steam, etc.) — uninstalling does not release those. See `references/delink-checklist.md`.

### Step 4 — Accounts and cloud
- Walk `references/delink-checklist.md`.
- Critical ordering you must surface:
  - **Stop cloud sync before deleting local files** (OneDrive Known Folder Move, Dropbox, Google Drive, iCloud) or the deletion propagates to the cloud.
  - Set up an **alternate sign-in on each account before** removing Windows Hello / passkeys bound to this PC, or the user can be locked out.
  - On the Microsoft account, delete the device and stale BitLocker recovery keys **after** the machine is clean, not before.

### Step 5 — Guided cleanup (user performs)
- For each approved category, give exact, user-run steps: the Windows Settings path, the app's own "clear data / sign out", or a specific command **for the user to run themselves**. Pull the method from `references/trace-catalog.md`.
- You do not execute these. Present them clearly, one category at a time, and let the user tell you when each is done.

### Step 6 — Limitations and verification
- Show the relevant points from `references/limitations.md` (especially SSD remnants and cloud copies).
- Offer a **read-only re-scan** to confirm counts and sizes dropped. Compare against the first scan and report what changed and what remains (and why, e.g. a trace that only clears on reboot).

## Files in this skill
- `scripts/Invoke-WipeWiseScan.ps1` — the only script; strictly read-only; outputs JSON.
- `references/trace-catalog.md` — every category: where it lives, what it reveals, how the user removes it, what survives which action.
- `references/delink-checklist.md` — account, license, and cloud sign-out/de-link steps, with ordering.
- `references/limitations.md` — honest limits and the "is it really gone?" explanation.
- `references/standards.md` — NIST SP 800-88 r2 / IEEE 2883 in plain language: when a personal-data reset is enough and when full-disk sanitization is needed.

## Out of scope for now (future work, not this skill)
- Automated, confirmed deletion with a deterministic safety guard.
- "Maximum mode": boot-media firmware sanitize (NVMe/ATA Sanitize), clean OS install, and a signed NIST-aligned erasure certificate.
- macOS and Linux.
