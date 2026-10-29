# WipeWise

**Prepare a Windows PC for a new owner — with nothing of yours left behind.**

![License](https://img.shields.io/badge/license-Apache--2.0-blue)
![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-0078D6)
![Status](https://img.shields.io/badge/status-v0.1%20read--only-orange)
![Claude](https://img.shields.io/badge/Claude-Agent%20Skill-6C5CE7)

WipeWise is an open-source [Claude](https://claude.com/claude-code) skill that helps you find and remove the personal data and usage traces on a Windows 10/11 PC before you **sell, return, recycle, or hand it over**. It inspects the machine, shows you exactly what is there — category by category — and walks you through clearing it.

> **v0.1 is read-only and guidance-only.** It scans and reports; it does **not** delete or change anything on its own. **You** confirm and perform each removal. Automated deletion and recovery-proof, whole-disk sanitization are on the [roadmap](#roadmap).

---

## Why

When you pass a computer on, you leave behind far more than the obvious files:

- saved passwords and autofill, Wi-Fi keys, stored Windows credentials
- browser history, cookies, and signed-in sessions
- app and message data, caches, and activity history
- deleted-but-recoverable files and free-space remnants

Windows' built-in **"Reset this PC"** does not meet recognized data-erasure standards, and on SSDs it can leave data that is still recoverable. WipeWise exists to close that gap for everyday users, grounded in **NIST SP 800-88 r2** and **IEEE 2883**.

## What it does (v0.1)

| Capability | Details |
|---|---|
| Read-only scan | Reports what personal data and traces exist, by category, with sizes and counts — reading only files/folders and registry key counts, running no external commands |
| Category report | 20 categories / 370+ documented artifacts: personal files & cloud storage, browsers, messaging & email, apps/media/games, finance & crypto wallets, virtual machines & backups, accounts & identity, credentials & developer secrets, network, devices, activity & forensic traces, Recall/Copilot, system leftovers, **other user accounts**, and **other drives/volumes** |
| Installed programs | Lists programs to sign out of and uninstall |
| De-link checklist | Accounts, licenses, and cloud links to sign out of — in the right order, so you do not get locked out |
| Guided cleanup | Exact, user-run steps to clear each category you approve |
| Honest limits | Clear about what a reset can and cannot guarantee; offers a verification re-scan |

## How it works

1. **Orient** — confirm you own the device.
2. **Scan** — read-only; produces a category report.
3. **Review** — go category by category (counts, sizes, examples).
4. **Programs** — choose what to uninstall.
5. **Accounts and cloud** — work through the de-link checklist.
6. **Clean** — you perform each approved removal, with WipeWise's guidance.
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

> On claude.ai (web) the skill can only give **guidance** — it has no access to your disks. Scanning and cleanup need a local environment (Claude Code or the desktop Code tab) with Windows PowerShell 5.1+.

## Roadmap

- **v0.1 — Audit and guidance** (read-only) — you are here
- **v0.2 — Reset** — staged, confirmed deletion with a verification report
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
