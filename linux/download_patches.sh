#!/bin/bash
#
# Download commits json data using github api
# Example:
#   wget https://api.github.com/repos/{owner}/{repo}/commits?per_page=1000&page=1&sha={branch} -O out.json


for i in $(seq 0 $((`jq 'length' out.json` - 1)))
do
FILENAME="$(printf "%04d" $((i + 1)))-$(jq -r "reverse | .[${i}].commit.message" out.json | head -n1 | sed 's#[ !:()/]#-#g').patch"
LINK="$(jq -r "reverse | .[${i}].html_url" out.json).patch"
wget $LINK -O $FILENAME
done
