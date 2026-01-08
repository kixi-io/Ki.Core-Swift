//
// DurationExtensionTests.swift
// Ki.Core-Swift
//
// Created by Dan Leuck on 2026-01-08.
// Copyright © 2026 Kixi. MIT License.
//

import Testing
import Foundation
@testable import KiCore

// MARK: - Duration Extension Tests

@Suite("Duration Extension")
struct DurationExtensionTests {
    
    // MARK: - kiFormat Basic Tests
    
    @Suite("kiFormat Basic")
    struct KiFormatBasicTests {
        
        @Test("formats nanoseconds")
        func formatsNanoseconds() {
            let duration: Duration = .nanoseconds(500)
            let result: String = duration.kiFormat()
            
            #expect(result == "500ns")
        }
        
        @Test("formats milliseconds")
        func formatsMilliseconds() {
            let duration: Duration = .milliseconds(250)
            let result: String = duration.kiFormat()
            
            #expect(result == "250ms")
        }
        
        @Test("formats seconds")
        func formatsSeconds() {
            let duration: Duration = .seconds(30)
            let result: String = duration.kiFormat()
            
            #expect(result == "30s")
        }
        
        @Test("formats minutes")
        func formatsMinutes() {
            let duration: Duration = .seconds(300) // 5 minutes
            let result: String = duration.kiFormat()
            
            #expect(result == "5min")
        }
        
        @Test("formats hours")
        func formatsHours() {
            let duration: Duration = .seconds(3600) // 1 hour
            let result: String = duration.kiFormat()
            
            #expect(result == "1h")
        }
        
        @Test("formats days")
        func formatsDays() {
            let duration: Duration = .seconds(86400) // 1 day
            let result: String = duration.kiFormat()
            
            #expect(result == "1day")
        }
        
        @Test("formats multiple days")
        func formatsMultipleDays() {
            let duration: Duration = .seconds(172800) // 2 days
            let result: String = duration.kiFormat()
            
            #expect(result == "2days")
        }
    }
    
    // MARK: - kiFormat Compound Tests
    
    @Suite("kiFormat Compound")
    struct KiFormatCompoundTests {
        
        @Test("formats hours minutes seconds")
        func formatsHoursMinutesSeconds() {
            // 1 hour, 30 minutes, 45 seconds = 5445 seconds
            let duration: Duration = .seconds(5445)
            let result: String = duration.kiFormat()
            
            #expect(result == "1:30:45")
        }
        
        @Test("formats minutes and seconds")
        func formatsMinutesAndSeconds() {
            // 5 minutes, 30 seconds = 330 seconds
            let duration: Duration = .seconds(330)
            let result: String = duration.kiFormat()
            
            #expect(result == "0:5:30")
        }
        
        @Test("formats days hours minutes seconds")
        func formatsDaysHoursMinutesSeconds() {
            // 1 day + 2 hours + 30 minutes + 15 seconds = 95415 seconds
            let duration: Duration = .seconds(95415)
            let result: String = duration.kiFormat()
            
            #expect(result == "1day:2:30:15")
        }
    }
    
    // MARK: - kiFormat Zero Padding Tests
    
    @Suite("kiFormat Zero Padding")
    struct KiFormatZeroPaddingTests {
        
        @Test("zero pads time components")
        func zeroPadsTimeComponents() {
            // 1 hour, 5 minutes, 3 seconds = 3903 seconds
            let duration: Duration = .seconds(3903)
            let result: String = duration.kiFormat(zeroPad: true)
            
            #expect(result == "01:05:03")
        }
        
        @Test("zero pads with days")
        func zeroPadsWithDays() {
            // 1 day + 2 hours + 3 minutes + 4 seconds = 93784 seconds
            let duration: Duration = .seconds(93784)
            let result: String = duration.kiFormat(zeroPad: true)
            
            #expect(result == "1day:02:03:04")
        }
        
        @Test("no padding without zeroPad")
        func noPaddingWithoutZeroPad() {
            // 1 hour, 5 minutes, 3 seconds
            let duration: Duration = .seconds(3903)
            let result: String = duration.kiFormat(zeroPad: false)
            
            #expect(result == "1:5:3")
        }
    }
    
    // MARK: - kiFormat Fractional Seconds Tests
    
    @Suite("kiFormat Fractional Seconds")
    struct KiFormatFractionalSecondsTests {
        
        @Test("formats seconds with nanoseconds")
        func formatsSecondsWithNanoseconds() {
            // 30.5 seconds = 30_500_000_000 nanoseconds
            let duration: Duration = .nanoseconds(30_500_000_000)
            let result: String = duration.kiFormat()
            
            #expect(result == "30.5s")
        }
        
        @Test("formats compound duration with fraction")
        func formatsCompoundWithFraction() {
            // 1 hour + 30 minutes + 45.5 seconds
            let baseSeconds: Int64 = 1 * 3600 + 30 * 60 + 45
            let nanos: Int64 = baseSeconds * 1_000_000_000 + 500_000_000
            let duration: Duration = .nanoseconds(nanos)
            let result: String = duration.kiFormat()
            
            #expect(result.contains(".5" as String))
        }
    }
    
    // MARK: - kiFormat Negative Duration Tests
    
    @Suite("kiFormat Negative Duration")
    struct KiFormatNegativeDurationTests {
        
        @Test("formats negative nanoseconds")
        func formatsNegativeNanoseconds() {
            let duration: Duration = .nanoseconds(-500)
            let result: String = duration.kiFormat()
            
            #expect(result == "-500ns")
        }
        
        @Test("formats negative milliseconds")
        func formatsNegativeMilliseconds() {
            let duration: Duration = .milliseconds(-250)
            let result: String = duration.kiFormat()
            
            #expect(result == "-250ms")
        }
        
        @Test("formats negative seconds")
        func formatsNegativeSeconds() {
            let duration: Duration = .seconds(-30)
            let result: String = duration.kiFormat()
            
            #expect(result == "-30s")
        }
        
        @Test("formats negative compound duration")
        func formatsNegativeCompound() {
            let duration: Duration = .seconds(-3903) // -1 hour, 5 minutes, 3 seconds
            let result: String = duration.kiFormat()
            
            #expect(result.hasPrefix("-"))
        }
    }
    
    // MARK: - kiFormat Edge Cases
    
    @Suite("kiFormat Edge Cases")
    struct KiFormatEdgeCasesTests {
        
        @Test("formats zero duration")
        func formatsZeroDuration() {
            let duration: Duration = .zero
            let result: String = duration.kiFormat()
            
            #expect(result == "0ns")
        }
        
        @Test("formats exactly one nanosecond")
        func formatsOneNanosecond() {
            let duration: Duration = .nanoseconds(1)
            let result: String = duration.kiFormat()
            
            #expect(result == "1ns")
        }
        
        @Test("formats exactly one millisecond")
        func formatsOneMillisecond() {
            let duration: Duration = .milliseconds(1)
            let result: String = duration.kiFormat()
            
            #expect(result == "1ms")
        }
        
        @Test("formats exactly one second")
        func formatsOneSecond() {
            let duration: Duration = .seconds(1)
            let result: String = duration.kiFormat()
            
            #expect(result == "1s")
        }
        
        @Test("formats exactly one minute")
        func formatsOneMinute() {
            let duration: Duration = .seconds(60)
            let result: String = duration.kiFormat()
            
            #expect(result == "1min")
        }
        
        @Test("formats exactly one hour")
        func formatsOneHour() {
            let duration: Duration = .seconds(3600)
            let result: String = duration.kiFormat()
            
            #expect(result == "1h")
        }
        
        @Test("formats 999 nanoseconds stays in nanoseconds")
        func formatsSubMillisecond() {
            let duration: Duration = .nanoseconds(999)
            let result: String = duration.kiFormat()
            
            #expect(result == "999ns")
        }
        
        @Test("formats 1000000 nanoseconds as milliseconds")
        func formatsMillisecondBoundary() {
            let duration: Duration = .nanoseconds(1_000_000)
            let result: String = duration.kiFormat()
            
            #expect(result == "1ms")
        }
        
        @Test("formats 59 seconds as seconds")
        func formatsSubMinuteSeconds() {
            let duration: Duration = .seconds(59)
            let result: String = duration.kiFormat()
            
            #expect(result == "59s")
        }
    }
    
    // MARK: - Consistency Tests
    
    @Suite("Consistency")
    struct ConsistencyTests {
        
        @Test("kiFormat matches Ki.formatDuration")
        func matchesKiFormatDuration() {
            let duration: Duration = .seconds(3723) // 1:2:3
            let extensionResult: String = duration.kiFormat()
            let staticResult: String = Ki.formatDuration(duration)
            
            #expect(extensionResult == staticResult)
        }
        
        @Test("kiFormat with zeroPad matches Ki.formatDuration with zeroPad")
        func matchesKiFormatDurationWithZeroPad() {
            let duration: Duration = .seconds(3723)
            let extensionResult: String = duration.kiFormat(zeroPad: true)
            let staticResult: String = Ki.formatDuration(duration, zeroPad: true)
            
            #expect(extensionResult == staticResult)
        }
        
        @Test("default zeroPad is false")
        func defaultZeroPadIsFalse() {
            let duration: Duration = .seconds(3903) // 1:5:3
            let defaultResult: String = duration.kiFormat()
            let explicitResult: String = duration.kiFormat(zeroPad: false)
            
            #expect(defaultResult == explicitResult)
        }
    }
    
    // MARK: - Large Values Tests
    
    @Suite("Large Values")
    struct LargeValuesTests {
        
        @Test("formats many days")
        func formatsManyDays() {
            let duration: Duration = .seconds(864000) // 10 days
            let result: String = duration.kiFormat()
            
            #expect(result == "10days")
        }
        
        @Test("formats many hours")
        func formatsManyHours() {
            let duration: Duration = .seconds(36000) // 10 hours
            let result: String = duration.kiFormat()
            
            #expect(result == "10h")
        }
        
        @Test("formats large compound duration")
        func formatsLargeCompound() {
            // 365 days
            let duration: Duration = .seconds(365 * 86400)
            let result: String = duration.kiFormat()
            
            #expect(result == "365days")
        }
    }
}
