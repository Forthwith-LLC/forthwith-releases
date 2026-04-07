# Forthwith CLI Releases

This repository hosts the official release binaries for the [Forthwith CLI](https://forthwith.dev).

Forthwith CLI extracts localizable strings from your project, sends new or changed strings to Forthwith for translation, and writes translated resources back into framework-specific files.

## Prerequisites

You need a Forthwith account to use this CLI. [Sign up at forthwith.dev](https://forthwith.dev) before getting started.

## Installation

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Forthwith-LLC/forthwith-releases/main/install.sh | bash
```

On macOS, this downloads and installs the notarized `.pkg` for your architecture. On Linux, it downloads the `.tar.gz` archive and installs the binary to `/usr/local/bin` by default.

To pin a specific release, set `FORTHWITH_VERSION`:

```bash
curl -fsSL https://raw.githubusercontent.com/Forthwith-LLC/forthwith-releases/main/install.sh | FORTHWITH_VERSION=v0.1.0-rc.7 bash
```

### macOS (Homebrew)

```bash
brew install Forthwith-LLC/forthwith/forthwith
```

If you prefer to add the tap first, you can also run:

```bash
brew tap Forthwith-LLC/forthwith
brew install forthwith
```

### Windows (Scoop)

```bash
scoop bucket add forthwith https://github.com/Forthwith-LLC/scoop-forthwith
scoop install forthwith
```

### Windows (Chocolatey)

```bash
choco install forthwith
```

### Manual Download
Download the installer or archive for your platform from the Releases page. Homebrew uses the macOS `.tar.gz` archives; direct macOS installs should use the notarized `.pkg`.

| Platform | Architecture   | File |
|----------|----------------|------|
| macOS    | Apple Silicon  | `forthwith_<version>_darwin_arm64.pkg` |
| macOS    | Apple Silicon  | `forthwith_<version>_darwin_arm64.tar.gz` |
| macOS    | Intel          | `forthwith_<version>_darwin_amd64.pkg` |
| macOS    | Intel          | `forthwith_<version>_darwin_amd64.tar.gz` |
| Linux    | x86_64         | `forthwith_<version>_linux_amd64.tar.gz` |
| Linux    | ARM64          | `forthwith_<version>_linux_arm64.tar.gz` |
| Windows  | x86_64         | `forthwith_<version>_windows_amd64.zip` |
| Windows  | ARM64          | `forthwith_<version>_windows_arm64.zip` |

## Updating

Update Forthwith using the same method you used to install it:

### macOS / Linux (install script)

Run the installer again to upgrade to the latest release:

```bash
curl -fsSL https://raw.githubusercontent.com/Forthwith-LLC/forthwith-releases/main/install.sh | bash
```

To update to a specific release, set `FORTHWITH_VERSION`:

```bash
curl -fsSL https://raw.githubusercontent.com/Forthwith-LLC/forthwith-releases/main/install.sh | FORTHWITH_VERSION=v0.1.0-rc.7 bash
```

### macOS (Homebrew)

```bash
brew update
brew upgrade forthwith
```

### Windows (Scoop)

```bash
scoop update forthwith
```

### Windows (Chocolatey)

```bash
choco upgrade forthwith
```

### Manual Download

Download the latest release for your platform from the Releases page, then reinstall it the same way:

- On macOS, run the newer `.pkg`.
- On Linux, replace the existing `forthwith` binary with the one from the newer `.tar.gz`.
- On Windows, replace the existing `forthwith.exe` with the one from the newer `.zip`.

## Uninstallation
### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/Forthwith-LLC/forthwith-releases/main/uninstall.sh | bash
```

For non-interactive environments, you can skip the confirmation prompt:

```bash
curl -fsSL https://raw.githubusercontent.com/Forthwith-LLC/forthwith-releases/main/uninstall.sh | FORTHWITH_UNINSTALL_YES=1 bash
```

or if installed with homebrew on macOS:
```bash
brew uninstall forthwith
brew untap Forthwith-LLC/forthwith
```

### Windows

If installed with Chocolatey:
```bash
choco uninstall forthwith
```

If installed with Scoop:
```bash
scoop uninstall forthwith
```

## Getting Started

```bash
# Authenticate
forthwith login

# Initialize your project
forthwith init

# Translate new or changed strings
forthwith translate
```

See the [Forthwith CLI documentation](https://forthwith.dev/docs) for complete usage instructions.
