// CoordinateGridTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
@testable import KiCore

// MARK: - Coordinate Tests

@Suite("Coordinate")
struct CoordinateTests {
    
    @Suite("Creation")
    struct Creation {
        
        @Test("standard creates valid coordinate")
        func standardCreatesValid() throws {
            let coord = try Coordinate.standard(x: 4, y: 3)
            #expect(coord.x == 4)
            #expect(coord.y == 3)
            #expect(coord.z == nil)
        }
        
        @Test("standard with z creates 3D coordinate")
        func standardWithZ() throws {
            let coord = try Coordinate.standard(x: 1, y: 2, z: 3)
            #expect(coord.x == 1)
            #expect(coord.y == 2)
            #expect(coord.z == 3)
            #expect(coord.hasZ)
        }
        
        @Test("sheet notation creates valid coordinate")
        func sheetCreatesValid() throws {
            let coord = try Coordinate.sheet(c: "E", r: 1)
            #expect(coord.x == 4)
            #expect(coord.y == 0)
            #expect(coord.column == "E")
            #expect(coord.row == 1)
        }
        
        @Test("sheet notation with multi-letter column")
        func sheetMultiLetter() throws {
            let coord = try Coordinate.sheet(c: "AA", r: 100)
            #expect(coord.x == 26)
            #expect(coord.y == 99)
            #expect(coord.column == "AA")
            #expect(coord.row == 100)
        }
        
        @Test("throws on negative x")
        func throwsOnNegativeX() throws {
            #expect(throws: KiError.self) {
                try Coordinate.standard(x: -1, y: 0)
            }
        }
        
        @Test("throws on negative y")
        func throwsOnNegativeY() throws {
            #expect(throws: KiError.self) {
                try Coordinate.standard(x: 0, y: -1)
            }
        }
    }
    
    @Suite("Parsing")
    struct Parsing {
        
        @Test("parse sheet notation")
        func parseSheetNotation() throws {
            let coord = try Coordinate.parse("A1")
            #expect(coord.x == 0)
            #expect(coord.y == 0)
        }
        
        @Test("parse sheet notation with multi-letter column")
        func parseSheetMultiLetter() throws {
            let coord = try Coordinate.parse("AA100")
            #expect(coord.x == 26)
            #expect(coord.y == 99)
        }
        
        @Test("parse standard notation")
        func parseStandardNotation() throws {
            let coord = try Coordinate.parse("4,0")
            #expect(coord.x == 4)
            #expect(coord.y == 0)
        }
        
        @Test("parse standard notation with spaces")
        func parseStandardWithSpaces() throws {
            let coord = try Coordinate.parse("4, 3")
            #expect(coord.x == 4)
            #expect(coord.y == 3)
        }
        
        @Test("parse standard notation with z")
        func parseStandardWithZ() throws {
            let coord = try Coordinate.parse("1,2,3")
            #expect(coord.x == 1)
            #expect(coord.y == 2)
            #expect(coord.z == 3)
        }
        
        @Test("parseOrNull returns nil on failure")
        func parseOrNullReturnsNil() {
            #expect(Coordinate.parseOrNull("invalid") == nil)
        }
    }
    
    @Suite("Column Index Conversion")
    struct ColumnConversion {
        
        @Test("indexToColumn converts correctly")
        func indexToColumn() {
            #expect(Coordinate.indexToColumn(0) == "A")
            #expect(Coordinate.indexToColumn(25) == "Z")
            #expect(Coordinate.indexToColumn(26) == "AA")
            #expect(Coordinate.indexToColumn(27) == "AB")
            #expect(Coordinate.indexToColumn(51) == "AZ")
            #expect(Coordinate.indexToColumn(52) == "BA")
        }
        
        @Test("columnToIndex converts correctly")
        func columnToIndex() {
            #expect(Coordinate.columnToIndex("A") == 0)
            #expect(Coordinate.columnToIndex("Z") == 25)
            #expect(Coordinate.columnToIndex("AA") == 26)
            #expect(Coordinate.columnToIndex("AB") == 27)
            #expect(Coordinate.columnToIndex("AZ") == 51)
            #expect(Coordinate.columnToIndex("BA") == 52)
        }
        
        @Test("roundtrip conversion")
        func roundtripConversion() {
            for i in 0..<100 {
                let column = Coordinate.indexToColumn(i)
                let backToIndex = Coordinate.columnToIndex(column)
                #expect(backToIndex == i)
            }
        }
    }
    
    @Suite("Movement")
    struct Movement {
        
        @Test("right moves correctly")
        func rightMoves() throws {
            let coord = try Coordinate.standard(x: 0, y: 0)
            let moved = try coord.right(3)
            #expect(moved.x == 3)
            #expect(moved.y == 0)
        }
        
        @Test("left moves correctly")
        func leftMoves() throws {
            let coord = try Coordinate.standard(x: 5, y: 0)
            let moved = try coord.left(3)
            #expect(moved.x == 2)
            #expect(moved.y == 0)
        }
        
        @Test("down moves correctly")
        func downMoves() throws {
            let coord = try Coordinate.standard(x: 0, y: 0)
            let moved = try coord.down(5)
            #expect(moved.x == 0)
            #expect(moved.y == 5)
        }
        
        @Test("up moves correctly")
        func upMoves() throws {
            let coord = try Coordinate.standard(x: 0, y: 10)
            let moved = try coord.up(3)
            #expect(moved.x == 0)
            #expect(moved.y == 7)
        }
        
        @Test("left throws when result is negative")
        func leftThrowsNegative() throws {
            let coord = try Coordinate.standard(x: 2, y: 0)
            #expect(throws: KiError.self) {
                try coord.left(5)
            }
        }
    }
    
    @Suite("String Representations")
    struct StringRepresentations {
        
        @Test("toSheetNotation")
        func toSheetNotation() throws {
            let coord = try Coordinate.standard(x: 4, y: 0)
            #expect(coord.toSheetNotation() == "E1")
        }
        
        @Test("toStandardNotation")
        func toStandardNotation() throws {
            let coord = try Coordinate.standard(x: 4, y: 3)
            #expect(coord.toStandardNotation() == "4,3")
        }
        
        @Test("toKiLiteral")
        func toKiLiteral() throws {
            let coord = try Coordinate.standard(x: 4, y: 0)
            #expect(coord.toKiLiteral() == ".coordinate(x=4, y=0)")
        }
    }
}

// MARK: - CoordinateRange Tests

@Suite("CoordinateRange")
struct CoordinateRangeTests {
    
    @Test("range properties")
    func rangeProperties() throws {
        let start = try Coordinate.standard(x: 0, y: 0)
        let end = try Coordinate.standard(x: 2, y: 2)
        let range = start...end
        
        #expect(range.width == 3)
        #expect(range.height == 3)
        #expect(range.count == 9)
    }
    
    @Test("range iteration")
    func rangeIteration() throws {
        let start = try Coordinate.standard(x: 0, y: 0)
        let end = try Coordinate.standard(x: 1, y: 1)
        let range = start...end
        
        let coords = range.toArray()
        #expect(coords.count == 4)
        #expect(coords[0].toSheetNotation() == "A1")
        #expect(coords[1].toSheetNotation() == "B1")
        #expect(coords[2].toSheetNotation() == "A2")
        #expect(coords[3].toSheetNotation() == "B2")
    }
    
    @Test("range contains")
    func rangeContains() throws {
        let start = try Coordinate.standard(x: 0, y: 0)
        let end = try Coordinate.standard(x: 2, y: 2)
        let range = start...end
        
        #expect(range.contains(try Coordinate.standard(x: 1, y: 1)))
        #expect(!range.contains(try Coordinate.standard(x: 5, y: 5)))
    }
}

// MARK: - GeoPoint Tests

@Suite("Simple GeoPoint")
struct SimpleGeoPointTests {
    
    @Suite("Creation")
    struct Creation {
        
        @Test("creates valid point")
        func createsValid() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            #expect(abs(point.lat - 37.7749) < 0.0001)
            #expect(abs(point.lon - (-122.4194)) < 0.0001)
            #expect(point.altitude == nil)
        }
        
        @Test("creates point with altitude")
        func createsWithAltitude() throws {
            let point = try GeoPoint.of(latitude: 35.6762, longitude: 139.6503, altitude: 40.0)
            #expect(point.hasAltitude)
            #expect(abs(point.alt! - 40.0) < 0.0001)
        }
        
        @Test("throws on invalid latitude")
        func throwsOnInvalidLatitude() throws {
            #expect(throws: KiError.self) {
                try GeoPoint.of(latitude: 91.0, longitude: 0.0)
            }
        }
        
        @Test("throws on invalid longitude")
        func throwsOnInvalidLongitude() throws {
            #expect(throws: KiError.self) {
                try GeoPoint.of(latitude: 0.0, longitude: 181.0)
            }
        }
    }
    
    @Suite("Parsing")
    struct Parsing {
        
        @Test("parse simple geo literal")
        func parseSimple() throws {
            let point = try GeoPoint.parse(".geo(37.7749, -122.4194)")
            #expect(abs(point.lat - 37.7749) < 0.0001)
            #expect(abs(point.lon - (-122.4194)) < 0.0001)
        }
        
        @Test("parse geo literal with altitude")
        func parseWithAltitude() throws {
            let point = try GeoPoint.parse(".geo(35.6762, 139.6503, 40.0)")
            #expect(point.hasAltitude)
            #expect(abs(point.alt! - 40.0) < 0.0001)
        }
        
        @Test("throws on empty literal")
        func throwsOnEmpty() throws {
            #expect(throws: ParseError.self) {
                try GeoPoint.parse("")
            }
        }
        
        @Test("throws on invalid prefix")
        func throwsOnInvalidPrefix() throws {
            #expect(throws: ParseError.self) {
                try GeoPoint.parse("geo(1, 2)")
            }
        }
    }
    
    @Suite("Properties")
    struct Properties {
        
        @Test("hemisphere properties")
        func hemisphereProperties() throws {
            let northern = try GeoPoint.of(latitude: 45.0, longitude: 0.0)
            #expect(northern.isNorthern)
            #expect(!northern.isSouthern)
            
            let southern = try GeoPoint.of(latitude: -45.0, longitude: 0.0)
            #expect(southern.isSouthern)
            #expect(!southern.isNorthern)
            
            let eastern = try GeoPoint.of(latitude: 0.0, longitude: 90.0)
            #expect(eastern.isEastern)
            #expect(!eastern.isWestern)
            
            let western = try GeoPoint.of(latitude: 0.0, longitude: -90.0)
            #expect(western.isWestern)
            #expect(!western.isEastern)
        }
        
        @Test("origin is at null island")
        func originIsNullIsland() {
            #expect(GeoPoint.ORIGIN.isOrigin)
            #expect(GeoPoint.ORIGIN.lat == 0)
            #expect(GeoPoint.ORIGIN.lon == 0)
        }
    }
    
    @Suite("Distance")
    struct Distance {
        
        @Test("distance to same point is zero")
        func distanceToSameIsZero() throws {
            let point = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let distance = point.distanceTo(point)
            #expect(distance < 0.001)
        }
        
        @Test("distance calculation is approximately correct")
        func distanceCalculation() throws {
            // San Francisco to Los Angeles is approximately 559 km
            let sf = try GeoPoint.of(latitude: 37.7749, longitude: -122.4194)
            let la = try GeoPoint.of(latitude: 34.0522, longitude: -118.2437)
            let distance = sf.distanceTo(la)
            #expect(distance > 500 && distance < 600)
        }
    }
}

// MARK: - Grid Tests

@Suite("Grid")
struct GridTests {
    
    @Suite("Creation")
    struct Creation {
        
        @Test("of creates grid with default value")
        func ofCreatesGrid() {
            let grid = Grid.of(width: 3, height: 3, defaultValue: 0)
            #expect(grid.width == 3)
            #expect(grid.height == 3)
            #expect(grid.size == 9)
            #expect(grid[0, 0] == 0)
        }
        
        @Test("ofNulls creates grid with nil values")
        func ofNullsCreatesGrid() {
            let grid: Grid<Int> = Grid.ofNulls(width: 3, height: 3)
            #expect(grid[0, 0] == nil)
            #expect(grid.isEmpty)
        }
        
        @Test("fromRows creates grid from arrays")
        func fromRowsCreatesGrid() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            #expect(grid.width == 3)
            #expect(grid.height == 2)
            #expect(grid[0, 0] == 1)
            #expect(grid[2, 1] == 6)
        }
        
        @Test("fromRows throws on inconsistent row lengths")
        func fromRowsThrowsOnInconsistent() throws {
            #expect(throws: WrongRowLengthError.self) {
                try Grid.fromRows([
                    [1, 2, 3],
                    [4, 5]  // Wrong length
                ])
            }
        }
    }
    
    @Suite("Access")
    struct Access {
        
        @Test("subscript with x, y")
        func subscriptXY() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            #expect(grid[0, 0] == 1)
            #expect(grid[2, 1] == 6)
        }
        
        @Test("subscript with sheet notation")
        func subscriptSheetNotation() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            #expect(grid["A", 1] == 1)
            #expect(grid["C", 2] == 6)
        }
        
        @Test("subscript with sheet string")
        func subscriptSheetString() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            #expect(grid["A1"] == 1)
            #expect(grid["C2"] == 6)
        }
        
        @Test("subscript with Coordinate")
        func subscriptCoordinate() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let coord = try Coordinate.standard(x: 2, y: 1)
            #expect(grid[coord] == 6)
        }
        
        @Test("set value via subscript")
        func setValueViaSubscript() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            grid[1, 1] = 99
            #expect(grid[1, 1] == 99)
        }
    }
    
    @Suite("Row and Column Operations")
    struct RowColumnOps {
        
        @Test("getRowCopy returns copy")
        func getRowCopyReturnsCopy() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let row = grid.getRowCopy(0)
            #expect(row == [1, 2, 3])
        }
        
        @Test("getColumnCopy returns copy")
        func getColumnCopyReturnsCopy() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let column = grid.getColumnCopy(0)
            #expect(column == [1, 4])
        }
        
        @Test("setRow updates entire row")
        func setRowUpdates() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            grid.setRow(0, values: [10, 20, 30])
            #expect(grid.getRowCopy(0) == [10, 20, 30])
        }
        
        @Test("setColumn updates entire column")
        func setColumnUpdates() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            grid.setColumn(0, values: [10, 40])
            #expect(grid.getColumnCopy(0) == [10, 40])
        }
    }
    
    @Suite("Operations")
    struct Operations {
        
        @Test("transpose swaps rows and columns")
        func transposeSwaps() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let transposed = grid.transpose()
            #expect(transposed.width == 2)
            #expect(transposed.height == 3)
            #expect(transposed[0, 0] == 1)
            #expect(transposed[1, 0] == 4)
            #expect(transposed[0, 2] == 3)
        }
        
        @Test("subgrid extracts region")
        func subgridExtracts() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3, 4],
                [5, 6, 7, 8],
                [9, 10, 11, 12]
            ])
            let sub = grid.subgrid(startX: 1, startY: 1, width: 2, height: 2)
            #expect(sub.width == 2)
            #expect(sub.height == 2)
            #expect(sub[0, 0] == 6)
            #expect(sub[1, 1] == 11)
        }
        
        @Test("map transforms values")
        func mapTransforms() throws {
            let grid = try Grid.fromRows([
                [1, 2],
                [3, 4]
            ])
            let mapped = grid.map { ($0 ?? 0) * 2 }
            #expect(mapped[0, 0] == 2)
            #expect(mapped[1, 1] == 8)
        }
        
        @Test("fill sets all values")
        func fillSetsAll() throws {
            let grid = try Grid.fromRows([
                [1, 2],
                [3, 4]
            ])
            grid.fill(0)
            #expect(grid[0, 0] == 0)
            #expect(grid[1, 1] == 0)
        }
        
        @Test("clear sets all to nil")
        func clearSetsNil() throws {
            let grid = try Grid.fromRows([
                [1, 2],
                [3, 4]
            ])
            grid.clear()
            #expect(grid[0, 0] == nil)
            #expect(grid.isEmpty)
        }
    }
    
    @Suite("Search")
    struct Search {
        
        @Test("find returns first match")
        func findReturnsFirst() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let result = grid.find { $0 == 5 }
            #expect(result != nil)
            #expect(result?.0.x == 1)
            #expect(result?.0.y == 1)
            #expect(result?.1 == 5)
        }
        
        @Test("find returns nil when not found")
        func findReturnsNilWhenNotFound() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let result = grid.find { $0 == 99 }
            #expect(result == nil)
        }
        
        @Test("findAll returns all matches")
        func findAllReturnsAll() throws {
            let grid = try Grid.fromRows([
                [1, 2, 2],
                [2, 5, 6]
            ])
            let results = grid.findAll { $0 == 2 }
            #expect(results.count == 3)
        }
        
        @Test("count returns number of matches")
        func countReturnsNumber() throws {
            let grid = try Grid.fromRows([
                [1, 2, 2],
                [2, 5, 6]
            ])
            let count = grid.count { $0 == 2 }
            #expect(count == 3)
        }
        
        @Test("any returns true when match exists")
        func anyReturnsTrue() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            #expect(grid.any { $0 == 5 })
            #expect(!grid.any { $0 == 99 })
        }
        
        @Test("all returns true when all match")
        func allReturnsTrue() throws {
            let grid = try Grid.fromRows([
                [2, 4, 6],
                [8, 10, 12]
            ])
            #expect(grid.all { ($0 ?? 0) % 2 == 0 })
            #expect(!grid.all { ($0 ?? 0) > 5 })
        }
    }
    
    @Suite("Row and Column Views")
    struct RowColumnViews {
        
        @Test("rows accessor provides views")
        func rowsAccessorProvidesViews() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let row = grid.rows[0]
            #expect(row[0] == 1)
            #expect(row[1] == 2)
            #expect(row[2] == 3)
        }
        
        @Test("row view modification updates grid")
        func rowViewModificationUpdates() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            grid.rows[0][0] = 99
            #expect(grid[0, 0] == 99)
        }
        
        @Test("columns accessor provides views")
        func columnsAccessorProvidesViews() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let column = grid.columns[0]
            #expect(column[0] == 1)
            #expect(column[1] == 4)
        }
        
        @Test("column view by letter")
        func columnViewByLetter() throws {
            let grid = try Grid.fromRows([
                [1, 2, 3],
                [4, 5, 6]
            ])
            let column = grid.columns["B"]
            #expect(column[0] == 2)
            #expect(column[1] == 5)
        }
    }
}
