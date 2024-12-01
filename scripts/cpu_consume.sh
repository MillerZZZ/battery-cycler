#!/bin/bash
# This script consumes CPU by continuously hashing random data
cat /dev/random | md5sum
