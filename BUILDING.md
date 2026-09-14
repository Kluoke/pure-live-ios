# Build and test

## Requirements

- macOS
- Xcode 16 or newer
- iOS 17 SDK
- XcodeGen (`brew install xcodegen`)

## Generate the Xcode project

```bash
git clone https://github.com/Kluoke/pure-live-ios.git
cd pure-live-ios
xcodegen generate --spec PureLive/Config/Project.yml
open PureLive.xcodeproj
```

`PureLive.xcodeproj` is generated and is intentionally not committed. Regenerate it after changing `Project.yml`.

## Build from the command line

List available simulators first:

```bash
xcrun simctl list devices available
```

Then use one of the installed device names:

```bash
xcodebuild -project PureLive.xcodeproj \
  -scheme PureLive \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' \
  build
```

If your installed simulator has a different name, replace `iPhone 17` with that name.

## Run unit tests

```bash
xcodebuild test \
  -project PureLive.xcodeproj \
  -scheme PureLive \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest'
```

The test target currently covers basic model/platform wiring and the M3U8 fallback parser.

## Run in Xcode

1. Open `PureLive.xcodeproj`.
2. Select the `PureLive` scheme.
3. Select an iOS Simulator or a connected iPhone.
4. `Cmd+B` builds the app.
5. `Cmd+U` runs the unit tests.
6. `Cmd+R` launches the app.

## Functional smoke test

1. Open the **直播** tab.
2. Select a platform.
3. Search for a known live room or streamer.
4. Open a result.
5. Confirm that the stream list appears and that AVPlayer starts playback.
6. Switch quality when multiple stream URLs are returned.
7. Open **设置** and verify quality/danmaku preferences persist after relaunch.

## Current platform boundary

Bilibili, Douyu and Huya have native HTTP metadata/stream adapters in this repository. Kuaishou, Douyin and NetEase CC are wired into the same native adapter architecture but currently report an explicit unsupported/dynamic-signing error instead of pretending that an empty result is a successful implementation. Their upstream protocols require additional dynamic signing/session work before they can be considered production-ready.

Danmaku transport is similarly separated from the generic UI model; platform-specific WebSocket/protocol implementations are not claimed as complete until they can be exercised against live rooms.

The project intentionally does **not** expose the upstream custom IPTV/M3U8-source feature as a product feature. Internal HLS/M3U8 parsing remains because platform live streams commonly use HLS.
