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

The project has two external dependencies:
- `swift-crypto` (3.0.0+): Apple's cryptographic library
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
   - Supports multiple output targets (print, syslog, file, OSLog, ring buffer)
   - Environment/UserDefaults configurable via `LOGLEVEL` and `LOGSINK`
   - Thread-safe with background dispatch queue (`Logger.dispatchQueue`); all sink
     calls arrive serially on that queue — sinks can rely on this for confinement
   - `RingBufferLogger` ("flight recorder"): buffers entries in RAM only and replays
     them to a target sink on demand. Use it when logging I/O would perturb or hide
     timing-sensitive bugs, or in release builds to retrieve the recent past after a
     problem was observed. Configure via
     `LOGSINK=ring://?capacity=65536&keep=30&target=<percent-encoded sink url>&autodump=error`
     (plus `LOGLEVEL=TRACE` so entries reach the buffer). Triggers:
     `Logger.ringBuffer?.dump(last:)` from code, `installTrigger(signal: SIGUSR1)` +
     `kill -USR1 <pid>` from outside, or `autodump=error|fault` for automatic flushing.
     Without a `target`, dumps go to a timestamped `logdump-*.log` in Caches.
     In tests, synchronize with `waitUntilDumped()` — never with sleeps

4. **PropertyWrappers** (`PropertyWrappers/`): Utility property wrappers
   - `@Default`: Codable with default values
   - `@Clamped`: Value constraints
   - `@HexEncoded`: Automatic hex encoding/decoding
   - `@Protected`: Thread-safe property access

5. **Storage** (`Storage/`): Data persistence abstractions
   - `Keychain`: Secure storage interface
   - `ExtendedFileAttributes`: File metadata handling
   - Storage backend protocol for pluggable backends

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

Reliability rules for logging tests (output-based tests have proven flaky here):
- Never assert on captured stdout/stderr — feed entries into an in-memory recording
  sink and assert on its collected `LogEntry` values instead
- Never synchronize with sleeps — feed entries via `Logger.dispatchQueue.sync` (the
  production path) and use `RingBufferLogger.waitUntilDumped()` after dumps
- Avoid the global `Logger.destination`/`overrideSink` static state in tests;
  instantiate sinks directly so tests stay order-independent
- When testing signal delivery, use process-directed `kill(getpid(), SIG…)`, not
  `raise()` — the latter targets the calling thread, which may block the signal
  under XCTest; also keep re-sending in a poll loop, since dispatch signal sources
  register asynchronously and an early one-shot signal can get lost

## Development Practices

- All files include copyright header: `// Cornucopia – (C) Dr. Lauer Information Technology`
- Extensions are organized by the type they extend
- Comprehensive `#if` conditions ensure cross-platform compatibility
- Property wrappers follow Codable protocols where applicable
- Logger uses background queue for thread safety
