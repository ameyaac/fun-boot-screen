# Only run on a fresh boot, not sleep/lock resume
$uptime = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
if ($uptime.TotalMinutes -gt 5) { exit }

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Clear-Host

Write-Host ""
Write-Host "  starting in 3 seconds...  press [S] to skip." -ForegroundColor DarkGray
Write-Host ""
$sw = [System.Diagnostics.Stopwatch]::StartNew()
while ($sw.Elapsed.TotalSeconds -lt 3) {
  if ([Console]::KeyAvailable) {
    $k = [Console]::ReadKey($true)
    if ($k.KeyChar -in 's', 'S') { exit }
    break
  }
  Start-Sleep -Milliseconds 60
}

$key = $null
$sw = [System.Diagnostics.Stopwatch]::StartNew()

while ($sw.Elapsed.TotalSeconds -lt 4) {
  if ([Console]::KeyAvailable) {
    $key = [Console]::ReadKey($true)
    break
  }
  Start-Sleep -Milliseconds 80
}

if ($key -and $key.KeyChar -in @('s', 'S')) {
  Write-Host "  skipped. have a quiet one." -ForegroundColor DarkGray
  Write-Host ""
  return   # exits the script, stays in the shell
}
# ────────────────────────────────────────────────────────

# =========================
# GLOBAL CONFIG
# =========================

$Host.UI.RawUI.WindowTitle = "DAILY COMMAND CENTER :: PERSONAL DEV NODE v3.0"
$script:StartTime = Get-Date

# =========================
# UTILITY: PAUSE
# =========================

function Pause {
  param([int]$min = 180, [int]$max = 420)
  Start-Sleep -Milliseconds (Get-Random -Minimum $min -Maximum $max)
}

# =========================
# UTILITY: PICK RANDOM
# =========================

function Pick {
  param($list)
  return $list | Get-Random
}

# =========================
# CHAOS PHRASES
# =========================

$Phrases = @(
  "booting local dev brain subsystem (unstable but functional)",
  "reviving yesterday's bugs... they are awake again",
  "hydrating javascript runtime with questionable decisions",
  "reconstructing broken promises in package-lock.json",
  "syncing unfinished thoughts across git branches",
  "loading emotionally unstable build pipeline",
  "warming node_modules dependency jungle",
  "patching reality mismatch in localhost environment",
  "importing chaos module: dev.mode = TRUE",
  "debugging existential recursion in dev brain",
  "compiling side-projects that were never finished",
  "indexing abandoned ideas from midnight commits",
  "starting localhost imagination engine",
  "aligning asynchronous thoughts with caffeine",
  "convincing npm that everything is fine",
  "negotiating with the garbage collector",
  "rehydrating stale coffee-driven architecture",
  "resolving merge conflicts in personal life",
  "pretending the tech debt is totally manageable",
  "overriding imposter syndrome with sudo confidence",
  "defragmenting scattered attention span",
  "mounting read-write access to motivation drive",
  "checking for updates to personal roadmap",
  "spawning background process: creative_mode.exe",
  "injecting dopamine mock into reward system",
  "scanning for unclosed browser tabs (316 found)",
  "suppressing low priority anxiety threads",
  "rebooting decision engine after yesterday's choices",
  "loading yesterday's unread Slack messages (skipping)",
  "initializing deep work firewall",
  "shaking dust off half-finished weekend project",
  "recovering lost genius from browser cache",
  "reconnecting with the one good idea from 2:13 AM",
  "auditing suspicious confidence levels in current code",
  "rerouting panic through humor middleware",
  "opening forbidden folder: final_final_v2_REAL",
  "restoring faith in semicolons",
  "decompressing compressed deadlines",
  "asking webpack to calm down",
  "replaying phantom bugs for dramatic effect",
  "summoning courage to rename poorly named variables",
  "rediscovering why the app broke after one tiny change",
  "opening 14 tabs to solve 1 problem",
  "cross-compiling ambition into realistic goals",
  "checking if the bug is somehow CSS again",
  "rebuilding confidence from green test results",
  "teaching the terminal to respect your feelings",
  "untangling spaghetti logic with ceremonial focus",
  "polishing rough edges nobody asked you to polish",
  "backing up fragile optimism to cloud storage",
  "verifying that vibes are still deployable",
  "reanimating the side quest that became the main quest",
  "looking directly at the backlog (brave)",
  "capturing fleeting productivity before it escapes",
  "reheating old ideas in the microwave of destiny",
  "calibrating keyboard clacks for maximum output",
  "synchronizing brain lag with monitor refresh rate",
  "detecting dangerous levels of overengineering",
  "poking production with a very long stick",
  "greasing the gears of improbable progress",
  "translating vague ambition into commit history",
  "unpacking emotional baggage from previous sprint",
  "refilling patience buffer",
  "loading emergency memes into runtime memory",
  "mapping unknown regions of the codebase",
  "searching recursively for the source of nonsense",
  "optimizing tab-switch throughput",
  "reconnecting broken flow state tunnel",
  "sharpening problem-solving instincts with coffee vapor",
  "spinning up a temporary genius container",
  "tuning debugger for dramatic reveals",
  "convincing legacy code to cooperate one more day",
  "reading error messages this time for real",
  "converting panic into structured logging",
  "patching tiny hole in motivation hull",
  "enabling premium deluxe focus mode",
  "running static analysis on today's life choices",
  "checking if the fix broke the fix for the previous fix",
  "praying softly to the package manager gods",
  "loosening tightly coupled bad decisions",
  "stitching together confidence from stack traces",
  "warming up the typo detection instincts",
  "checking whether the issue is between keyboard and chair",
  "rebuilding dev morale from cached compliments",
  "authenticating with the caffeine provider",
  "simulating control over the situation",
  "importing calm from external universe",
  "generating fresh excuses for unfinished refactor",
  "preheating ambition to production temperature",
  "sweeping mystery warnings under elegant rugs",
  "handshaking with chaos over mutually assured productivity",
  "reordering priorities like browser tabs during panic",
  "testing whether hope is a valid dependency",
  "re-linking disconnected fragments of brilliance",
  "decoding cryptic intentions of past-you",
  "smoothing runtime turbulence with optimism",
  "rebooting inner monologue with fewer error tones"
)

$OkMessages = @(
  "[OK] ... probably",
  "[OK] (fingers crossed)",
  "[OK] do not look too closely",
  "[OK] sure, let's go with that",
  "[OK] close enough",
  "[OK] by a miracle",
  "[OK]",
  "[OK] we believe in you",
  "[OK] technically speaking",
  "[OK] vibes check passed",
  "[OK] good enough for government work",
  "[OK] lgtm (no review done)",
  "[OK] shipped it",
  "[OK] works on my machine",
  "[OK] no one will notice",
  "[OK] (please hold)",
  "[OK] allegedly"
)

$WarningMessages = @(
  "[WARN] something smells off but continuing",
  "[WARN] ignored gracefully",
  "[WARN] filed under: future me's problem",
  "[WARN] suppressed with extreme prejudice",
  "[WARN] that's... fine. that's totally fine.",
  "[WARN] known issue. will fix. eventually."
)

$ErrorRecoveries = @(
  "[ERR->OK] recovered via sheer willpower",
  "[ERR->OK] exception swallowed whole",
  "[ERR->OK] stack trace composted",
  "[ERR->OK] vigorously ignored"
)

# =========================
# MOTIVATIONAL QUOTES
# =========================

$Quotes = @(
  "you are NOT behind. you are on your own timeline.",
  "the best code is the code you actually ship.",
  "today's good enough beats tomorrow's perfect.",
  "naps are a valid part of the dev workflow.",
  "chaos is just an undocumented feature.",
  "your past self would be proud of where you are now.",
  "done is better than perfect. ship it.",
  "every senior dev was once a confused junior dev.",
  "the bugs you fixed today were written by a past you who was trying.",
  "rest is not a reward. it is part of the process.",
  "clarity comes from action, not from more planning.",
  "small commits, shipped often. that is the way.",
  "the imposter syndrome is loudest right before a breakthrough.",
  "one focused hour beats six distracted ones."
)

# =========================
# DEV HOROSCOPE
# =========================

$Horoscopes = @(
  "your variables are well-named today. the compiler smiles upon you.",
  "a mysterious bug will appear at 4:52 PM. it will be a missing semicolon.",
  "today is not the day to refactor. tomorrow is also not the day.",
  "stack overflow will have the exact answer you need, from 2013.",
  "someone will ask if it is 'almost done'. it is not almost done.",
  "you will write your best code 20 minutes after deciding to quit for the day.",
  "a dependency will deprecate itself out of spite.",
  "git blame will reveal that you wrote the broken code. in 2022. with confidence.",
  "the documentation lies. trust only the source code.",
  "today you will understand recursion. then forget. then understand again.",
  "your rubber duck debugging session will be unexpectedly emotional.",
  "the meeting that could have been an email will be rescheduled."
)

# =========================
# DAILY MISSIONS
# =========================

$Missions = @(
  "finish one thing you have been avoiding all week",
  "delete dead code without fear",
  "write one useful comment in your codebase",
  "close 10 browser tabs before opening new ones",
  "commit something, anything, before noon",
  "take a real lunch break away from the screen",
  "review something you wrote last month without cringing (try)",
  "say no to one low-value task today",
  "drink water at regular intervals like a person",
  "ship the imperfect thing instead of perfecting the unshipped thing"
)



$FunEvents = @(
  "a wild typo has appeared",
  "someone somewhere just said 'it works on my machine'",
  "rubber duck debugging has entered the chat",
  "build pipeline is feeling dramatic today",
  "you suddenly remember an unfinished side project",
  "the terminal is judging you silently",
  "another tab has been opened with no clear purpose",
  "your focus briefly reaches legendary status",
  "a bug fixes itself out of pure confusion",
  "git is preparing a character-building exercise",
  "one missing comma is about to waste 17 minutes",
  "you are one snack away from a breakthrough",
  "the codebase has chosen mischief",
  "your debugger smells fear",
  "the laptop fan is now emotionally invested",
  "a highly unnecessary refactor is whispering your name",
  "one function is pretending to be 6 functions",
  "the commit history is becoming performance art",
  "productivity has been spotted in the distance",
  "there is a non-zero chance the CSS is haunted"
)

$FunStatuses = @(
  "cosmic alignment stable",
  "gremlin activity nominal",
  "vibe engine synchronized",
  "chaos budget approved",
  "snack reserves acceptable",
  "debug aura detected",
  "coffee resonance high",
  "creative overclock active",
  "mild wizardry online",
  "suspicious confidence building"
)

$ExtremeFunEvents = @(
  "EXTREME MODE :: ALERT :: quantum raccoons detected in the cooling system (definitely fake)",
  "EXTREME MODE :: WARNING :: moonlight overclock engaged to 9000 GHz (obviously not real)",
  "EXTREME MODE :: INCIDENT :: refrigerator API returned 418 teapot (pure nonsense)",
  "EXTREME MODE :: CRITICAL :: keyboard achieved sentience and requested equity (joke)",
  "EXTREME MODE :: PANIC :: gpu preparing for interdimensional ray tracing (not a real thing)",
  "EXTREME MODE :: SECURITY :: toaster attempted ssh login from the kitchen (completely fake)",
  "EXTREME MODE :: TELEMETRY :: cpu core escaped into astral plane (impossible)",
  "EXTREME MODE :: EMERGENCY :: npm dependency now legally classified as ancient evil (fiction)",
  "EXTREME MODE :: ALERT :: thermal paste has become self-aware (absolutely fake)",
  "EXTREME MODE :: STATUS :: caffeine levels exceeded safe orbital velocity (cartoon logic)",
  "EXTREME MODE :: WARNING :: codebase achieved consciousness and is disappointed (not real)",
  "EXTREME MODE :: ERROR :: local host promoted itself to regional emperor (ridiculous joke)",
  "EXTREME MODE :: INCIDENT :: ram modules unionized for better airflow (fake)",
  "EXTREME MODE :: ALERT :: git branch merged with alternate timeline (science fiction)",
  "EXTREME MODE :: REDLINE :: compiler started speaking in prophecies (100 percent fake)"
)

function SafeValue {
  param($value, $fallback = "unknown")
  if ($null -eq $value) { return $fallback }
  $s = [string]$value
  if ([string]::IsNullOrWhiteSpace($s)) { return $fallback }
  return $s.Trim()
}

function Format-GB {
  param($bytes)
  if ($null -eq $bytes) { return "unknown" }
  return ([math]::Round($bytes / 1GB, 2)).ToString() + " GB"
}

function Format-MB {
  param($bytes)
  if ($null -eq $bytes) { return "unknown" }
  return ([math]::Round($bytes / 1MB, 2)).ToString() + " MB"
}

function WriteKeyValue {
  param(
    [string]$key,
    [string]$value,
    [System.ConsoleColor]$color = [System.ConsoleColor]::White
  )
  Write-Host ("  " + $key.PadRight(18) + ": ") -NoNewline
  Write-Host $value -ForegroundColor $color
}

# =========================
# TYPE EFFECT (SLOW + HUMAN)
# =========================

function TypeLine {
  param(
    [string]$text,
    [int]$minDelay = 30,
    [int]$maxDelay = 85,
    [System.ConsoleColor]$color = [System.ConsoleColor]::White
  )

  $hostColor = $Host.UI.RawUI.ForegroundColor
  $Host.UI.RawUI.ForegroundColor = $color

  foreach ($c in $text.ToCharArray()) {
    Write-Host -NoNewline $c
    Start-Sleep -Milliseconds (Get-Random -Minimum $minDelay -Maximum $maxDelay)

    # Random hesitation
    if ((Get-Random -Minimum 0 -Maximum 100) -lt 5) {
      Start-Sleep -Milliseconds (Get-Random -Minimum 90 -Maximum 280)
    }

    # Punctuation micro-pause
    if ($c -in @('.', ',', ':', ';', '(', ')', '!', '?')) {
      Start-Sleep -Milliseconds (Get-Random -Minimum 70 -Maximum 200)
    }
  }

  $Host.UI.RawUI.ForegroundColor = $hostColor
  Write-Host ""
}

# =========================
# SECTION HEADER
# =========================

function SectionHeader {
  param([string]$title, [string]$subtitle = "")
  Write-Host ""
  Write-Host ("  " + ("=" * 52)) -ForegroundColor DarkGray
  Write-Host ("  " + $title) -ForegroundColor Green
  if ($subtitle -ne "") {
    Write-Host ("  " + $subtitle) -ForegroundColor DarkGray
  }
  Write-Host ("  " + ("=" * 52)) -ForegroundColor DarkGray
  Write-Host ""
  Pause 200 400
}

# =========================
# LOADER (WITH PERSONALITY)
# =========================

function Loader {
  param(
    [string]$msg,
    [string]$type = "normal"
  )

  switch ($type) {
    "warn" { Write-Host " [LOAD] " -NoNewline -ForegroundColor Yellow }
    "error" { Write-Host " [LOAD] " -NoNewline -ForegroundColor Red }
    default { Write-Host " [LOAD] " -NoNewline -ForegroundColor Cyan }
  }

  TypeLine $msg 28 75 White

  Pause 350 800

  $roll = Get-Random -Minimum 0 -Maximum 100
  if ($roll -lt 70) {
    $okMsg = Pick $OkMessages
    Write-Host ("         " + $okMsg) -ForegroundColor Green
  }
  elseif ($roll -lt 88) {
    $warnMsg = Pick $WarningMessages
    Write-Host ("         " + $warnMsg) -ForegroundColor Yellow
  }
  else {
    $errMsg = Pick $ErrorRecoveries
    Write-Host ("         " + $errMsg) -ForegroundColor Red
    Pause 200 400
    Write-Host "         [RECOVERING...]" -ForegroundColor DarkGray
    Pause 400 800
  }

  Write-Host ""
  Pause 100 300
}

# =========================
# ANIMATED PROGRESS BAR
# =========================

function AnimatedBar {
  param(
    [string]$label,
    [int]$targetValue,
    [System.ConsoleColor]$barColor = [System.ConsoleColor]::Cyan
  )

  $width = 36
  $current = 0
  $step = [math]::Max(1, [math]::Round($targetValue / 14))
  $padded = $label.PadRight(26)

  while ($current -lt $targetValue) {
    $current = [math]::Min($current + $step + (Get-Random -Minimum 0 -Maximum ([math]::Max(1, $step))), $targetValue)
    $fill = [math]::Round(($current / 100) * $width)
    $empty = $width - $fill

    $filled = "=" * [math]::Max(0, ($fill - 1))
    $head = if ($current -lt $targetValue) { ">" } else { "=" }
    $spaces = "-" * $empty

    $barStr = $filled + $head + $spaces

    Write-Host -NoNewline ("`r  " + $padded + " [")
    Write-Host -NoNewline $barStr -ForegroundColor $barColor
    Write-Host -NoNewline ("] " + ("$current%").PadLeft(4) + "  ")

    Start-Sleep -Milliseconds (Get-Random -Minimum 35 -Maximum 110)
  }

  Write-Host ""
  Pause 80 180
}

# =========================
# COUNTDOWN TIMER (DRAMATIC)
# =========================

function Countdown {
  param([string]$label, [int]$seconds = 3)
  Write-Host ""
  for ($i = $seconds; $i -ge 1; $i--) {
    Write-Host -NoNewline ("`r  $label in $i...  ") -ForegroundColor DarkYellow
    Start-Sleep -Milliseconds 900
  }
  Write-Host -NoNewline "`r  $label NOW.       " -ForegroundColor Yellow
  Write-Host ""
  Pause 300 500
}

# =========================
# FAKE SCAN EFFECT
# =========================

function ScanEffect {
  param([string]$label, [int]$lines = 8)
  Write-Host "  $label" -ForegroundColor DarkGray
  for ($i = 0; $i -lt $lines; $i++) {
    $addr = "0x" + (Get-Random -Minimum 0x1000 -Maximum 0xFFFF).ToString("X4")
    $val = (Get-Random -Minimum 10 -Maximum 9999).ToString().PadLeft(6)
    $tag = Pick @("READ", "SCAN", "MAP", "LINK", "BIND", "INIT", "EXEC", "REG")
    Write-Host ("    " + $addr + "  " + $val + "  [" + $tag + "]") -ForegroundColor DarkGray
    Start-Sleep -Milliseconds (Get-Random -Minimum 60 -Maximum 160)
  }
  Write-Host ""
}

# =========================
# SYSTEM SNAPSHOT
# =========================

function Snapshot {
  SectionHeader "SYSTEM SNAPSHOT :: REAL DATA" "live telemetry from your actual machine"

  $cpuInfo = Get-CimInstance Win32_Processor | Select-Object -First 1
  $allCpuInfo = Get-CimInstance Win32_Processor
  $os = Get-CimInstance Win32_OperatingSystem
  $bios = Get-CimInstance Win32_BIOS | Select-Object -First 1
  $board = Get-CimInstance Win32_BaseBoard | Select-Object -First 1
  $cs = Get-CimInstance Win32_ComputerSystem | Select-Object -First 1
  $gpuList = @(Get-CimInstance Win32_VideoController)
  $ramSticks = @(Get-CimInstance Win32_PhysicalMemory)
  $disks = @(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3")
  $physicalDisks = @(Get-CimInstance Win32_DiskDrive)
  $netAdapters = @(Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.NetEnabled -eq $true })
  $soundDevices = @(Get-CimInstance Win32_SoundDevice)
  $usbControllers = @(Get-CimInstance Win32_USBController)
  $pnpsigned = @(Get-CimInstance Win32_PnPSignedDriver)
  $services = @(Get-Service)
  $hotfixes = @(Get-HotFix)
  $processes = @(Get-Process)
  $topProcCpu = $processes | Sort-Object CPU -Descending | Select-Object -First 5
  $topProcMem = $processes | Sort-Object WorkingSet64 -Descending | Select-Object -First 5
  $startupCmds = @(Get-CimInstance Win32_StartupCommand)
  $envPathCount = (($env:Path -split ';') | Where-Object { $_ -and $_.Trim() -ne '' }).Count

  $cpuLoad = [math]::Round(($allCpuInfo | Measure-Object -Property LoadPercentage -Average).Average)
  $uptime = (Get-Date) - $os.LastBootUpTime
  $uptimeStr = "{0}d {1}h {2}m" -f $uptime.Days, $uptime.Hours, $uptime.Minutes

  $totalGB = [math]::Round($os.TotalVisibleMemorySize / 1MB, 2)
  $freeGB = [math]::Round($os.FreePhysicalMemory / 1MB, 2)
  $usedGB = [math]::Round($totalGB - $freeGB, 2)
  $memPct = if ($totalGB -gt 0) { [math]::Round(($usedGB / $totalGB) * 100) } else { 0 }

  $diskLines = @()
  $diskUsagePercents = @()
  foreach ($d in $disks) {
    $size = if ($d.Size) { [math]::Round($d.Size / 1GB, 2) } else { 0 }
    $free = if ($d.FreeSpace) { [math]::Round($d.FreeSpace / 1GB, 2) } else { 0 }
    $usedPct = if ($size -gt 0) { [math]::Round((($size - $free) / $size) * 100) } else { 0 }
    $diskUsagePercents += $usedPct
    $diskLines += ("{0}  {1} free / {2} total  [{3}% used]" -f $d.DeviceID, $free, $size, $usedPct)
  }
  $avgDiskUsage = if ($diskUsagePercents.Count -gt 0) { [math]::Round(($diskUsagePercents | Measure-Object -Average).Average) } else { 0 }

  $installedAppCount = 0
  $appPaths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  foreach ($path in $appPaths) {
    try {
      $installedAppCount += @(Get-ItemProperty $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }).Count
    }
    catch {}
  }

  $realSoftware = [ordered]@{
    "PowerShell" = SafeValue($PSVersionTable.PSVersion.ToString())
    ".NET CLR"   = SafeValue([System.Environment]::Version.ToString())
    "OS Build"   = SafeValue($os.BuildNumber)
    "OS Version" = SafeValue($os.Version)
    "BIOS Ver"   = SafeValue($bios.SMBIOSBIOSVersion)
  }

  foreach ($cmd in @('git', 'node', 'npm', 'python', 'python3', 'code', 'java', 'docker')) {
    try {
      $version = & $cmd --version 2>$null | Select-Object -First 1
      if ($version) { $realSoftware[$cmd] = SafeValue($version) }
    }
    catch {}
  }

  $devCoherence = Get-Random -Minimum 55 -Maximum 99
  $caffeineLevel = Get-Random -Minimum 60 -Maximum 100
  $bugDensity = Get-Random -Minimum 20 -Maximum 85
  $focusScore = Get-Random -Minimum 40 -Maximum 95
  $techDebt = Get-Random -Minimum 50 -Maximum 100

  Write-Host "  HARDWARE" -ForegroundColor DarkGray
  WriteKeyValue "Manufacturer" (SafeValue $cs.Manufacturer) Cyan
  WriteKeyValue "Model"        (SafeValue $cs.Model) Cyan
  WriteKeyValue "CPU"          (SafeValue $cpuInfo.Name) White
  WriteKeyValue "CPU Cores"    ((SafeValue $cpuInfo.NumberOfCores) + " cores / " + (SafeValue $cpuInfo.NumberOfLogicalProcessors) + " logical") Yellow
  WriteKeyValue "CPU MaxClock" ((SafeValue $cpuInfo.MaxClockSpeed) + " MHz") Yellow
  WriteKeyValue "CPU Load"     ($cpuLoad.ToString() + " %") Yellow
  WriteKeyValue "Memory"       ($usedGB.ToString() + " GB used / " + $totalGB.ToString() + " GB total") Yellow
  WriteKeyValue "Memory Sticks"($ramSticks.Count.ToString()) Yellow
  WriteKeyValue "Motherboard"  ((SafeValue $board.Manufacturer) + " / " + (SafeValue $board.Product)) White
  WriteKeyValue "BIOS"         ((SafeValue $bios.Manufacturer) + " / " + (SafeValue $bios.SMBIOSBIOSVersion)) White
  WriteKeyValue "Uptime"       $uptimeStr Cyan
  WriteKeyValue "Physical Disks"($physicalDisks.Count.ToString()) White
  WriteKeyValue "GPUs"         ($gpuList.Count.ToString()) White
  WriteKeyValue "Audio Devices"($soundDevices.Count.ToString()) White
  WriteKeyValue "USB Controllers"($usbControllers.Count.ToString()) White
  Write-Host ""

  if ($gpuList.Count -gt 0) {
    Write-Host "  GPU DETAILS" -ForegroundColor DarkGray
    foreach ($gpu in $gpuList | Select-Object -First 4) {
      WriteKeyValue "Adapter" (SafeValue $gpu.Name) Green
      WriteKeyValue "Driver"  (SafeValue $gpu.DriverVersion) DarkGray
      WriteKeyValue "RAM"     (Format-GB $gpu.AdapterRAM) DarkGray
      Write-Host ""
    }
  }

  if ($ramSticks.Count -gt 0) {
    Write-Host "  MEMORY STICKS" -ForegroundColor DarkGray
    foreach ($stick in $ramSticks | Select-Object -First 6) {
      $cap = if ($stick.Capacity) { [math]::Round($stick.Capacity / 1GB, 2) } else { "unknown" }
      $spd = SafeValue $stick.Speed
      $mfr = SafeValue $stick.Manufacturer
      $part = SafeValue $stick.PartNumber
      WriteKeyValue "Stick" ($cap.ToString() + " GB @ " + $spd + " MHz :: " + $mfr + " :: " + $part) DarkCyan
    }
    Write-Host ""
  }

  if ($diskLines.Count -gt 0) {
    Write-Host "  STORAGE" -ForegroundColor DarkGray
    foreach ($line in $diskLines) {
      Write-Host ("  - " + $line) -ForegroundColor White
    }
    Write-Host ""
  }

  if ($netAdapters.Count -gt 0) {
    Write-Host "  NETWORK" -ForegroundColor DarkGray
    foreach ($na in $netAdapters | Select-Object -First 6) {
      $speed = if ($na.Speed) { [math]::Round($na.Speed / 1MB, 2).ToString() + " Mbps" } else { "unknown" }
      WriteKeyValue "Adapter" (SafeValue $na.Name) White
      WriteKeyValue "MAC"     (SafeValue $na.MACAddress) DarkGray
      WriteKeyValue "Speed"   $speed DarkGray
      Write-Host ""
    }
  }

  Write-Host "  SESSION" -ForegroundColor DarkGray
  WriteKeyValue "User"        (SafeValue $env:USERNAME) White
  WriteKeyValue "Machine"     (SafeValue $env:COMPUTERNAME) White
  WriteKeyValue "OS"          (SafeValue $os.Caption) White
  WriteKeyValue "OS Arch"     (SafeValue $os.OSArchitecture) White
  WriteKeyValue "Boot Time"   ($script:StartTime.ToString("HH:mm:ss")) Cyan
  WriteKeyValue "Time Zone"   (SafeValue (Get-TimeZone).DisplayName) Cyan
  WriteKeyValue "Processes"   ($processes.Count.ToString()) White
  WriteKeyValue "Services"    ($services.Count.ToString()) White
  WriteKeyValue "Drivers"     ($pnpsigned.Count.ToString()) White
  WriteKeyValue "Startup Apps"($startupCmds.Count.ToString()) White
  WriteKeyValue "Hotfixes"    ($hotfixes.Count.ToString()) White
  WriteKeyValue "PATH Entries"($envPathCount.ToString()) White
  Write-Host ""

  Write-Host "  SOFTWARE" -ForegroundColor DarkGray
  foreach ($k in $realSoftware.Keys) {
    WriteKeyValue $k $realSoftware[$k] Green
  }
  WriteKeyValue "Installed Apps" ($installedAppCount.ToString()) Yellow
  Write-Host ""

  Write-Host "  TOP PROCESSES BY MEMORY" -ForegroundColor DarkGray
  foreach ($proc in $topProcMem) {
    $mem = [math]::Round($proc.WorkingSet64 / 1MB, 1)
    Write-Host (("  - " + $proc.ProcessName).PadRight(28) + ($mem.ToString() + " MB")) -ForegroundColor White
  }
  Write-Host ""

  Write-Host "  TOP PROCESSES BY CPU" -ForegroundColor DarkGray
  foreach ($proc in $topProcCpu) {
    $cpuVal = if ($proc.CPU) { [math]::Round($proc.CPU, 1) } else { 0 }
    Write-Host (("  - " + $proc.ProcessName).PadRight(28) + ($cpuVal.ToString() + " sec")) -ForegroundColor White
  }
  Write-Host ""

  $sanityLabel = switch ($true) {
    ($devCoherence -gt 85) { "HIGH  (suspicious)" }
    ($devCoherence -gt 70) { "MED   (realistic)" }
    ($devCoherence -gt 55) { "LOW   (relatable)" }
    default { "VOID  (send help)" }
  }
  $sanityColor = switch ($true) {
    ($devCoherence -gt 85) { "Green" }
    ($devCoherence -gt 70) { "Yellow" }
    default { "Red" }
  }

  Write-Host "  DEV VITALS" -ForegroundColor DarkGray
  Write-Host "  Sanity Level      : " -NoNewline
  Write-Host $sanityLabel -ForegroundColor $sanityColor
  Write-Host ""

  AnimatedBar "CPU load"             $cpuLoad       Cyan
  AnimatedBar "memory pressure"      $memPct        Cyan
  AnimatedBar "avg disk usage"       $avgDiskUsage  Cyan
  AnimatedBar "dev coherence"        $devCoherence  Green
  AnimatedBar "caffeine level"       $caffeineLevel Yellow
  AnimatedBar "focus score"          $focusScore    Green
  AnimatedBar "bug density"          $bugDensity    Red
  AnimatedBar "tech debt index"      $techDebt      Red

  if ((Get-Random -Minimum 0 -Maximum 100) -lt 18) {
    Write-Host ""
    Write-Host "  joke-only extreme event follows:" -ForegroundColor DarkGray
    Write-Host "  >> " -NoNewline -ForegroundColor DarkGray
    TypeLine (Pick $ExtremeFunEvents) 20 55 Red
  }

  Write-Host ""
  Write-Host "  [SNAPSHOT COMPLETE]" -ForegroundColor DarkGray
  Write-Host ""
  Pause 500 900
}
# =========================
# BOOT PHASES
# =========================

function BootSequence {
  Clear-Host

  SectionHeader "DAILY COMMAND CENTER :: BOOT SEQUENCE v3.0" (Get-Date -Format "dddd, MMMM dd yyyy  ::  HH:mm:ss")

  # --------------------------------------------------
  # PHASE 1 :: HARDWARE SCAN
  # --------------------------------------------------
  Write-Host "  PHASE 1 :: hardware scan" -ForegroundColor Magenta
  Write-Host ""
  ScanEffect "scanning memory banks..." 6
  ScanEffect "probing i/o subsystems..." 5
  Loader "hardware enumeration complete"
  Loader "bios handshake acknowledged"
  Loader "entropy pool seeded"

  Pause 300 600

  # --------------------------------------------------
  # PHASE 2 :: CHAOS WARMUP
  # --------------------------------------------------
  Write-Host "  PHASE 2 :: warming dev brain" -ForegroundColor Cyan
  Write-Host ""

  $phrasePool = $Phrases | Get-Random -Count ([math]::Min(10, $Phrases.Count))
  foreach ($phrase in $phrasePool) {
    Loader $phrase

    if ((Get-Random -Minimum 0 -Maximum 100) -lt 28) {
      if ((Get-Random -Minimum 0 -Maximum 100) -lt 82) {
        Write-Host "         ~ random event: " -NoNewline -ForegroundColor DarkGray
        TypeLine (Pick $FunEvents) 18 45 DarkYellow
      }
      else {
        Write-Host "         ~ absurd event: " -NoNewline -ForegroundColor DarkGray
        TypeLine (Pick $ExtremeFunEvents) 18 45 Red
      }
      Pause 120 260
    }
  }

  Write-Host "  status pulse :: " -NoNewline -ForegroundColor DarkGray
  TypeLine (Pick $FunStatuses) 20 50 Green
  Write-Host ""

  Pause 300 600

  # --------------------------------------------------
  # PHASE 3 :: SYSTEM ALIGNMENT
  # --------------------------------------------------
  Write-Host "  PHASE 3 :: system alignment" -ForegroundColor Cyan
  Write-Host ""

  Loader "cache warmed (some of it)"
  Loader "thread pool stabilized (loosely)"
  Loader "localhost handshake complete"
  Loader "git state: messy but alive"
  Loader "TODO list: acknowledged. ignored."
  Loader "node_modules: do not open. do not look inside."
  Loader "environment variables: mostly correct"
  Loader "dark mode: confirmed"

  Pause 300 600

  # --------------------------------------------------
  # PHASE 4 :: NETWORK PROBE
  # --------------------------------------------------
  Write-Host "  PHASE 4 :: network probe" -ForegroundColor Cyan
  Write-Host ""

  $netTargets = @("localhost", "127.0.0.1", "github.com", "npm registry", "the void")
  foreach ($target in $netTargets) {
    Write-Host "   pinging " -NoNewline -ForegroundColor DarkGray
    Write-Host $target -NoNewline -ForegroundColor White
    Write-Host "..." -NoNewline -ForegroundColor DarkGray
    Pause 400 900

    if ($target -eq "the void") {
      Write-Host "  [no response. as expected.]" -ForegroundColor DarkGray
    }
    else {
      $ping = Get-Random -Minimum 1 -Maximum 42
      $replyFlavor = Pick @(
        "reply received",
        "handshake accepted",
        "signal coherent",
        "response vaguely trustworthy",
        "connection appears emotionally stable"
      )
      Write-Host ("  " + $replyFlavor + " in " + $ping + "ms") -ForegroundColor Green
    }
    Pause 100 250
  }

  Write-Host ""
  Pause 300 600

  # --------------------------------------------------
  # PHASE 5 :: DEV ENVIRONMENT CHECK
  # --------------------------------------------------
  Write-Host "  PHASE 5 :: dev environment check" -ForegroundColor Cyan
  Write-Host ""

  $envChecks = @(
    @{ name = "node.js runtime"; status = "found"; version = "v20.x.x" },
    @{ name = "npm"; status = "found"; version = "10.x.x" },
    @{ name = "git"; status = "found"; version = "2.44.x" },
    @{ name = "VS Code"; status = "found"; version = "1.90.x" },
    @{ name = "docker daemon"; status = "warn"; version = "not running" },
    @{ name = "stale .env files"; status = "warn"; version = "3 found" },
    @{ name = "motivation.dll"; status = "warn"; version = "low battery" },
    @{ name = "work-life-balance.exe"; status = "error"; version = "process not found" }
  )

  foreach ($check in $envChecks) {
    Write-Host ("   " + $check.name.PadRight(26)) -NoNewline
    switch ($check.status) {
      "found" { Write-Host ("[OK]    " + $check.version) -ForegroundColor Green }
      "warn" { Write-Host ("[WARN]  " + $check.version) -ForegroundColor Yellow }
      "error" { Write-Host ("[FAIL]  " + $check.version) -ForegroundColor Red }
    }
    Pause 250 550
  }

  Write-Host ""
  Pause 400 700

  # --------------------------------------------------
  # PHASE 6 :: EXISTENTIAL CHECK-IN
  # --------------------------------------------------
  Write-Host "  PHASE 6 :: existential check-in" -ForegroundColor Cyan
  Write-Host ""

  Write-Host "  >> today's mission: " -NoNewline -ForegroundColor DarkGray
  TypeLine (Pick $Missions) 32 90 Yellow
  Write-Host ""
  Pause 300 600

  Write-Host "  >> daily reminder: " -NoNewline -ForegroundColor DarkGray
  TypeLine (Pick $Quotes) 32 90 White
  Write-Host ""
  Pause 300 600

  Write-Host "  >> dev horoscope:  " -NoNewline -ForegroundColor DarkGray
  TypeLine (Pick $Horoscopes) 32 90 Cyan
  Write-Host ""
  Pause 250 500

  if ((Get-Random -Minimum 0 -Maximum 100) -lt 84) {
    Write-Host "  >> random omen:    " -NoNewline -ForegroundColor DarkGray
    TypeLine (Pick $FunEvents) 28 75 DarkYellow
  }
  else {
    Write-Host "  >> absurd omen:    " -NoNewline -ForegroundColor DarkGray
    TypeLine (Pick $ExtremeFunEvents) 28 75 Red
  }
  Write-Host ""
  Pause 600 1000

  # --------------------------------------------------
  # PHASE 7 :: SNAPSHOT
  # --------------------------------------------------
  Write-Host "  PHASE 7 :: system snapshot" -ForegroundColor Cyan
  Write-Host ""
  Pause 300 600

  Snapshot
}

# =========================
# FAKE FULLSCREEN LOADER
# =========================

function FakeFullscreen {
  $stages = @(
    @{ pct = 3; msg = "POST check passed. barely."; log = "bios: v2.71.8" },
    @{ pct = 9; msg = "initializing dev node..."; log = "node id: 0xDEADBEEF" },
    @{ pct = 18; msg = "loading chaos modules..."; log = "entropy: high. good." },
    @{ pct = 26; msg = "mounting imagination drive..."; log = "inode: creative_mode" },
    @{ pct = 35; msg = "warming up coffee subsystem..."; log = "temp: 94 celsius" },
    @{ pct = 43; msg = "negotiating with dependencies..."; log = "npm: stubborn as usual" },
    @{ pct = 51; msg = "patching reality.exe..."; log = "patch 0019: applied" },
    @{ pct = 60; msg = "scanning for lost focus..."; log = "located: partially" },
    @{ pct = 67; msg = "syncing git branches with life choices..."; log = "conflicts: many" },
    @{ pct = 69; msg = "nice."; log = "continuing..." },
    @{ pct = 75; msg = "suppressing low priority anxiety threads..."; log = "3 suppressed, 2 rescheduled" },
    @{ pct = 82; msg = "reticulating splines..."; log = "spline integrity: nominal" },
    @{ pct = 89; msg = "ignoring deprecation warnings..."; log = "warnings: 47 (skipped)" },
    @{ pct = 95; msg = "final checks (skipping most of them)..."; log = "yolo: enabled" },
    @{ pct = 100; msg = "boot complete. you may begin suffering in style."; log = "status: ALIVE" }
  )

  foreach ($stage in $stages) {
    Clear-Host
    Write-Host ""
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host "  |  DAILY COMMAND CENTER                v3.0               |" -ForegroundColor Green
    Write-Host "  |  PERSONAL DEV NODE  ::  BOOT SEQUENCE                   |" -ForegroundColor DarkGray
    Write-Host "  +---------------------------------------------------------+" -ForegroundColor DarkGray
    Write-Host ""

    Write-Host ("  BOOT LOADING... " + "$($stage.pct)%".PadLeft(5)) -ForegroundColor Yellow
    Write-Host ""
    Write-Host ("  > " + $stage.msg) -ForegroundColor Cyan
    Write-Host ("    " + $stage.log) -ForegroundColor DarkGray
    Write-Host ""

    $fill = [math]::Round(($stage.pct / 100) * 52)
    $empty = 52 - $fill
    $bar = ("[") + ("=" * [math]::Max(0, ($fill - 1))) + (">") + (" " * [math]::Max(0, $empty - 1)) + ("]")
    if ($stage.pct -ge 100) { $bar = "[" + ("=" * 52) + "]" }
    Write-Host ("  " + $bar) -ForegroundColor Yellow
    Write-Host ""
    Write-Host ("  " + (Get-Date -Format "HH:mm:ss.fff") + "  ::  elapsed: " + ([math]::Round(((Get-Date) - $script:StartTime).TotalSeconds, 1)) + "s") -ForegroundColor DarkGray

    Pause 380 820
  }

  Pause 500 800
}

# =========================
# RUN
# =========================

FakeFullscreen
BootSequence
