# CornucopiaCore

🌽 **The "horn of plenty"** – a symbol of abundance.

[![SwiftPM](https://img.shields.io/badge/SPM-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS-success?logo=swift)](https://swift.org)
[![Swift](https://github.com/Cornucopia-Swift/CornucopiaCore/workflows/Swift/badge.svg)](https://github.com/Cornucopia-Swift/CornucopiaCore/actions?query=workflow%3ASwift)

## Overview

CornucopiaCore is a comprehensive Swift Package Manager library that provides essential utilities for Swift developers across all Apple platforms (iOS 16+, macOS 13+, tvOS 16+, watchOS 9+). It's designed as a "horn of plenty" – offering a rich collection of extensions, utilities, and helper classes to augment Foundation and platform-specific frameworks.

## Features

### 🛠 Extensions
Powerful extensions to Foundation and platform types:
- **String**: Hex encoding/decoding, validation, crypto utilities, IPv4 handling
- **Data**: Array conversion, number encoding/decoding, string utilities
- **Array & Collection**: Dictionary conversion, hex operations, chunked sequences
- **Date & Time**: Pretty printing, past/present/future checks, ISO8601 formatting
- **FileManager**: Compression, path utilities, extended attributes
- **And many more**: All extensions use the `CC_` prefix to avoid naming conflicts

### 📊 Data Structures
Thread-safe and efficient data structures:
- **ChunkedSequence & ReverseChunkedSequence**: Process collections in chunks
- **ThreadSafeDictionary**: Concurrent access to dictionaries
- **CyclicSequenceNumber**: Rolling sequence numbers

### 🏷 Property Wrappers
Convenient property wrappers for common patterns:
- **@Clamped**: Automatically clamp values to specified ranges
- **@HexEncoded**: Automatic hex string encoding/decoding for Data
- **@Protected**: Thread-safe property access with locking
- **@Default**: Codable properties with fallback values

### 📱 Device & System
Cross-platform device information and system utilities:
- **DeviceInfo**: Hardware model, OS version, user agent strings
- **Device**: Persistent UUID generation with Keychain storage
- **Environment**: Easy access to environment variables
- **SysLog**: System logging integration

### 🔐 Security & Storage
Secure storage and cryptographic utilities:
- **Keychain**: Simple, secure storage interface
- **JWT**: JSON Web Token support with cryptographic validation
- **PKCS12**: Certificate and private key handling
- **Extended File Attributes**: Metadata storage on files

### 📋 Logging System
Flexible, configurable logging with multiple output targets:
- **Multi-sink support**: Print, file, syslog (UDP/TCP), OSLog
- **Environment configuration**: Control via `LOGLEVEL` and `LOGSINK` variables
- **Thread-safe**: Background dispatch queue processing
- **Level filtering**: Trace, debug, info, notice, error, fault

### ⚡ Concurrency & Performance
Modern async/await utilities and performance tools:
- **AsyncWithTimeout**: Timeout support for async operations
- **Benchmarking**: Performance measurement utilities
- **Task**: Sleep utilities for async contexts
  
For higher-level HTTP networking, use the dedicated sibling package [CornucopiaHTTP](../CornucopiaHTTP).

## Installation

### Swift Package Manager

Add CornucopiaCore to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Cornucopia-Swift/CornucopiaCore.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/Cornucopia-Swift/CornucopiaCore.git`

## Usage Examples

### Basic Logging

```swift
import CornucopiaCore

let logger = Cornucopia.Core.Logger()

logger.info("Application started")
logger.debug("Debug information")
logger.error("Something went wrong")

// Configure via environment variables
// LOGLEVEL=DEBUG LOGSINK=print:// ./your-app
```

### Property Wrappers

```swift
import CornucopiaCore

struct GameScore {
    @Cornucopia.Core.Clamped(to: 0...100)
    var health: Int = 100
    
    @Cornucopia.Core.HexEncoded
    var sessionId: Data = Data()
    
    @Cornucopia.Core.Protected
    var score: Int = 0
}

var game = GameScore()
game.health = 150  // Automatically clamped to 100
game.sessionId = "deadbeef".CC_hexDecodedData
```

### Device Information

```swift
import CornucopiaCore

let device = Cornucopia.Core.Device.current
print("Device: \(device.info.model)")
print("OS: \(device.info.operatingSystem) \(device.info.operatingSystemVersion)")
print("User Agent: \(device.info.userAgent)")
print("Persistent UUID: \(device.uuid)")
```

### String Extensions

```swift
import CornucopiaCore

// Hex operations
let data = "deadbeef".CC_hexDecodedData
let hexString = data.CC_hexEncodedString()

// Content validation
let isValidEmail = "user@example.com".CC_isValidEmail
let isValidIPv4 = "192.168.1.1".CC_isValidIPv4Address

// Crypto
let sha256 = "Hello World".CC_sha256
```

### Secure Storage

```swift
import CornucopiaCore

let keychain = Cornucopia.Core.Keychain.standard

// Store sensitive data
let apiKey = "secret-api-key".data(using: .utf8)!
keychain.save(data: apiKey, for: "api-key")

// Retrieve data
if let storedKey = keychain.load(key: "api-key") {
    let keyString = String(data: storedKey, encoding: .utf8)
}
```

### Data Structures

```swift
import CornucopiaCore

// Thread-safe dictionary
let safeDict = Cornucopia.Core.ThreadSafeDictionary<String, Int>()
safeDict["key"] = 42

// Process collections in chunks
let numbers = Array(1...1000)
for chunk in numbers.CC_chunked(by: 10) {
    // Process 10 numbers at a time
    print(chunk)
}
```

### Concurrency

```swift
import CornucopiaCore

// Timeout for async operations
let result = try await Cornucopia.Core.asyncWithTimeout(seconds: 5) {
    return await someAsyncOperation()
}

// Benchmarking
let duration = Cornucopia.Core.benchmark {
    // Code to measure
    expensiveOperation()
}
print("Operation took: \(duration) seconds")
```

## Platform Support

- **iOS**: 16.0+
- **macOS**: 13.0+
- **tvOS**: 16.0+
- **watchOS**: 9.0+
- **macCatalyst**: 13.0+

## Dependencies

CornucopiaCore has minimal external dependencies:
- [swift-crypto](https://github.com/apple/swift-crypto): Apple's cryptographic library
- [AnyCodable](https://github.com/mickeyl/AnyCodable): Type-erased Codable support

## Architecture

All public APIs are organized under the `Cornucopia.Core` namespace to avoid naming conflicts. The library is structured into logical modules:

- **Extensions/**: Foundation and platform type extensions
- **Features/**: Standalone functionality (DeviceInfo, JWT, etc.)
- **Logging/**: Flexible logging system
- **PropertyWrappers/**: Utility property wrappers
- **Storage/**: Data persistence abstractions

## Contributing

Contributions are welcome! This library grows on-demand as real-world projects require new functionality. Feel free to:

1. Report issues or request features
2. Submit pull requests with new utilities
3. Improve documentation and examples

## License

CornucopiaCore is available under the MIT license. See LICENSE for details.

---

**Cornucopia** – *Dr. Lauer Information Technology*
