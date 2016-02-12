#!/bin/sh

set -e

find $1 -name "*.jax" -print | xargs nvcheck
