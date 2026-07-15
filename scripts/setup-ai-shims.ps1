# setup-ai-shims.ps1 — replace .claude/{agents,commands,skills}/ with NTFS
# junctions pointing at the canonical .opencode/{agents,commands,skills}/ so
# Claude Code keeps working while OpenCode reads the canonical files.
#
# Idempotent. Safe-by-default. Backs up anything it touches before replacing.
#
# Usage:
#   pwsh ./scripts/setup-ai-shims.ps1 [-DryRun] [-Yes]
#
# Flags:
#   -DryRun   print what would happen without making changes
#   -Yes      run every shim replacement without prompting (default: prompt)
#   -Help     show this message
#
# Effects on each pair (.claude\<dir> <-> .opencode\<dir>):
#   - if .claude\<dir> is already a junction/symlink to .opencode\<dir>: skip
#   - if .opencode\<dir> does not exist: skip with warning
#   - else: backup .claude\<dir> -> .claude\<dir>.bak-<timestamp>, then
#           Remove-Item .claude\<dir> + New-Item -ItemType Junction
#
# Rollback (per shim):
#   Remove-Item .claude\<dir>                 # remove the junction (it acts like a dir)
#   Move-Item .claude\<dir>.bak-* .claude\<dir>  # restore the backup
#
# Tested with PowerShell 5.1 on Windows 11.
[CmdletBinding()]
param(
  [switch]$DryRun,
  [switch]$Yes,
  [switch]$Help
)

if ($Help) {
  Get-Content "$PSCommandPath" -TotalCount 35 | Select-Object -Skip 1
  exit 0
}

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $RepoRoot

$Pairs = @("agents", "commands", "skills")
$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyyMMddTHHmmssZ")

function Test-IsShim {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  $item = Get-Item -LiteralPath $Path -Force
  return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}

function Confirm {
  param([string]$Prompt)
  if ($Yes) { Write-Host "$Prompt [auto-yes]"; return $true }
  $reply = Read-Host "$Prompt [y/N]"
  return ($reply -match '^(y|yes)$')
}

function Backup-IfNeeded {
  param([string]$Target)
  if (Test-IsShim $Target) {
    Write-Host "  $Target is already a shim (skipped backup)"
    return $true
  }
  if (-not (Test-Path -LiteralPath $Target)) {
    Write-Host "  $Target does not exist (nothing to back up)"
    return $true
  }
  $backup = "$Target.bak-$Timestamp"
  if (Test-Path -LiteralPath $backup) {
    Write-Host "  backup already exists: $backup (skipping to avoid overwrite)"
    return $false
  }
  if ($DryRun) {
    Write-Host "  [DRY-RUN] would copy $Target -> $backup"
  } else {
    Copy-Item -LiteralPath $Target -Destination $backup -Recurse -Force
    Write-Host "  backup $Target -> $backup"
  }
  return $true
}

foreach ($dir in $Pairs) {
  $claude   = Join-Path ".claude"   $dir
  $opencode = Join-Path ".opencode" $dir

  Write-Host ""
  Write-Host "========== $claude <-> $opencode =========="

  if (-not (Test-Path -LiteralPath $opencode)) {
    Write-Host "  [SKIP] $opencode does not exist - run Phase 4 first."
    continue
  }

  if (Test-IsShim $claude) {
    $target = (Get-Item -LiteralPath $claude -Force).Target
    Write-Host "  [SKIP] $claude is already a shim -> $target"
    continue
  }

  if (-not (Confirm "Replace $claude with junction to ..\.opencode\$dir?")) {
    Write-Host "  [SKIP] user declined"
    continue
  }

  if (-not (Backup-IfNeeded $claude)) {
    Write-Host "  [ABORT] backup step failed for $claude"
    continue
  }

  if ($DryRun) {
    Write-Host "  [DRY-RUN] would Remove-Item $claude and New-Item Junction to ..\.opencode\$dir"
    continue
  }

  Remove-Item -LiteralPath $claude -Recurse -Force
  $absTarget = (Resolve-Path -LiteralPath (Join-Path $RepoRoot ".opencode\$dir") -ErrorAction Stop).Path
  New-Item -ItemType Junction -Path $claude -Target $absTarget | Out-Null
  Write-Host "  [OK]    junction created: $claude -> $absTarget"

  # Verify
  $item = Get-Item -LiteralPath $claude -Force
  if (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
    $entries = (Get-ChildItem -LiteralPath $claude -Recurse -ErrorAction SilentlyContinue | Measure-Object).Count
    Write-Host "  [OK]    junction resolves, $entries entries reachable"
  } else {
    Write-Host "  [FAIL]  junction did not resolve - manual rollback required" -ForegroundColor Red
  }
}

Write-Host ""
Write-Host "Done. Verify with: Get-Item .claude\{agents,commands,skills} -Force | Select Attributes,Target"
Write-Host "Rollback any single pair:"
Write-Host "  Remove-Item .claude\<dir>"
Write-Host "  Move-Item .claude\<dir>.bak-* .claude\<dir>"
