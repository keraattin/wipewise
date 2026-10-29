# WipeWise (Claude skill)

**WipeWise** is a Claude Agent Skill that helps you prepare a Windows 10/11 PC
for a new owner. It finds the personal data and usage traces the current user
left behind, shows them to you **category by category**, and guides you through
removing them — while keeping Windows installed.

> **v0.1 is read-only and guidance-only.** The skill scans and reports; it never
> deletes, overwrites, formats, or changes anything. **You** confirm and perform
> each removal. Automated (confirmed, guarded) deletion and full-disk
> sanitization are planned for later versions.

## What it does

- Read-only scan of personal files, browser data, saved passwords and Wi-Fi
  keys, app/message data, activity history, Recall/Copilot, and system traces.
- A list of installed programs to sign out of and uninstall.
- An account, license and cloud **sign-out / de-link checklist** (with the
  ordering that prevents lockouts and accidental cloud deletion).
- Honest **limitations** and standards guidance (what a reset can and cannot
  guarantee; when you actually need a full-disk purge).

## Layout

```
wipewise/
  SKILL.md                         # the skill (instructions for Claude)
  scripts/Invoke-WipeWiseScan.ps1  # the only script — strictly read-only, outputs JSON
  references/
    trace-catalog.md               # every category: location, what it reveals, how to remove
    delink-checklist.md            # account / license / cloud sign-out steps
    limitations.md                 # honest limits ("is it really gone?")
    standards.md                   # NIST 800-88 r2 / IEEE 2883 in plain language
```

## Requirements

- Windows 10 (22H2+) or Windows 11.
- To scan, run it where Claude can execute PowerShell locally (Claude Code or the
  desktop Code tab). On surfaces without local shell access the skill is
  guidance-only.

## Safety and scope

WipeWise is privacy hygiene and handover preparation **for a device you own**.
It is not an anti-forensics tool: it will not spoof identifiers, forge or clear
logs to conceal activity, or disable security features. Use it only on a device
you are authorized to prepare. Work/school devices may be managed or under legal
hold — those go through your IT.

## License

Apache-2.0. See the forthcoming `LICENSE` file. No warranty: you are responsible
for verifying results before relying on them or handing over a device.
