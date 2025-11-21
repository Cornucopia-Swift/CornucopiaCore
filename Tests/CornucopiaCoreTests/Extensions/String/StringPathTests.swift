//
//  Cornucopia – (C) Dr. Lauer Information Technology
//
import XCTest
@testable import CornucopiaCore

final class StringPathTests: XCTestCase {
    
    // MARK: - CC_basename Tests
    
    func testCC_basenameSimple() {
        let input = "/path/to/file.txt"
        let expected = "file.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameNoDirectory() {
        let input = "file.txt"
        let expected = "file.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameRoot() {
        let input = "/"
        let expected = ""
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameTrailingSlash() {
        let input = "/path/to/directory/"
        let expected = ""
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameMultipleSlashes() {
        let input = "/path/to//file.txt"
        let expected = "file.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameEmpty() {
        let input = ""
        let expected = ""
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameOnlySlashes() {
        let input = "///"
        let expected = ""
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameWithSpecialCharacters() {
        let input = "/path/to/file with spaces.txt"
        let expected = "file with spaces.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameDeepPath() {
        let input = "/very/deep/nested/path/to/file.ext"
        let expected = "file.ext"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    // MARK: - CC_dirname Tests
    
    func testCC_dirnameSimple() {
        let input = "/path/to/file.txt"
        let expected = "/path/to"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameNoDirectory() {
        let input = "file.txt"
        let expected = "/"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameRoot() {
        let input = "/"
        let expected = "/"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameTrailingSlash() {
        let input = "/path/to/directory/"
        let expected = "/path/to"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameMultipleSlashes() {
        let input = "/path/to//file.txt"
        let expected = "/path/to"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameEmpty() {
        let input = ""
        let expected = "/"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameOnlySlashes() {
        let input = "///"
        let expected = "/"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameSingleLevel() {
        let input = "/file.txt"
        let expected = "/"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameDeepPath() {
        let input = "/very/deep/nested/path/to/file.ext"
        let expected = "/very/deep/nested/path/to"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_dirnameComplexPath() {
        let input = "/Users/username/Documents/project/source/file.swift"
        let expected = "/Users/username/Documents/project/source"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    // MARK: - CC_realpath Tests
    
    func testCC_realpathExistingFile() {
        // Test with a path that should exist
        let input = "/"
        let result = input.CC_realpath
        XCTAssertNotNil(result)
        XCTAssertEqual(result, "/")
    }
    
    func testCC_realpathNonExistent() {
        let input = "/non/existent/path/that/should/not/exist"
        let result = input.CC_realpath
        XCTAssertNil(result)
    }
    
    func testCC_realpathEmpty() {
        let input = ""
        let result = input.CC_realpath
        XCTAssertNil(result)
    }
    
    func testCC_realpathRelative() {
        // Test with relative path (should work if current directory exists)
        let input = "."
        let result = input.CC_realpath
        XCTAssertNotNil(result)
        // Result should be an absolute path
        XCTAssertTrue(result!.starts(with: "/"))
    }
    
    // MARK: - Performance Tests
    
    func testCC_basenamePerformanceBaseline() {
        let input = "/very/deep/nested/path/with/many/components/to/file.txt"
        
        measure {
            for _ in 0..<1000 {
                _ = input.CC_basename
            }
        }
    }
    
    func testCC_dirnamePerformanceBaseline() {
        let input = "/very/deep/nested/path/with/many/components/to/file.txt"
        
        measure {
            for _ in 0..<1000 {
                _ = input.CC_dirname
            }
        }
    }
    
    // MARK: - Edge Cases
    
    func testCC_basenameUnicode() {
        let input = "/path/to/文件.txt"
        let expected = "文件.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_dirnameUnicode() {
        let input = "/路径/到/文件.txt"
        let expected = "/路径/到"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_basenameWithEmoji() {
        let input = "/path/to/📄document.txt"
        let expected = "📄document.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_basenameVeryLongPath() {
        let longComponent = String(repeating: "a", count: 100)
        let input = "/" + longComponent + "/" + longComponent + "/file.txt"
        let expected = "file.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_dirnameVeryLongPath() {
        let longComponent = String(repeating: "a", count: 100)
        let input = "/" + longComponent + "/" + longComponent + "/file.txt"
        let expected = "/" + longComponent + "/" + longComponent
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    // MARK: - Consistency Tests
    
    func testBasenameDirnameConsistency() {
        let paths = [
            "/path/to/file.txt",
            "/file.txt",
            "file.txt",
            "/path/to/directory/",
            "/",
            "",
            "/very/deep/nested/path/to/file.ext"
        ]
        
        for path in paths {
            let basename = path.CC_basename
            let dirname = path.CC_dirname
            
            // If basename is not empty, dirname + "/" + basename should reconstruct the original path
            // (unless original had trailing slash or was just a filename)
            if !basename.isEmpty && path.contains("/") {
                let separator = dirname.hasSuffix("/") || dirname.isEmpty ? "" : "/"
                let reconstructed = dirname + separator + basename
                if path.hasSuffix("/") {
                    XCTAssertTrue(reconstructed.hasPrefix(path.dropLast()))
                } else if path.contains("//") {
                    let normalizedReconstructed = reconstructed.replacingOccurrences(of: "/+", with: "/", options: .regularExpression)
                    let normalizedOriginal = path.replacingOccurrences(of: "/+", with: "/", options: .regularExpression)
                    XCTAssertEqual(normalizedReconstructed, normalizedOriginal)
                } else if !path.starts(with: "/") {
                    XCTAssertEqual(reconstructed, "/" + path)
                } else {
                    XCTAssertEqual(reconstructed, path)
                }
            }
        }
    }
    
    // MARK: - Regression Tests
    
    func testCC_basenameRegression1() {
        // Test edge case with multiple consecutive slashes
        let input = "//path//to//file.txt"
        let expected = "file.txt"
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_dirnameRegression1() {
        // Test edge case with multiple consecutive slashes
        let input = "//path//to//file.txt"
        let expected = "//path//to"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    func testCC_basenameRegression2() {
        // Test path with only slashes
        let input = "////"
        let expected = ""
        XCTAssertEqual(input.CC_basename, expected)
    }
    
    func testCC_dirnameRegression2() {
        // Test path with only slashes
        let input = "////"
        let expected = "/"
        XCTAssertEqual(input.CC_dirname, expected)
    }
    
    static var allTests = [
        // CC_basename tests
        ("testCC_basenameSimple", testCC_basenameSimple),
        ("testCC_basenameNoDirectory", testCC_basenameNoDirectory),
        ("testCC_basenameRoot", testCC_basenameRoot),
        ("testCC_basenameTrailingSlash", testCC_basenameTrailingSlash),
        ("testCC_basenameMultipleSlashes", testCC_basenameMultipleSlashes),
        ("testCC_basenameEmpty", testCC_basenameEmpty),
        ("testCC_basenameOnlySlashes", testCC_basenameOnlySlashes),
        ("testCC_basenameWithSpecialCharacters", testCC_basenameWithSpecialCharacters),
        ("testCC_basenameDeepPath", testCC_basenameDeepPath),
        
        // CC_dirname tests
        ("testCC_dirnameSimple", testCC_dirnameSimple),
        ("testCC_dirnameNoDirectory", testCC_dirnameNoDirectory),
        ("testCC_dirnameRoot", testCC_dirnameRoot),
        ("testCC_dirnameTrailingSlash", testCC_dirnameTrailingSlash),
        ("testCC_dirnameMultipleSlashes", testCC_dirnameMultipleSlashes),
        ("testCC_dirnameEmpty", testCC_dirnameEmpty),
        ("testCC_dirnameOnlySlashes", testCC_dirnameOnlySlashes),
        ("testCC_dirnameSingleLevel", testCC_dirnameSingleLevel),
        ("testCC_dirnameDeepPath", testCC_dirnameDeepPath),
        ("testCC_dirnameComplexPath", testCC_dirnameComplexPath),
        
        // CC_realpath tests
        ("testCC_realpathExistingFile", testCC_realpathExistingFile),
        ("testCC_realpathNonExistent", testCC_realpathNonExistent),
        ("testCC_realpathEmpty", testCC_realpathEmpty),
        ("testCC_realpathRelative", testCC_realpathRelative),
        
        // Performance tests
        ("testCC_basenamePerformanceBaseline", testCC_basenamePerformanceBaseline),
        ("testCC_dirnamePerformanceBaseline", testCC_dirnamePerformanceBaseline),
        
        // Edge cases
        ("testCC_basenameUnicode", testCC_basenameUnicode),
        ("testCC_dirnameUnicode", testCC_dirnameUnicode),
        ("testCC_basenameWithEmoji", testCC_basenameWithEmoji),
        ("testCC_basenameVeryLongPath", testCC_basenameVeryLongPath),
        ("testCC_dirnameVeryLongPath", testCC_dirnameVeryLongPath),
        
        // Consistency tests
        ("testBasenameDirnameConsistency", testBasenameDirnameConsistency),
        
        // Regression tests
        ("testCC_basenameRegression1", testCC_basenameRegression1),
        ("testCC_dirnameRegression1", testCC_dirnameRegression1),
        ("testCC_basenameRegression2", testCC_basenameRegression2),
        ("testCC_dirnameRegression2", testCC_dirnameRegression2),
    ]
}
