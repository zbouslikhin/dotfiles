# Set up a Windows machine in one command; safe to re-run. In PowerShell (no admin needed):
#
#   irm https://raw.githubusercontent.com/zbouslikhin/dotfiles/main/bootstrap.ps1 | iex
#
# Installs or updates WSL (one admin prompt), installs Ubuntu, creates your Linux user
# (asks for its password once), turns on systemd, then runs bootstrap.sh inside it.
# If Windows needs a restart for WSL, setup carries on by itself after you sign in.
#
# Overrides ($env:NAME = 'value' before running):
#   DOTFILES_BRANCH  branch to use                         (default: main)
#   DOTFILES_DISTRO  name of the Ubuntu distro in WSL       (default: Ubuntu)
#   DOTFILES_USER    Linux user, if the distro has none    (default: your Windows user name)
# Other DOTFILES_* variables (DOTFILES_DIR, DOTFILES_REPO, ...) are passed on to bootstrap.sh.
# Written for Windows PowerShell 5.1, which every Windows has.

function Install-Dotfiles {
  $ErrorActionPreference = 'Stop'
  # wsl.exe prints UTF-16 unless told otherwise.
  $env:WSL_UTF8 = '1'
  # Text piped to wsl.exe: UTF-8 without the BOM Windows PowerShell adds by default.
  $OutputEncoding = New-Object System.Text.UTF8Encoding $false
  # Strips a BOM and CRs from piped text on the Linux side, in case one still gets through.
  $clean = 'sed ''1s/^\xEF\xBB\xBF//; s/\r$//'''

  $branch = if ($env:DOTFILES_BRANCH) { $env:DOTFILES_BRANCH } else { 'main' }
  $distro = if ($env:DOTFILES_DISTRO) { $env:DOTFILES_DISTRO } else { 'Ubuntu' }
  $raw = "https://raw.githubusercontent.com/zbouslikhin/dotfiles/$branch"

  function Info($msg) { Write-Host "==> $msg" -ForegroundColor Cyan }
  function Fail($msg) { throw "xx  $msg" }

  function Test-ModernWsl {
    # The old built-in wsl.exe has no --version and no systemd support.
    try { & wsl.exe --version *> $null; return ($LASTEXITCODE -eq 0) } catch { return $false }
  }

  function Get-Distros {
    try { @(& wsl.exe --list --quiet 2>$null) | ForEach-Object { $_.Trim([char]0, ' ') } | Where-Object { $_ } }
    catch { @() }
  }

  # Runs a sh script as root in the distro and returns its output. The script goes in on
  # stdin, and --exec skips WSL's own shell (which would expand $ a second time).
  function Invoke-Root([string]$script) {
    $script | & wsl.exe -d $distro -u root --exec sh -c "$clean | sh -e"
    if ($LASTEXITCODE -ne 0) { Fail "Command failed in $distro as root." }
  }

  # The first start after a WSL update can fail transiently (e.g. low memory), so retry.
  function Start-Distro {
    for ($i = 1; $i -le 3; $i++) {
      $out = & wsl.exe -d $distro -u root -- true 2>&1 | Out-String
      if ($LASTEXITCODE -eq 0) { return }
      Write-Host "    $distro did not start (try $i of 3): $($out.Trim())" -ForegroundColor Yellow
      Start-Sleep -Seconds 10
    }
    Fail "$distro will not start. Close some programs (WSL needs free memory) or restart Windows, then run the same command again."
  }

  # --- 1. WSL itself -----------------------------------------------------------
  if (Test-ModernWsl) {
    Info 'WSL is up to date'
  } else {
    Info 'Installing WSL (approve the admin prompt)'
    $elevated = @'
$ErrorActionPreference = 'Stop'
$restart = $false
foreach ($f in 'Microsoft-Windows-Subsystem-Linux', 'VirtualMachinePlatform') {
  if ((Get-WindowsOptionalFeature -Online -FeatureName $f).State -ne 'Enabled') {
    if ((Enable-WindowsOptionalFeature -Online -FeatureName $f -All -NoRestart).RestartNeeded) { $restart = $true }
  }
}
if ($restart) { exit 3010 }
& wsl.exe --update --web-download
exit $LASTEXITCODE
'@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($elevated))
    try {
      $proc = Start-Process powershell.exe -Verb RunAs -Wait -PassThru `
        -ArgumentList '-NoProfile', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $encoded
    } catch { Fail 'The admin prompt was declined; WSL cannot be installed without it.' }

    if ($proc.ExitCode -eq 3010) {
      # Resume after the restart, with the same overrides.
      $vars = Get-ChildItem env: | Where-Object { $_.Name -like 'DOTFILES_*' } |
        ForEach-Object { "`$env:$($_.Name)='$($_.Value)'; " }
      $resume = "$($vars -join '')irm $raw/bootstrap.ps1 | iex"
      Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce' 'DotfilesBootstrap' `
        "powershell.exe -NoProfile -ExecutionPolicy Bypass -NoExit -Command `"$resume`""
      Info 'Restart Windows to finish enabling WSL. Setup continues by itself after you sign in.'
      return
    }
    if (-not (Test-ModernWsl)) { Fail "WSL could not be installed (exit code $($proc.ExitCode))." }
  }

  # --- 2. The distro -----------------------------------------------------------
  if ((Get-Distros) -contains $distro) {
    Info "$distro is installed"
  } else {
    Info "Installing $distro"
    $installArgs = @('--install', 'Ubuntu', '--no-launch')
    if ($distro -ne 'Ubuntu') { $installArgs += @('--name', $distro) }
    & wsl.exe @installArgs
    if ($LASTEXITCODE -ne 0) { Fail "Installing $distro failed." }
    if (-not ((Get-Distros) -contains $distro)) {
      # Store-packaged distros are only registered once their launcher runs.
      & ubuntu.exe install --root
      if (-not ((Get-Distros) -contains $distro)) { Fail "$distro was installed but did not register." }
    }
  }

  # --- 3. Linux user and systemd -----------------------------------------------
  Start-Distro
  $user = (Invoke-Root "getent passwd | awk -F: '`$3 >= 1000 && `$3 < 60000 { print `$1; exit }'" | Out-String).Trim()
  if ($user) {
    Info "Using Linux user '$user'"
  } else {
    $user = if ($env:DOTFILES_USER) { $env:DOTFILES_USER } else { $env:USERNAME.ToLower() -replace '[^a-z0-9_-]', '' }
    if ($user -notmatch '^[a-z_][a-z0-9_-]*$') { Fail "'$user' is not a valid Linux user name; set `$env:DOTFILES_USER." }
    Info "Creating Linux user '$user'"
    while ($true) {
      $p1 = Read-Host "Choose a password for '$user' in $distro" -AsSecureString
      $p2 = Read-Host 'Type it again' -AsSecureString
      $plain = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p1))
      $check = [Runtime.InteropServices.Marshal]::PtrToStringBSTR([Runtime.InteropServices.Marshal]::SecureStringToBSTR($p2))
      if ($plain -and $plain -eq $check) { break }
      Write-Host 'The passwords were empty or did not match; try again.' -ForegroundColor Yellow
    }
    Invoke-Root "useradd -m -s /bin/bash -G sudo '$user'"
    # The password goes in on stdin, never on a command line.
    "${user}:$plain" | & wsl.exe -d $distro -u root --exec sh -c "$clean | chpasswd"
    if ($LASTEXITCODE -ne 0) { Fail 'Setting the password failed.' }
    $plain = $null; $check = $null
  }

  # systemd (needed by the Nix installer) and the default user, both in /etc/wsl.conf.
  Invoke-Root @"
conf=/etc/wsl.conf
touch `$conf
set_key() {
  # set_key <section> <key> <value>
  if grep -q "^`$2=" `$conf; then sed -i "s|^`$2=.*|`$2=`$3|" `$conf
  elif grep -q "^\[`$1\]" `$conf; then sed -i "/^\[`$1\]/a `$2=`$3" `$conf
  else printf '\n[%s]\n%s=%s\n' "`$1" "`$2" "`$3" >> `$conf
  fi
}
before=`$(cat `$conf)
set_key boot systemd true
set_key user default '$user'
[ "`$before" = "`$(cat `$conf)" ] || touch /tmp/.wsl-conf-changed
"@
  $changed = & wsl.exe -d $distro -u root --exec sh -c 'rm /tmp/.wsl-conf-changed 2>/dev/null && echo yes'
  if ($changed -eq 'yes') {
    Info "Restarting $distro to apply /etc/wsl.conf"
    & wsl.exe --terminate $distro | Out-Null
    Start-Distro
  }
  & wsl.exe -d $distro -u root --exec sh -c 'for i in 1 2 3 4 5 6 7 8 9 10; do [ -d /run/systemd/system ] && exit 0; sleep 1; done; exit 1'
  if ($LASTEXITCODE -ne 0) { Fail "systemd is not running in $distro." }

  # --- 4. bootstrap.sh inside the distro ----------------------------------------
  # Password-free sudo just for this run, so nothing inside asks; removed afterwards.
  $sudoers = '/etc/sudoers.d/zz-dotfiles-bootstrap'
  Invoke-Root "printf '%s ALL=(ALL) NOPASSWD: ALL\n' '$user' > $sudoers && chmod 440 $sudoers"
  try {
    $env:DOTFILES_BRANCH = $branch
    # WSLENV hands these Windows variables to the Linux side.
    $pass = Get-ChildItem env: | Where-Object { $_.Name -like 'DOTFILES_*' -and $_.Name -ne 'DOTFILES_DISTRO' } |
      ForEach-Object { $_.Name }
    $env:WSLENV = (@($env:WSLENV -split ':') + $pass | Where-Object { $_ } | Select-Object -Unique) -join ':'
    Info "Running bootstrap.sh in $distro as $user"
    & wsl.exe -d $distro -u $user --cd '~' --exec sh -c "curl -fsSL $raw/bootstrap.sh | sh"
    if ($LASTEXITCODE -ne 0) { Fail 'bootstrap.sh failed; see the output above. Run the same command again to retry.' }
  } finally {
    & wsl.exe -d $distro -u root -- rm -f $sudoers
  }

  Info "Done. Open '$distro' from the Start menu or Windows Terminal; it starts in zsh."
}

Install-Dotfiles
