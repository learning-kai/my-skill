param(
  [string]$Repository = "learning-kai/my-skill",
  [string]$SkillName = "publish-to-github",
  [string]$Destination = (Join-Path $env:USERPROFILE ".codex\skills")
)

$ErrorActionPreference = "Stop"

$archiveName = "$SkillName.skill"
$downloadUrl = "https://github.com/$Repository/releases/latest/download/$archiveName"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("$SkillName-install-" + [guid]::NewGuid().ToString("N"))
$archivePath = Join-Path $tempDir $archiveName
$targetDir = Join-Path $Destination $SkillName

New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
New-Item -ItemType Directory -Force -Path $Destination | Out-Null

try {
  Write-Host "Downloading $downloadUrl"
  Invoke-WebRequest -Uri $downloadUrl -OutFile $archivePath

  if (Test-Path -LiteralPath $targetDir) {
    Remove-Item -Recurse -Force -LiteralPath $targetDir
  }

  Expand-Archive -LiteralPath $archivePath -DestinationPath $Destination -Force
  Write-Host "Installed $SkillName to $targetDir"
  Write-Host "Restart Codex or open a new session before using the skill."
} finally {
  if (Test-Path -LiteralPath $tempDir) {
    Remove-Item -Recurse -Force -LiteralPath $tempDir
  }
}
