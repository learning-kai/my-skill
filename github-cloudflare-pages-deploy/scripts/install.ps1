$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:REPO_URL) { $env:REPO_URL } else { "https://github.com/learning-kai/my-skill.git" }
$SkillName = "github-cloudflare-pages-deploy"
$Agent = if ($env:AGENT) { $env:AGENT.ToLowerInvariant() } else { "codex" }

switch ($Agent) {
  "codex" {
    $TargetRoot = if ($env:SKILLS_DIR) { $env:SKILLS_DIR } else { Join-Path $env:USERPROFILE ".codex\skills" }
  }
  "claude" {
    $TargetRoot = if ($env:SKILLS_DIR) { $env:SKILLS_DIR } else { Join-Path $env:USERPROFILE ".claude\skills" }
  }
  "claude-code" {
    $TargetRoot = if ($env:SKILLS_DIR) { $env:SKILLS_DIR } else { Join-Path $env:USERPROFILE ".claude\skills" }
  }
  "kiro" {
    $TargetRoot = if ($env:SKILLS_DIR) { $env:SKILLS_DIR } else { Join-Path $env:USERPROFILE ".kiro\skills" }
  }
  default {
    throw "Unsupported AGENT '$Agent'. Use codex, claude, or kiro."
  }
}

$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("github-cloudflare-pages-deploy-" + [guid]::NewGuid().ToString("N"))
$RepoPath = Join-Path $TempRoot "repo"
$TargetPath = Join-Path $TargetRoot $SkillName

try {
  git clone --depth 1 $RepoUrl $RepoPath | Out-Null
  New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null

  if (Test-Path -LiteralPath $TargetPath) {
    Remove-Item -LiteralPath $TargetPath -Recurse -Force
  }

  Copy-Item -LiteralPath (Join-Path $RepoPath $SkillName) -Destination $TargetPath -Recurse
  Write-Host "Installed $SkillName to $TargetPath"
} finally {
  if (Test-Path -LiteralPath $TempRoot) {
    Remove-Item -LiteralPath $TempRoot -Recurse -Force
  }
}
