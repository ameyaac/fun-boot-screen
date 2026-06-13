# Fun Boot Screen

Co-authored by ChatGPT-5.2 (initially) and then Claude Sonet 4.6 (Thinking)

# Daily Command Center

A cinematic PowerShell boot sequence for your Windows machine — real hardware telemetry, dev environment checks, motivational chaos, and animated progress bars. Runs automatically on startup and dismisses with a keypress.

---

## What It Does

Every time your machine boots and you log in, a full-screen terminal sequence fires:

- **Fake fullscreen loader** — 15-stage animated boot bar with progress, log lines, and elapsed time
- **Hardware scan** — fake scrolling hex/register output for atmosphere
- **Chaos warmup** — 10 random phrases from a pool of 90+, with random event callouts and status pulses
- **System alignment** — loader sequence with randomized `[OK]`, `[WARN]`, and `[ERR->OK]` responses
- **Network probe** — pings localhost, GitHub, npm, and the void
- **Dev environment check** — verifies node, git, VS Code, docker, and a few fictional ones (`motivation.dll`, `work-life-balance.exe`)
- **Existential check-in** — daily mission, motivational quote, dev horoscope, and a random omen
- **System snapshot** — real live data from your machine (see below)

All text types out character-by-character with human-like hesitation, punctuation pauses, and micro-delays.

---

## System Snapshot: Real Data Collected

The snapshot collects everything in a single pass for performance, then displays it across sections:

### Hardware

| Section  | Fields                                                                                                                              |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Overview | Manufacturer, model, CPU name, architecture, cores/threads, max clock, current load, socket, stepping                               |
| Memory   | Total/used GB, stick count, per-stick: capacity, speed, manufacturer, part number, slot label                                       |
| GPU      | Name, driver version, VRAM, current resolution, refresh rate, color depth                                                           |
| Storage  | Physical disks: model, media type, size — Logical drives: free/total GB, usage %                                                    |
| Network  | Active adapters: name, MAC address, link speed                                                                                      |
| Misc     | Motherboard, BIOS version + date, battery status (laptops), monitor count, audio devices, USB controllers, optical drives, printers |

### Session

| Section  | Fields                                                                                                                              |
| -------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Identity | Username, machine name, domain                                                                                                      |
| OS       | Caption, architecture, build number, version, locale, last boot timestamp                                                           |
| Runtime  | PowerShell version, .NET CLR version, timezone                                                                                      |
| Activity | Process count, services running/stopped, driver count, startup app count, installed hotfixes, PATH entry count, installed app count |

### Software Versions (auto-detected)

Probes these tools if present: `git`, `node`, `npm`, `yarn`, `pnpm`, `python`, `python3`, `pip`, `java`, `go`, `rustc`, `code`, `docker`, `kubectl`, `az`, `gh`

### Dev Vitals (fake — entertainment only)

Animated bars for: CPU load (real), memory pressure (real), disk usage (real), dev coherence, caffeine level, focus score, bug density, tech debt index, git anxiety, yak-shaving risk.

### Extreme Events (clearly labeled jokes)

~18% chance of a `** JOKE ALERT **` extreme event appearing after the vitals — things like "quantum raccoons detected in the cooling system" and "keyboard achieved sentience and requested equity." Impossible in real hardware, labeled clearly as jokes.

---

## Requirements

- Windows 10 or 11
- PowerShell 5.1+ (built-in) or PowerShell 7+
- No external modules required
- AC power (by design — see Setup)

---

## Setup

### Step 1 — Save the script

Save `daily-command-center.ps1` somewhere permanent, for example:

```
C:\Users\YourName\Scripts\daily-command-center.ps1
```

### Step 2 — Add the boot guard to the top of the script

Paste this block at the very top of the file, before everything else. It enforces three conditions before the sequence runs:

```powershell
# ── BOOT GUARD ──────────────────────────────────────────────

# 1. Only run within 10 minutes of a fresh boot (blocks sleep/lock/resume)
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
if ($uptime.TotalMinutes -gt 10) { exit }

# 2. Only run on AC power — skipped automatically on desktops (no battery)
$battery = Get-CimInstance Win32_Battery | Select-Object -First 1
if ($battery -and $battery.BatteryStatus -ne 2) { exit }

# 3. Skip gate — press S within 3 seconds to exit cleanly
Write-Host ""
Write-Host "  starting in 3s...  [S] to skip." -ForegroundColor DarkGray
Write-Host ""
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt 3) {
    if ([Console]::KeyAvailable) {
        $k = [Console]::ReadKey($true)
        if ($k.KeyChar -in 's','S') { exit }
        break
    }
    Start-Sleep -Milliseconds 60
}

# ────────────────────────────────────────────────────────────
```

### Step 3 — Add the exit gate to the bottom of the script

Paste this after the final `BootSequence` call so it waits for you to dismiss the window:

```powershell
Write-Host ""
Write-Host "  [ press any key to dismiss ]" -ForegroundColor DarkGray
Write-Host ""
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit
```

### Step 4 — Set up Task Scheduler

Open **Task Scheduler** and create a new task with these settings:

**General tab**

- Name: `DailyCommandCenter`
- Run only when user is logged on
- Do NOT check "Run with highest privileges" unless your script needs admin access

**Triggers tab**

- Begin the task: `At log on`
- Specific user: your Windows account
- Delay: `10 seconds` (gives the desktop time to settle first)
- ✅ Enabled

**Actions tab**

- Program: `powershell.exe`
- Arguments:
  ```
  -ExecutionPolicy Bypass -NoProfile -WindowStyle Normal -File "C:\Users\YourName\Scripts\daily-command-center.ps1"
  ```
- Replace the path with your actual script location

**Conditions tab**

- ✅ Start the task only if the computer is on AC power
- ☐ Stop if the computer switches to battery power — your choice
- ☐ Wake the computer to run this task — leave OFF

**Settings tab**

- ✅ Allow task to be run on demand (lets you test it manually)
- ☐ Run task as soon as possible after a scheduled start is missed — leave OFF (prevents it firing on sleep resume)
- If the task is already running: `Do not start a new instance`

### Step 5 — Set execution policy (if needed)

If PowerShell blocks the script, run this once in an admin terminal:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## Skipping It

| Method                 | How                                                |
| ---------------------- | -------------------------------------------------- |
| **On the day**         | Press `S` within 3 seconds of the window appearing |
| **Mid-run**            | `Ctrl+C` — always works                            |
| **Close the window**   | `Alt+F4` or click X                                |
| **On battery**         | Exits silently before anything shows (by design)   |
| **After sleep/resume** | Exits silently — uptime check blocks it            |

---

## Customization

All content pools are plain PowerShell arrays at the top of the script — easy to edit:

| Variable            | What it controls                       |
| ------------------- | -------------------------------------- |
| `$Phrases`          | ~90 chaos loader phrases during warmup |
| `$OkMessages`       | 17 `[OK]` variants after each loader   |
| `$WarningMessages`  | Occasional `[WARN]` messages           |
| `$ErrorRecoveries`  | Rare `[ERR->OK]` dramatic recoveries   |
| `$Quotes`           | Motivational reminders                 |
| `$Horoscopes`       | Dev horoscopes                         |
| `$Missions`         | Daily missions                         |
| `$FunEvents`        | Random event callouts during warmup    |
| `$FunStatuses`      | Status pulses between phases           |
| `$ExtremeFunEvents` | Clearly-labeled joke extreme events    |

**Timing** is controlled by the `TypeLine` function's `$minDelay`/`$maxDelay` parameters (in milliseconds) and the `Pause` calls between sections. Lower values = faster boot experience.

**Uptime window** — the `10` in the boot guard (`TotalMinutes -gt 10`) can be adjusted. `5` is tighter, `15` is safer for slow machines.

---

## How It Works

```
FakeFullscreen        → 15-stage animated loader, no real data
BootSequence
  └── Phase 1         → fake hardware scan (visual only)
  └── Phase 2         → chaos phrases + random events
  └── Phase 3         → system alignment loaders
  └── Phase 4         → network probe
  └── Phase 5         → dev environment check
  └── Phase 6         → existential check-in
  └── Phase 7         → Snapshot()
        └── CollectSystemData()   ← all CIM/WMI calls happen once here
        └── display sections      ← reads from cached data, no re-queries
```

`CollectSystemData` batches all Windows Management Instrumentation queries into one pass, so the snapshot display itself is fast regardless of how many fields are shown.

---

## Troubleshooting

**Script doesn't run on startup**

- Verify the Task Scheduler action path matches where you saved the script
- Check that "Run only when user is logged on" is selected (not SYSTEM)
- Make sure the machine is on AC power if the condition is ticked
- Run the task manually from Task Scheduler to test

**Colors don't show / looks broken**

- Use Windows Terminal or PowerShell 7 for best rendering
- Legacy `cmd.exe` does not support ANSI colors

**Snapshot is slow**

- `Win32_PnPSignedDriver` (driver count) can be slow on some systems — remove that line from `CollectSystemData` if you want to speed up the snapshot

**Runs after sleep/resume**

- Reduce the uptime threshold from `10` to `5` minutes in the boot guard

**"Execution of scripts is disabled"**

- Run `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser` in an admin PowerShell window once
