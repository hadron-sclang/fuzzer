#!/usr/bin/env bash
#
# Copied from the "Simplify parallel fuzzing" bug filed
# on rust-fuzz: https://github.com/rust-fuzz/afl.rs/issues/132
# and then modified to add a few features.
#
# Requirements:
#
# - nproc
# - tmux

set -euo pipefail

# Detect cores
ALL_CORES=$(nproc)
USED_CORES=$((ALL_CORES - 2))
if [[ "$USED_CORES" -lt 2 ]]; then
	echo "Error: USED_CORES < 2"
	exit 1
fi

# Usage
function print_usage() {
	echo "Usage: $0 [-j PROCS]"
	echo ""
	echo "Options:"
	echo "  -j PROCS    Number of parallel jobs to use (default: $USED_CORES)"
	echo "  -h,--help   Print this help and exit"
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
	case $1 in
		-j) USED_CORES=$2; shift ;;
		-h|--help) print_usage; exit 0 ;;
	esac
	shift
done
echo "Using $USED_CORES out of $ALL_CORES cores"

# Local variables
in_dir=in
sync_dir=out
tmux_window=afl

# Start main node
tmux new -d -s "afl01" -n $tmux_window "cargo afl fuzz -i $in_dir -o $sync_dir -M fuzzer01 target/debug/hadron_sclang_fuzzer"
echo "Spawned main instance afl01"

# Start secondary instances
for i in $(seq -f "%02.0f" 2 "$USED_CORES"); do
	tmux new -d -s "afl$i" -n $tmux_window "cargo afl fuzz -i $in_dir -o $sync_dir -S fuzzer$i target/debug/hadron_sclang_fuzzer"
	echo "Spawned secondary instance afl$i"
done

# Show status output
echo ""
echo "Tmux sessions:"
tmux ls | grep afl
echo ""
echo "Tmux cheatsheet (shell):"
echo "  Attach:"
echo "    tmux attach -t afl01"
echo "  Kill all sessions:"
echo "    tmux kill-server"
echo ""
echo "Tmux chatsheet (inside tmux):"
echo "  List sessions:"
echo "    Ctrl-b s"
echo "  Switch to next session:"
echo "    Ctrl-b )"
echo "  Switch to prev session:"
echo "    Ctrl-b ("
echo "  Detach:"
echo "    Ctrl-b d"

