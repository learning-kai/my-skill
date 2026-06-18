param()

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$preflight = Join-Path $scriptDir "preflight.ps1"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("publish-to-github-preflight-test-" + [guid]::NewGuid().ToString("N"))
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-Utf8File {
  param(
    [string]$Path,
    [string]$Content
  )

  [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function New-ReadmeContent {
  param(
    [string]$Name,
    [switch]$Chinese
  )

  $intro = if ($Chinese) {
    "用于验证发布准备度的测试项目。"
  } else {
    "A test project used to verify publish readiness."
  }

  $languageLine = if ($Chinese) {
    "[English](README.md) | 简体中文"
  } else {
    "English | [简体中文](README.zh-CN.md)"
  }

  $whyHeading = if ($Chinese) { "为什么做" } else { "Why" }
  $featuresHeading = if ($Chinese) { "核心特性" } else { "Core Features" }
  $screenshotsHeading = if ($Chinese) { "截图与演示" } else { "Screenshots & Demo" }
  $quickStartHeading = if ($Chinese) { "快速开始" } else { "Quick Start" }
  $installHeading = if ($Chinese) { "安装" } else { "Installation" }
  $usageHeading = if ($Chinese) { "使用" } else { "Usage" }
  $qualityHeading = if ($Chinese) { "工程质量" } else { "Engineering Quality" }
  $docsHeading = if ($Chinese) { "项目文档" } else { "Project Docs" }
  $privacyHeading = if ($Chinese) { "隐私与安全边界" } else { "Privacy & Security" }
  $releaseHeading = if ($Chinese) { "发布与更新" } else { "Release & Updates" }
  $roadmapHeading = if ($Chinese) { "路线图" } else { "Roadmap" }
  $contributingHeading = if ($Chinese) { "贡献" } else { "Contributing" }
  $troubleshootingHeading = if ($Chinese) { "故障排查" } else { "Troubleshooting" }

  $content = @"
# $Name

[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Latest release](https://img.shields.io/github/v/release/example/$Name)](https://github.com/example/$Name/releases/latest)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey)
![Bash](https://img.shields.io/badge/shell-Bash-4EAA25)

$languageLine

$intro

## $whyHeading

This fixture exists to verify README quality gates.

## $featuresHeading

- Bilingual README checks.
- Release install checks.
- Badge checks.

## $screenshotsHeading

Command-line and skill fixtures use command output instead of screenshots.

## $quickStartHeading

Run the preflight script.

## $installHeading

```bash
curl -fsSL https://github.com/example/$Name/releases/latest/download/install.sh | bash
```

```powershell
irm https://github.com/example/$Name/releases/latest/download/install.ps1 | iex
```

## $usageHeading

Run the tool.

## $qualityHeading

The fixture exposes deterministic sections for preflight tests.

## $docsHeading

Read the README pair.

## $privacyHeading

Do not publish secrets.

## $releaseHeading

Follow the release flow and attach install assets.

## $roadmapHeading

- Keep the fixture aligned with README gates.

## $contributingHeading

Keep tests focused and readable.

## $troubleshootingHeading

Check authentication and paths.

## License

MIT.
"@

  return $content
}

function New-FixtureRepo {
  param(
    [string]$Name,
    [switch]$Skill
  )

  $repo = Join-Path $tempRoot $Name
  New-Item -ItemType Directory -Force -Path $repo | Out-Null
  Push-Location $repo
  try {
    git init | Out-Null
    git config user.email "test@example.com"
    git config user.name "Preflight Test"

    Write-Utf8File (Join-Path $repo ".gitignore") "*.log`n.env`n"
    Write-Utf8File (Join-Path $repo "README.md") (New-ReadmeContent -Name $Name)
    Write-Utf8File (Join-Path $repo "README.zh-CN.md") (New-ReadmeContent -Name $Name -Chinese)
    Write-Utf8File (Join-Path $repo "LICENSE") "MIT`n"

    if ($Skill) {
      Write-Utf8File (Join-Path $repo "SKILL.md") "---`nname: $Name`ndescription: Publish test skill.`n---`n`n# $Name`n"
    } else {
      Write-Utf8File (Join-Path $repo "package.json") "{`"scripts`":{`"test`":`"echo test`",`"build`":`"echo build`"}}`n"
    }

    git add .
    git commit -m "fixture" | Out-Null
  } finally {
    Pop-Location
  }

  return $repo
}

function Invoke-Preflight {
  param([string[]]$Arguments)

  $output = & pwsh -NoProfile -ExecutionPolicy Bypass -File $preflight @Arguments 2>&1
  return [pscustomobject]@{
    ExitCode = $LASTEXITCODE
    Text = ($output -join "`n")
  }
}

function Assert-Contains {
  param(
    [string]$Text,
    [string]$Needle
  )

  if (-not $Text.Contains($Needle)) {
    throw "Expected output to contain '$Needle'. Output:`n$Text"
  }
}

try {
  New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

  $projectRepo = New-FixtureRepo -Name "sample-project"
  $projectResult = Invoke-Preflight @("-RepoRoot", $projectRepo, "-Mode", "project", "-ProjectName", ".")
  if ($projectResult.ExitCode -ne 0) {
    throw "Project preflight failed:`n$($projectResult.Text)"
  }
  Assert-Contains $projectResult.Text "== Target Project =="
  Assert-Contains $projectResult.Text "Mode: project"
  Assert-Contains $projectResult.Text "[OK] README.md exists"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md exists"
  Assert-Contains $projectResult.Text "[OK] README.md has a release badge"
  Assert-Contains $projectResult.Text "[OK] README.md has a curl install command"
  Assert-Contains $projectResult.Text "[OK] README.md has a PowerShell install command"
  Assert-Contains $projectResult.Text "[OK] README.md has 3+ top badges"
  Assert-Contains $projectResult.Text "[OK] README.md has a License badge"
  Assert-Contains $projectResult.Text "[OK] README.md has a release/version badge"
  Assert-Contains $projectResult.Text "[OK] README.md has a platform/tech badge"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 3+ top badges"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has a License badge"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has a release/version badge"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has a platform/tech badge"
  Assert-Contains $projectResult.Text "[OK] README.md links to README.zh-CN.md"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md links back to README.md"
  Assert-Contains $projectResult.Text "[OK] README.md has Why section"
  Assert-Contains $projectResult.Text "[OK] README.md has Core Features section"
  Assert-Contains $projectResult.Text "[OK] README.md has Screenshots & Demo section"
  Assert-Contains $projectResult.Text "[OK] README.md has Engineering Quality section"
  Assert-Contains $projectResult.Text "[OK] README.md has Release & Updates section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 为什么做 section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 核心特性 section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 截图与演示 section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 工程质量 section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 发布与更新 section"
  Assert-Contains $projectResult.Text "npm test"
  Assert-Contains $projectResult.Text "npm run build"

  $skillRepo = New-FixtureRepo -Name "sample-skill" -Skill
  $skillResult = Invoke-Preflight @("-RepoRoot", $skillRepo, "-Mode", "auto", "-ProjectName", ".")
  if ($skillResult.ExitCode -ne 0) {
    throw "Skill preflight failed:`n$($skillResult.Text)"
  }
  Assert-Contains $skillResult.Text "Mode: skill"
  Assert-Contains $skillResult.Text "[OK] SKILL.md frontmatter: name=sample-skill"
  Assert-Contains $skillResult.Text "[OK] README.md exists"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md exists"
  Assert-Contains $skillResult.Text "[OK] README.md has a release badge"
  Assert-Contains $skillResult.Text "[OK] README.md has a curl install command"
  Assert-Contains $skillResult.Text "[OK] README.md has a PowerShell install command"
  Assert-Contains $skillResult.Text "[OK] README.md has 3+ top badges"
  Assert-Contains $skillResult.Text "[OK] README.md has a License badge"
  Assert-Contains $skillResult.Text "[OK] README.md has a release/version badge"
  Assert-Contains $skillResult.Text "[OK] README.md has a platform/tech badge"
  Assert-Contains $skillResult.Text "[OK] README.md links to README.zh-CN.md"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md links back to README.md"
  Assert-Contains $skillResult.Text "[OK] README.md has Troubleshooting section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 故障排查 section"
  Assert-Contains $skillResult.Text "[OK] README.md has Project Docs section"
  Assert-Contains $skillResult.Text "[OK] README.md has Privacy & Security section"
  Assert-Contains $skillResult.Text "[OK] README.md has Roadmap section"
  Assert-Contains $skillResult.Text "[OK] README.md has Contributing section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 项目文档 section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 隐私与安全边界 section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 路线图 section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 贡献 section"

  $missingReadme = Join-Path $skillRepo "README.zh-CN.md"
  Remove-Item -LiteralPath $missingReadme
  $missingResult = Invoke-Preflight @("-RepoRoot", $skillRepo, "-Mode", "skill", "-ProjectName", ".")
  Assert-Contains $missingResult.Text "README.zh-CN.md is missing"

  Write-Host "preflight tests passed"
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -Recurse -Force -LiteralPath $tempRoot
  }
}
