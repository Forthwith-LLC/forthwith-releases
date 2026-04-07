#!/bin/sh
set -eu

BINARY_NAME="forthwith"
INSTALL_DIR="${FORTHWITH_INSTALL_DIR:-/usr/local/bin}"
BINARY_PATH="${INSTALL_DIR}/${BINARY_NAME}"
PKG_ID="com.forthwith.cli"
ASSUME_YES="${FORTHWITH_UNINSTALL_YES:-}"

main() {
    if [ ! -f "$BINARY_PATH" ]; then
        echo "${BINARY_NAME} is not installed at ${BINARY_PATH}"
        if is_macos && command -v pkgutil >/dev/null 2>&1 && pkgutil --pkg-info "$PKG_ID" >/dev/null 2>&1; then
            forget_receipt
        fi
        exit 0
    fi

    if [ "$ASSUME_YES" = "1" ]; then
        answer="yes"
    else
        answer="$(prompt_for_confirmation "Remove ${BINARY_NAME} from ${INSTALL_DIR}? [y/N] ")" || exit 1
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

prompt_for_confirmation() {
    prompt="$1"

    if [ -t 2 ]; then
        printf "%s" "$prompt" >&2
        if answer="$(
            sh -c '
                if IFS= read -r answer < /dev/tty; then
                    printf "%s\n" "$answer"
                else
                    exit 1
                fi
            ' 2>/dev/null
        )"; then
            printf '%s\n' "$answer"
            return 0
        fi
    fi

    if [ -t 0 ]; then
        printf "%s" "$prompt"
        if read -r answer; then
            printf '%s\n' "$answer"
            return 0
        fi
    fi

    echo "Error: could not read confirmation from the terminal." >&2
    echo "Re-run interactively, or set FORTHWITH_UNINSTALL_YES=1 to skip the prompt." >&2
    return 1
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
