#!/bin/bash

set -Eeuox pipefail

INSTALL_LOCKFILE="gdal_install.lock"

gdal-config --version
# check a file to not run into a recursion
if [[ ! -e "$INSTALL_LOCKFILE" ]]; then
  touch "$INSTALL_LOCKFILE"
  # install gdal with specific options to use the host gdal library
  # need to remove the previously installed version for it to work correctly, but yarn remove would change the lock file
  rm -rf node_modules/gdal-async
  # install gdal-async with special flags for scalingo
  # use the range from package.json: a bare `yarn add gdal-async` takes the latest release and
  # rewrites package.json and yarn.lock, which fails the buildpack's frozen-lockfile prune step
  GDAL_ASYNC_RANGE=$(node -p "require('./package.json').dependencies['gdal-async']")
  CXXFLAGS="-I$HOME/.apt/usr/include/gdal" npm_config_build_from_source=true npm_config_shared_gdal=true yarn add --frozen-lockfile "gdal-async@$GDAL_ASYNC_RANGE"
  rm "$INSTALL_LOCKFILE"
fi
