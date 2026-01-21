#!/bin/bash
# Install cm to a directory in PATH

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_INSTALL_DIR="$HOME/.local/bin"

echo "CM Installer"
echo "============"
echo
echo "This will:"
echo "  1. Copy 'cm' to your chosen directory"
echo "  2. Create symlinks for 'authorized_keys' and 'workspaces/'"
echo
read -p "Install directory [$DEFAULT_INSTALL_DIR]: " INSTALL_DIR
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

# Expand ~
INSTALL_DIR="${INSTALL_DIR/#\~/$HOME}"

# Create install directory if needed
if [[ ! -d "$INSTALL_DIR" ]]; then
    echo "Creating $INSTALL_DIR"
    mkdir -p "$INSTALL_DIR"
fi

# Copy cm script
echo "Copying cm to $INSTALL_DIR/"
rm -f "$INSTALL_DIR/cm"
cp "$SCRIPT_DIR/cm" "$INSTALL_DIR/cm"
chmod +x "$INSTALL_DIR/cm"

# Helper to safely create symlink (only removes existing symlinks, never directories)
safe_symlink() {
    local target="$1"
    local link="$2"
    local name="$(basename "$link")"

    if [[ -L "$link" ]]; then
        rm "$link"
    elif [[ -e "$link" ]]; then
        echo "Error: $link exists and is not a symlink. Remove it manually to proceed."
        exit 1
    fi
    ln -s "$target" "$link"
    echo "Created symlink: $link -> $target"
}

safe_symlink "$SCRIPT_DIR/authorized_keys" "$INSTALL_DIR/authorized_keys"
safe_symlink "$SCRIPT_DIR/workspaces" "$INSTALL_DIR/workspaces"

echo
echo "Installed successfully!"
echo
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Note: $INSTALL_DIR is not in your PATH."
    echo "Add it with:"
    echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc"
fi
