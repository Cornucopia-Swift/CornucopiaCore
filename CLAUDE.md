# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CornucopiaCore is a Swift Package Manager library providing essential utilities for Swift developers across Apple platforms (iOS 14+, macOS 12+, tvOS 14+, watchOS 8+). It's a collection of extensions, utilities, and helper classes designed to augment Foundation and platform-specific frameworks.

## Build System & Commands

This project uses Swift Package Manager with the following commands:

- **Build**: `swift build`
- **Test**: `swift test`
- **Clean**: `swift package clean`

The project targets Swift 5.10+ and has continuous integration via GitHub Actions that runs on both Ubuntu and macOS.

## Dependencies

The project has three external dependencies:
- `swift-crypto` (3.0.0+): Apple's cryptographic library
- `SWCompression` (4.8.5+): Compression utilities  
- `AnyCodable` (0.6.6+): Type-erased Codable support (re-exported at module level)

## Code Architecture

### Module Structure
The main module `CornucopiaCore` is organized into several logical groups:

#### Core Namespace
All public APIs are nested under `Cornucopia.Core` namespace. The main entry point is `Sources/CornucopiaCore/CornucopiaCore.swift` which defines the namespace and re-exports `AnyCodable`.

#### Major Component Categories

1. **Extensions** (`Extensions/`): Platform and Foundation type extensions
   - Organized by type (Array, String, Data, etc.)
   - Follow `CC_` prefix convention for public methods
   - Cover networking, data manipulation, validation, and utility functions

2. **Features** (`Features/`): Standalone functionality modules
   - `DeviceInfo`: Cross-platform device identification with UUID persistence
   - `JWT`: JSON Web Token support
   - `Benchmarking`: Performance measurement utilities
   - `Concurrency`: Async/await utilities and timeout mechanisms
   - `Environment`: Environment variable handling

3. **Logging** (`Logging/`): Flexible logging system
   - `Logger`: Main logging interface with configurable sinks
   - Supports multiple output targets (print, syslog, file, OSLog)
   - Environment/UserDefaults configurable via `LOGLEVEL` and `LOGSINK`
   - Thread-safe with background dispatch queue

4. **PropertyWrappers** (`PropertyWrappers/`): Utility property wrappers
   - `@Default`: Codable with default values
   - `@Clamped`: Value constraints
   - `@HexEncoded`: Automatic hex encoding/decoding
   - `@Protected`: Thread-safe property access

5. **Storage** (`Storage/`): Data persistence abstractions
   - `Keychain`: Secure storage interface
   - `ExtendedFileAttributes`: File metadata handling
   - Storage backend protocol for pluggable backends

6. **Networking** (`Networking/`): HTTP utilities
   - HTTP constants and status codes
   - Networking helper functions

### Naming Conventions

- Public extension methods use `CC_` prefix
- Internal static constants use descriptive names
- Property wrappers follow Swift conventions
- Logger categories derived from `#fileID` by default

### Platform Considerations

The codebase includes extensive platform-specific compilation conditions:
- `#if canImport(ObjectiveC)` for Apple vs. Linux differentiation  
- Platform-specific imports (`UIKit`, `WatchKit`, etc.)
- Conditional feature availability (syslog not available on watchOS)
- Architecture-specific code paths in DeviceInfo

### Testing Structure

Tests mirror the source structure under `Tests/CornucopiaCoreTests/` and cover:
- Extension functionality
- Property wrapper behavior
- Core features like logging and device info
- Cross-platform compatibility

## Development Practices

- All files include copyright header: `// Cornucopia – (C) Dr. Lauer Information Technology`
- Extensions are organized by the type they extend
- Comprehensive `#if` conditions ensure cross-platform compatibility
- Property wrappers follow Codable protocols where applicable
- Logger uses background queue for thread safety