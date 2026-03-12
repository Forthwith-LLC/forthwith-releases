#!/bin/sh
set -eu

BINARY_NAME="forthwith"
INSTALL_DIR="${FORTHWITH_INSTALL_DIR:-/usr/local/bin}"
BINARY_PATH="${INSTALL_DIR}/${BINARY_NAME}"
PKG_ID="com.forthwith.cli"

main() {
    if [ ! -f "$BINARY_PATH" ]; then
        echo "${BINARY_NAME} is not installed at ${BINARY_PATH}"
        if is_macos && command -v pkgutil >/dev/null 2>&1 && pkgutil --pkg-info "$PKG_ID" >/dev/null 2>&1; then
            forget_receipt
        fi
        exit 0
    fi

    printf "Remove %s from %s? [y/N] " "$BINARY_NAME" "$INSTALL_DIR"
    if ! read -r answer; then
        answer=""
    fi
    case "$answer" in
        [Yy]|[Yy][Ee][Ss])
            remove_binary
            echo "Successfully removed ${BINARY_NAME} from ${INSTALL_DIR}"
            ;;
        *)
            echo "Cancelled"
            exit 0
            ;;
    esac
}

remove_binary() {
    if [ -w "$INSTALL_DIR" ]; then
        rm -f "$BINARY_PATH"
    else
        sudo rm -f "$BINARY_PATH"
    fi

    if is_macos && command -v pkgutil >/dev/null 2>&1; then
        forget_receipt
    fi
}

forget_receipt() {
    if pkgutil --pkg-info "$PKG_ID" >/dev/null 2>&1; then
        if [ "$(id -u)" -eq 0 ]; then
            pkgutil --forget "$PKG_ID" >/dev/null 2>&1 || true
        else
            sudo pkgutil --forget "$PKG_ID" >/dev/null 2>&1 || true
        fi
    fi
}

is_macos() {
    [ "$(uname -s)" = "Darwin" ]
}

main
