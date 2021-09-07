#! /usr/bin/env python

import sys

nums = map(int, sys.stdin.readlines()[0].strip()[2:-2].split(","))

keep=[]
for num in nums:
	if num % 3 == 0:
		keep.append(int(num/3))
print(str(keep).replace('[','{ ').replace(']',' }').replace(", ",","))
