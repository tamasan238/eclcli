#!/usr/bin/env bash
set -euo pipefail

WORKDIR="${WORKDIR:-$HOME/work/ecl-local}"
VENV_DIR="${VENV_DIR:-$WORKDIR/venv}"
PYTHON_BIN="${PYTHON_BIN:-python3.14}"
ECLSDK_REPO="${ECLSDK_REPO:-https://github.com/tamasan238/eclsdk.git}"
ECLCLI_REPO="${ECLCLI_REPO:-https://github.com/tamasan238/eclcli.git}"
ECLSDK_BRANCH="${ECLSDK_BRANCH:-queens-python314-deps}"
ECLCLI_BRANCH="${ECLCLI_BRANCH:-feat/python-312-314-support}"

usage() {
    cat <<'USAGE'
Usage:
  scripts/install-local-branches.sh
  scripts/install-local-branches.sh --uninstall

Environment variables:
  WORKDIR        Default: $HOME/work/ecl-local
  VENV_DIR       Default: $WORKDIR/venv
  PYTHON_BIN     Default: python3.14
  ECLSDK_REPO    Default: https://github.com/tamasan238/eclsdk.git
  ECLCLI_REPO    Default: https://github.com/tamasan238/eclcli.git
  ECLSDK_BRANCH  Default: queens-python314-deps
  ECLCLI_BRANCH  Default: feat/python-312-314-support
USAGE
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    usage
    exit 0
fi

if [[ "${1:-}" == "--uninstall" ]]; then
    if [[ ! -x "$VENV_DIR/bin/python" ]]; then
        echo "Virtualenv not found: $VENV_DIR"
        exit 0
    fi
    "$VENV_DIR/bin/python" -m pip uninstall -y eclcli eclsdk
    echo "Uninstalled eclcli and eclsdk from $VENV_DIR"
    exit 0
fi

if [[ $# -gt 0 ]]; then
    usage
    exit 2
fi

checkout_repo() {
    local repo_url="$1"
    local branch="$2"
    local dest="$3"

    if [[ -d "$dest/.git" ]]; then
        git -C "$dest" fetch origin
        git -C "$dest" checkout "$branch"
        git -C "$dest" pull --ff-only origin "$branch"
    else
        git clone -b "$branch" "$repo_url" "$dest"
    fi
}

mkdir -p "$WORKDIR"

checkout_repo "$ECLSDK_REPO" "$ECLSDK_BRANCH" "$WORKDIR/eclsdk"
checkout_repo "$ECLCLI_REPO" "$ECLCLI_BRANCH" "$WORKDIR/eclcli"

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

"$VENV_DIR/bin/python" -m pip install -U pip setuptools wheel

git -C "$WORKDIR/eclsdk" tag -f 1.10.0 HEAD
"$VENV_DIR/bin/python" -m pip install "$WORKDIR/eclsdk"

git -C "$WORKDIR/eclcli" tag -f 4.7.1 HEAD
"$VENV_DIR/bin/python" -m pip install "$WORKDIR/eclcli"

"$VENV_DIR/bin/python" -m pip check
"$VENV_DIR/bin/ecl" --version

cat <<EOF

Installation complete.

Activate the environment with:
  source "$VENV_DIR/bin/activate"

Then verify CLI loading with dummy auth values:
  export OS_AUTH_URL=http://example.invalid
  export OS_USERNAME=dummy
  export OS_PASSWORD=dummy
  export OS_PROJECT_NAME=dummy
  export OS_PROJECT_DOMAIN_NAME=Default
  export OS_USER_DOMAIN_NAME=Default
  ecl module list
EOF
