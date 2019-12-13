#!/bin/bash
set -eo pipefail
./intcode | xargs ./count-blocks.sh