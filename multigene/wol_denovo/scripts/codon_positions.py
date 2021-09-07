#! /usr/bin/env python

import sys

nums = map(int, sys.stdin.readlines()[0].strip().split(", "))

res = []
for i in nums:
	res += [i, i+1, i+2]
print(str(res).replace('[','{ ').replace(']',' }').replace(", ",","))
