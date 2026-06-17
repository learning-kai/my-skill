param()

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$preflight = Join-Path $scriptDir "preflight.ps1"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("publish-to-github-preflight-test-" + [guid]::NewGuid().ToString("N"))

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

    Set-Content -LiteralPath ".gitignore" -Value "*.log`n.env`n" -NoNewline
    Set-Content -LiteralPath "README.md" -Value "# $Name`n`n[![Latest release](https://img.shields.io/github/v/release/example/$Name)](https://github.com/example/$Name/releases/latest)`n`nEnglish readme.`n`n``````bash`ncurl -fsSL https://github.com/example/$Name/releases/latest/download/install.sh | bash`n```````n`n``````powershell`nirm https://github.com/example/$Name/releases/latest/download/install.ps1 | iex`n```````n" -NoNewline
    Set-Content -LiteralPath "README.zh-CN.md" -Value "# $Name`n`n[![最新发布](https://img.shields.io/github/v/release/example/$Name)](https://github.com/example/$Name/releases/latest)`n`n中文说明。`n`n``````bash`ncurl -fsSL https://github.com/example/$Name/releases/latest/download/install.sh | bash`n```````n`n``````powershell`nirm https://github.com/example/$Name/releases/latest/download/install.ps1 | iex`n```````n" -NoNewline
    Set-Content -LiteralPath "LICENSE" -Value "MIT`n" -NoNewline

    if ($Skill) {
      Set-Content -LiteralPath "SKILL.md" -Value "---`nname: $Name`ndescription: Publish test skill.`n---`n`n# $Name`n" -NoNewline
    } else {
      Set-Content -LiteralPath "package.json" -Value "{`"scripts`":{`"test`":`"echo test`",`"build`":`"echo build`"}}`n" -NoNewline
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

  $output = & powershell -NoProfile -ExecutionPolicy Bypass -File $preflight @Arguments 2>&1
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
