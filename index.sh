#!/bin/bash
{
    readonly DOCS_DIR="docs"
    cd "./$DOCS_DIR"
    echo "# Index"
    echo ""
    find . -mindepth 1 -not -name '.DS_Store' -print0 |
        sort -z |
        while IFS= read -r -d '' item; do
            relative="$DOCS_DIR/${item#./}"
            name=$(basename "$relative")
            depth=$(echo "$relative" | tr -cd '/' | tr -d ' ' | wc -c | tr -d ' ')
            indent=$(printf '%*s' $((depth * 4 - 4)) '')
            if [ -d "$item" ]; then
                title=$(echo "$name" | perl -pe 's/-/ /g; s/\b(\w)/\u$1/g')
                echo "${indent}* [${title}](${relative}/)"
            else
                echo "${indent}* [${name}](${relative})"
            fi
        done
} > README.md
echo "README.md generated."