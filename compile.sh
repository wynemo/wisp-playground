#!/bin/bash
for path in $*; do
  filename=$(basename "$path")
  prefix="${filename%.*}"
  wisp <"$path" >"$prefix.js"
done