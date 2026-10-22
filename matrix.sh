#!/usr/bin/env bash
# Builds every react-native-svg × react-native pair, with and without shimMissingExports.
set -u
run() {
  pnpm add react-native-svg@$1 react-native@$2 >/dev/null 2>&1
  printf "%-8s RN %-7s %-20s → " "$1" "$2" "$3"
  pnpm exec vite build --config $3 2>&1 | sed 's/\x1b\[[0-9;]*m//g' \
    | grep -oE "built in [0-9.]+m?s|\"TurboModuleRegistry\" is not exported|failed to resolve import \"[^\"]+\" from \"[^\"]*react-native-svg/[^\"]+\"" \
    | sed -E 's#from ".*react-native-svg/#from react-native-svg/#' | head -1
}
run 15.15.4 0.86.3 vite.config.js
run 15.15.4 0.88.0 vite.config.js
run 15.16.0 0.86.3 vite.config.js
run 15.16.0 0.88.0 vite.config.js
run 15.16.0 0.86.3 vite.shim.config.js
run 15.16.0 0.88.0 vite.shim.config.js
git checkout -q package.json pnpm-lock.yaml && pnpm install >/dev/null 2>&1
