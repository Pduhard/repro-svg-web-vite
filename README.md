# react-native-svg 15.16 breaks a Vite web build

A Vite 8 app (pnpm, `react-native` aliased to `react-native-web`) that renders one `<Svg><Rect/></Svg>`.
Two independent errors, for [#3086](https://github.com/software-mansion/react-native-svg/issues/3086) and [#3087](https://github.com/software-mansion/react-native-svg/issues/3087).

## Run

```sh
pnpm install
pnpm build      # react-native-svg 15.16.0, react-native 0.88.0
./matrix.sh     # every pair below
```

| react-native-svg | react-native | config | `vite build` |
|---|---|---|---|
| 15.15.4 | 0.86.3 | default | ✓ |
| 15.15.4 | 0.88.0 | default | ✗ cannot resolve `@react-native/assets-registry/registry` from `lib/resolveAssetUri.js` |
| 15.16.0 | 0.86.3 | default | ✗ `"TurboModuleRegistry" is not exported` by react-native-web |
| 15.16.0 | 0.88.0 | default | ✗ `"TurboModuleRegistry" is not exported` |
| 15.16.0 | 0.86.3 | `shimMissingExports` | ✓ |
| 15.16.0 | 0.88.0 | `shimMissingExports` | ✗ cannot resolve `@react-native/assets-registry/registry` from `lib/resolveAssetUri.web.js` |

## 1. `TurboModuleRegistry` on the web ([#3086](https://github.com/software-mansion/react-native-svg/issues/3086))

New in 15.16.0. `lib/SvgTouchableMixin.js` requires `../fabric/NativeSvgSoundModule` inside an Android-only branch,
but the bundler still follows it, and that file imports `TurboModuleRegistry`, which react-native-web does not export.
Rolldown (Vite 8) fails on a missing export by default.

## 2. `@react-native/assets-registry` is not declared ([#3087](https://github.com/software-mansion/react-native-svg/issues/3087))

`lib/resolveAssetUri.web.js` imports `@react-native/assets-registry/registry`, but react-native-svg does not list it in its dependencies.
Up to React Native 0.86 it resolves through react-native's own dependency (pnpm hoists it into `node_modules/.pnpm/node_modules`).
React Native 0.87 stopped depending on it, so nothing provides it. [#3076](https://github.com/software-mansion/react-native-svg/pull/3076) removed the import from the native path only.

## Fix

Branch [`with-fix`](../../tree/with-fix): `pnpm build` passes on 15.16.0 + React Native 0.88.0 with the default config, and the page renders the `<rect>` with no console error.

- `@react-native/assets-registry` added to react-native-svg's `dependencies` (`packageExtensions` in `pnpm-workspace.yaml`).
- The touch sound moves out of `SvgTouchableMixin` into `lib/playTouchSound.android.js`, with a no-op `lib/playTouchSound.js` for iOS and web (`patches/`), the same split as `resolveAssetUri.ts` / `resolveAssetUri.web.ts`. The sound module stays out of the iOS and web graphs, and is never evaluated on iOS, as with today's lazy `require`.
