# Standards — when a personal-data reset is enough, and when it is not

Plain-language summary of the sanitization standards, so Claude can set honest expectations. Primary sources are listed at the end.

## The three levels (NIST SP 800-88 Rev. 2, final Sept 2025)

- **Clear** — overwrite or reset through the normal read/write interface. Stops ordinary recovery. On SSDs it cannot reach spare/over-provisioned cells.
- **Purge** — use the drive's own firmware sanitize command (NVMe Sanitize / Format, ATA Sanitize / Secure Erase) or cryptographic erase. Reaches the whole device, including spare cells. This is what "the data cannot practically be recovered" means.
- **Destroy** — physically destroy the media (shred, incinerate). For the most sensitive data leaving your control.

Rev. 2 points to **IEEE 2883-2022** for the exact command per media type, says a single overwrite pass is enough for Clear (multi-pass is unnecessary on modern drives), and prefers whole-device sanitization. There is no such thing as a "NIST-certified" tool; the correct phrase is "aligned with NIST SP 800-88 r2".

## Where WipeWise v0.1 sits

A **personal-data reset removes data through the normal interface** — it is a targeted Clear of the current user's data and traces, not a device-wide Purge. That is the right level for:
- handing a PC to family or a trusted person,
- a device with nothing highly sensitive on it,
- a quick privacy clean you are keeping the PC after.

For **selling to a stranger, returning under warranty, or disposing of a device that held sensitive data**, the correct level is **Purge of the whole drive**, which requires the drive's firmware sanitize — usually from boot media, and outside the scope of a skill that runs inside Windows. That is the planned **Maximum mode**. Until then, WipeWise should say so and point the user to a bootable purge tool if they need that assurance.

## Why "selling to a stranger" needs Purge
Rev. 2's decision flow: media leaving your control should be **Purged** at minimum (and highly sensitive media destroyed). A within-Windows clean cannot sanitize the system disk it is running from, and cannot reach an SSD's spare cells. So for resale assurance, frame the honest answer: a personal-data reset greatly reduces risk, but only a firmware Purge (or full-disk encryption used from first use, then key destruction) gives the standards-level guarantee.

## Compliance note (businesses)
- **Turkey — KVKK:** the deletion/destruction regulation requires logging each destruction and keeping the record at least 3 years, and names a destruction policy and periodic destruction. A personal-data reset of one account is not, by itself, a business's destruction process.
- **EU — GDPR Art. 17** (erasure) and **ISO/IEC 27001:2022 A.7.14 / A.8.10** (secure disposal / information deletion) expect evidence of deletion. A signed erasure certificate — part of the future Maximum mode — is what satisfies this; v0.1 does not produce one.

## Primary sources
- NIST SP 800-88 Rev. 2: https://csrc.nist.gov/pubs/sp/800/88/r2/final — FAQ: https://csrc.nist.gov/files/pubs/sp/800/88/r2/final/docs/sp800-88r2-faq.pdf
- IEEE 2883-2022: https://standards.ieee.org/ieee/2883/10277/
- Windows "Reset this PC" behavior: https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/how-push-button-reset-features-work
- KVKK deletion regulation: https://www.kvkk.gov.tr/Icerik/5441/KISISEL-VERILERIN-SILINMESI-YOK-EDILMESI-VEYA-ANONIM-HALE-GETIRILMESI-HAKKINDA-YONETMELIK
