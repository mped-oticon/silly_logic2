#!/usr/bin/env bash
set -eu # exit on failure

THIS_SCRIPT_FILE="$(readlink -f ${BASH_SOURCE[0]})"
THIS_SCRIPT_DIR="$(dirname $THIS_SCRIPT_FILE)"
ROOT_DIR="${THIS_SCRIPT_DIR}/../.."
export PATH="$PATH:${ROOT_DIR}"


function folder_bigger_than
{
    local folder="$1"
    local bytes="$2"

    test -e "$folder" && \
    du --total --summarize --bytes "$folder" \
    | awk -v thres=$bytes '
        {n=$1}
        END {
            bigger = (n>=thres)
            print bigger ? "ge": "lt", n, thres
            exit(bigger ? 0 : 1) 
        }
    '
}



cd $ROOT_DIR

export DISPLAY=:SOMETHING_INTENTIONALLY_WRONG

# Perform virtual capture
auto_saleae.py --server_cmd './logic_vnc.sh' --capture --verbose -d F4241 --outdir "${THIS_SCRIPT_DIR}/output" ${GITHUB_OPTS-}

# Check capture contains more than some small csv headlines
folder_bigger_than "${THIS_SCRIPT_DIR}/output" 10000

rm -rf "${THIS_SCRIPT_DIR}/output" || true
