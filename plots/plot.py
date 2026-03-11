#!/usr/bin/env python3
"""
Plot comparison of multiple OSU benchmark results.

Usage:
    python plot_osu.py \
        --files bw_gpu1.dat bw_gpu2.dat lat_gpu1.dat \
        --labels "GPU1 BW" "GPU2 BW" "GPU1 Lat" \
        --title "OSU MPI Benchmarks comparison" \
        --outfile osu_compare.png
"""

import argparse
import re
from pathlib import Path

import matplotlib.pyplot as plt

# Colors and linestyles chosen to resemble the example figure
COLOR_CYCLE = ['b', 'g', 'r', 'm', 'c', 'y']
LINESTYLE_CYCLE = ['-', '--', '-.', ':']
MARKER_CYCLE = ['o', 's', 'D', '^', 'v', 'x']

font_size=16

def parse_nccl_file(path):
    """
    Parse an nccl-tests result file.

    Returns:
        sizes  : list[int]   -- message sizes in bytes (non-zero only)
        values : list[float] -- out-of-place time in microseconds
        quantity : str       -- 'Latency'
        unit     : str       -- 'us'
    """
    sizes = []
    values = []

    with open(path, 'r') as f:
        for line in f:
            line = line.rstrip('\n')

            # Skip comments: lines starting with '#' or ' .. '
            stripped = line.lstrip()
            if not stripped:
                continue
            if stripped.startswith('#') or stripped.startswith('..'):
                continue

            parts = line.split()
            # Expect (at least) columns: size count type redop root time algbw busbw #wrong ...
            if len(parts) < 6:
                continue

            try:
                size = int(parts[1])
                # out-of-place time (us) is the first time column
                time_us = float(parts[5])
            except ValueError:
                # Not a data line
                continue

            # Skip tests that were not executed (size == 0)
            if size < 4:
                continue

            sizes.append(size)
            values.append(time_us)
#            if size >= 1048576:
#                break

    quantity = "Latency"
    unit = "us"
    return sizes, values, quantity, unit


def parse_osu_file(path):
    """
    Parse an OSU benchmark result file.

    Returns:
        sizes: list of int
        values: list of float (converted to GB/s if bandwidth in MB/s)
        quantity: str, either 'Bandwidth' or 'Latency'
        unit: str, e.g. 'GB/s' or 'us'
    """
    sizes = []
    values = []
    quantity = None
    unit = None

    header_re = re.compile(r'#\s*Size\s+(\w+)\s*\(([^)]+)\)', re.IGNORECASE)

    with open(path, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            if line.startswith('#'):
                # Try to detect what is measured and in which units
                m = header_re.match(line)
                if m:
                    quantity = m.group(1).capitalize()  # "Bandwidth" or "Latency"
                    unit = m.group(2)
                continue

            # Data line: size value
            parts = line.split()
            if len(parts) < 2:
                continue
            try:
                size = int(parts[0])
                val = float(parts[1])
            except ValueError:
                continue

            sizes.append(size)
            values.append(val)

    # Fallback if header pattern was not found
    if quantity is None or unit is None:
        with open(path, 'r') as f:
            txt = f.read().lower()
        if 'bandwidth' in txt:
            quantity = 'Bandwidth'
            if 'mb/s' in txt or 'mbps' in txt:
                unit = 'MB/s'
            else:
                unit = ''
        elif 'latency' in txt:
            quantity = 'Latency'
            if 'us' in txt:
                unit = 'us'
            else:
                unit = ''
        else:
            quantity = 'Value'
            unit = ''

    # Convert bandwidth from MB/s to GB/s for plotting
    if quantity == 'Bandwidth' and unit.lower() in ['mb/s', 'mbps', 'mb/s ']:
        # Use 1024 MB = 1 GB; change to 1000.0 if you prefer decimal
        values = [v / 1024.0 for v in values]
        unit = 'GB/s'

    return sizes, values, quantity, unit

def parse_file(path):
    p = str(path).lower()
    if "_perf_" in p:
        return parse_nccl_file(path)
    else:
        return parse_osu_file(path)


def main():
    parser = argparse.ArgumentParser(
        description="Plot comparison of multiple OSU benchmark results."
    )
    parser.add_argument(
        "--files",
        nargs="+",
        required=True,
        help="Input OSU result files.",
    )
    parser.add_argument(
        "--labels",
        nargs="+",
        help="Labels for each line (same order as --files). "
             "If omitted, filenames will be used.",
    )
    parser.add_argument(
        "--title",
        default="OSU Benchmarks comparison",
        help="Plot title.",
    )
    parser.add_argument(
        "--outfile",
        default=None,
        help="If given, save figure to this file instead of showing it.",
    )
    parser.add_argument(
        "--styles",
        nargs="+",
        help=(
            "Optional matplotlib line styles for each curve "
            "(same order as --files), e.g. 'r-o' 'g--' 'b^:'. "
            "If omitted, built-in color/marker cycles are used."
        ),
    )
    args = parser.parse_args()

    files = [Path(f) for f in args.files]
    if args.labels and len(args.labels) != len(files):
        raise SystemExit("Number of --labels must match number of --files")

    if args.styles and len(args.styles) != len(files):
        raise SystemExit("Number of --styles must match number of --files")

    labels = args.labels or [p.stem for p in files]
    styles = args.styles  # may be None

    plt.figure(figsize=(8, 6))

    # We might mix bandwidth and latency; keep track to know what to put on y-axis label.
    quantities = set()
    units = set()

    for idx, (path, label) in enumerate(zip(files, labels)):
        sizes, values, quantity, unit = parse_file(path)
        quantities.add(quantity)
        units.add(unit)

        if styles is not None:
            # Use user-provided matplotlib style string, e.g. 'r-o', 'g--', 'b^:'
            style = styles[idx]
            plt.plot(
                sizes,
                values,
                style,
                label=label,
                linewidth=2,
                markersize=6,
            )
        else:
            # Fallback to automatic cycles
            color = COLOR_CYCLE[idx % len(COLOR_CYCLE)]
            linestyle = LINESTYLE_CYCLE[idx % len(LINESTYLE_CYCLE)]
            marker = MARKER_CYCLE[idx % len(MARKER_CYCLE)]

            plt.plot(
                sizes,
                values,
                label=label,
                color=color,
                linestyle=linestyle,
                marker=marker,
                markersize=6,
                linewidth=2,
            )

    plt.xscale("log", base=10)
    plt.yscale("log", base=10)
    plt.xlabel("Message size (bytes)", fontsize=font_size)

    # Build y-label depending on what we actually plotted
    if len(quantities) == 1 and len(units) == 1:
        q = next(iter(quantities))
        u = next(iter(units))
        ylabel = f"{q} ({u})" if u else q
    else:
        # Mixed plot
        ylabel = "Metric"
    plt.ylabel(ylabel, fontsize=font_size)

    plt.title(args.title, fontsize=font_size+2, fontweight="bold")

    # Style similar to your example: grid, legend box with white background
    plt.grid(True, which="major", linestyle="-", linewidth=0.7, alpha=0.7)
    legend = plt.legend(
        loc="best",
        fontsize=font_size-2,
        frameon=True,
    )
    legend.get_frame().set_alpha(0.9)
    legend.get_frame().set_edgecolor("black")

    plt.tight_layout()

    if args.outfile:
        plt.savefig(args.outfile, dpi=300)
    else:
        plt.show()


if __name__ == "__main__":
    main()
