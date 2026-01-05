// BlobTests.swift
// Ki.Core-Swift
//
// Author: Dan Leuck on 2026-01-05.
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

@Suite("Blob")
struct BlobTests {
    
    @Suite("Creation")
    struct Creation {
        
        @Test("creates from string")
        func fromString() {
            let blob = Blob.of("Hello")
            #expect(blob.size == 5)
            #expect(blob.decodeToString() == "Hello")
        }
        
        @Test("creates from bytes")
        func fromBytes() {
            let blob = Blob.of([0x48, 0x69])  // "Hi"
            #expect(blob.size == 2)
            #expect(blob.decodeToString() == "Hi")
        }
        
        @Test("creates empty blob")
        func empty() {
            let blob = Blob.empty()
            #expect(blob.isEmpty)
            #expect(blob.size == 0)
        }
    }
    
    @Suite("Base64 Encoding")
    struct Base64Encoding {
        
        @Test("encodes to standard Base64")
        func encodesStandard() {
            let blob = Blob.of("Hello World!")
            #expect(blob.toBase64() == "SGVsbG8gV29ybGQh")
        }
        
        @Test("encodes to URL-safe Base64")
        func encodesUrlSafe() {
            // Create data that would produce + and / in standard Base64
            let blob = Blob.of([0xfb, 0xff, 0xfe])
            let urlSafe = blob.toBase64UrlSafe()
            #expect(!urlSafe.contains("+"))
            #expect(!urlSafe.contains("/"))
        }
    }
    
    @Suite("Parsing")
    struct Parsing {
        
        @Test("parses raw Base64")
        func parsesRawBase64() throws {
            let blob = try Blob.parse("SGVsbG8=")
            #expect(blob.decodeToString() == "Hello")
        }
        
        @Test("parses Base64 with whitespace")
        func parsesWithWhitespace() throws {
            let blob = try Blob.parse("SGVs\n  bG8=")
            #expect(blob.decodeToString() == "Hello")
        }
        
        @Test("parses URL-safe Base64")
        func parsesUrlSafe() throws {
            // URL-safe encoded data
            let blob = try Blob.parse("--__")  // Would be ++// in standard
            #expect(blob.isNotEmpty)
        }
        
        @Test("parses Ki literal")
        func parsesLiteral() throws {
            let blob = try Blob.parseLiteral(".blob(SGVsbG8=)")
            #expect(blob.decodeToString() == "Hello")
        }
        
        @Test("parses empty Ki literal")
        func parsesEmptyLiteral() throws {
            let blob = try Blob.parseLiteral(".blob()")
            #expect(blob.isEmpty)
        }
        
        @Test("parseOrNull returns nil on invalid")
        func parseOrNullReturnsNil() {
            #expect(Blob.parseOrNull("not-valid-base64!!!") == nil)
        }
        
        @Test("parseLiteral throws on invalid prefix")
        func throwsOnInvalidPrefix() throws {
            #expect(throws: ParseError.self) {
                try Blob.parseLiteral("blob(SGVsbG8=)")
            }
        }
    }
    
    @Suite("String Representations")
    struct StringRepresentations {
        
        @Test("short blob is single line")
        func shortBlobSingleLine() {
            let blob = Blob.of("Hello")
            #expect(blob.description == ".blob(SGVsbG8=)")
        }
        
        @Test("empty blob format")
        func emptyBlobFormat() {
            let blob = Blob.empty()
            #expect(blob.description == ".blob()")
        }
        
        @Test("isLiteral detects blob literals")
        func isLiteralDetects() {
            #expect(Blob.isLiteral(".blob(SGVsbG8=)"))
            #expect(Blob.isLiteral(".blob()"))
            #expect(!Blob.isLiteral("blob(SGVsbG8=)"))
            #expect(!Blob.isLiteral("not a blob"))
        }
    }
    
    @Suite("Equality")
    struct Equality {
        
        @Test("equal blobs have same content")
        func equalBlobs() {
            let blob1 = Blob.of("Hello")
            let blob2 = Blob.of("Hello")
            #expect(blob1 == blob2)
        }
        
        @Test("different blobs are not equal")
        func differentBlobs() {
            let blob1 = Blob.of("Hello")
            let blob2 = Blob.of("World")
            #expect(blob1 != blob2)
        }
    }
}
