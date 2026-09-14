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
- WebKit for dynamic provider web sessions
- URLSession / URLSessionWebSocketTask
- Observation / AppStorage
- XcodeGen project definition

## Architecture

`SwiftUI Views -> ViewModels -> Platform Services -> Web/HTTP session -> LiveStream -> AVPlayer`

Each provider implements the same `LivePlatformService` interface. Provider-specific HTTP parameters, response parsing, session bootstrap and playback URL construction stay isolated from the UI.

## Native features

- Native SwiftUI application shell
- Platform selector
- Live-room search flow
- Room detail and native HLS/stream playback
- Provider playback headers applied to AVPlayer
- Bilibili category/search/play URL adapter
- Douyu category/search/play URL adapter
- Huya search/category/play URL adapter
- Kuaishou GraphQL + web-session playback adapter
- Douyin live-page web-session playback adapter
- NetEase CC live-page web-session playback adapter
- M3U8 master-playlist parsing
- Danmaku transport abstraction and UI model
- Settings screen
- Unit-test target

### Dynamic provider sessions

Kuaishou, Douyin and NetEase CC use `WKWebView` as a compatibility boundary for provider-controlled JavaScript/session state. This lets the current web page establish cookies, tokens and page-generated playback descriptors instead of shipping a stale copied signing algorithm. Public JSON/GraphQL fallbacks are used where available.

The rest of the application remains native Swift; the web session is isolated inside the platform adapters.

## Building

The repository contains `PureLive/Config/Project.yml` for XcodeGen. On macOS with XcodeGen installed:

```bash
xcodegen generate --spec PureLive/Config/Project.yml
open PureLive.xcodeproj
```

See `BUILDING.md` for simulator tests and the functional smoke-test checklist.

## License

This project is derived from the GPL-3.0 licensed Pure Live project. See `LICENSE` and `NOTICE.md` for licensing and attribution.
