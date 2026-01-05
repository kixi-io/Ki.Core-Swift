// GridChangeListener.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// Listener protocol for grid change events.
///
/// Implement this protocol to receive notifications when a `Grid` is modified.
/// Register listeners using `Grid.addChangeListener`.
///
/// ## Usage
/// ```swift
/// let grid = Grid.of(width: 10, height: 10, defaultValue: 0)
///
/// class MyListener: GridChangeListener {
///     func onCellChanged<T>(_ event: CellChangeEvent<T>) {
///         print("Cell \(event.coordinate) changed")
///     }
/// }
///
/// grid.addChangeListener(MyListener())
/// ```
public protocol GridChangeListener: AnyObject {
    
    /// Called when a single cell value changes.
    func onCellChanged<T>(_ event: CellChangeEvent<T>)
    
    /// Called when a row is inserted, deleted, or modified.
    func onRowChanged<T>(_ event: RowChangeEvent<T>)
    
    /// Called when a column is inserted, deleted, or modified.
    func onColumnChanged<T>(_ event: ColumnChangeEvent<T>)
    
    /// Called when a bulk operation (clear, fill, paste) occurs.
    func onBulkChange<T>(_ event: BulkChangeEvent<T>)
}

/// Default implementations (do nothing by default).
public extension GridChangeListener {
    func onCellChanged<T>(_ event: CellChangeEvent<T>) {}
    func onRowChanged<T>(_ event: RowChangeEvent<T>) {}
    func onColumnChanged<T>(_ event: ColumnChangeEvent<T>) {}
    func onBulkChange<T>(_ event: BulkChangeEvent<T>) {}
}

/// Event fired when a single cell value changes.
public struct CellChangeEvent<T> {
    
    /// The coordinate of the changed cell.
    public let coordinate: Coordinate
    
    /// The previous value (may be nil).
    public let oldValue: T?
    
    /// The new value (may be nil).
    public let newValue: T?
    
    /// The x (column) index of the changed cell.
    public var x: Int { coordinate.x }
    
    /// The y (row) index of the changed cell.
    public var y: Int { coordinate.y }
    
    /// Creates a new cell change event.
    public init(coordinate: Coordinate, oldValue: T?, newValue: T?) {
        self.coordinate = coordinate
        self.oldValue = oldValue
        self.newValue = newValue
    }
}

/// Types of row change operations.
public enum RowChangeType: Sendable {
    /// A new row was inserted.
    case inserted
    /// An existing row was deleted.
    case deleted
    /// Row values were modified (e.g., via fillRow).
    case modified
}

/// Event fired when a row is inserted, deleted, or modified.
public struct RowChangeEvent<T> {
    
    /// The zero-based row index.
    public let rowIndex: Int
    
    /// The type of change.
    public let type: RowChangeType
    
    /// The previous row values (for deleted or modified).
    public let oldValues: [T?]?
    
    /// The new row values (for inserted or modified).
    public let newValues: [T?]?
    
    /// Creates a new row change event.
    public init(rowIndex: Int, type: RowChangeType, oldValues: [T?]? = nil, newValues: [T?]? = nil) {
        self.rowIndex = rowIndex
        self.type = type
        self.oldValues = oldValues
        self.newValues = newValues
    }
}

/// Types of column change operations.
public enum ColumnChangeType: Sendable {
    /// A new column was inserted.
    case inserted
    /// An existing column was deleted.
    case deleted
    /// Column values were modified (e.g., via fillColumn).
    case modified
}

/// Event fired when a column is inserted, deleted, or modified.
public struct ColumnChangeEvent<T> {
    
    /// The zero-based column index.
    public let columnIndex: Int
    
    /// The type of change.
    public let type: ColumnChangeType
    
    /// The previous column values (for deleted or modified).
    public let oldValues: [T?]?
    
    /// The new column values (for inserted or modified).
    public let newValues: [T?]?
    
    /// Creates a new column change event.
    public init(columnIndex: Int, type: ColumnChangeType, oldValues: [T?]? = nil, newValues: [T?]? = nil) {
        self.columnIndex = columnIndex
        self.type = type
        self.oldValues = oldValues
        self.newValues = newValues
    }
}

/// Types of bulk change operations.
public enum BulkChangeType: Sendable {
    /// Grid was cleared (all cells set to nil or default).
    case clear
    /// Grid was filled with a value.
    case fill
    /// A region was pasted or copied into the grid.
    case paste
    /// Grid was transposed (rows and columns swapped).
    case transpose
    /// Grid was resized.
    case resize
}

/// Event fired when a bulk operation occurs.
public struct BulkChangeEvent<T> {
    
    /// The type of bulk operation.
    public let type: BulkChangeType
    
    /// The coordinate range affected by the operation (if applicable).
    public let affectedRegion: CoordinateRange?
    
    /// Additional description of the operation.
    public let desc: String?
    
    /// Creates a new bulk change event.
    public init(type: BulkChangeType, affectedRegion: CoordinateRange? = nil, description: String? = nil) {
        self.type = type
        self.affectedRegion = affectedRegion
        self.desc = description
    }
}
