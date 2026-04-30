#!/usr/bin/env python3
import sys

for line in sys.stdin:
    line = line.strip()
    fields = line.split(',')
    if len(fields) > 5 and fields[5] != 'AREA NAME':
        area = fields[5]
        print(f'{area}\t1')