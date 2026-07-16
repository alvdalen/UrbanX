#!/bin/sh

CONFIG="${SRCROOT}/swiftgen.yml"

for candidate in \
  /opt/homebrew/bin/swiftgen \
  /usr/local/bin/swiftgen; do
  if [ -x "$candidate" ]; then
    exec "$candidate" config run --config "$CONFIG"
  fi
done

if command -v swiftgen >/dev/null 2>&1; then
  exec swiftgen config run --config "$CONFIG"
fi

echo "warning: SwiftGen not installed, using committed Strings.swift" >&2
