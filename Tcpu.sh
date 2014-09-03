#!/bin/bash

sensors | grep 'CPU Temp' | awk '{print $3}' | sed -e 's/+//'
