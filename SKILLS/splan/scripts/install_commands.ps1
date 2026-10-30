<#
install_commands.ps1 - install Splan commands into AI tool command directories.

Usage:
  powershell -NoProfile -ExecutionPolicy Bypass -File install_commands.ps1
  powershell -NoProfile -ExecutionPolicy Bypass -File install_commands.ps1 -Target claude
  powershell -NoProfile -ExecutionPolicy Bypass -File install_commands.ps1 -Target "D:\my-tool\commands"
  powershell -NoProfile -ExecutionPolicy Bypass -File install_commands.ps1 -Project "D:\my-project"

Default -Target auto detects installed tools. Symbolic links are preferred;
if link creation is not permitted, files are copied.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [string]$Target = 'auto',
    [string]$Project = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$SkillRoot = Split-Path -Parent $PSScriptRoot
$SourceDir = Join-Path $SkillRoot 'commands'
if (-not (Test-Path -LiteralPath $SourceDir)) {
    throw "commands directory not found: $SourceDir"
}

$files = @(Get-ChildItem -LiteralPath $SourceDir -Filter 'splan*.md' -File)
if ($files.Count -eq 0) {
    throw "no splan*.md files found in $SourceDir"
}

$HomeDir = $env:USERPROFILE

function Get-ToolDirs {
    param([string]$Tool)
    switch ($Tool) {
        'claude' { @(Join-Path $HomeDir '.claude\commands') }
        'opencode' { @(Join-Path $HomeDir '.config\opencode\command') }
        'cursor' { @(Join-Path $HomeDir '.cursor\commands') }
        'codex' { @(Join-Path $HomeDir '.codex\prompts') }
        'copilot' { @(Join-Path $Project '.github\prompts') }
        'windsurf' { @(Join-Path $Project '.windsurf\workflows') }
        'cline' { @(Join-Path $Project '.clinerules\workflows') }
        'roo' { @(Join-Path $Project '.roo\commands') }
        'continue' { @(Join-Path $Project '.continue\prompts') }
        'gemini' { @(Join-Path $HomeDir '.gemini\commands') }
        default { @() }
    }
}

function Test-Tool {
    param([string]$Tool)
    switch ($Tool) {
        'claude' { Test-Path -LiteralPath (Join-Path $HomeDir '.claude') }
        'opencode' { Test-Path -LiteralPath (Join-Path $HomeDir '.config\opencode') }
        'cursor' { Test-Path -LiteralPath (Join-Path $HomeDir '.cursor') }
        'codex' { Test-Path -LiteralPath (Join-Path $HomeDir '.codex') }
        'gemini' { Test-Path -LiteralPath (Join-Path $HomeDir '.gemini') }
        'copilot' { Test-Path -LiteralPath (Join-Path $Project '.github') }
        'windsurf' { Test-Path -LiteralPath (Join-Path $Project '.windsurf') }
        'cline' { Test-Path -LiteralPath (Join-Path $Project '.clinerules') }
        'roo' { Test-Path -LiteralPath (Join-Path $Project '.roo') }
        'continue' { Test-Path -LiteralPath (Join-Path $Project '.continue') }
        default { $false }
    }
}

function Resolve-Targets {
    param([string]$Tool)
    if ($Tool -eq 'auto') {
        $found = @()
        foreach ($t in @('claude', 'opencode', 'cursor', 'codex', 'copilot', 'windsurf', 'cline', 'roo', 'continue', 'gemini')) {
            if (Test-Tool $t) { $found += $t }
        }
        if ($found.Count -eq 0) {
            if ($PSScriptRoot -match '[\\/]\.claude[\\/]skills[\\/]') { $found = @('claude') }
            elseif ($PSScriptRoot -match '[\\/]\.config[\\/]opencode[\\/]skills[\\/]') { $found = @('opencode') }
        }
        return $found
    }
    if (Test-Path -LiteralPath $Tool -PathType Container) { return @($Tool) }
    if ((Get-ToolDirs $Tool).Count -gt 0) { return @($Tool) }
    return @($Tool)
}

$targets = @(Resolve-Targets $Target)
if ($targets.Count -eq 0) {
    Write-Host "No AI tool detected. Use -Target claude|opencode|cursor|codex|copilot|windsurf|cline|roo|continue|gemini, or -Target <dir>." -ForegroundColor Yellow
    exit 1
}

foreach ($tool in $targets) {
    $dirs = @(Get-ToolDirs $tool)
    if ($dirs.Count -eq 0) { $dirs = @($tool) }
    if ($tool -eq 'gemini') {
        Write-Host "[warn] Gemini CLI uses TOML commands; Markdown files are copied as-is and may need conversion." -ForegroundColor Yellow
    }
    if ($tool -eq 'continue') {
        Write-Host "[warn] Continue uses .prompt files; Markdown files are copied as-is and may need conversion." -ForegroundColor Yellow
    }

    foreach ($dir in $dirs) {
        if (-not (Test-Path -LiteralPath $dir)) {
            if ($PSCmdlet.ShouldProcess($dir, 'create directory')) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
        }
        $linked = 0
        $copied = 0
        $skipped = 0
        foreach ($f in $files) {
            $dst = Join-Path $dir $f.Name
            if (Test-Path -LiteralPath $dst) {
                $item = Get-Item -LiteralPath $dst -Force
                if ($item.LinkType -eq 'SymbolicLink' -and $item.Target -eq $f.FullName) {
                    $skipped++
                    continue
                }
                if ($PSCmdlet.ShouldProcess($dst, 'replace')) {
                    Remove-Item -LiteralPath $dst -Force
                }
            }
            if ($PSCmdlet.ShouldProcess($dst, 'install symlink/copy')) {
                try {
                    New-Item -ItemType SymbolicLink -Path $dst -Target $f.FullName -ErrorAction Stop | Out-Null
                    $linked++
                }
                catch {
                    Copy-Item -LiteralPath $f.FullName -Destination $dst -Force
                    $copied++
                }
            }
        }
        Write-Host ("[{0}] {1}  linked={2} copied={3} skipped={4}" -f $tool, $dir, $linked, $copied, $skipped) -ForegroundColor Green
    }
}
