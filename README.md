# WipeWise

**Prepare a Windows PC for a new owner — with nothing of yours left behind.**

![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6)
![Status](https://img.shields.io/badge/status-v0.4%20scan%20%2B%20reset-orange)
![Claude](https://img.shields.io/badge/Claude-Agent%20Skill-6C5CE7)

WipeWise is an open-source [Claude](https://claude.com/claude-code) skill that helps you find and remove the personal data and usage traces on a Windows 10/11 PC before you **sell, return, recycle, or hand it over**. It inspects the machine, shows you exactly what is there — category by category — and walks you through clearing it.

> **The scan is read-only** — it reads files/folders and registry key counts and runs no external commands. **v0.3 ships an opt-in, experimental reset** (`Invoke-WipeWiseReset.ps1`) that can remove approved items: it is **dry-run by default**, uses the **Recycle Bin by default**, only touches file paths under your own profile, refuses system / other-user / other-drive / junction / cloud targets, clears only a fixed exact-path allowlist of per-user (HKCU) history/forensic registry keys, and needs `-Execute -Confirm <PC name>` to act. **Always dry-run first and keep a backup.** Recovery-proof whole-disk sanitization is still on the [roadmap](#roadmap).

---

## Why

When you pass a computer on, you leave behind far more than the obvious files:

- saved passwords and autofill, Wi-Fi keys, stored Windows credentials
- browser history, cookies, and signed-in sessions
- app and message data, caches, and activity history
- deleted-but-recoverable files and free-space remnants

Windows' built-in **"Reset this PC"** does not meet recognized data-erasure standards, and on SSDs it can leave data that is still recoverable. WipeWise exists to close that gap for everyday users, grounded in **NIST SP 800-88 r2** and **IEEE 2883**.

## What it does (v0.4)

| Capability | Details |
|---|---|
| Read-only scan | Reports what personal data and traces exist, by category, with sizes and counts — reading only files/folders and registry key counts, running no external commands |
| Category report | 20 categories / 700+ documented artifacts: personal files & cloud storage, browsers, messaging & email, apps/media/games, finance & crypto wallets, virtual machines & backups, accounts & identity, credentials & developer secrets, network, devices, activity & forensic traces, Recall/Copilot, system leftovers, **other user accounts**, and **other drives/volumes** |
| Installed programs | Lists programs to sign out of and uninstall |
| De-link checklist | Accounts, licenses, and cloud links to sign out of — in the right order, so you do not get locked out |
| Guided cleanup | Exact, user-run steps to clear each category you approve |
| Reset (opt-in, experimental) | `Invoke-WipeWiseReset.ps1` removes approved files/folders and clears an exact-path allowlist of HKCU history/forensic keys (Explorer MRUs, UserAssist, ShellBags, MUICache, FeatureUsage, RDP MRUs, …) — **dry-run by default**, Recycle Bin by default, profile-only, refuses system/other-user/other-drive/junction/cloud; **you** run `-Execute`, or `-Interactive` for a guided category-by-category flow that applies only after you type the PC name |
| Honest limits | Clear about what a reset can and cannot guarantee; offers a verification re-scan |

## How it works

1. **Orient** — confirm you own the device.
2. **Scan** — read-only; produces a category report.
3. **Review** — go category by category (counts, sizes, examples).
4. **Programs** — choose what to uninstall.
5. **Accounts and cloud** — work through the de-link checklist.
6. **Clean** — clear each approved category with WipeWise's guidance, or optionally run the **reset** (dry-run first, then `-Execute`) to remove the approved items for you.
7. **Verify** — a read-only re-scan confirms what is gone.

## Install (Claude Code / Claude desktop)

Clone the repo into your Claude skills folder as `wipewise`:

```bash
git clone https://github.com/keraattin/wipewise.git ~/.claude/skills/wipewise
```

Then, in Claude Code, just ask — for example *"Use WipeWise to get my PC ready to sell."* The skill also triggers automatically on related requests.

Run the read-only scanner directly:

```bash
powershell -ExecutionPolicy Bypass -File ~/.claude/skills/wipewise/scripts/Invoke-WipeWiseScan.ps1 -OutFile wipewise-scan.json
```

Preview a reset (**dry-run — changes nothing**), review the plan, then run it for real only when satisfied (sends to the Recycle Bin; add `-Mode Delete` for permanent):

```powershell
powershell -ExecutionPolicy Bypass -File ~/.claude/skills/wipewise/scripts/Invoke-WipeWiseReset.ps1 -ScanFile wipewise-scan.json -Categories personal-files,browsers
```

Or run it **interactively** — pick categories, preview the plan, choose Recycle or Delete, and confirm by typing this PC's name (nothing is removed until then; in a non-interactive shell it just aborts):

```powershell
powershell -ExecutionPolicy Bypass -File ~/.claude/skills/wipewise/scripts/Invoke-WipeWiseReset.ps1 -ScanFile wipewise-scan.json -Interactive
```

> **The reset is experimental.** It is dry-run by default and only touches paths under your own profile, but it performs irreversible operations — always review the dry-run plan and keep a backup first, and test in a disposable VM (e.g. Windows Sandbox) before using it on data you care about.

> On claude.ai (web) the skill can only give **guidance** — it has no access to your disks. Scanning and cleanup need a local environment (Claude Code or the desktop Code tab) with Windows PowerShell 5.1+.

## Roadmap

- **v0.1 — Audit and guidance** (read-only) — done
- **v0.2 — Reset** (experimental) — done: confirmed, dry-run-first removal of approved files/folders + known Windows history keys; Recycle Bin by default; profile-only with strong safety guards
- **v0.3 — Wider reset** (experimental) — done: the registry auto-clear allowlist also covers the per-user (HKCU) forensic history keys (UserAssist, ShellBags, MUICache, FeatureUsage, the Remote-Desktop connection MRUs and Map Network Drive MRU) alongside the Explorer MRUs, each cleared by exact path and verified
- **v0.4 — Interactive reset** (experimental) — **you are here:** `-Interactive` guides you category-by-category, previews the plan, lets you choose Recycle vs Delete, and removes nothing until you type this PC's name at a final gate (and safely aborts in a non-interactive shell). Next: other accounts/volumes and system/admin locations (still guidance today)
- **Maximum mode** — recovery-proof, whole-device sanitization: firmware **Sanitize** (NVMe/ATA), cryptographic erase, free-space and metadata cleaning, and a signed **NIST SP 800-88 r2**-aligned certificate — so the previous owner's data cannot be recovered, including by forensic tools
- **macOS and Linux**

## Scope and responsible use

WipeWise is for **devices and data you own or are authorized to erase**, so you can transfer a machine without leaving your personal data behind. Its aim is thorough, recovery-resistant removal.

It is **not** a tool for falsifying records or obstructing lawful process: it does not fabricate or alter logs or timestamps, spoof hardware identifiers, or help defeat a legal hold or investigation. Do not use it to destroy data you are legally required to keep.

## Limitations

WipeWise is honest about what it cannot reach: SSD spare-cell remnants, cloud and backup copies, and firmware/hardware persistence (TPM, BIOS password, Absolute, on-sensor fingerprint templates), among others. See [references/limitations.md](references/limitations.md).

## Documentation

- [SKILL.md](SKILL.md) — how Claude runs WipeWise
- [references/trace-catalog.md](references/trace-catalog.md) — every category: where it lives, what it reveals, how to remove it
- [references/delink-checklist.md](references/delink-checklist.md) — account / license / cloud sign-out, in order
- [references/standards.md](references/standards.md) — NIST SP 800-88 r2 / IEEE 2883 in plain language

## License

[Apache-2.0](LICENSE). **No warranty** — WipeWise guides irreversible data operations; verify the target and keep a backup before you rely on results.

## Contributing

Issues and pull requests are welcome — new trace locations, clearer guidance, translations, and testing on more hardware all help.
