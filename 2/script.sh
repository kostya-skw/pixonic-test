#!/usr/bin/env python3
import sys


def main(file = sys.argv[1]):
    ips = {}
    with open(file, encoding = 'utf-8') as f:
        for line in f:
            ip = line.split()[0]
            if ip not in ips:
                ips[ip] = 0
            ips[ip] += 1

    top_ips = sorted(ips.items(), key=lambda d: d[1], reverse=True)[0:5]
    n = len(str(top_ips[0][1])) + 3
    format = "{:>15}: {:.>%s}" % n
    for ip, count in top_ips:
        print(format.format(ip, count))

if __name__ == "__main__":
    main()
