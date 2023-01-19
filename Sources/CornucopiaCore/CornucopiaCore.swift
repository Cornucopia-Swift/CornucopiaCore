//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import Foundation
import CoreFoundation
@_exported import AnyCodable

/// The "horn of plenty" – a symbol of abundance.
public enum Cornucopia {
    /// Core Subsystem
    public enum Core {
        static let Subsystem = "de.vanille.Cornucopia.Core"
        static var stderr = FileHandle.standardError
    }
}
