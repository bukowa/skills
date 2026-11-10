<#
.SYNOPSIS
    Syncs skills and rules between this repository and the global Gemini/Antigravity config (~/.gemini/config).
.PARAMETER Pull
    Pull skills and rules from global config into this repository.
.PARAMETER Link
    Attempts NTFS directory junctions for skills and symlinks for rules (falls back to copy if denied).
.PARAMETER Watch
    Watches .agents/ and continuously syncs changes on save.
.PARAMETER DryRun
    Preview actions without writing any files.
#>
[CmdletBinding()]
param(
    [switch]$Pull,
    [switch]$Link,
    [switch]$Watch,
    [switch]$DryRun
)

$RepoAgents = Join-Path $PSScriptRoot ".agents"
$GlobalConfig = Join-Path $env:USERPROFILE ".gemini\config"

$Categories = @(
    @{ Name = "rules";  IsFolder = $false },
    @{ Name = "skills"; IsFolder = $true  }
)

function Test-SameFileContent($fileA, $fileB) {
    if (-not (Test-Path $fileA) -or -not (Test-Path $fileB)) { return $false }
    $hashA = (Get-FileHash -Path $fileA -Algorithm MD5).Hash
    $hashB = (Get-FileHash -Path $fileB -Algorithm MD5).Hash
    return ($hashA -eq $hashB)
}

function Sync-Items($srcDir, $dstDir, [bool]$isFolder, [bool]$tryLink) {
    if (-not (Test-Path $srcDir)) { return }
    if (-not (Test-Path $dstDir)) {
        if (-not $DryRun) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }
    }

    $items = Get-ChildItem -Path $srcDir
    foreach ($item in $items) {
        $targetPath = Join-Path $dstDir $item.Name

        if ($isFolder -and $item.PSIsContainer) {
            # Skill folder
            if ($tryLink) {
                if (Test-Path $targetPath) {
                    Write-Host "  [Skip] Destination exists: $($item.Name)" -ForegroundColor DarkGray
                    continue
                }
                if ($DryRun) {
                    Write-Host "  [DryRun] Would junction: $($item.Name) -> $targetPath" -ForegroundColor Cyan
                    continue
                }
                try {
                    New-Item -ItemType Junction -Path $targetPath -Target $item.FullName -ErrorAction Stop | Out-Null
                    Write-Host "  [Junction] $($item.Name)" -ForegroundColor Green
                    continue
                } catch {
                    Write-Host "  [Notice] Junction denied. Falling back to copy." -ForegroundColor Yellow
                }
            }

            # Copy folder contents
            if ($DryRun) {
                Write-Host "  [DryRun] Would sync skill folder: $($item.Name)" -ForegroundColor Cyan
            } else {
                if (-not (Test-Path $targetPath)) {
                    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                }
                Copy-Item -Path "$($item.FullName)\*" -Destination $targetPath -Recurse -Force
                Write-Host "  [Synced] Skill: $($item.Name)" -ForegroundColor Green
            }
        } elseif (-not $isFolder -and -not $item.PSIsContainer) {
            # Rule file
            if (Test-Path $targetPath) {
                if (Test-SameFileContent $item.FullName $targetPath) {
                    Write-Host "  [Up to date] $($item.Name)" -ForegroundColor DarkGray
                    continue
                }
            }

            if ($tryLink) {
                if ($DryRun) {
                    Write-Host "  [DryRun] Would link rule: $($item.Name)" -ForegroundColor Cyan
                    continue
                }
                try {
                    New-Item -ItemType SymbolicLink -Path $targetPath -Target $item.FullName -ErrorAction Stop | Out-Null
                    Write-Host "  [Symlink] $($item.Name)" -ForegroundColor Green
                    continue
                } catch {
                    # Fallback to copy
                }
            }

            if ($DryRun) {
                Write-Host "  [DryRun] Would sync rule: $($item.Name)" -ForegroundColor Cyan
            } else {
                Copy-Item -Path $item.FullName -Destination $targetPath -Force
                Write-Host "  [Synced] Rule: $($item.Name)" -ForegroundColor Green
            }
        }
    }
}

function Run-Sync {
    if ($Pull) {
        Write-Host ">>> Pulling from Global Config into Repo ($RepoAgents) <<<" -ForegroundColor Cyan
        foreach ($cat in $Categories) {
            Write-Host "`nSyncing $($cat.Name)..." -ForegroundColor Yellow
            $src = Join-Path $GlobalConfig $cat.Name
            $dst = Join-Path $RepoAgents $cat.Name
            Sync-Items -srcDir $src -dstDir $dst -isFolder $cat.IsFolder -tryLink $false
        }
    } else {
        Write-Host ">>> Pushing from Repo ($RepoAgents) to Global Config <<<" -ForegroundColor Cyan
        foreach ($cat in $Categories) {
            Write-Host "`nSyncing $($cat.Name)..." -ForegroundColor Yellow
            $src = Join-Path $RepoAgents $cat.Name
            $dst = Join-Path $GlobalConfig $cat.Name
            Sync-Items -srcDir $src -dstDir $dst -isFolder $cat.IsFolder -tryLink $Link
        }
    }
    Write-Host "`nSync completed!" -ForegroundColor Green
}

if ($Watch) {
    Write-Host "Watching $RepoAgents for changes... (Press Ctrl+C to stop)" -ForegroundColor Cyan
    Run-Sync

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path = $RepoAgents
    $watcher.IncludeSubdirectories = $true
    $watcher.EnableRaisingEvents = $true

    $action = {
        param($source, $event)
        Write-Host "`n[$([DateTime]::Now.ToString('HH:mm:ss'))] Detected $($event.ChangeType): $($event.Name)" -ForegroundColor Magenta
        Run-Sync
    }

    Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
    Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
    Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null

    try {
        while ($true) { Start-Sleep -Seconds 1 }
    } finally {
        Unregister-Event -SourceIdentifier $watcher.ToString() -ErrorAction SilentlyContinue
        $watcher.Dispose()
    }
} else {
    Run-Sync
}
