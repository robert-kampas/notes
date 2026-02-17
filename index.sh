#!/bin/bash

{
    echo "# Index"

    find . -mindepth 1 -not -path './.git*' -not -name 'README.md' -not -name 'index.sh' -not -name '.DS_Store' | sort | while read -r item; do
        relative="${item#./}"
        name=$(basename "$relative")
        depth=$(echo "$relative" | tr -cd '/' | wc -c)
        indent=$(printf '%*s' $((depth * 4)) '')

        if [ -d "$item" ]; then
            title=$(echo "$name" | sed 's/-/ /g; s/\b\(.\)/\u\1/g')
            echo "${indent}* [${title}](${relative}/)"
        else
            echo "${indent}* [${name}](${relative})"
        fi
    done
} > README.md

echo "README.md generated."