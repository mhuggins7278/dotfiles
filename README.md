These are my dotfiles, they can be used under macOS and Linux (mainly Arch Linux but Ubuntu is also supported). What is special about it is that Ansible is used to configure and sync your system settings. This has many advantages in contrast to simple bash scripts or a `Makefile`.

## Features

* update packages (homebrew, pacman, apt) and the dotfiles repository with `$ update`
* update your settings (dotfiles) with `$ dotfiles`
* sync your packages with `$ brewsync` between hosts
* Try to use consistent color theme and fonts between all components
* set some macOS defaults (`dotfiles/ansible/tasks/macos_defaults.yml`)
* set some Arch Linux specific options (`dotfiles/ansible/tasks/arch.yml`)
* dnscrypt for encrypted and locally cached DNS queries (macOS only)
* try to keep `~/` clean
* configuration is mainly handled by Ansible (playbook: `~/.dotfiles/ansible/dotfiles.yml`)

## Included configurations

* OS
  * macOS
  * Arch Linux
  * Ubuntu / (CentOS)
* curl
* fish / zsh / bash
* GTK
* i3 (i3blocks)
* iTerm 2
* SSH
* Terminator
* Termite
* tmux
* Transmission
* Vim
* Visual Studio Code
* Wget
* Kanata (keyboard remapping, replaces Karabiner-Elements)

## Install (for me)

```bash
$ git clone https://github.com/mhuggins7278/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles/init
$ ./setup.sh
```

## Install (for you)

* Fork this repository
* Edit at least the following files (better take a look at all files):

```
├── ansible
│   ├── tasks
│   │   └── macos_defaults.yml
│   ├── vars
│   │   ├── casks.yml
│   │   ├── formula.yml
│   │   ├── gems.yml
│   │   ├── pip.yml
│   │   └── taps.yml
│   └── vars.yml
└── init
    └── macos.bash
```

* Some interesting variables for the Ansible playbook are set in `dotfiles/ansible/vars.yml`

  * `login_shell: /usr/local/bin/zsh`
  * `sudo_without_password: true`

* Clone and install dotfiles repository:

```bash
$ git clone https://github.com/<YOURNAME>/dotfiles.git ~/.dotfiles
$ cd ~/.dotfiles/init
$ .init/setup.sh
```

## Manual steps after install

### Allow Karabiner-DriverKit-VirtualHIDDevice system extension (macOS, one-time)

The Ansible playbook automatically downloads and installs the standalone `Karabiner-DriverKit-VirtualHIDDevice` driver pkg (no full Karabiner-Elements app needed). This driver provides the virtual HID device that kanata uses for keyboard output.

On first install (or after a macOS upgrade), the DriverKit system extension must be approved manually:

1. Open **System Settings → Privacy & Security → Security**
2. Approve the blocked system extension from `pqrs.org`
3. Reboot when prompted

If you previously had `karabiner-elements` installed via brew, uninstall it after running the playbook to avoid conflicts — the standalone driver pkg replaces it:

```bash
brew uninstall --cask karabiner-elements
sudo installer -pkg /tmp/Karabiner-DriverKit-VirtualHIDDevice-6.12.0.pkg -target /
```

> **Note:** `brew uninstall --cask karabiner-elements` deletes the driver files. Re-run the Ansible playbook (`dotfiles`) or the second `installer` line above to restore them.

### Grant kanata Input Monitoring permission (macOS)

kanata requires Input Monitoring (Privacy & Security) permission to read from the keyboard. After running `dotfiles`, grant it manually:

1. Open **System Settings → Privacy & Security → Input Monitoring**
2. Click **+**
3. In the file picker, press **Cmd+Shift+G** and enter `/opt/homebrew/bin/`
4. Select **kanata** and click Open
5. Restart kanata: `sudo launchctl bootout system/com.kanata.service && sudo launchctl bootstrap system /Library/LaunchDaemons/com.kanata.service.plist`

> **Note:** macOS 26 (Tahoe) doesn't allow browsing to non-app-bundle binaries directly in the file picker — the Cmd+Shift+G path trick is required.

## What is missing

* `gitconfig`

### SSH client configuration

`~/.ssh/config` or system wide in `/etc/ssh/ssh_config`, an basic example can be found at `contrib/ssh_config`.

## Inspired by

* https://bitbucket.org/keimlink/dotfiles
* https://gist.github.com/brandonb927/3195465
* https://github.com/alrra/dotfiles
* https://github.com/donnemartin/dev-setup
* https://github.com/drduh/OS-X-Security-and-Privacy-Guide
* https://github.com/herrbischoff/awesome-osx-command-line
* https://github.com/mathiasbynens/dotfiles
* https://github.com/monstermunchkin/dotfiles
* https://github.com/mrzool/bash-sensible
* https://github.com/necolas/dotfiles
