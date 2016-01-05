#!/bin/bash
DIR="$( cd "$( dirname "$0" )" && pwd )"
pushd $DIR >/dev/null

# use tridentloop shortened uname
read -p "Username: " FTPUSER
scp -r www-release/* "$FTPUSER@tridentloop.com:www/preview"

open http://tridentloop.com/preview

popd >/dev/null
