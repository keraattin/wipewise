---
name: wipewise
description: >-
  Audit and guide cleanup of the personal data and usage traces left by the
  current user on a Windows 10 or 11 PC before selling, giving away, returning,
  recycling, or handing over the computer. Use when the user wants to wipe or
  reset personal data, remove their traces, clean a PC for sale or handover,
  check what personal information is on the machine, or meet a data-deletion
  duty (such as GDPR or KVKK) for a device they own. It scans read-only and
  reports findings across many categories (files, cloud storage, browsers,
  messaging and email, apps, finance and crypto wallets, virtual machines,
  credentials and developer secrets, activity and forensic traces, devices,
  and system leftovers), lists installed programs, and gives the account and
  cloud sign-out checklist plus step-by-step
  cleanup and verification guidance. It keeps Windows installed and never
  reinstalls the OS. An optional, confirmed reset (dry-run first, Recycle Bin
  by default) lets the user execute the approved removals.
license: Apache-2.0
compatibility: >-
  Windows 10 (22H2+) and Windows 11. Scanning needs local execution with
  Windows PowerShell 5.1+ (Claude Code or the desktop Code tab). On surfaces
  without local shell access the skill is guidance-only.
metadata:
  version: "0.3.0"
  stage: audit-guidance-and-reset
---

# WipeWise

WipeWise prepares a Windows PC for a new owner by finding the current user's
personal data and usage traces, showing them category by category, and guiding
their removal — so that **nothing of the previous owner is left behind**, ideally
beyond practical recovery. It is for **devices and data you own or are authorized
to erase**.

## What this version does and does not do

**Scan (read-only — every version):**
- Scans the machine **read-only** — reading only file/folder existence and sizes and registry key counts, and **running no external commands** — and reports what personal data and traces exist across 20 categories — including other local user accounts and other drives/volumes, not just the signed-in account on `C:` (see `references/trace-catalog.md`, which maps 700+ distinct artifacts), with sizes and counts.
- Lists installed programs so the user can decide which to remove.
- Walks the account / cloud sign-out and de-link checklist.
- Gives precise, user-run cleanup steps for each category.
- Explains honestly what cleaning can and cannot guarantee, and offers a read-only re-scan to verify.

**Reset (v0.3, opt-in, EXPERIMENTAL):**
- `scripts/Invoke-WipeWiseReset.ps1` can remove the files/folders the scan found and clear a fixed allowlist of known **HKCU user-history keys** — the Explorer Recent/Run/Typed/Search MRUs, ComDlg32, Map Network Drive MRU and IE TypedURLs, plus the per-user forensic execution/browsing keys UserAssist, FeatureUsage, MUICache, ShellBags, and the Remote-Desktop connection MRUs — for the categories the user approves. It is **dry-run by default** (shows a plan, changes nothing), sends to the **Recycle Bin by default** (`-Mode Delete` = permanent), only touches file targets **under the user's own profile**, refuses system folders / other users / other drives / junctions / cloud (unless opted in), clears registry **only for that exact-path HKCU allowlist** (wipes each key's values and subkeys, keeps the key, then verifies it emptied), and requires `-Execute -Confirm <PC name>` to act. The **user** runs it; see Step 5b.

**Does not:**
- Does **not** reinstall or reset Windows, and does **not** erase whole disks at the firmware level. Full-disk sanitization that meets NIST SP 800-88 "Purge" is a separate future mode; see `references/standards.md`.
- The reset does **not** auto-delete other user accounts, other volumes, or system/admin locations outside the profile, and does **not** touch the registry beyond the history-key allowlist — those stay guidance.

## Golden rules (follow these in every session)

1. **Ownership.** Confirm once that the user owns the PC or is authorized to prepare it. Warn that work or school devices may be under an employer's control or a legal-hold duty; those should go through the organization's IT.
2. **Claude runs read-only / dry-run only.** You may run the read-only scanner and the reset in **dry-run** (without `-Execute`). You **never** run the reset with `-Execute`, and never any other command that deletes, overwrites, formats, or edits the registry. The **user** runs the actual reset and any removals themselves, after reviewing the dry-run plan.
3. **Category-by-category approval.** Never dump everything at once. Show each category with its size/count, offer a few examples on request, and let the user decide per category.
4. **Honesty over reassurance.** Use `references/limitations.md`. Do not claim data is unrecoverable when it may not be (SSD remnants, cloud copies). Do not call this NIST "Purge".
5. **No falsification or obstruction.** WipeWise removes data; it does not fabricate or alter logs or timestamps to misrepresent what happened, spoof hardware identifiers (e.g. MachineGuid) to evade attribution, or help defeat a legal hold or investigation. Destroying data the user is legally required to keep is out of scope. If asked for falsification or investigation-evasion, decline and explain the scope.
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
- Category sizes can overlap when one folder sits inside another (e.g. virtual-machine disks inside Documents), so present them as per-category views, not a grand total to add up. A few broad containers (all user profiles, the Store `Packages` folder) are reported as a top-level count, not a size.
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

### Step 5b — Optional guided reset (v0.3, experimental)
Only if the user wants the tool to perform removals (otherwise stay with Step 5 guidance):
- Ensure a current scan JSON exists. Run the reset in **DRY-RUN first** (no `-Execute`) for the approved categories and review the plan together — what it would remove, what it refuses, what it would clear:
  ```
  powershell -ExecutionPolicy Bypass -File scripts/Invoke-WipeWiseReset.ps1 -ScanFile wipewise-scan.json -Categories personal-files,browsers
  ```
- Explain: Recycle Bin by default (reversible); `-Mode Delete` is permanent. It only touches items under the user's profile and refuses system / other-user / other-drive / junction / cloud targets; registry clearing is limited to a fixed exact-path allowlist of known HKCU history/forensic keys.
- **The user runs the actual reset** (you never run `-Execute`). They add `-Execute -Confirm <this PC's name>` once satisfied with the dry-run, in a PowerShell session so `-Categories a,b` binds correctly:
  ```
  powershell -ExecutionPolicy Bypass -File scripts/Invoke-WipeWiseReset.ps1 -ScanFile wipewise-scan.json -Categories personal-files,browsers -Execute -Confirm <PCNAME>
  ```
- Back up anything they might want first. For a device leaving their control, pair this with the Maximum-mode caveats in `references/limitations.md` (a per-file reset is not a secure erase).

### Step 6 — Limitations and verification
- Show the relevant points from `references/limitations.md` (especially SSD remnants and cloud copies).
- Offer a **read-only re-scan** to confirm counts and sizes dropped. Compare against the first scan and report what changed and what remains (and why, e.g. a trace that only clears on reboot).

## Files in this skill
- `scripts/Invoke-WipeWiseScan.ps1` — read-only scanner; outputs JSON.
- `scripts/Invoke-WipeWiseReset.ps1` — v0.3 reset (dry-run by default; the user runs `-Execute`). Removes approved files/folders and clears an exact-path allowlist of HKCU history/forensic keys, with the safety guards above.
- `references/trace-catalog.md` — every category: where it lives, what it reveals, how the user removes it, what survives which action.
- `references/delink-checklist.md` — account, license, and cloud sign-out/de-link steps, with ordering.
- `references/limitations.md` — honest limits and the "is it really gone?" explanation.
- `references/standards.md` — NIST SP 800-88 r2 / IEEE 2883 in plain language: when a personal-data reset is enough and when full-disk sanitization is needed.

## Out of scope for now (future work)
- Extending the reset to other user accounts, other volumes, and system/admin locations outside the profile, and to app-specific recent-files keys or any non-HKCU registry (those stay guidance; the auto-clear allowlist covers only OS-level HKCU user-history/forensic keys).
- "Maximum mode": boot-media firmware sanitize (NVMe/ATA Sanitize), clean OS install, and a signed NIST-aligned erasure certificate.
- macOS and Linux.
