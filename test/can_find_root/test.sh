#!/usr/bin/env bash

THIS_SCRIPT_FILE="$(readlink -f ${BASH_SOURCE[0]})"
THIS_SCRIPT_DIR="$(dirname $THIS_SCRIPT_FILE)"
ROOT_DIR="${THIS_SCRIPT_DIR}/../.."
export PATH="$PATH:${ROOT_DIR}"

which -a auto_saleae.py