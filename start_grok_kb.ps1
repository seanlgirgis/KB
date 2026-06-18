# start_grok_kb.ps1
# STABLE — do not modify without explicit request from Sean.
#
# Runtime copy (use this):  C:\scripts\start_grok_kb.ps1
# Repo archive (git only):  D:\Workarea\kb\start_grok_kb.ps1
# Keep both files identical when a change is ever required.
#
# Location-agnostic launcher: kb vault -> Grok Build TUI
#
# Usage (from anywhere):
#   pwsh -ExecutionPolicy Bypass -File "C:\scripts\start_grok_kb.ps1"
#
# Opens a new PowerShell window by default. To run in the current shell:
#   ...\start_grok_kb.ps1 -NoNewWindow

param(
    [string]$KbRoot = 'D:\Workarea\kb',
    [switch]$NoNewWindow
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$WindowTitle = 'grok_kb'

function Resolve-KbPaths {
    param([string]$Kb)

    if (-not (Test-Path -LiteralPath $Kb)) {
        throw "kb folder not found: $Kb"
    }

    return [ordered]@{
        KbRoot = (Resolve-Path -LiteralPath $Kb).Path
    }
}

function Resolve-PwshExecutable {
    $pwshCmd = Get-Command pwsh -ErrorAction SilentlyContinue
    if ($pwshCmd) {
        return $pwshCmd.Source
    }

    $candidates = @(
        (Join-Path $env:ProgramFiles 'PowerShell\7\pwsh.exe')
        (Join-Path $env:ProgramFiles 'PowerShell\6\pwsh.exe')
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    throw "pwsh not found on PATH or under Program Files\PowerShell. Install PowerShell 7+ first."
}

function Resolve-GrokExecutable {
    $grokCmd = Get-Command grok -ErrorAction SilentlyContinue
    if ($grokCmd) {
        return $grokCmd.Source
    }

    $fallback = Join-Path $env:USERPROFILE '.grok\bin\grok.exe'
    if (Test-Path -LiteralPath $fallback) {
        return $fallback
    }

    throw "grok not found on PATH and not at $fallback. Install Grok CLI first."
}

function Get-GrokBootstrapRules {
    @'
For this kb (Knowledge Base) project session:
- Read BOOTSTRAP.md startup order before executing any task.
- Then read Grok_PROJECT_PROFILE.md, docs/NOTE_CONVENTIONS.md, and Grok_CURRENT_STATE.md as needed.
- Use Grok_ prefix for agent memory files (Grok_PROJECT_PROFILE.md, Grok_PROJECT_MEMORY.md, Grok_CURRENT_STATE.md).
- Full Sean context export: D:\Workarea\learning\sean_girgis_memory_context_export_2026-06-15.md (confirm time-sensitive facts).
- Run D:\py_venv\rag_application_builder_foundation\set_env.ps1 before any Python commands.
- Sean has ADD/ADHD: keep every response ~1 page or less; one concept at a time; wait for his reply before continuing.
- Create RAG-import-friendly Obsidian notes: YAML frontmatter, H2 chunk boundaries, wikilinks.
- When Sean asks for an opinion, give an honest assessment with tradeoffs — not blind agreement.
- Sean manages Git; director syncs via C:\scripts\gitqall.ps1.
'@
}

function Get-GrokBootstrapPrompt {
    param([string]$KbPath)

    @"
New Grok Build session for kb (Knowledge Base).

Read BOOTSTRAP.md and follow its startup order before doing any work. Confirm the Grok agent files are loaded and you are operating repository-first in $KbPath.
"@
}

function Start-GrokKbSession {
    $paths = Resolve-KbPaths -Kb $KbRoot
    $grokExe = Resolve-GrokExecutable

    try {
        $Host.UI.RawUI.WindowTitle = $WindowTitle
    } catch {
        # Some hosts do not support title changes.
    }

    Write-Host "=== $WindowTitle ===" -ForegroundColor Cyan
    Write-Host "kb: $($paths.KbRoot)" -ForegroundColor DarkGray

    Set-Location -LiteralPath $paths.KbRoot
    Write-Host "Working directory: $(Get-Location)" -ForegroundColor Green

    $rules = Get-GrokBootstrapRules
    $prompt = Get-GrokBootstrapPrompt -KbPath $paths.KbRoot

    Write-Host "`nStarting Grok Build..." -ForegroundColor Yellow
    & $grokExe --cwd $paths.KbRoot --rules $rules $prompt
}

if (-not $NoNewWindow) {
    $pwshExe = Resolve-PwshExecutable
    $paths = Resolve-KbPaths -Kb $KbRoot
    $scriptPath = $PSCommandPath

    $argList = @(
        '-NoExit'
        '-ExecutionPolicy', 'Bypass'
        '-File', $scriptPath
        '-KbRoot', $paths.KbRoot
        '-NoNewWindow'
    )

    Start-Process -FilePath $pwshExe -ArgumentList $argList -WorkingDirectory $paths.KbRoot | Out-Null
    return
}

Start-GrokKbSession