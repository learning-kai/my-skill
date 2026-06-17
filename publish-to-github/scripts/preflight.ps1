param(
  [string]$RepoRoot = ".",
  [string]$ProjectName,
  [string]$SkillName,
  [ValidateSet("auto", "project", "skill")]
  [string]$Mode = "auto",
  [switch]$All
)

$ErrorActionPreference = "Stop"

function Section {
  param([string]$Name)
  Write-Host ""
  Write-Host "== $Name =="
}

function Warn {
  param([string]$Message)
  Write-Warning $Message
}

function Resolve-RepoRoot {
  param([string]$Path)
  try {
    return (Resolve-Path -LiteralPath $Path).Path
  } catch {
    throw "RepoRoot not found: $Path"
  }
}

function Get-GitLines {
  param([string[]]$Arguments)
  $output = & git @Arguments 2>&1
  if ($LASTEXITCODE -ne 0) {
    throw ($output -join [Environment]::NewLine)
  }
  return @($output)
}

function Get-StatusEntries {
  $lines = Get-GitLines @("status", "--porcelain=v1", "-z")
  $text = ($lines -join "")
  if ([string]::IsNullOrEmpty($text)) {
    return @()
  }

  $parts = $text -split "`0" | Where-Object { $_ -ne "" }
  $entries = @()
  foreach ($part in $parts) {
    if ($part.Length -lt 4) {
      continue
    }

    $entries += [pscustomobject]@{
      Status = $part.Substring(0, 2)
      Path = $part.Substring(3)
    }
  }
  return $entries
}

function Get-TopLevelName {
  param([string]$Path)
  $normalized = $Path -replace "\\", "/"
  return ($normalized -split "/")[0]
}

function Get-TargetNames {
  param(
    [object[]]$StatusEntries,
    [string]$RequestedProject,
    [string]$RequestedSkill,
    [bool]$IncludeAll
  )

  if ($RequestedProject) {
    return @($RequestedProject)
  }

  if ($RequestedSkill) {
    Warn "-SkillName is kept for compatibility. Prefer -ProjectName with -Mode skill."
    return @($RequestedSkill)
  }

  if (-not $IncludeAll) {
    Warn "Neither -ProjectName nor -All was provided. Inspecting changed top-level directories."
  }

  $names = New-Object System.Collections.Generic.HashSet[string]
  foreach ($entry in $StatusEntries) {
    $top = Get-TopLevelName $entry.Path
    if ([string]::IsNullOrWhiteSpace($top) -or $top.StartsWith(".")) {
      continue
    }

    [void]$names.Add($top)
  }

  return @($names | Sort-Object)
}

function Resolve-TargetPath {
  param(
    [string]$Repo,
    [string]$TargetName
  )

  if ([string]::IsNullOrWhiteSpace($TargetName) -or $TargetName -eq ".") {
    return $Repo
  }

  $candidate = Join-Path -Path $Repo -ChildPath $TargetName
  if (Test-Path -LiteralPath $candidate) {
    return (Resolve-Path -LiteralPath $candidate).Path
  }

  return $candidate
}

function Get-EffectiveMode {
  param(
    [string]$TargetPath,
    [string]$RequestedMode
  )

  if ($RequestedMode -ne "auto") {
    return $RequestedMode
  }

  if (Test-Path -LiteralPath (Join-Path $TargetPath "SKILL.md") -PathType Leaf) {
    return "skill"
  }

  return "project"
}

function Test-FilePresence {
  param(
    [string]$TargetPath,
    [string]$FileName,
    [string]$OkMessage,
    [string]$MissingMessage
  )

  $file = Join-Path $TargetPath $FileName
  if (Test-Path -LiteralPath $file -PathType Leaf) {
    Write-Host "[OK] $OkMessage"
    return $true
  }

  Warn $MissingMessage
  return $false
}

function Test-SkillFrontmatter {
  param([string]$TargetPath)

  $skillFile = Join-Path -Path $TargetPath -ChildPath "SKILL.md"
  if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
    Warn "SKILL.md is missing"
    return
  }

  $content = Get-Content -Raw -Encoding utf8 -LiteralPath $skillFile
  $match = [regex]::Match($content, "(?s)^---\r?\n(.*?)\r?\n---")
  if (-not $match.Success) {
    Warn "SKILL.md frontmatter is missing or malformed"
    return
  }

  $frontmatter = $match.Groups[1].Value
  $nameMatch = [regex]::Match($frontmatter, "(?m)^name:\s*[""']?([a-z0-9-]+)[""']?\s*$")
  $descriptionMatch = [regex]::Match($frontmatter, "(?m)^description:\s*(.+?)\s*$")

  if (-not $nameMatch.Success) {
    Warn "SKILL.md frontmatter name is missing or not kebab-case"
    return
  }

  if (-not $descriptionMatch.Success -or [string]::IsNullOrWhiteSpace($descriptionMatch.Groups[1].Value)) {
    Warn "SKILL.md frontmatter description is missing or empty"
    return
  }

  Write-Host "[OK] SKILL.md frontmatter: name=$($nameMatch.Groups[1].Value)"
}

function Test-License {
  param([string]$TargetPath)

  $licenseNames = @("LICENSE", "LICENSE.md", "LICENSE.txt")
  foreach ($name in $licenseNames) {
    if (Test-Path -LiteralPath (Join-Path $TargetPath $name) -PathType Leaf) {
      Write-Host "[OK] License file exists: $name"
      return
    }
  }

  Warn "License file is missing. Ask the user which license to use before publishing."
}

function Test-ReadmeReleaseSignals {
  param([string]$TargetPath)

  $readme = Join-Path $TargetPath "README.md"
  if (-not (Test-Path -LiteralPath $readme -PathType Leaf)) {
    return
  }

  $content = Get-Content -Raw -Encoding utf8 -LiteralPath $readme
  if ($content -match "img\.shields\.io/github/v/release|/releases/latest") {
    Write-Host "[OK] README.md has a release badge"
  } else {
    Warn "README.md is missing a GitHub release badge or latest-release link."
  }

  if ($content -match "curl\s+(-[A-Za-z0-9]+\s+)*https?://") {
    Write-Host "[OK] README.md has a curl install command"
  } else {
    Warn "README.md is missing a one-line curl install command."
  }

  if ($content -match "irm\s+https?://.+\|\s*iex") {
    Write-Host "[OK] README.md has a PowerShell install command"
  } else {
    Warn "README.md is missing a one-line PowerShell install command."
  }
}

function Test-ReadmeLanguageLinks {
  param([string]$TargetPath)

  $readme = Join-Path $TargetPath "README.md"
  $readmeZh = Join-Path $TargetPath "README.zh-CN.md"

  if ((-not (Test-Path -LiteralPath $readme -PathType Leaf)) -or
      (-not (Test-Path -LiteralPath $readmeZh -PathType Leaf))) {
    return
  }

  $content = Get-Content -Raw -Encoding utf8 -LiteralPath $readme
  $zhContent = Get-Content -Raw -Encoding utf8 -LiteralPath $readmeZh

  if ($content -match "\]\(README\.zh-CN\.md\)") {
    Write-Host "[OK] README.md links to README.zh-CN.md"
  } else {
    Warn "README.md is missing a visible link to README.zh-CN.md."
  }

  if ($zhContent -match "\]\(README\.md\)") {
    Write-Host "[OK] README.zh-CN.md links back to README.md"
  } else {
    Warn "README.zh-CN.md is missing a visible link back to README.md."
  }
}

function Test-ReadmeCoreSections {
  param([string]$TargetPath)

  $sectionChecks = @(
    @{ File = "README.md"; Labels = @("Quick Start", "Installation", "Usage", "Project Publishing", "Skill Publishing", "Troubleshooting", "License"); Name = "README.md" },
    @{ File = "README.zh-CN.md"; Labels = @("快速开始", "安装", "使用", "普通项目发布", "Skill 发布", "故障排查", "License"); Name = "README.zh-CN.md" }
  )

  foreach ($check in $sectionChecks) {
    $file = Join-Path $TargetPath $check.File
    if (-not (Test-Path -LiteralPath $file -PathType Leaf)) {
      continue
    }

    $content = Get-Content -Raw -Encoding utf8 -LiteralPath $file
    foreach ($label in $check.Labels) {
      $pattern = "(?m)^#{2,3}\s+$([regex]::Escape($label))(?:\s|$)"
      if ($content -match $pattern) {
        Write-Host "[OK] $($check.Name) has $label section"
      } else {
        Warn "$($check.Name) is missing a high-star README section: $label."
      }
    }
  }
}

function Test-Mojibake {
  param([string]$TargetPath)

  $badPatterns = @(
    [string][char]0x9225,
    [string][char]0x922E,
    [string][char]0x9239,
    [string][char]0x9242,
    [string][char]0x9241,
    [string][char]0x99C3,
    [string][char]0x6F0F,
    [string][char]0xFFFD
  )
  $excludedDirs = @(".git", "node_modules", "dist", "build", ".cache", "__pycache__", ".pytest_cache")
  $files = Get-ChildItem -LiteralPath $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
      $path = $_.FullName -replace "\\", "/"
      foreach ($dir in $excludedDirs) {
        if ($path -match "/$([regex]::Escape($dir))(/|$)") {
          return $false
        }
      }
      return $true
    }

  $hits = @()
  foreach ($file in $files) {
    try {
      $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction Stop
    } catch {
      continue
    }

    foreach ($pattern in $badPatterns) {
      if ($content.Contains($pattern)) {
        $hits += $file.FullName
        break
      }
    }
  }

  if ($hits.Count -eq 0) {
    Write-Host "[OK] No obvious mojibake markers found"
  } else {
    $hits | Sort-Object -Unique | ForEach-Object { Warn "Possible mojibake: $_" }
  }
}

function Test-PlaceholderLiterals {
  param([string]$TargetPath)

  $placeholderPatterns = @(
    ("YOUR_" + "USERNAME"),
    ("YOUR_" + "REPO"),
    ("<model" + "-name>"),
    ("<path/to" + "/skill>")
  )
  $files = Get-ChildItem -LiteralPath $TargetPath -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -notmatch "\\(\.git|node_modules|dist|build|\.cache|__pycache__|\.pytest_cache)\\" -and
      $_.FullName -notmatch "\\scripts\\preflight\.(ps1|sh)$"
    }

  $hits = @()
  foreach ($file in $files) {
    try {
      $content = Get-Content -Raw -LiteralPath $file.FullName -ErrorAction Stop
    } catch {
      continue
    }

    foreach ($pattern in $placeholderPatterns) {
      if ($content.Contains($pattern)) {
        $hits += "$($file.FullName): $pattern"
      }
    }
  }

  if ($hits.Count -eq 0) {
    Write-Host "[OK] No obvious placeholder literals found"
  } else {
    $hits | Sort-Object -Unique | ForEach-Object { Warn "Placeholder literal found: $_" }
  }
}

function Show-QualityGate {
  param(
    [string]$TargetPath,
    [string]$EffectiveMode
  )

  Section "High-Star Readiness Gate"
  Test-FilePresence -TargetPath $TargetPath -FileName "README.md" -OkMessage "README.md exists" -MissingMessage "README.md is missing" | Out-Null
  Test-FilePresence -TargetPath $TargetPath -FileName "README.zh-CN.md" -OkMessage "README.zh-CN.md exists" -MissingMessage "README.zh-CN.md is missing" | Out-Null
  Test-License -TargetPath $TargetPath
  Test-ReadmeReleaseSignals -TargetPath $TargetPath
  Test-ReadmeLanguageLinks -TargetPath $TargetPath
  Test-ReadmeCoreSections -TargetPath $TargetPath
  Test-Mojibake -TargetPath $TargetPath
  Test-PlaceholderLiterals -TargetPath $TargetPath

  if ($EffectiveMode -eq "skill") {
    Test-SkillFrontmatter -TargetPath $TargetPath
  }
}

function Show-ProjectCommands {
  param([string]$TargetPath)

  Section "Suggested Verification Commands"
  $commands = New-Object System.Collections.Generic.List[string]

  $packageJson = Join-Path $TargetPath "package.json"
  if (Test-Path -LiteralPath $packageJson -PathType Leaf) {
    try {
      $json = Get-Content -Raw -LiteralPath $packageJson | ConvertFrom-Json
      if ($json.scripts.test) { [void]$commands.Add("npm test") }
      if ($json.scripts.build) { [void]$commands.Add("npm run build") }
      if ($json.scripts.lint) { [void]$commands.Add("npm run lint") }
    } catch {
      Warn "package.json exists but could not be parsed"
    }
  }

  if ((Test-Path -LiteralPath (Join-Path $TargetPath "pyproject.toml") -PathType Leaf) -or
      (Test-Path -LiteralPath (Join-Path $TargetPath "pytest.ini") -PathType Leaf) -or
      (Test-Path -LiteralPath (Join-Path $TargetPath "tests") -PathType Container)) {
    [void]$commands.Add("python -m pytest")
  }

  if (Test-Path -LiteralPath (Join-Path $TargetPath "Cargo.toml") -PathType Leaf) {
    [void]$commands.Add("cargo test")
    [void]$commands.Add("cargo build")
  }

  if (Test-Path -LiteralPath (Join-Path $TargetPath "go.mod") -PathType Leaf) {
    [void]$commands.Add("go test ./...")
  }

  if ($commands.Count -eq 0) {
    Warn "No standard test/build command detected. Mention this explicitly before publishing."
  } else {
    $commands | Sort-Object -Unique | ForEach-Object { Write-Host $_ }
  }
}

function Test-RiskyPath {
  param([string]$Path)

  $normalized = $Path -replace "\\", "/"
  $patterns = @(
    "(^|/)\.env($|\.)",
    "(^|/)node_modules/",
    "(^|/)dist/",
    "(^|/)build/",
    "(^|/)\.cache/",
    "(^|/)__pycache__/",
    "(^|/)\.pytest_cache/",
    "(^|/)playwright-report/",
    "(^|/)test-results/",
    "\.log$",
    "\.pem$",
    "\.key$",
    "(^|/)id_rsa($|\.)",
    "token",
    "credential",
    "secret"
  )

  foreach ($pattern in $patterns) {
    if ($normalized -match $pattern) {
      return $true
    }
  }

  return $false
}

$repo = Resolve-RepoRoot $RepoRoot
Set-Location -LiteralPath $repo

Section "Repository"
Write-Host "Root: $repo"

try {
  $inside = Get-GitLines @("rev-parse", "--is-inside-work-tree")
  if (($inside | Select-Object -First 1) -ne "true") {
    throw "Not inside a Git work tree."
  }
} catch {
  throw "This is not a Git repository: $repo"
}

$branch = (Get-GitLines @("branch", "--show-current") | Select-Object -First 1)
$upstream = ""
try {
  $upstream = (Get-GitLines @("rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{u}") | Select-Object -First 1)
} catch {
  $upstream = "(none)"
}

Write-Host "Branch: $branch"
Write-Host "Upstream: $upstream"

Section "Remotes"
try {
  Get-GitLines @("remote", "-v") | ForEach-Object { Write-Host $_ }
} catch {
  Warn "No Git remotes configured."
}

Section "GitHub CLI"
try {
  $ghCommand = Get-Command gh -ErrorAction Stop
  Write-Host "Command: $($ghCommand.Source)"
  $ghVersionOutput = @(& gh --version 2>&1)
  $ghVersion = $ghVersionOutput | Select-Object -First 1
  if ([string]::IsNullOrWhiteSpace($ghVersion)) {
    $ghVersion = "gh version output unavailable"
  }
  Write-Host $ghVersion
  $authOutput = & gh auth status 2>&1
  $authExitCode = $LASTEXITCODE
  $authOutput | ForEach-Object { Write-Host $_ }
  if ($authExitCode -ne 0) {
    Warn "GitHub CLI exists but is not authenticated."
  }
} catch {
  Warn "GitHub CLI is missing or unavailable. Push may still work through Git credentials."
}

Section "Git Status"
$statusEntries = Get-StatusEntries
if ($statusEntries.Count -eq 0) {
  Write-Host "Working tree has no pending changes."
} else {
  $statusEntries | ForEach-Object { Write-Host "$($_.Status) $($_.Path)" }
}

$targets = Get-TargetNames -StatusEntries $statusEntries -RequestedProject $ProjectName -RequestedSkill $SkillName -IncludeAll ([bool]$All)
if ($targets.Count -eq 0) {
  Warn "No target directories found from current changes."
} else {
  foreach ($target in $targets) {
    $targetPath = Resolve-TargetPath -Repo $repo -TargetName $target

    Section "Target Project"
    Write-Host "Name: $target"
    Write-Host "Path: $targetPath"

    if (-not (Test-Path -LiteralPath $targetPath -PathType Container)) {
      Warn "Target directory not found: $target"
      continue
    }

    $effectiveMode = Get-EffectiveMode -TargetPath $targetPath -RequestedMode $Mode
    Write-Host "Mode: $effectiveMode"
    if ($Mode -ne $effectiveMode) {
      Write-Host "Requested mode: $Mode"
    }

    Show-QualityGate -TargetPath $targetPath -EffectiveMode $effectiveMode
    Show-ProjectCommands -TargetPath $targetPath
  }
}

Section "Repository Ignore File"
if (Test-Path -LiteralPath ".gitignore") {
  Write-Host "[OK] .gitignore exists"
} else {
  Warn ".gitignore is missing. Review generated files carefully before staging."
}

Section "Risky Pending Paths"
$risky = @($statusEntries | Where-Object { Test-RiskyPath $_.Path })
if ($risky.Count -eq 0) {
  Write-Host "No obvious secret/cache/build paths found in pending changes."
} else {
  $risky | ForEach-Object { Warn "$($_.Status) $($_.Path)" }
}

Section "Large Pending Files"
$pendingPaths = @($statusEntries | ForEach-Object { $_.Path } | Sort-Object -Unique)
$largeFiles = @()
foreach ($path in $pendingPaths) {
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    $item = Get-Item -LiteralPath $path
    if ($item.Length -gt 5MB) {
      $largeFiles += [pscustomobject]@{
        Path = $path
        MB = [math]::Round($item.Length / 1MB, 2)
      }
    }
  }
}

if ($largeFiles.Count -eq 0) {
  Write-Host "No pending files larger than 5 MB found."
} else {
  $largeFiles | Sort-Object MB -Descending | Format-Table -AutoSize
}

Section "Next Step"
Write-Host "Review this output before staging. This script did not change files, stage commits, or push."
