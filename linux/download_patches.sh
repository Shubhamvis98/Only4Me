#!/bin/bash
#
# Download commits json data using github api
# Example:
#   wget https://api.github.com/repos/{owner}/{repo}/commits?per_page=1000&page=1&sha={branch} -O out.json
#   LAST will be the recent commit's SHA

LINK='https://api.github.com/repos/{owner}/{repo}/commits?per_page=1000&page=1&sha={branch}'
FIRST=2b3f3d9ebe24938fc0eab889292fee712ada1ea0
LAST=2329226f86c8a9d8b66220a38a2ca3eec96ae91a
START=0
COUNT=0

if [ ! -f out.json ]; then
    echo '[*] Downloading commit metadata...'
    wget -q "$LINK" -O out.json
fi

echo '[*] Downloading patches...'
for i in $(seq 0 $((`jq 'length' out.json` - 1))); do
    FILENAME="$(printf "%04d" $((COUNT + 1)))-$(jq -r "reverse | .[${i}].commit.message" out.json | head -n1 | sed 's#[ !:()/=]#-#g').patch"
    LINK="$(jq -r "reverse | .[${i}].html_url" out.json).patch"
    SHA=$(jq -r "reverse | .[${i}].sha" out.json)
    [ "$SHA" == "$FIRST" ] && START=1
    if [ "$START" -eq 1 ]; then
        echo FOUND $SHA
        wget $LINK -O $FILENAME
        COUNT=$((COUNT + 1))
    fi
    [ "$SHA" == "$LAST" ] && START=0
done

