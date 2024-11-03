#!/bin/bash

# Usage:
#   ./development/update_playwright_driver.sh 1.14.0-next-1628583854000
#
# Available versions can be found in https://github.com/microsoft/playwright/actions/workflows/publish_canary_driver.yml
#
# NOTE: direnv is assumed to be installed.

DRIVER_VERSION=$1
DRIVER_DOWNLOAD_DIR=~/Downloads

if [ "$(uname)" == 'Darwin' ]; then
  DRIVER_PLATFORM='mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  DRIVER_PLATFORM='linux'
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

echo "## Downloading driver"

wget https://playwright.azureedge.net/builds/driver/next/playwright-$DRIVER_VERSION-$DRIVER_PLATFORM.zip -O __driver.zip || wget https://playwright.azureedge.net/builds/driver/playwright-$DRIVER_VERSION-$DRIVER_PLATFORM.zip -O __driver.zip

echo "## Extracting driver"

mv __driver.zip $DRIVER_DOWNLOAD_DIR/
pushd $DRIVER_DOWNLOAD_DIR/
unzip __driver.zip -d playwright-$DRIVER_VERSION-$DRIVER_PLATFORM
rm __driver.zip
DRIVER_DIR=$(pwd)/playwright-$DRIVER_VERSION-$DRIVER_PLATFORM
DRIVER_PATH="$DRIVER_DIR/node $DRIVER_DIR/package/cli.js"
popd

echo "## Setting PLAYWRIGHT_CLI_EXECUTABLE_PATH($DRIVER_PATH) into .envrc"

echo "export \"PLAYWRIGHT_CLI_EXECUTABLE_PATH=$DRIVER_PATH\"" > .envrc
direnv allow .

echo "## Updating API docs"

$DRIVER_PATH print-api-json | jq > development/api.json
# $DRIVER_PATH --version | cut -d' ' -f2 > development/CLI_VERSION
echo $DRIVER_VERSION > development/CLI_VERSION

echo "## Updating auto-gen codes"

rm lib/playwright_api/*.rb
find documentation/docs -name "*.md" | grep -v documentation/docs/article/ | xargs rm
bundle exec ruby development/generate_api.rb

echo "## Downloading browsers"

$DRIVER_PATH install
