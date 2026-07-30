[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateNotNullOrEmpty()]
    [string]$Message,

    [switch]$SkipChecks,
    [switch]$AllowMain,
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw 'Git was not found on PATH. Install Git or open this repository through GitHub Desktop first.'
}

$repositoryRoot = (& git rev-parse --show-toplevel 2>$null)
if ($LASTEXITCODE -ne 0 -or -not $repositoryRoot) {
    throw 'Run this script from inside a Git repository.'
}

Push-Location $repositoryRoot
try {
    $branch = (& git branch --show-current).Trim()
    if (-not $branch) {
        throw 'The repository is in detached HEAD state. Switch to a branch before updating GitHub.'
    }
    if ($branch -eq 'main' -and -not $AllowMain) {
        throw 'Direct updates to main are blocked. Use a working branch, or pass -AllowMain intentionally.'
    }

    $origin = (& git remote get-url origin 2>$null)
    if ($LASTEXITCODE -ne 0 -or -not $origin) {
        throw 'The repository does not have an origin remote.'
    }

    $changedFiles = @(& git status --porcelain)
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to inspect the Git working tree.'
    }
    if ($changedFiles.Count -eq 0) {
        Write-Host 'Nothing to update. The working tree is clean.'
        return
    }

    $blockedExtensions = @(
        '.tif', '.tiff', '.mat', '.xls', '.xlsx', '.prism',
        '.fig', '.avi', '.mp4', '.p12', '.pfx', '.pem', '.key'
    )
    $untrackedFiles = @(& git ls-files --others --exclude-standard)
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to inspect untracked files.'
    }

    $blockedFiles = foreach ($relativePath in $untrackedFiles) {
        $item = Get-Item -LiteralPath (Join-Path $repositoryRoot $relativePath)
        if ($blockedExtensions -contains $item.Extension.ToLowerInvariant() -or
            $item.Length -gt 25MB -or
            $item.Name -like '.env*') {
            $relativePath
        }
    }
    if ($blockedFiles) {
        throw "Potential data, credential, or large files must be reviewed before committing:`n$($blockedFiles -join "`n")"
    }

    Write-Host "Repository: $repositoryRoot"
    Write-Host "Branch:     $branch"
    Write-Host "Remote:     $origin"
    & git status --short

    if (-not $SkipChecks) {
        if (-not (Get-Command matlab -ErrorAction SilentlyContinue)) {
            throw 'MATLAB was not found on PATH. Fix PATH or pass -SkipChecks intentionally.'
        }
        Write-Host 'Running MATLAB repository checks...'
        & matlab -batch "runRepositoryChecks"
        if ($LASTEXITCODE -ne 0) {
            throw "MATLAB checks failed with exit code $LASTEXITCODE. Nothing was committed."
        }
    }

    if ($DryRun) {
        Write-Host 'Dry run complete. No files were staged, committed, pulled, or pushed.'
        return
    }

    Invoke-Git -Arguments @('fetch', 'origin')
    & git show-ref --verify --quiet "refs/remotes/origin/$branch"
    $remoteBranchExists = $LASTEXITCODE -eq 0

    Invoke-Git -Arguments @('add', '--all')
    & git diff --cached --stat
    Invoke-Git -Arguments @('commit', '-m', $Message)
    if ($remoteBranchExists) {
        Invoke-Git -Arguments @('rebase', "origin/$branch")
    }
    Invoke-Git -Arguments @('push', '--set-upstream', 'origin', $branch)

    Write-Host "GitHub update completed successfully on branch '$branch'."
}
finally {
    Pop-Location
}
