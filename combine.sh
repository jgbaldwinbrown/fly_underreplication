#!/bin/bash
set -e

cat files.txt | go run combine.go > combined.txt
