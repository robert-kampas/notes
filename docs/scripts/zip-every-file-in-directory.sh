#!/bin/bash

for dir in */; do
    dir="${dir%/}"
    zip -r "${dir}.zip" "${dir}"
done
