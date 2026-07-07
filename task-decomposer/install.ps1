$ErrorActionPreference = "Stop"

$repoUrl = "https://github.com/learning-kai/my-skill.git"
$targetRoot = if ($env:CODEX_HOME) {
  Join-Path $env:CODEX_HOME "skills"
} else {
  Join-Path $env:USERPROFILE ".codex\skills"
}
$target = Join-Path $targetRoot "task-decomposer"
$tmpDir = Join-Path $env:TEMP ("task-decomposer-" + [guid]::NewGuid().ToString("N"))

try {
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required to install task-decomposer."
  }

  git clone --depth 1 $repoUrl $tmpDir | Out-Null
  New-Item -ItemType Directory -Force -Path $targetRoot | Out-Null

  if (Test-Path -LiteralPath $target) {
    $backup = "$target.backup.$(Get-Date -Format yyyyMMddHHmmss)"
    Move-Item -LiteralPath $target -Destination $backup
    Write-Host "Existing task-decomposer moved to $backup"
  }

  Copy-Item -Recurse -Force -LiteralPath (Join-Path $tmpDir "task-decomposer") -Destination $target
  Write-Host "Installed task-decomposer to $target"
} finally {
  if (Test-Path -LiteralPath $tmpDir) {
    Remove-Item -Recurse -Force -LiteralPath $tmpDir
  }
}
