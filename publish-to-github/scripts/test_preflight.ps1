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

  $installHeading = if ($Chinese) { "安装" } else { "Installation" }
  $usageHeading = if ($Chinese) { "使用" } else { "Usage" }
  $projectPublishingHeading = if ($Chinese) { "普通项目发布" } else { "Project Publishing" }
  $skillPublishingHeading = if ($Chinese) { "Skill 发布" } else { "Skill Publishing" }
  $troubleshootingHeading = if ($Chinese) { "故障排查" } else { "Troubleshooting" }

  $content = @"
# $Name

[![Latest release](https://img.shields.io/github/v/release/example/$Name)](https://github.com/example/$Name/releases/latest)

$languageLine

$intro

## $installHeading

```bash
curl -fsSL https://github.com/example/$Name/releases/latest/download/install.sh | bash
```

```powershell
irm https://github.com/example/$Name/releases/latest/download/install.ps1 | iex
```

## $usageHeading

Run the tool.

## $projectPublishingHeading

Follow the project publishing flow.

## $skillPublishingHeading

Follow the skill publishing flow.

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
  Assert-Contains $projectResult.Text "[OK] README.md links to README.zh-CN.md"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md links back to README.md"
  Assert-Contains $projectResult.Text "[OK] README.md has Installation section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 安装 section"
  Assert-Contains $projectResult.Text "[OK] README.md has Project Publishing section"
  Assert-Contains $projectResult.Text "[OK] README.md has Skill Publishing section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has 普通项目发布 section"
  Assert-Contains $projectResult.Text "[OK] README.zh-CN.md has Skill 发布 section"
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
  Assert-Contains $skillResult.Text "[OK] README.md links to README.zh-CN.md"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md links back to README.md"
  Assert-Contains $skillResult.Text "[OK] README.md has Troubleshooting section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 故障排查 section"
  Assert-Contains $skillResult.Text "[OK] README.md has Project Publishing section"
  Assert-Contains $skillResult.Text "[OK] README.md has Skill Publishing section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has 普通项目发布 section"
  Assert-Contains $skillResult.Text "[OK] README.zh-CN.md has Skill 发布 section"

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
