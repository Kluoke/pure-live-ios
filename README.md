# Pure Live iOS

Native iOS rewrite of [Pure Live](https://github.com/DuckHK/pure_live), implemented with Swift and SwiftUI.

## Goal

Rebuild the Pure Live experience as a first-class native iOS application instead of porting the Flutter UI/runtime.

Planned platforms:

- Bilibili
- Douyu
- Huya
- Kuaishou
- Douyin
- NetEase CC
- Custom M3U8 / IPTV

## Native stack

- Swift / SwiftUI
- AVFoundation / AVKit
- URLSession
- URLSessionWebSocketTask
- SwiftData

## Architecture

`Views -> ViewModels -> Platform Services -> Network/Parser -> Player`

Platform adapters expose a common native interface so individual live-stream providers can be migrated independently.

## License

This project is derived from the architecture and functionality of the GPL-3.0 licensed Pure Live project. See `LICENSE` for the applicable license text and `NOTICE` for attribution.
