#!/bin/sh

set -e

find $1 -name "*.jax" -print | while read line; do
  echo Checking $line
  nvcheck $line
done
