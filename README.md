# Pure Live iOS

Native iOS rewrite of [Pure Live](https://github.com/DuckHK/pure_live), implemented with Swift and SwiftUI.

## Supported providers

- Bilibili
- Douyu
- Huya
- Kuaishou
- Douyin
- NetEase CC

> Custom M3U8 / IPTV is intentionally not part of this native rewrite.

## Native stack

- Swift 6 / SwiftUI
- AVFoundation / AVKit
- URLSession
- URLSessionWebSocketTask
- Observation / AppStorage
- XcodeGen project definition

## Architecture

`SwiftUI Views -> ViewModels -> Platform Services -> URLSession -> AVPlayer`

Each provider implements the same `LivePlatformService` interface. Provider-specific HTTP parameters, response parsing and playback URL construction stay isolated from the UI.

## Current native features

- Native SwiftUI application shell
- Platform selector
- Live-room search flow
- Room detail and native HLS/stream playback flow
- Bilibili category/search/play URL adapter
- Douyu category/search/play URL adapter
- Huya search/category/play URL adapter
- Kuaishou / Douyin / NetEase CC adapter placeholders for provider endpoints that require additional current signing/protocol work
- M3U8 master-playlist parsing
- Danmaku transport abstraction
- Settings screen
- Unit-test target

## Building

The repository contains `PureLive/Config/Project.yml` for XcodeGen. On macOS with XcodeGen installed:

```bash
xcodegen generate --spec PureLive/Config/Project.yml
open PureLive.xcodeproj
```

## License

This project is derived from the GPL-3.0 licensed Pure Live project. See `LICENSE` and `NOTICE.md` for licensing and attribution.
