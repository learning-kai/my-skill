param(
  [Parameter(Mandatory = $true)]
  [string]$ProjectRoot
)

$ErrorActionPreference = "Stop"

function Section($Name) {
  Write-Host ""
  Write-Host "== $Name =="
}

$root = Resolve-Path -LiteralPath $ProjectRoot
Set-Location -LiteralPath $root.Path

Section "Project"
Write-Host "Root: $($root.Path)"

Section "GitHub CLI"
try {
  gh --version | Select-Object -First 1
  gh auth status
} catch {
  Write-Warning "GitHub CLI is missing or not authenticated. Run: gh auth login"
}

Section "Git"
try {
  git status -sb
  Write-Host ""
  git remote -v
} catch {
  Write-Warning "This directory is not a Git repository yet."
}

Section "Ignored generated files"
if (Test-Path -LiteralPath ".gitignore") {
  Get-Content -LiteralPath ".gitignore"
} else {
  Write-Warning ".gitignore is missing. Add one before committing."
}

Section "Package scripts"
if (Test-Path -LiteralPath "package.json") {
  $package = Get-Content -Raw -LiteralPath "package.json" | ConvertFrom-Json
  if ($package.scripts) {
    $package.scripts.PSObject.Properties | ForEach-Object {
      Write-Host "$($_.Name): $($_.Value)"
    }
  } else {
    Write-Warning "package.json has no scripts."
  }
} else {
  Write-Warning "package.json not found."
}

Section "Large tracked candidates"
try {
  $candidates = git ls-files --others --cached --exclude-standard
  $candidates |
    ForEach-Object { Get-Item -LiteralPath $_ -ErrorAction SilentlyContinue } |
    Where-Object { $_ -and $_.Length -gt 5MB } |
    Sort-Object Length -Descending |
    Select-Object FullName, @{Name = "MB"; Expression = { [math]::Round($_.Length / 1MB, 2) } }
} catch {
  Write-Warning "Could not inspect Git file candidates."
}

Write-Host ""
Write-Host "Preflight complete. Review warnings before publishing."
