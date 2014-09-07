#!/bin/bash

echo "$(LC_ALL=C lscpu | grep  'CPU MHz' | grep -o [0-9\.]*$ | grep -o ^[0-9]*) MHz"
