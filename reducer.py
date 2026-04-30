#!/usr/bin/env python3
import sys

current_area = None
current_count = 0

for line in sys.stdin:
    line = line.strip()
    area, count = line.split('\t', 1)
    count = int(count)
    if area == current_area:
        current_count += count
    else:
        if current_area:
            print(f'{current_area}\t{current_count}')
        current_area = area
        current_count = count

if current_area:
    print(f'{current_area}\t{current_count}')