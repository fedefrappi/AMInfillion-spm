# AMInfillion

## Description

AMInfillion is an iOS SDK that integrates TrueX ads into iOS applications. It provides a wrapper around TrueX's web-based ad platform, handling ad loading, display, and interaction events.

## Installation

The package can be installed using Swift Package Manager. Minimum required iOS version is 14.0.

Add the following to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "<repository-url>", from: "<version>")
]
```

## Usage

1. Initialize the manager:

```swift
let manager = InfillionManager()
```

2. Request and show an ad:

```swift
// Request an ad
let ad = try await manager.request(userId: "user_id", placementKey: "placement_key")

// Show the ad
manager.showAd(ad, on: viewController,
    onStart: { ad in /* Handle ad start */ },
    onCredit: { ad in /* Handle ad credit */ },
    onClickthrough: { ad in /* Handle ad clickthrough */ },
    onFinish: { ad in /* Handle ad finish */ },
    onClose: { ad in /* Handle ad close */ }
)
```

## Features

- Asynchronous ad loading and display
- Event handling for ad interactions:
  - Start
  - Credit
  - Clickthrough
  - Finish
  - Close
- Full-screen ad presentation
- Built-in clickthrough handling
- Portrait mode orientation lock
- Support for inline media playback
- Debug mode web inspector (iOS 16.4+)

## Requirements

- iOS 14.0+
- Swift 5.4+
- WebKit framework
- JavaScriptCore framework

## Technical Details

The SDK integrates with TrueX's web-based ad platform using:

- Native view controllers for ad presentation
- WKWebView for ad content display
- JavaScript bridge for event handling
- Support for inline media playback
- Automatic ad lifecycle management
