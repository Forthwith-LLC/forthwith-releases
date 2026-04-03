#!/bin/sh
set -eu

REPO="Forthwith-LLC/forthwith-releases"
BINARY_NAME="forthwith"
INSTALL_DIR="${FORTHWITH_INSTALL_DIR:-/usr/local/bin}"
FORTHWITH_VERSION="${FORTHWITH_VERSION:-}"
PKG_ID="com.forthwith.cli"

main() {
    os="$(detect_os)"
    arch="$(detect_arch)"

    if [ -z "$os" ] || [ -z "$arch" ]; then
        echo "Error: unsupported platform: $(uname -s)/$(uname -m)" >&2
        exit 1
    fi

    if ! version="$(get_latest_version)"; then
        version=""
    fi
    if [ -z "$version" ]; then
        echo "Error: could not determine latest version" >&2
        exit 1
    fi

    checksums_url="https://github.com/${REPO}/releases/download/${version}/checksums.txt"

    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT

    curl -sSfL "$checksums_url" -o "$tmpdir/checksums.txt"

    case "$os" in
        darwin)
            install_macos "$version" "$arch" "$tmpdir"
            ;;
        linux)
            install_linux "$version" "$arch" "$tmpdir"
            ;;
        *)
            echo "Error: unsupported platform: ${os}/${arch}" >&2
            exit 1
            ;;
    esac
}

detect_os() {
    case "$(uname -s)" in
        Darwin) echo "darwin" ;;
        Linux)  echo "linux" ;;
        *)      echo "" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  echo "amd64" ;;
        aarch64|arm64) echo "arm64" ;;
        *)             echo "" ;;
    esac
}

get_latest_version() {
    if [ -n "$FORTHWITH_VERSION" ]; then
        printf '%s\n' "$FORTHWITH_VERSION"
        return 0
    fi

    latest_release_url="https://api.github.com/repos/${REPO}/releases/latest"
    releases_url="https://api.github.com/repos/${REPO}/releases?per_page=1"

    response="$(github_api_get "$latest_release_url" 2>/dev/null || true)"
    version="$(printf '%s\n' "$response" | extract_tag_name)"
    if [ -n "$version" ]; then
        printf '%s\n' "$version"
        return 0
    fi

    response="$(github_api_get "$releases_url" 2>/dev/null || true)"
    version="$(printf '%s\n' "$response" | extract_tag_name)"
    if [ -n "$version" ]; then
        printf '%s\n' "$version"
        return 0
    fi

    return 1
}

github_api_get() {
    curl -sSfL \
        -H "Accept: application/vnd.github+json" \
        -H "X-GitHub-Api-Version: 2022-11-28" \
        -H "User-Agent: forthwith-install-script" \
        "$1"
}

extract_tag_name() {
    sed -n 's/.*"tag_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' |
        sed -n '1p'
}

install_macos() {
    version="$1"
    arch="$2"
    tmpdir="$3"
    package="forthwith_${version#v}_darwin_${arch}.pkg"
    url="https://github.com/${REPO}/releases/download/${version}/${package}"

    if [ "$INSTALL_DIR" != "/usr/local/bin" ]; then
        echo "Error: FORTHWITH_INSTALL_DIR is not supported on macOS package installs" >&2
        exit 1
    fi

    echo "Downloading ${BINARY_NAME} ${version} for ${arch}..."
    curl -sSfL "$url" -o "$tmpdir/$package"

    echo "Verifying checksum..."
    verify_checksum "$tmpdir" "$package"

    if command -v spctl >/dev/null 2>&1; then
        echo "Validating notarized package..."
        spctl --assess --type install -vv "$tmpdir/$package"
    fi

    echo "Installing package to /usr/local/bin..."
    if [ "$(id -u)" -eq 0 ]; then
        installer -pkg "$tmpdir/$package" -target /
    else
        sudo installer -pkg "$tmpdir/$package" -target /
    fi

    if command -v pkgutil >/dev/null 2>&1; then
        pkgutil --pkg-info "$PKG_ID" >/dev/null 2>&1 || true
    fi

    echo "Successfully installed ${BINARY_NAME} ${version} to /usr/local/bin/${BINARY_NAME}"
}

install_linux() {
    version="$1"
    arch="$2"
    tmpdir="$3"
    archive="forthwith_${version#v}_linux_${arch}.tar.gz"
    url="https://github.com/${REPO}/releases/download/${version}/${archive}"

    echo "Downloading ${BINARY_NAME} ${version} for linux/${arch}..."
    curl -sSfL "$url" -o "$tmpdir/$archive"

    echo "Verifying checksum..."
    verify_checksum "$tmpdir" "$archive"

    echo "Extracting..."
    tar -xzf "$tmpdir/$archive" -C "$tmpdir"

    echo "Installing to ${INSTALL_DIR}..."
    install_binary "$tmpdir/$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"

    echo "Successfully installed ${BINARY_NAME} ${version} to ${INSTALL_DIR}/${BINARY_NAME}"
}

verify_checksum() {
    dir="$1"
    file="$2"
    expected="$(awk -v f="$file" '$2 == f || $2 == "*" f { print $1; exit }' "$dir/checksums.txt")"

    if [ -z "$expected" ]; then
        echo "Error: checksum not found for $file" >&2
        exit 1
    fi

    if command -v sha256sum >/dev/null 2>&1; then
        actual="$(sha256sum "$dir/$file" | awk '{print $1}')"
    elif command -v shasum >/dev/null 2>&1; then
        actual="$(shasum -a 256 "$dir/$file" | awk '{print $1}')"
    else
        echo "Error: no sha256 tool found (need sha256sum or shasum)" >&2
        exit 1
    fi

    if [ "$expected" != "$actual" ]; then
        echo "Error: checksum mismatch" >&2
        echo "  expected: $expected" >&2
        echo "  actual:   $actual" >&2
        exit 1
    fi
}

install_binary() {
    src="$1"
    dest="$2"
    dest_dir="$(dirname "$dest")"

    if [ ! -d "$dest_dir" ]; then
        mkdir -p "$dest_dir" 2>/dev/null || sudo mkdir -p "$dest_dir"
    fi

    chmod +x "$src"

    if [ -w "$dest_dir" ]; then
        cp "$src" "$dest"
    else
        sudo cp "$src" "$dest"
    fi
}

main
