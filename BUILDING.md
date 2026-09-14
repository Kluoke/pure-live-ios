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

```bash
xcrun simctl list devices available
xcodebuild -project PureLive.xcodeproj -scheme PureLive -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest' build
```

Replace the simulator name when necessary.

## Run unit tests

```bash
xcodebuild test -project PureLive.xcodeproj -scheme PureLive -destination 'platform=iOS Simulator,name=iPhone 17,OS=latest'
```

The test target covers platform wiring and the M3U8 fallback parser.

## Functional smoke test

1. Open the **直播** tab.
2. Select a platform and search for a known live room.
3. Open a result and verify that stream URLs are returned.
4. Confirm AVPlayer starts playback and that provider HTTP headers are honored.
5. Switch quality when multiple URLs are available.
6. For Kuaishou, Douyin and NetEase CC, verify that the native web session can load the live page and obtain the current page-generated stream URL.
7. Open **设置** and verify preferences persist after relaunch.

## Dynamic web providers

Kuaishou, Douyin and NetEase CC do not rely on a copied, hard-coded signing algorithm. `PlatformWebSession` uses an iOS `WKWebView` with a persistent website data store so the provider's current JavaScript can establish cookies, tokens and other page/session state. The adapter then parses the live page's current stream descriptors and falls back to the provider's public JSON/GraphQL endpoint where available.

This is intentional: these providers change their web signatures and session fields frequently. Keeping the signing/session execution in the provider's own web runtime avoids shipping a stale signature implementation. The app still uses native Swift models, networking, AVPlayer and SwiftUI; WKWebView is only the compatibility boundary for dynamic provider web protocols.

## Platform coverage

Native adapters are now present for Bilibili, Douyu, Huya, Kuaishou, Douyin and NetEase CC. Kuaishou uses its GraphQL `LiveDetail` fallback; Douyin and CC use their current live-page session; all three share the same `LiveRoom`/`LiveStream` abstraction.

Platform-specific danmaku transports are still a separate layer and are not required for stream playback. The generic danmaku model/UI is already present and provider-specific WebSocket/protobuf implementations can be added without changing the player architecture.

The project intentionally does **not** expose the upstream custom IPTV/M3U8-source feature as a product feature. Internal HLS/M3U8 parsing remains because platform live streams commonly use HLS.
