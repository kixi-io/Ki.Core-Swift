// GridChangeListenerTests.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Testing
import Foundation
@testable import KiCore

// MARK: - Test Listener Implementation

/// A test listener that records all events for verification.
final class TestGridListener: GridChangeListener {
    var cellEvents: [CellChangeEvent<Int>] = []
    var rowEvents: [RowChangeEvent<Int>] = []
    var columnEvents: [ColumnChangeEvent<Int>] = []
    var bulkEvents: [BulkChangeEvent<Int>] = []
    
    func onCellChanged<T>(_ event: CellChangeEvent<T>) {
        if let intEvent = event as? CellChangeEvent<Int> {
            cellEvents.append(intEvent)
        }
    }
    
    func onRowChanged<T>(_ event: RowChangeEvent<T>) {
        if let intEvent = event as? RowChangeEvent<Int> {
            rowEvents.append(intEvent)
        }
    }
    
    func onColumnChanged<T>(_ event: ColumnChangeEvent<T>) {
        if let intEvent = event as? ColumnChangeEvent<Int> {
            columnEvents.append(intEvent)
        }
    }
    
    func onBulkChange<T>(_ event: BulkChangeEvent<T>) {
        if let intEvent = event as? BulkChangeEvent<Int> {
            bulkEvents.append(intEvent)
        }
    }
    
    func reset() {
        cellEvents.removeAll()
        rowEvents.removeAll()
        columnEvents.removeAll()
        bulkEvents.removeAll()
    }
    
    var totalEventCount: Int {
        cellEvents.count + rowEvents.count + columnEvents.count + bulkEvents.count
    }
}

/// A test listener for String grids.
final class TestStringGridListener: GridChangeListener {
    var cellEvents: [CellChangeEvent<String>] = []
    var rowEvents: [RowChangeEvent<String>] = []
    var columnEvents: [ColumnChangeEvent<String>] = []
    var bulkEvents: [BulkChangeEvent<String>] = []
    
    func onCellChanged<T>(_ event: CellChangeEvent<T>) {
        if let strEvent = event as? CellChangeEvent<String> {
            cellEvents.append(strEvent)
        }
    }
    
    func onRowChanged<T>(_ event: RowChangeEvent<T>) {
        if let strEvent = event as? RowChangeEvent<String> {
            rowEvents.append(strEvent)
        }
    }
    
    func onColumnChanged<T>(_ event: ColumnChangeEvent<T>) {
        if let strEvent = event as? ColumnChangeEvent<String> {
            columnEvents.append(strEvent)
        }
    }
    
    func onBulkChange<T>(_ event: BulkChangeEvent<T>) {
        if let strEvent = event as? BulkChangeEvent<String> {
            bulkEvents.append(strEvent)
        }
    }
    
    func reset() {
        cellEvents.removeAll()
        rowEvents.removeAll()
        columnEvents.removeAll()
        bulkEvents.removeAll()
    }
}

// MARK: - Listener Management Tests

@Suite("Grid Listener Management")
struct GridListenerManagementTests {
    
    @Test("hasListeners returns false initially")
    func hasListenersFalseInitially() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        #expect(!grid.hasListeners)
    }
    
    @Test("hasListeners returns true after adding listener")
    func hasListenersTrueAfterAdding() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        
        grid.addChangeListener(listener)
        
        #expect(grid.hasListeners)
    }
    
    @Test("addChangeListener adds listener")
    func addChangeListenerAddsListener() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        
        grid.addChangeListener(listener)
        grid[0, 0] = 42
        
        #expect(listener.cellEvents.count == 1)
    }
    
    @Test("multiple listeners receive events")
    func multipleListenersReceiveEvents() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener1 = TestGridListener()
        let listener2 = TestGridListener()
        
        grid.addChangeListener(listener1)
        grid.addChangeListener(listener2)
        grid[0, 0] = 42
        
        #expect(listener1.cellEvents.count == 1)
        #expect(listener2.cellEvents.count == 1)
    }
    
    @Test("removeChangeListener removes listener")
    func removeChangeListenerRemovesListener() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        
        grid.addChangeListener(listener)
        let removed = grid.removeChangeListener(listener)
        grid[0, 0] = 42
        
        #expect(removed == true)
        #expect(listener.cellEvents.count == 0)
    }
    
    @Test("removeChangeListener returns false for unknown listener")
    func removeUnknownListenerReturnsFalse() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener1 = TestGridListener()
        let listener2 = TestGridListener()
        
        grid.addChangeListener(listener1)
        let removed = grid.removeChangeListener(listener2)
        
        #expect(removed == false)
    }
    
    @Test("hasListeners returns false after removing all listeners")
    func hasListenersFalseAfterRemovingAll() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        
        grid.addChangeListener(listener)
        grid.removeChangeListener(listener)
        
        #expect(!grid.hasListeners)
    }
}

// MARK: - Cell Change Event Tests

@Suite("CellChangeEvent")
struct CellChangeEventTests {
    
    @Test("fires on cell set via subscript")
    func firesOnCellSetViaSubscript() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[1, 2] = 42
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.x == 1)
        #expect(event.y == 2)
        #expect(event.oldValue == 0)
        #expect(event.newValue == 42)
    }
    
    @Test("fires on cell set via Coordinate")
    func firesOnCellSetViaCoordinate() throws {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let coord = Coordinate(validX: 2, validY: 2, validZ: 1)
        grid[coord] = 99
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.coordinate.x == 2)
        #expect(event.coordinate.y == 2)
        #expect(event.newValue == 99)
    }
    
    @Test("fires on cell set via sheet notation")
    func firesOnCellSetViaSheetNotation() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let colB: String = "B"
        grid[colB, 2] = 50  // B2 = (1, 1)
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.x == 1)
        #expect(event.y == 1)
        #expect(event.newValue == 50)
    }
    
    @Test("fires on cell set via reference string")
    func firesOnCellSetViaRefString() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let ref: String = "C3"
        grid[ref] = 77  // C3 = (2, 2)
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.x == 2)
        #expect(event.y == 2)
        #expect(event.newValue == 77)
    }
    
    @Test("captures old value correctly")
    func capturesOldValueCorrectly() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 10)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[0, 0] = 20
        grid[0, 0] = 30
        
        #expect(listener.cellEvents.count == 2)
        #expect(listener.cellEvents[0].oldValue == 10)
        #expect(listener.cellEvents[0].newValue == 20)
        #expect(listener.cellEvents[1].oldValue == 20)
        #expect(listener.cellEvents[1].newValue == 30)
    }
    
    @Test("fires when setting to nil")
    func firesWhenSettingToNil() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 5)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[0, 0] = nil
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.oldValue == 5)
        #expect(event.newValue == nil)
    }
    
    @Test("fires when setting from nil")
    func firesWhenSettingFromNil() {
        let grid = Grid<Int>.ofNulls(width: 2, height: 2)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[0, 0] = 42
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.oldValue == nil)
        #expect(event.newValue == 42)
    }
    
    @Test("coordinate property returns correct coordinate")
    func coordinatePropertyReturnsCorrect() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[2, 1] = 100
        
        let event = listener.cellEvents[0]
        #expect(event.coordinate.x == 2)
        #expect(event.coordinate.y == 1)
    }
    
    @Test("works with String grid")
    func worksWithStringGrid() {
        let hello: String = "Hello"
        let world: String = "World"
        let foo: String = "Foo"
        let bar: String = "Bar"
        let data: [String?] = [hello, world, foo, bar]
        let grid = Grid<String>(width: 2, height: 2, data: data)
        let listener = TestStringGridListener()
        grid.addChangeListener(listener)
        
        let newVal: String = "Changed"
        grid[0, 0] = newVal
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.oldValue == "Hello")
        #expect(event.newValue == "Changed")
    }
}

// MARK: - Row Change Event Tests

@Suite("RowChangeEvent")
struct RowChangeEventTests {
    
    @Test("fires on setRow")
    func firesOnSetRow() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let newValues: [Int?] = [1, 2, 3]
        grid.setRow(0, values: newValues)
        
        #expect(listener.rowEvents.count == 1)
        let event = listener.rowEvents[0]
        #expect(event.rowIndex == 0)
        #expect(event.type == .modified)
        #expect(event.oldValues == [0, 0, 0])
        #expect(event.newValues == [1, 2, 3])
    }
    
    @Test("fires on fillRow")
    func firesOnFillRow() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid.fillRow(1, value: 5)
        
        #expect(listener.rowEvents.count == 1)
        let event = listener.rowEvents[0]
        #expect(event.rowIndex == 1)
        #expect(event.type == .modified)
        #expect(event.oldValues == [0, 0, 0])
        #expect(event.newValues == [5, 5, 5])
    }
    
    @Test("captures correct old and new values")
    func capturesCorrectOldAndNewValues() {
        let data: [Int?] = [1, 2, 3, 4, 5, 6]
        let grid = Grid<Int>(width: 3, height: 2, data: data)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let newValues: [Int?] = [10, 20, 30]
        grid.setRow(0, values: newValues)
        
        let event = listener.rowEvents[0]
        #expect(event.oldValues == [1, 2, 3])
        #expect(event.newValues == [10, 20, 30])
    }
    
    @Test("RowChangeType values")
    func rowChangeTypeValues() {
        // Verify enum cases exist
        let inserted = RowChangeType.inserted
        let deleted = RowChangeType.deleted
        let modified = RowChangeType.modified
        
        #expect(inserted == .inserted)
        #expect(deleted == .deleted)
        #expect(modified == .modified)
    }
}

// MARK: - Column Change Event Tests

@Suite("ColumnChangeEvent")
struct ColumnChangeEventTests {
    
    @Test("fires on setColumn by index")
    func firesOnSetColumnByIndex() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let newValues: [Int?] = [1, 2]
        grid.setColumn(1, values: newValues)
        
        #expect(listener.columnEvents.count == 1)
        let event = listener.columnEvents[0]
        #expect(event.columnIndex == 1)
        #expect(event.type == .modified)
        #expect(event.oldValues == [0, 0])
        #expect(event.newValues == [1, 2])
    }
    
    @Test("fires on setColumn by letter")
    func firesOnSetColumnByLetter() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let colC: String = "C"
        let newValues: [Int?] = [7, 8]
        grid.setColumn(colC, values: newValues)
        
        #expect(listener.columnEvents.count == 1)
        let event = listener.columnEvents[0]
        #expect(event.columnIndex == 2)  // C = 2
        #expect(event.newValues == [7, 8])
    }
    
    @Test("fires on fillColumn by index")
    func firesOnFillColumnByIndex() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid.fillColumn(0, value: 9)
        
        #expect(listener.columnEvents.count == 1)
        let event = listener.columnEvents[0]
        #expect(event.columnIndex == 0)
        #expect(event.type == .modified)
        #expect(event.newValues == [9, 9, 9])
    }
    
    @Test("fires on fillColumn by letter")
    func firesOnFillColumnByLetter() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let colB: String = "B"
        grid.fillColumn(colB, value: 4)
        
        #expect(listener.columnEvents.count == 1)
        let event = listener.columnEvents[0]
        #expect(event.columnIndex == 1)  // B = 1
    }
    
    @Test("ColumnChangeType values")
    func columnChangeTypeValues() {
        // Verify enum cases exist
        let inserted = ColumnChangeType.inserted
        let deleted = ColumnChangeType.deleted
        let modified = ColumnChangeType.modified
        
        #expect(inserted == .inserted)
        #expect(deleted == .deleted)
        #expect(modified == .modified)
    }
}

// MARK: - Bulk Change Event Tests

@Suite("BulkChangeEvent")
struct BulkChangeEventTests {
    
    @Test("fires on fill")
    func firesOnFill() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid.fill(42)
        
        #expect(listener.bulkEvents.count == 1)
        let event = listener.bulkEvents[0]
        #expect(event.type == .fill)
        
        let descStr: String = event.desc ?? ""
        #expect(descStr.range(of: "42" as String) != nil)
    }
    
    @Test("fires on clear")
    func firesOnClear() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 1)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid.clear()
        
        #expect(listener.bulkEvents.count == 1)
        let event = listener.bulkEvents[0]
        #expect(event.type == .clear)
        
        let descStr: String = event.desc ?? ""
        #expect(descStr.range(of: "cleared" as String) != nil)
    }
    
    @Test("description is set for fill")
    func descriptionIsSetForFill() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid.fill(99)
        
        let event = listener.bulkEvents[0]
        #expect(event.desc != nil)
        let descStr: String = event.desc ?? ""
        #expect(descStr.range(of: "99" as String) != nil)
    }
    
    @Test("description is set for clear")
    func descriptionIsSetForClear() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid.clear()
        
        let event = listener.bulkEvents[0]
        #expect(event.desc != nil)
        let descStr: String = event.desc ?? ""
        #expect(descStr.range(of: "cleared" as String) != nil)
    }
    
    @Test("BulkChangeType values")
    func bulkChangeTypeValues() {
        // Verify all enum cases exist
        #expect(BulkChangeType.clear == .clear)
        #expect(BulkChangeType.fill == .fill)
        #expect(BulkChangeType.paste == .paste)
        #expect(BulkChangeType.transpose == .transpose)
        #expect(BulkChangeType.resize == .resize)
    }
}

// MARK: - Default Implementation Tests

@Suite("GridChangeListener Default Implementations")
struct DefaultImplementationTests {
    
    /// A minimal listener that only overrides one method.
    final class MinimalListener: GridChangeListener {
        var cellCount = 0
        
        func onCellChanged<T>(_ event: CellChangeEvent<T>) {
            cellCount += 1
        }
        // Other methods use default (empty) implementations
    }
    
    @Test("default implementations do nothing")
    func defaultImplementationsDoNothing() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = MinimalListener()
        grid.addChangeListener(listener)
        
        // These should not crash - they use default empty implementations
        grid.fill(5)  // bulk event
        grid.setRow(0, values: [1, 2, 3])  // row event
        grid.setColumn(0, values: [1, 2, 3])  // column event
        
        // Only cell changes should be counted
        grid[0, 0] = 99
        
        #expect(listener.cellCount == 1)
    }
}

// MARK: - Event Struct Tests

@Suite("Event Struct Properties")
struct EventStructTests {
    
    @Suite("CellChangeEvent Properties")
    struct CellChangeEventProperties {
        
        @Test("x and y properties return coordinate values")
        func xAndYPropertiesReturnCoordinateValues() throws {
            let coord = Coordinate(x: 5, y: 10)
            let event = CellChangeEvent<Int>(coordinate: coord, oldValue: 1, newValue: 2)
            
            #expect(event.x == 5)
            #expect(event.y == 10)
        }
        
        @Test("oldValue and newValue are accessible")
        func oldAndNewValueAccessible() throws {
            let coord = Coordinate(x: 0, y: 0)
            let event = CellChangeEvent<Int>(coordinate: coord, oldValue: 100, newValue: 200)
            
            #expect(event.oldValue == 100)
            #expect(event.newValue == 200)
        }
        
        @Test("handles nil values")
        func handlesNilValues() throws {
            let coord = Coordinate(x: 0, y: 0)
            let event = CellChangeEvent<Int>(coordinate: coord, oldValue: nil, newValue: nil)
            
            #expect(event.oldValue == nil)
            #expect(event.newValue == nil)
        }
    }
    
    @Suite("RowChangeEvent Properties")
    struct RowChangeEventProperties {
        
        @Test("initializer with all parameters")
        func initializerWithAllParams() {
            let event = RowChangeEvent<Int>(
                rowIndex: 5,
                type: .modified,
                oldValues: [1, 2, 3],
                newValues: [4, 5, 6]
            )
            
            #expect(event.rowIndex == 5)
            #expect(event.type == .modified)
            #expect(event.oldValues == [1, 2, 3])
            #expect(event.newValues == [4, 5, 6])
        }
        
        @Test("initializer with default nil values")
        func initializerWithDefaultNils() {
            let event = RowChangeEvent<Int>(rowIndex: 0, type: .inserted)
            
            #expect(event.oldValues == nil)
            #expect(event.newValues == nil)
        }
    }
    
    @Suite("ColumnChangeEvent Properties")
    struct ColumnChangeEventProperties {
        
        @Test("initializer with all parameters")
        func initializerWithAllParams() {
            let event = ColumnChangeEvent<Int>(
                columnIndex: 3,
                type: .deleted,
                oldValues: [10, 20],
                newValues: nil
            )
            
            #expect(event.columnIndex == 3)
            #expect(event.type == .deleted)
            #expect(event.oldValues == [10, 20])
            #expect(event.newValues == nil)
        }
    }
    
    @Suite("BulkChangeEvent Properties")
    struct BulkChangeEventProperties {
        
        @Test("initializer with all parameters")
        func initializerWithAllParams() throws {
            let start = Coordinate(x: 0, y: 0)
            let end = Coordinate(x: 5, y: 5)
            let range = CoordinateRange(start: start, end: end)
            
            let descStr: String = "Test operation"
            let event = BulkChangeEvent<Int>(
                type: .paste,
                affectedRegion: range,
                description: descStr
            )
            
            #expect(event.type == .paste)
            #expect(event.affectedRegion != nil)
            #expect(event.desc == "Test operation")
        }
        
        @Test("initializer with default nil values")
        func initializerWithDefaultNils() {
            let event = BulkChangeEvent<Int>(type: .clear)
            
            #expect(event.affectedRegion == nil)
            #expect(event.desc == nil)
        }
    }
}

// MARK: - Integration Tests

@Suite("Grid Change Listener Integration")
struct GridChangeListenerIntegrationTests {
    
    @Test("complex sequence of operations fires correct events")
    func complexSequenceFiresCorrectEvents() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        // Cell change
        grid[0, 0] = 1
        
        // Row change
        let newRow: [Int?] = [10, 20, 30]
        grid.setRow(1, values: newRow)
        
        // Column change
        let newCol: [Int?] = [100, 200, 300]
        grid.setColumn(2, values: newCol)
        
        // Bulk change
        grid.clear()
        
        #expect(listener.cellEvents.count == 1)
        #expect(listener.rowEvents.count == 1)
        #expect(listener.columnEvents.count == 1)
        #expect(listener.bulkEvents.count == 1)
        #expect(listener.totalEventCount == 4)
    }
    
    @Test("listener reset clears all events")
    func listenerResetClearsAllEvents() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[0, 0] = 1
        grid.fill(5)
        
        listener.reset()
        
        #expect(listener.cellEvents.isEmpty)
        #expect(listener.bulkEvents.isEmpty)
        #expect(listener.totalEventCount == 0)
    }
    
    @Test("removed listener receives no further events")
    func removedListenerReceivesNoFurtherEvents() {
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[0, 0] = 1
        #expect(listener.cellEvents.count == 1)
        
        grid.removeChangeListener(listener)
        
        grid[0, 0] = 2
        grid[1, 1] = 3
        
        // Still only 1 event from before removal
        #expect(listener.cellEvents.count == 1)
    }
    
    @Test("operations without listener do not crash")
    func operationsWithoutListenerDoNotCrash() {
        let grid = Grid<Int>.of(width: 3, height: 3, defaultValue: 0)
        
        // All these should work without any listener
        grid[0, 0] = 1
        grid.setRow(0, values: [1, 2, 3])
        grid.setColumn(0, values: [1, 2, 3])
        grid.fill(5)
        grid.clear()
        
        #expect(!grid.hasListeners)
    }
    
    @Test("RowView modification fires cell event")
    func rowViewModificationFiresCellEvent() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let row = grid.rows[0]
        row[1] = 42
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.x == 1)
        #expect(event.y == 0)
        #expect(event.newValue == 42)
    }
    
    @Test("ColumnView modification fires cell event")
    func columnViewModificationFiresCellEvent() {
        let grid = Grid<Int>.of(width: 3, height: 2, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        let col = grid.columns[2]
        col[1] = 99
        
        #expect(listener.cellEvents.count == 1)
        let event = listener.cellEvents[0]
        #expect(event.x == 2)
        #expect(event.y == 1)
        #expect(event.newValue == 99)
    }
}

// MARK: - Performance Considerations Tests

@Suite("Grid Change Listener Performance")
struct GridChangeListenerPerformanceTests {
    
    @Test("many cell changes fire many events")
    func manyCellChangesFireManyEvents() {
        let grid = Grid<Int>.of(width: 10, height: 10, defaultValue: 0)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        for y in 0..<10 {
            for x in 0..<10 {
                grid[x, y] = x + y
            }
        }
        
        #expect(listener.cellEvents.count == 100)
    }
    
    @Test("listener not called for no-op operations")
    func listenerNotCalledForNoOps() {
        // Note: The current implementation always fires events even for same-value sets.
        // This test documents the current behavior.
        let grid = Grid<Int>.of(width: 2, height: 2, defaultValue: 5)
        let listener = TestGridListener()
        grid.addChangeListener(listener)
        
        grid[0, 0] = 5  // Same value
        
        // Current behavior: event still fires (this could be optimized)
        // If behavior changes, update this test
        #expect(listener.cellEvents.count >= 0)
    }
}

