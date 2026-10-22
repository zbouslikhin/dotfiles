# Set up a Windows machine in one command; safe to re-run. In PowerShell (no admin needed):
#
#   irm https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.ps1 | iex
#
# Installs or updates WSL (one admin prompt), installs Ubuntu, creates your Linux user
# (Linux asks for its password), turns on systemd, then runs bootstrap.sh inside it.
# Set $env:DOTFILES_BRANCH first to use another branch.

function Install-Dotfiles {
  $env:WSL_UTF8 = '1'  # plain text from wsl.exe, not UTF-16
  $branch = if ($env:DOTFILES_BRANCH) { $env:DOTFILES_BRANCH } else { 'main' }

  # Runs a command as root in Ubuntu. --exec skips WSL's own shell.
  function Root([string]$cmd) {
    & wsl.exe -d Ubuntu -u root --exec sh -c $cmd
    if ($LASTEXITCODE -ne 0) { throw "Failed in Ubuntu: $cmd" }
  }

  # 1. A WSL that supports systemd (the old built-in one has no --version).
  & wsl.exe --version *> $null
  if ($LASTEXITCODE -ne 0) {
    Write-Host '==> Installing WSL (approve the admin prompt)'
    Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList '-Command', 'wsl --update; wsl --install --no-distribution'
    & wsl.exe --version *> $null
    if ($LASTEXITCODE -ne 0) { throw 'WSL needs a Windows restart. Restart, then run the same command again.' }
  }

  # 2. Ubuntu.
  if (@(& wsl.exe --list --quiet) -notcontains 'Ubuntu') {
    Write-Host '==> Installing Ubuntu'
    & wsl.exe --install -d Ubuntu --no-launch
  }

  # 3. A Linux user (the first one created is uid 1000), systemd, and the default user.
  $user = (& wsl.exe -d Ubuntu -u root --exec sh -c 'id -nu 1000 2>/dev/null || true')
  if ($LASTEXITCODE -ne 0) { throw 'Ubuntu did not start. Close some programs to free memory, or restart Windows, then run again.' }
  if (-not $user) {
    $user = $env:USERNAME.ToLower()
    Write-Host "==> Creating Linux user '$user'"
    Root "useradd -m -s /bin/bash -G sudo $user"
    & wsl.exe -d Ubuntu -u root --exec passwd $user
  }
  $conf = "[boot]`nsystemd=true`n[user]`ndefault=$user"
  if ((& wsl.exe -d Ubuntu -u root --exec cat /etc/wsl.conf) -join "`n" -ne $conf) {
    Root "printf '$($conf -replace "`n", '\n')\n' > /etc/wsl.conf"
    & wsl.exe --terminate Ubuntu | Out-Null
  }

  # 4. bootstrap.sh, with password-free sudo for this run only.
  $sudoers = '/etc/sudoers.d/zz-dotfiles-bootstrap'
  Root "echo '$user ALL=(ALL) NOPASSWD: ALL' > $sudoers"
  try {
    & wsl.exe -d Ubuntu -u $user --cd '~' --exec env "DOTFILES_BRANCH=$branch" sh -c `
      "curl -fsSL https://raw.githubusercontent.com/zbouslikhin/dotfiles/$branch/bootstrap.sh | sh"
    if ($LASTEXITCODE -ne 0) { throw 'bootstrap.sh failed; see above. Run the same command again to retry.' }
  } finally {
    Root "rm -f $sudoers"
  }
  Write-Host "==> Done. Open Ubuntu from the Start menu; it starts in zsh."
}

Install-Dotfiles
