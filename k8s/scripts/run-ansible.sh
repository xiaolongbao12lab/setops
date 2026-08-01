#!/bin/bash

set -e

VENV="$(dirname "$0")/../.venv"

if [ ! -d "$VENV" ]; then
    echo "Virtual environment not found: $VENV"
    exit 1
fi

"$VENV/bin/ansible-playbook" "$@"