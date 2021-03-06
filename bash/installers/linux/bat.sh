#!/bin/bash

echo -e "Installing latest version of bat\n"

download_url=$(
  curl -sL https://api.github.com/repos/sharkdp/bat/releases/latest \
  | jq -r '.assets[] | select(.name | (contains("bat_") and contains("amd64"))) | .browser_download_url'
)

echo "Downloading from $download_url"
curl -sL "$download_url" -o bat-latest.deb

echo "Running installer"
sudo dpkg -i bat-latest.deb

echo "Cleaning up"
rm bat-latest.deb

echo -e "✔ Done!\n"
