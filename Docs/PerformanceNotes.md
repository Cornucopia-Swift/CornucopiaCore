## Performance Notes: Frozen & Move-Only Types

Summary of November 2024 audit focusing on Swift’s resilience and ownership features.

### Current Status
- `LogLevel`, `LogEntry`, `AnyValue` (+ `Error`), `RollingTimestamp` (+ `Mode`), `Parity`, `SysLogEntry` (+ nested enums), `JWT`, `AsyncWithTimeoutError`, `Environment`, `HexColor`, `RegularExpression`, and the stream `Exception` enums are now annotated `@frozen`. This removes the resilience cost when they’re consumed outside the defining module.

### `@frozen` Candidates
- `Sources/CornucopiaCore/Logging/LogSink.swift:19` – `LogLevel` exposes a closed set of cases that map to syslog levels. Freezing lets downstream code exhaustively switch without runtime thunks; `LogEntry` (line 40) benefits similarly thanks to its immutable payload.
- `Sources/CornucopiaCore/Extensions/OutputStream/OutputStream+ThrowingWrite.swift:8` and `Extensions/InputStream/InputStream+ThrowingRead.swift:8` – `Exception` enums cover the entire error surface (`unknown`/`eof`). Marking them frozen removes existential overhead when catching or comparing errors.
- `Sources/CornucopiaCore/Types/RollingTimestamp.swift:12` – `RollingTimestamp.Mode` is a simple two-case enum (`absolute`/`relative`); freezing eliminates resilient-switch indirection.
- `Sources/CornucopiaCore/Types/AnyValue.swift:54` – `AnyValue.Error` has fixed cases (`typeMismatch`, `outOfBounds`). Freezing enables better inlining for heavy generic call sites.
- `Sources/CornucopiaCore/Features/PKCS12/PKCS12.swift:12` – the `Error` enum encapsulates every exit path from `SecPKCS12Import`. Freezing ensures exhaustive pattern matching stays ABI-stable.

Before tagging additional structs (e.g., the various loggers or JWT records), double-check whether you might need to add stored properties later; freezing locks their layout.

### `~Copyable` (Move-Only) Opportunities
- `Sources/CornucopiaCore/Logging/FileLogger.swift:9` – wraps an exclusive `FileHandle`. Making `FileLogger` (and potentially `LogSink`) move-only prevents accidental implicit copies that might interleave writes or close the descriptor twice.
- `Sources/CornucopiaCore/Features/PKCS12/PKCS12.swift:10` – owns CF/Sec identities and trusts. Move-only semantics express single ownership, trimming redundant retain/release traffic when the struct crosses module boundaries.
- `Sources/CornucopiaCore/Types/RollingTimestamp.swift:10` – embeds a lazily created `CFDateFormatter`. Treating the struct as move-only keeps the formatter tied to a single logical timer and avoids duplicating the non-thread-safe CF object.

Adopting `~Copyable` requires the upcoming features `MoveOnlyPartialTypes` and `NoncopyableGenerics`. Compile with the corresponding `-enable-upcoming-feature` flags until these ship in stable Swift and gate the code with compiler checks if necessary. Also audit any existential storage (e.g., `Logger.destination`) to ensure it can host move-only conformers once you flip the switch.

### Next Steps
1. Decide which `@frozen` annotations are ABI-safe for the next release; bump the semantic version accordingly and run the test suite.
2. Prototype the move-only migration behind a feature flag, then measure log/PKCS12 hot paths with Instruments to verify the expected ARC reductions.
3. Revisit this document when Swift’s ownership features graduate to stable releases to remove the compiler flags and make the annotations unconditional.
