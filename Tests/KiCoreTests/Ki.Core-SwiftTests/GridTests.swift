// GridTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - Grid Initialization Tests

@Suite("Grid Initialization")
struct GridInitializationTests {
    
    @Test("creates grid with specified dimensions and data")
    func createsWithDimensionsAndData() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        #expect(grid.width == 3)
        #expect(grid.height == 2)
        #expect(grid.size == 6)
    }
    
    @Test("stores data in row-major order")
    func storesInRowMajorOrder() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        // Row 0: 1, 2, 3
        #expect(grid[0, 0] == 1)
        #expect(grid[1, 0] == 2)
        #expect(grid[2, 0] == 3)
        
        // Row 1: 4, 5, 6
        #expect(grid[0, 1] == 4)
        #expect(grid[1, 1] == 5)
        #expect(grid[2, 1] == 6)
    }
    
    @Test("creates grid with nil values")
    func createsWithNilValues() {
        let data: [Int?] = [1, nil, 3, nil, 5, nil]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        #expect(grid[0, 0] == 1)
        #expect(grid[1, 0] == nil)
        #expect(grid[2, 0] == 3)
        #expect(grid[0, 1] == nil)
        #expect(grid[1, 1] == 5)
        #expect(grid[2, 1] == nil)
    }
    
    @Test("creates grid with String type")
    func createsWithStringType() {
        let a: String = "a"
        let b: String = "b"
        let c: String = "c"
        let d: String = "d"
        let data: [String?] = [a, b, c, d]
        let grid = Grid<String>(width: 2, height: 2, data: data)
        
        #expect(grid[0, 0] == "a")
        #expect(grid[1, 0] == "b")
        #expect(grid[0, 1] == "c")
        #expect(grid[1, 1] == "d")
    }
    
    @Test("creates 1x1 grid")
    func creates1x1Grid() {
        let data: [Int?] = [42]
        let grid = Grid<Int>(width: 1, height: 1, data: data)
        
        #expect(grid.width == 1)
        #expect(grid.height == 1)
        #expect(grid.size == 1)
        #expect(grid[0, 0] == 42)
    }
    
    @Test("creates wide grid (single row)")
    func createsWideGrid() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let grid = Grid<Int>(width: 10, height: 1, data: data)
        
        #expect(grid.width == 10)
        #expect(grid.height == 1)
        for i in 0..<10 {
            #expect(grid[i, 0] == i + 1)
        }
    }
    
    @Test("creates tall grid (single column)")
    func createsTallGrid() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let grid = Grid<Int>(width: 1, height: 10, data: data)
        
        #expect(grid.width == 1)
        #expect(grid.height == 10)
        for i in 0..<10 {
            #expect(grid[0, i] == i + 1)
        }
    }
}

// MARK: - Grid Factory Methods Tests

@Suite("Grid Factory Methods")
struct GridFactoryMethodsTests {
    
    @Suite("of(width:height:defaultValue:)")
    struct OfDefaultValue {
        
        @Test("creates grid with default value")
        func createsWithDefaultValue() {
            let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 42)
            
            #expect(grid.width == 3)
            #expect(grid.height == 2)
            #expect(grid[0, 0] == 42)
            #expect(grid[1, 0] == 42)
            #expect(grid[2, 0] == 42)
            #expect(grid[0, 1] == 42)
            #expect(grid[1, 1] == 42)
            #expect(grid[2, 1] == 42)
        }
        
        @Test("creates grid with nil default value")
        func createsWithNilDefault() {
            let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: nil)
            
            #expect(grid[0, 0] == nil)
            #expect(grid[1, 0] == nil)
            #expect(grid[0, 1] == nil)
            #expect(grid[1, 1] == nil)
        }
        
        @Test("creates grid with String default value")
        func createsWithStringDefault() {
            let defaultStr: String = "default"
            let grid = Grid<String>.of(width: 2, height: 2, defaultValue: defaultStr)
            
            #expect(grid[0, 0] == "default")
            #expect(grid[1, 1] == "default")
        }
    }
    
    @Suite("ofNulls(width:height:)")
    struct OfNulls {
        
        @Test("creates grid with all nils")
        func createsWithAllNils() {
            let grid = Grid<Int>.ofNulls(width: 3, height: 3)
            
            #expect(grid.width == 3)
            #expect(grid.height == 3)
            #expect(grid.isEmpty)
            
            for y in 0..<3 {
                for x in 0..<3 {
                    #expect(grid[x, y] == nil)
                }
            }
        }
    }
    
    @Suite("fromRows(_:)")
    struct FromRows {
        
        @Test("creates grid from rows")
        func createsFromRows() throws {
            let row1: [Int?] = [1, 2, 3]
            let row2: [Int?] = [4, 5, 6]
            let rows: [[Int?]] = [row1, row2]
            let grid = try Grid<Int>.fromRows(rows)
            
            #expect(grid.width == 3)
            #expect(grid.height == 2)
            #expect(grid[0, 0] == 1)
            #expect(grid[2, 1] == 6)
        }
        
        @Test("creates grid from single row")
        func createsFromSingleRow() throws {
            let row: [Int?] = [1, 2, 3, 4, 5]
            let rows: [[Int?]] = [row]
            let grid = try Grid<Int>.fromRows(rows)
            
            #expect(grid.width == 5)
            #expect(grid.height == 1)
        }
        
        @Test("creates grid from String rows")
        func createsFromStringRows() throws {
            let a: String = "a"
            let b: String = "b"
            let c: String = "c"
            let d: String = "d"
            let row1: [String?] = [a, b]
            let row2: [String?] = [c, d]
            let rows: [[String?]] = [row1, row2]
            let grid = try Grid<String>.fromRows(rows)
            
            #expect(grid[0, 0] == "a")
            #expect(grid[1, 1] == "d")
        }
        
        @Test("throws on empty row list")
        func throwsOnEmptyRowList() throws {
            let emptyRows: [[Int?]] = []
            #expect(throws: KiError.self) {
                try Grid<Int>.fromRows(emptyRows)
            }
        }
        
        @Test("throws on inconsistent row lengths")
        func throwsOnInconsistentRowLengths() throws {
            let row1: [Int?] = [1, 2, 3]
            let row2: [Int?] = [4, 5]  // Wrong length
            let rows: [[Int?]] = [row1, row2]
            
            #expect(throws: WrongRowLengthError.self) {
                try Grid<Int>.fromRows(rows)
            }
        }
        
        @Test("throws on empty first row")
        func throwsOnEmptyFirstRow() throws {
            let emptyRow: [Int?] = []
            let rows: [[Int?]] = [emptyRow]
            
            #expect(throws: KiError.self) {
                try Grid<Int>.fromRows(rows)
            }
        }
    }
    
    @Suite("fromSingleRow(_:)")
    struct FromSingleRow {
        
        @Test("creates single-row grid")
        func createsSingleRowGrid() throws {
            let values: [Int?] = [1, 2, 3, 4, 5]
            let grid = try Grid<Int>.fromSingleRow(values)
            
            #expect(grid.width == 5)
            #expect(grid.height == 1)
            #expect(grid[0, 0] == 1)
            #expect(grid[4, 0] == 5)
        }
    }
    
    @Suite("fromSingleColumn(_:)")
    struct FromSingleColumn {
        
        @Test("creates single-column grid")
        func createsSingleColumnGrid() throws {
            let values: [Int?] = [1, 2, 3, 4, 5]
            let grid = try Grid<Int>.fromSingleColumn(values)
            
            #expect(grid.width == 1)
            #expect(grid.height == 5)
            #expect(grid[0, 0] == 1)
            #expect(grid[0, 4] == 5)
        }
    }
    
    @Suite("build(width:height:_:)")
    struct Build {
        
        @Test("creates grid using builder function")
        func createsUsingBuilder() {
            let grid = Grid<Int>.build(width: 3, height: 3) { x, y in
                x + y * 3
            }
            
            #expect(grid[0, 0] == 0)
            #expect(grid[1, 0] == 1)
            #expect(grid[2, 0] == 2)
            #expect(grid[0, 1] == 3)
            #expect(grid[1, 1] == 4)
            #expect(grid[2, 2] == 8)
        }
        
        @Test("creates multiplication table")
        func createsMultiplicationTable() {
            let grid = Grid<Int>.build(width: 10, height: 10) { x, y in
                (x + 1) * (y + 1)
            }
            
            #expect(grid[0, 0] == 1)   // 1 * 1
            #expect(grid[4, 4] == 25)  // 5 * 5
            #expect(grid[9, 9] == 100) // 10 * 10
        }
        
        @Test("builder can return nil")
        func builderCanReturnNil() {
            let grid = Grid<Int>.build(width: 3, height: 3) { x, y in
                (x + y) % 2 == 0 ? x + y : nil
            }
            
            #expect(grid[0, 0] == 0)
            #expect(grid[1, 0] == nil)
            #expect(grid[0, 1] == nil)
            #expect(grid[1, 1] == 2)
        }
    }
    
    @Suite("isLiteral(_:)")
    struct IsLiteral {
        
        @Test("detects grid literal")
        func detectsGridLiteral() {
            let literal1: String = ".grid(1 2 3)"
            let literal2: String = ".grid<Int>(1 2 3)"
            let notLiteral1: String = "grid(1 2 3)"
            let notLiteral2: String = ".grid(1 2 3"
            let notLiteral3: String = "not a grid"
            
            #expect(Grid<Int>.isLiteral(literal1))
            #expect(Grid<Int>.isLiteral(literal2))
            #expect(!Grid<Int>.isLiteral(notLiteral1))
            #expect(!Grid<Int>.isLiteral(notLiteral2))
            #expect(!Grid<Int>.isLiteral(notLiteral3))
        }
        
        @Test("handles whitespace")
        func handlesWhitespace() {
            let literalWithWhitespace: String = "  .grid(1 2 3)  "
            #expect(Grid<Int>.isLiteral(literalWithWhitespace))
        }
    }
}

// MARK: - Grid Computed Properties Tests

@Suite("Grid Computed Properties")
struct GridComputedPropertiesTests {
    
    @Test("size returns total cells")
    func sizeReturnsTotalCells() {
        let grid = Grid<Int>.of(width: 5, height: 4, defaultValue: 0)
        #expect(grid.size == 20)
    }
    
    @Test("isEmpty returns true for all-nil grid")
    func isEmptyForAllNil() {
        let grid = Grid<Int>.ofNulls(width: 3, height: 3)
        #expect(grid.isEmpty)
        #expect(!grid.isNotEmpty)
    }
    
    @Test("isEmpty returns false when any cell has value")
    func isEmptyFalseWhenHasValue() {
        let grid = Grid<Int>.ofNulls(width: 3, height: 3)
        grid[1, 1] = 42
        #expect(!grid.isEmpty)
        #expect(grid.isNotEmpty)
    }
    
    @Test("isNotEmpty returns true for filled grid")
    func isNotEmptyForFilled() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 1)
        #expect(grid.isNotEmpty)
        #expect(!grid.isEmpty)
    }
}

// MARK: - Grid Cell Access Tests

@Suite("Grid Cell Access")
struct GridCellAccessTests {
    
    @Suite("Subscript [x, y]")
    struct SubscriptXY {
        
        @Test("gets value at coordinates")
        func getsValueAtCoordinates() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6, 7, 8, 9]
            let grid = Grid<Int>(width: 3, height: 3, data: data)
            
            #expect(grid[0, 0] == 1)
            #expect(grid[1, 1] == 5)
            #expect(grid[2, 2] == 9)
        }
        
        @Test("sets value at coordinates")
        func setsValueAtCoordinates() {
            let grid = Grid<Int>.ofNulls(width: 3, height: 3)
            
            grid[1, 1] = 42
            #expect(grid[1, 1] == 42)
        }
        
        @Test("sets nil value")
        func setsNilValue() {
            let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 1)
            
            grid[0, 0] = nil
            #expect(grid[0, 0] == nil)
        }
    }
    
    @Suite("Subscript [coord: Coordinate]")
    struct SubscriptCoordinate {
        
        @Test("gets value using Coordinate")
        func getsValueUsingCoordinate() throws {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            let coord = try Coordinate(x: 2, y: 1)
            
            #expect(grid[coord] == 6)
        }
        
        @Test("sets value using Coordinate")
        func setsValueUsingCoordinate() throws {
            let grid = Grid<Int>.ofNulls(width: 3, height: 3)
            let coord = try Coordinate(x: 1, y: 2)
            
            grid[coord] = 99
            #expect(grid[coord] == 99)
            #expect(grid[1, 2] == 99)
        }
    }
    
    @Suite("Subscript [column: String, row: Int]")
    struct SubscriptColumnRow {
        
        @Test("gets value using sheet notation")
        func getsValueUsingSheetNotation() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            // Column A = 0, Row 1 = index 0
            let colA: String = "A"
            #expect(grid[colA, 1] == 1)
            
            // Column C = 2, Row 2 = index 1
            let colC: String = "C"
            #expect(grid[colC, 2] == 6)
        }
        
        @Test("sets value using sheet notation")
        func setsValueUsingSheetNotation() {
            let grid = Grid<Int>.ofNulls(width: 3, height: 3)
            
            let colB: String = "B"
            grid[colB, 2] = 42
            #expect(grid[1, 1] == 42)  // B=1, row 2 = index 1
        }
        
        @Test("handles multi-letter columns")
        func handlesMultiLetterColumns() {
            let grid = Grid<Int>.of(width: 30, height: 2, defaultValue: 0)
            
            let colAA: String = "AA"
            grid[colAA, 1] = 100  // AA = column 26
            #expect(grid[26, 0] == 100)
        }
    }
    
    @Suite("Subscript [ref: String]")
    struct SubscriptRef {
        
        @Test("gets value using reference string")
        func getsValueUsingRefString() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let refA1: String = "A1"
            let refC2: String = "C2"
            #expect(grid[refA1] == 1)
            #expect(grid[refC2] == 6)
        }
        
        @Test("sets value using reference string")
        func setsValueUsingRefString() {
            let grid = Grid<Int>.ofNulls(width: 3, height: 3)
            
            let refB2: String = "B2"
            grid[refB2] = 42
            #expect(grid[1, 1] == 42)
        }
        
        @Test("returns nil for invalid reference")
        func returnsNilForInvalidRef() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 1)
            
            let invalidRef: String = "invalid"
            #expect(grid[invalidRef] == nil)
        }
    }
}

// MARK: - Grid Row and Column Operations Tests

@Suite("Grid Row and Column Operations")
struct GridRowColumnOperationsTests {
    
    @Suite("getRowCopy(_:)")
    struct GetRowCopy {
        
        @Test("returns copy of row data")
        func returnsCopyOfRowData() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let row0 = grid.getRowCopy(0)
            let row1 = grid.getRowCopy(1)
            
            #expect(row0 == [1, 2, 3])
            #expect(row1 == [4, 5, 6])
        }
        
        @Test("returns independent copy")
        func returnsIndependentCopy() {
            let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 1)
            
            var row = grid.getRowCopy(0)
            row[0] = 99
            
            // Original grid unchanged
            #expect(grid[0, 0] == 1)
        }
    }
    
    @Suite("getColumnCopy(_:)")
    struct GetColumnCopy {
        
        @Test("returns copy of column data by index")
        func returnsCopyOfColumnByIndex() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let col0 = grid.getColumnCopy(0)
            let col2 = grid.getColumnCopy(2)
            
            #expect(col0 == [1, 4])
            #expect(col2 == [3, 6])
        }
        
        @Test("returns copy of column data by letter")
        func returnsCopyOfColumnByLetter() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let colA: String = "A"
            let colC: String = "C"
            let col0 = grid.getColumnCopy(colA)
            let col2 = grid.getColumnCopy(colC)
            
            #expect(col0 == [1, 4])
            #expect(col2 == [3, 6])
        }
    }
    
    @Suite("setRow(_:values:)")
    struct SetRow {
        
        @Test("sets entire row")
        func setsEntireRow() {
            let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
            
            let newValues: [Int?] = [7, 8, 9]
            grid.setRow(1, values: newValues)
            
            #expect(grid[0, 1] == 7)
            #expect(grid[1, 1] == 8)
            #expect(grid[2, 1] == 9)
            
            // Row 0 unchanged
            #expect(grid[0, 0] == 0)
        }
        
        @Test("sets row with nil values")
        func setsRowWithNilValues() {
            let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 1)
            
            let newValues: [Int?] = [nil, 5, nil]
            grid.setRow(0, values: newValues)
            
            #expect(grid[0, 0] == nil)
            #expect(grid[1, 0] == 5)
            #expect(grid[2, 0] == nil)
        }
    }
    
    @Suite("setColumn(_:values:)")
    struct SetColumn {
        
        @Test("sets entire column by index")
        func setsEntireColumnByIndex() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
            
            let newValues: [Int?] = [1, 2, 3]
            grid.setColumn(1, values: newValues)
            
            #expect(grid[1, 0] == 1)
            #expect(grid[1, 1] == 2)
            #expect(grid[1, 2] == 3)
            
            // Other columns unchanged
            #expect(grid[0, 0] == 0)
            #expect(grid[2, 2] == 0)
        }
        
        @Test("sets entire column by letter")
        func setsEntireColumnByLetter() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
            
            let colB: String = "B"
            let newValues: [Int?] = [10, 20, 30]
            grid.setColumn(colB, values: newValues)
            
            #expect(grid[1, 0] == 10)
            #expect(grid[1, 1] == 20)
            #expect(grid[1, 2] == 30)
        }
    }
}

// MARK: - Grid Transformation Tests

@Suite("Grid Transformations")
struct GridTransformationsTests {
    
    @Suite("transpose()")
    struct Transpose {
        
        @Test("transposes grid")
        func transposesGrid() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            // Original:
            // 1 2 3
            // 4 5 6
            
            let transposed = grid.transpose()
            // Transposed:
            // 1 4
            // 2 5
            // 3 6
            
            #expect(transposed.width == 2)
            #expect(transposed.height == 3)
            #expect(transposed[0, 0] == 1)
            #expect(transposed[1, 0] == 4)
            #expect(transposed[0, 1] == 2)
            #expect(transposed[1, 1] == 5)
            #expect(transposed[0, 2] == 3)
            #expect(transposed[1, 2] == 6)
        }
        
        @Test("double transpose returns original")
        func doubleTransposeReturnsOriginal() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let doubleTransposed = grid.transpose().transpose()
            
            #expect(doubleTransposed.width == grid.width)
            #expect(doubleTransposed.height == grid.height)
            #expect(doubleTransposed == grid)
        }
        
        @Test("transposes square grid")
        func transposesSquareGrid() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            let transposed = grid.transpose()
            
            #expect(transposed[0, 0] == 1)
            #expect(transposed[1, 0] == 3)
            #expect(transposed[0, 1] == 2)
            #expect(transposed[1, 1] == 4)
        }
    }
    
    @Suite("subgrid(startX:startY:width:height:)")
    struct Subgrid {
        
        @Test("extracts subgrid")
        func extractsSubgrid() {
            let grid = Grid<Int>.build(width: 5, height: 5) { x, y in
                y * 5 + x
            }
            
            let sub = grid.subgrid(startX: 1, startY: 1, width: 3, height: 3)
            
            #expect(sub.width == 3)
            #expect(sub.height == 3)
            #expect(sub[0, 0] == 6)   // (1,1) in original
            #expect(sub[2, 2] == 18)  // (3,3) in original
        }
        
        @Test("extracts single cell as 1x1 subgrid")
        func extractsSingleCell() {
            let grid = Grid<Int>.build(width: 3, height: 3) { x, y in
                x + y
            }
            
            let sub = grid.subgrid(startX: 1, startY: 1, width: 1, height: 1)
            
            #expect(sub.width == 1)
            #expect(sub.height == 1)
            #expect(sub[0, 0] == 2)
        }
        
        @Test("extracts full grid as subgrid")
        func extractsFullGrid() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            let sub = grid.subgrid(startX: 0, startY: 0, width: 2, height: 2)
            
            #expect(sub == grid)
        }
    }
    
    @Suite("map(_:)")
    struct Map {
        
        @Test("transforms all values")
        func transformsAllValues() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            let doubled = grid.map { ($0 ?? 0) * 2 }
            
            #expect(doubled[0, 0] == 2)
            #expect(doubled[1, 0] == 4)
            #expect(doubled[0, 1] == 6)
            #expect(doubled[1, 1] == 8)
        }
        
        @Test("changes element type")
        func changesElementType() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            let stringGrid: Grid<String> = grid.map { value in
                if let v = value {
                    return String(v)
                }
                return nil
            }
            
            #expect(stringGrid[0, 0] == "1")
            #expect(stringGrid[1, 1] == "4")
        }
        
        @Test("handles nil values")
        func handlesNilValues() {
            let data: [Int?] = [1, nil, 3, nil]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            let mapped = grid.map { $0 }
            
            #expect(mapped[0, 0] == 1)
            #expect(mapped[1, 0] == nil)
            #expect(mapped[0, 1] == 3)
            #expect(mapped[1, 1] == nil)
        }
    }
    
    @Suite("mapIndexed(_:)")
    struct MapIndexed {
        
        @Test("transforms with coordinates")
        func transformsWithCoordinates() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
            
            let indexed = grid.mapIndexed { x, y, _ in
                x * 10 + y
            }
            
            #expect(indexed[0, 0] == 0)
            #expect(indexed[1, 0] == 10)
            #expect(indexed[2, 1] == 21)
            #expect(indexed[2, 2] == 22)
        }
    }
    
    @Suite("copy()")
    struct Copy {
        
        @Test("creates independent copy")
        func createsIndependentCopy() {
            let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 1)
            let gridCopy = grid.copy()
            
            gridCopy[0, 0] = 99
            
            #expect(grid[0, 0] == 1)
            #expect(gridCopy[0, 0] == 99)
        }
        
        @Test("copy equals original")
        func copyEqualsOriginal() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            let gridCopy = grid.copy()
            
            #expect(grid == gridCopy)
        }
    }
}

// MARK: - Grid Iteration Tests

@Suite("Grid Iteration")
struct GridIterationTests {
    
    @Suite("forEach(_:)")
    struct ForEach {
        
        @Test("iterates all values")
        func iteratesAllValues() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            var sum = 0
            grid.forEach { value in
                sum += value ?? 0
            }
            
            #expect(sum == 10)
        }
    }
    
    @Suite("forEachIndexed(_:)")
    struct ForEachIndexed {
        
        @Test("iterates with coordinates")
        func iteratesWithCoordinates() {
            let data: [Int?] = [1, 2, 3, 4]
            let grid = Grid<Int>(width: 2, height: 2, data: data)
            
            var coords: [(Int, Int)] = []
            grid.forEachIndexed { x, y, _ in
                coords.append((x, y))
            }
            
            // Row-major order
            #expect(coords.count == 4)
            #expect(coords[0] == (0, 0))
            #expect(coords[1] == (1, 0))
            #expect(coords[2] == (0, 1))
            #expect(coords[3] == (1, 1))
        }
    }
    
    @Suite("find(_:)")
    struct Find {
        
        @Test("finds first matching cell")
        func findsFirstMatching() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let result = grid.find { ($0 ?? 0) > 3 }
            
            #expect(result != nil)
            #expect(result?.0.x == 0)
            #expect(result?.0.y == 1)
            #expect(result?.1 == 4)
        }
        
        @Test("returns nil when no match")
        func returnsNilWhenNoMatch() {
            let data: [Int?] = [1, 2, 3]
            let grid = Grid<Int>(width: 3, height: 1, data: data)
            
            let result = grid.find { ($0 ?? 0) > 100 }
            
            #expect(result == nil)
        }
    }
    
    @Suite("findAll(_:)")
    struct FindAll {
        
        @Test("finds all matching cells")
        func findsAllMatching() {
            let data: [Int?] = [1, 2, 3, 4, 5, 6]
            let grid = Grid<Int>(width: 3, height: 2, data: data)
            
            let results = grid.findAll { ($0 ?? 0) % 2 == 0 }
            
            #expect(results.count == 3)
            // Values: 2, 4, 6
        }
        
        @Test("returns empty array when no match")
        func returnsEmptyWhenNoMatch() {
            let data: [Int?] = [1, 3, 5]
            let grid = Grid<Int>(width: 3, height: 1, data: data)
            
            let results = grid.findAll { ($0 ?? 0) % 2 == 0 }
            
            #expect(results.isEmpty)
        }
    }
}

// MARK: - Grid Fill Operations Tests

@Suite("Grid Fill Operations")
struct GridFillOperationsTests {
    
    @Suite("fill(_:)")
    struct Fill {
        
        @Test("fills all cells with value")
        func fillsAllCells() {
            let grid = Grid<Int>.ofNulls(width: 3, height: 3)
            
            grid.fill(42)
            
            for y in 0..<3 {
                for x in 0..<3 {
                    #expect(grid[x, y] == 42)
                }
            }
        }
        
        @Test("fills all cells with nil")
        func fillsAllWithNil() {
            let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 1)
            
            grid.fill(nil)
            
            #expect(grid.isEmpty)
        }
    }
    
    @Suite("fillRow(_:value:)")
    struct FillRow {
        
        @Test("fills single row")
        func fillsSingleRow() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
            
            grid.fillRow(1, value: 5)
            
            #expect(grid[0, 0] == 0)
            #expect(grid[0, 1] == 5)
            #expect(grid[1, 1] == 5)
            #expect(grid[2, 1] == 5)
            #expect(grid[0, 2] == 0)
        }
    }
    
    @Suite("fillColumn(_:value:)")
    struct FillColumn {
        
        @Test("fills single column by index")
        func fillsSingleColumnByIndex() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
            
            grid.fillColumn(1, value: 5)
            
            #expect(grid[0, 0] == 0)
            #expect(grid[1, 0] == 5)
            #expect(grid[1, 1] == 5)
            #expect(grid[1, 2] == 5)
            #expect(grid[2, 0] == 0)
        }
        
        @Test("fills single column by letter")
        func fillsSingleColumnByLetter() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
            
            let colB: String = "B"
            grid.fillColumn(colB, value: 7)
            
            #expect(grid[1, 0] == 7)
            #expect(grid[1, 1] == 7)
            #expect(grid[1, 2] == 7)
        }
    }
    
    @Suite("clear()")
    struct Clear {
        
        @Test("clears all cells to nil")
        func clearsAllCells() {
            let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 1)
            
            grid.clear()
            
            #expect(grid.isEmpty)
            for y in 0..<3 {
                for x in 0..<3 {
                    #expect(grid[x, y] == nil)
                }
            }
        }
    }
}

// MARK: - Grid Predicate Tests

@Suite("Grid Predicates")
struct GridPredicatesTests {
    
    @Test("count returns number of matching cells")
    func countReturnsMatching() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let evenCount = grid.count { ($0 ?? 0) % 2 == 0 }
        #expect(evenCount == 3)
    }
    
    @Test("any returns true if any cell matches")
    func anyReturnsTrueIfMatches() {
        let data: [Int?] = [1, 2, 3]
        let grid = Grid<Int>(width: 3, height: 1, data: data)
        
        #expect(grid.any { $0 == 2 })
        #expect(!grid.any { $0 == 100 })
    }
    
    @Test("all returns true if all cells match")
    func allReturnsTrueIfAllMatch() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 5)
        
        #expect(grid.all { $0 == 5 })
        
        grid[0, 0] = 1
        #expect(!grid.all { $0 == 5 })
    }
    
    @Test("none returns true if no cells match")
    func noneReturnsTrueIfNoneMatch() {
        let data: [Int?] = [1, 3, 5]
        let grid = Grid<Int>(width: 3, height: 1, data: data)
        
        #expect(grid.none { ($0 ?? 0) % 2 == 0 })
        #expect(!grid.none { $0 == 3 })
    }
}

// MARK: - Grid Conversion Tests

@Suite("Grid Conversion")
struct GridConversionTests {
    
    @Test("toArray returns flat array in row-major order")
    func toArrayReturnsFlatArray() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let array = grid.toArray()
        
        #expect(array == data)
    }
    
    @Test("toRowArray returns array of rows")
    func toRowArrayReturnsArrayOfRows() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let rows = grid.toRowArray()
        
        #expect(rows.count == 2)
        #expect(rows[0] == [1, 2, 3])
        #expect(rows[1] == [4, 5, 6])
    }
}

// MARK: - Grid Equality and Hashing Tests

@Suite("Grid Equality and Hashing")
struct GridEqualityHashingTests {
    
    @Test("equal grids are equal")
    func equalGridsAreEqual() {
        let data: [Int?] = [1, 2, 3, 4]
        let grid1 = Grid<Int>(width: 2, height: 2, data: data)
        let grid2 = Grid<Int>(width: 2, height: 2, data: data)
        
        #expect(grid1 == grid2)
    }
    
    @Test("different dimensions are not equal")
    func differentDimensionsNotEqual() {
        let data1: [Int?] = [1, 2, 3, 4, 5, 6]
        let data2: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid1 = Grid<Int>(width: 3, height: 2, data: data1)
        let grid2 = Grid<Int>(width: 2, height: 3, data: data2)
        
        #expect(grid1 != grid2)
    }
    
    @Test("different data are not equal")
    func differentDataNotEqual() {
        let data1: [Int?] = [1, 2, 3, 4]
        let data2: [Int?] = [1, 2, 3, 5]
        let grid1 = Grid<Int>(width: 2, height: 2, data: data1)
        let grid2 = Grid<Int>(width: 2, height: 2, data: data2)
        
        #expect(grid1 != grid2)
    }
    
    @Test("equal grids have equal hash values")
    func equalGridsHaveEqualHashes() {
        let data: [Int?] = [1, 2, 3, 4]
        let grid1 = Grid<Int>(width: 2, height: 2, data: data)
        let grid2 = Grid<Int>(width: 2, height: 2, data: data)
        
        #expect(grid1.hashValue == grid2.hashValue)
    }
    
    @Test("grids work in Set")
    func gridsWorkInSet() {
        let data1: [Int?] = [1, 2, 3, 4]
        let data2: [Int?] = [5, 6, 7, 8]
        let grid1 = Grid<Int>(width: 2, height: 2, data: data1)
        let grid2 = Grid<Int>(width: 2, height: 2, data: data2)
        let grid3 = Grid<Int>(width: 2, height: 2, data: data1)  // Same as grid1
        
        let set: Set<Grid<Int>> = [grid1, grid2, grid3]
        
        #expect(set.count == 2)
    }
}

// MARK: - Row Accessor Tests

@Suite("RowAccessor")
struct RowAccessorTests {
    
    @Test("count returns number of rows")
    func countReturnsNumberOfRows() {
        let grid = Grid<Int>.of(width: 3, height: 5, defaultValue: 0)
        #expect(grid.rows.count == 5)
    }
    
    @Test("subscript returns RowView")
    func subscriptReturnsRowView() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let row0 = grid.rows[0]
        let row1 = grid.rows[1]
        
        #expect(row0[0] == 1)
        #expect(row0[1] == 2)
        #expect(row0[2] == 3)
        #expect(row1[0] == 4)
        #expect(row1[2] == 6)
    }
    
    @Test("toArray returns all rows as views")
    func toArrayReturnsAllRows() {
        let grid = Grid<Int>.of(width: 3, height: 4, defaultValue: 0)
        
        let allRows = grid.rows.toArray()
        
        #expect(allRows.count == 4)
    }
}

// MARK: - RowView Tests

@Suite("RowView")
struct RowViewTests {
    
    @Test("provides live view of row data")
    func providesLiveView() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let row = grid.rows[0]
        
        // Modify through grid
        grid[1, 0] = 99
        
        // View reflects change
        #expect(row[1] == 99)
    }
    
    @Test("modification through view affects grid")
    func modificationAffectsGrid() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        
        let row = grid.rows[1]
        row[0] = 42
        
        #expect(grid[0, 1] == 42)
    }
    
    @Test("toCopy returns independent copy")
    func toCopyReturnsIndependentCopy() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let row = grid.rows[0]
        var rowCopy = row.toCopy()
        
        rowCopy[0] = 99
        
        #expect(grid[0, 0] == 1)  // Original unchanged
    }
    
    @Test("rowNumber returns one-based index")
    func rowNumberReturnsOneBased() {
        let grid = Grid<Int>.of(width: 3, height: 5, defaultValue: 0)
        
        #expect(grid.rows[0].rowNumber == 1)
        #expect(grid.rows[4].rowNumber == 5)
    }
    
    @Test("RowView is RandomAccessCollection")
    func isRandomAccessCollection() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let row = grid.rows[0]
        
        #expect(row.startIndex == 0)
        #expect(row.endIndex == 3)
        #expect(row.count == 3)
    }
}

// MARK: - Column Accessor Tests

@Suite("ColumnAccessor")
struct ColumnAccessorTests {
    
    @Test("count returns number of columns")
    func countReturnsNumberOfColumns() {
        let grid = Grid<Int>.of(width: 5, height: 3, defaultValue: 0)
        #expect(grid.columns.count == 5)
    }
    
    @Test("subscript by index returns ColumnView")
    func subscriptByIndexReturnsColumnView() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let col0 = grid.columns[0]
        let col2 = grid.columns[2]
        
        #expect(col0[0] == 1)
        #expect(col0[1] == 4)
        #expect(col2[0] == 3)
        #expect(col2[1] == 6)
    }
    
    @Test("subscript by letter returns ColumnView")
    func subscriptByLetterReturnsColumnView() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let colA: String = "A"
        let colC: String = "C"
        let col0 = grid.columns[colA]
        let col2 = grid.columns[colC]
        
        #expect(col0[0] == 1)
        #expect(col2[1] == 6)
    }
    
    @Test("toArray returns all columns as views")
    func toArrayReturnsAllColumns() {
        let grid = Grid<Int>.of(width: 4, height: 3, defaultValue: 0)
        
        let allCols = grid.columns.toArray()
        
        #expect(allCols.count == 4)
    }
}

// MARK: - ColumnView Tests

@Suite("ColumnView")
struct ColumnViewTests {
    
    @Test("provides live view of column data")
    func providesLiveView() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let col = grid.columns[1]
        
        // Modify through grid
        grid[1, 0] = 99
        
        // View reflects change
        #expect(col[0] == 99)
    }
    
    @Test("modification through view affects grid")
    func modificationAffectsGrid() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        
        let col = grid.columns[2]
        col[1] = 42
        
        #expect(grid[2, 1] == 42)
    }
    
    @Test("toCopy returns independent copy")
    func toCopyReturnsIndependentCopy() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let col = grid.columns[0]
        var colCopy = col.toCopy()
        
        colCopy[0] = 99
        
        #expect(grid[0, 0] == 1)  // Original unchanged
    }
    
    @Test("columnLetter returns correct letter")
    func columnLetterReturnsCorrectLetter() {
        let grid = Grid<Int>.of(width: 30, height: 2, defaultValue: 0)
        
        #expect(grid.columns[0].columnLetter == "A")
        #expect(grid.columns[25].columnLetter == "Z")
        #expect(grid.columns[26].columnLetter == "AA")
    }
    
    @Test("ColumnView is RandomAccessCollection")
    func isRandomAccessCollection() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        
        let col = grid.columns[0]
        
        #expect(col.startIndex == 0)
        #expect(col.endIndex == 2)
        #expect(col.count == 2)
    }
}

// MARK: - Grid Edge Cases Tests

@Suite("Grid Edge Cases")
struct GridEdgeCasesTests {
    
    @Test("handles large grid")
    func handlesLargeGrid() {
        let grid = Grid<Int>.build(width: 100, height: 100) { x, y in
            x + y
        }
        
        #expect(grid.size == 10000)
        #expect(grid[0, 0] == 0)
        #expect(grid[99, 99] == 198)
    }
    
    @Test("handles grid with all nil values")
    func handlesAllNilValues() {
        let grid = Grid<Int>.ofNulls(width: 5, height: 5)
        
        #expect(grid.isEmpty)
        #expect(grid.count { $0 == nil } == 25)
    }
    
    @Test("handles grid with mixed nil and values")
    func handlesMixedNilAndValues() {
        let grid = Grid<Int>.build(width: 3, height: 3) { x, y in
            (x + y) % 2 == 0 ? x + y : nil
        }
        
        #expect(grid[0, 0] == 0)
        #expect(grid[1, 0] == nil)
        #expect(grid[2, 0] == 2)
    }
    
    @Test("handles custom object type")
    func handlesCustomObjectType() {
        struct Point {
            let x: Int
            let y: Int
        }
        
        let grid = Grid<Point>.build(width: 2, height: 2) { x, y in
            Point(x: x, y: y)
        }
        
        #expect(grid[0, 0]?.x == 0)
        #expect(grid[0, 0]?.y == 0)
        #expect(grid[1, 1]?.x == 1)
        #expect(grid[1, 1]?.y == 1)
    }
    
    @Test("handles String grid operations")
    func handlesStringGridOperations() {
        let hello: String = "Hello"
        let world: String = "World"
        let foo: String = "Foo"
        let bar: String = "Bar"
        let data: [String?] = [hello, world, foo, bar]
        let grid = Grid<String>(width: 2, height: 2, data: data)
        
        // Access
        #expect(grid[0, 0] == "Hello")
        
        // Map
        let upper = grid.map { $0?.uppercased() }
        #expect(upper[0, 0] == "HELLO")
        
        // Find
        let result = grid.find { $0 == "World" }
        #expect(result?.0.x == 1)
        #expect(result?.0.y == 0)
    }
    
    @Test("stress test many operations")
    func stressTestManyOperations() {
        let grid = Grid<Int>.of(width: 10, height: 10, defaultValue: 0)
        
        // Many cell updates
        for i in 0..<100 {
            grid[i % 10, i / 10] = i
        }
        
        // Verify
        for y in 0..<10 {
            for x in 0..<10 {
                #expect(grid[x, y] == y * 10 + x)
            }
        }
    }
}
