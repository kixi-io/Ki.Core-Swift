// Grid.swift
// Ki.Core-Swift
//
// Copyright © 2026 Kixi. MIT License.

import Foundation

/// A two-dimensional grid of values with efficient flat array storage.
///
/// ## Ki Literal Format
/// ```
/// .grid(
///     2   4   6
///     8   10  12
///     14  16  18
/// )
/// ```
///
/// ## Accessing Cells
/// Grid supports multiple access styles:
/// ```swift
/// // Standard (zero-based x, y)
/// grid[2, 34]
///
/// // Sheet column (letter) and row (one-based)
/// grid["E", 8]
///
/// // Sheet notation string
/// grid["E8"]
///
/// // Coordinate object
/// grid[try Coordinate.parse("E8")]
/// ```
///
/// ## Common Operations
/// ```swift
/// let transposed = grid.transpose()
/// let subgrid = grid.subgrid(startX: 0, startY: 0, width: 5, height: 5)
/// let mapped = grid.map { $0 * 2 }
/// grid.fill(0)
/// ```
///
/// ## Storage
/// Grid uses a flat array with row-major ordering for optimal cache locality
/// and memory efficiency. Access is O(1) for all operations.
public class Grid<T> {
    
    /// The number of columns.
    public let width: Int
    
    /// The number of rows.
    public let height: Int
    
    /// The underlying data array.
    private var data: [T?]
    
    /// Lazy initialization for listeners - zero overhead when not used.
    private var listeners: [GridChangeListener]?
    
    // MARK: - Computed Properties
    
    /// The total number of cells in this grid.
    public var size: Int { width * height }
    
    /// True if all cells are nil.
    public var isEmpty: Bool { data.allSatisfy { $0 == nil } }
    
    /// True if any cell is non-nil.
    public var isNotEmpty: Bool { data.contains { $0 != nil } }
    
    /// Provides indexed access to rows.
    public lazy var rows: RowAccessor<T> = RowAccessor(grid: self)
    
    /// Provides indexed access to columns.
    public lazy var columns: ColumnAccessor<T> = ColumnAccessor(grid: self)
    
    // MARK: - Initialization
    
    /// Creates a grid with the specified dimensions and data.
    ///
    /// - Parameters:
    ///   - width: Number of columns
    ///   - height: Number of rows
    ///   - data: Initial data array (must have width * height elements)
    public init(width: Int, height: Int, data: [T?]) {
        precondition(width > 0, "Width must be positive, got: \(width)")
        precondition(height > 0, "Height must be positive, got: \(height)")
        precondition(data.count == width * height,
                     "Data array size \(data.count) doesn't match grid dimensions \(width) x \(height)")
        
        self.width = width
        self.height = height
        self.data = data
    }
    
    // MARK: - Cell Access Methods
    
    /// Gets the value at the specified (x, y) coordinate.
    ///
    /// - Parameters:
    ///   - x: The zero-based column index
    ///   - y: The zero-based row index
    /// - Returns: The value at (x, y), or nil if the cell is empty
    public subscript(x: Int, y: Int) -> T? {
        get {
            checkBounds(x: x, y: y)
            return data[index(x: x, y: y)]
        }
        set {
            checkBounds(x: x, y: y)
            let idx = index(x: x, y: y)
            let oldValue = data[idx]
            data[idx] = newValue
            fireOnCellChanged(coordinate: Coordinate(validX: x, validY: y, validZ: nil),
                              oldValue: oldValue, newValue: newValue)
        }
    }
    
    /// Gets the value at the specified Coordinate.
    public subscript(coord: Coordinate) -> T? {
        get { self[coord.x, coord.y] }
        set { self[coord.x, coord.y] = newValue }
    }
    
    /// Gets the value using sheet notation (letter column, one-based row).
    ///
    /// - Parameters:
    ///   - column: The column letter(s) (A, B, ..., Z, AA, ...)
    ///   - row: The one-based row number
    public subscript(column: String, row: Int) -> T? {
        get {
            let x = Coordinate.columnToIndex(column)
            let y = row - 1
            return self[x, y]
        }
        set {
            let x = Coordinate.columnToIndex(column)
            let y = row - 1
            self[x, y] = newValue
        }
    }
    
    /// Gets the value using a sheet notation string (e.g., "A1", "E8", "AA100").
    ///
    /// - Parameter ref: The sheet notation reference
    public subscript(ref: String) -> T? {
        get {
            guard let coord = Coordinate.parseOrNull(ref) else { return nil }
            return self[coord]
        }
        set {
            guard let coord = Coordinate.parseOrNull(ref) else { return }
            self[coord] = newValue
        }
    }
    
    /// Gets all values within a coordinate range as a new Grid.
    public subscript(range: CoordinateRange) -> Grid<T> {
        subgrid(startX: range.minX, startY: range.minY, width: range.width, height: range.height)
    }
    
    // MARK: - Row and Column Data Access
    
    /// Returns a copy of the specified row's data.
    ///
    /// - Parameter y: The zero-based row index
    /// - Returns: A new array containing copies of the row's values
    public func getRowCopy(_ y: Int) -> [T?] {
        precondition(y >= 0 && y < height, "Row index out of bounds: \(y)")
        let start = y * width
        return (0..<width).map { data[start + $0] }
    }
    
    /// Returns a copy of the specified column's data.
    ///
    /// - Parameter x: The zero-based column index
    /// - Returns: A new array containing copies of the column's values
    public func getColumnCopy(_ x: Int) -> [T?] {
        precondition(x >= 0 && x < width, "Column index out of bounds: \(x)")
        return (0..<height).map { data[$0 * width + x] }
    }
    
    /// Returns a copy of the column's data by letter.
    ///
    /// - Parameter column: The column letter(s) (A, B, ..., Z, AA, ...)
    public func getColumnCopy(_ column: String) -> [T?] {
        getColumnCopy(Coordinate.columnToIndex(column))
    }
    
    /// Sets an entire row's values.
    ///
    /// - Parameters:
    ///   - y: The zero-based row index
    ///   - values: The values to set (must have exactly `width` elements)
    public func setRow(_ y: Int, values: [T?]) {
        precondition(y >= 0 && y < height, "Row index out of bounds: \(y)")
        precondition(values.count == width,
                     "Row values must have exactly \(width) elements, got \(values.count)")
        
        let oldValues = getRowCopy(y)
        let start = y * width
        for (i, value) in values.enumerated() {
            data[start + i] = value
        }
        fireOnRowChanged(rowIndex: y, type: .modified, oldValues: oldValues, newValues: values)
    }
    
    /// Sets an entire column's values.
    ///
    /// - Parameters:
    ///   - x: The zero-based column index
    ///   - values: The values to set (must have exactly `height` elements)
    public func setColumn(_ x: Int, values: [T?]) {
        precondition(x >= 0 && x < width, "Column index out of bounds: \(x)")
        precondition(values.count == height,
                     "Column values must have exactly \(height) elements, got \(values.count)")
        
        let oldValues = getColumnCopy(x)
        for (i, value) in values.enumerated() {
            data[i * width + x] = value
        }
        fireOnColumnChanged(columnIndex: x, type: .modified, oldValues: oldValues, newValues: values)
    }
    
    /// Sets a column's values by letter.
    ///
    /// - Parameters:
    ///   - column: The column letter(s) (A, B, ..., Z, AA, ...)
    ///   - values: The values to set
    public func setColumn(_ column: String, values: [T?]) {
        setColumn(Coordinate.columnToIndex(column), values: values)
    }
    
    // MARK: - Common Operations
    
    /// Creates a transposed copy of this grid (rows become columns).
    public func transpose() -> Grid<T> {
        var newData: [T?] = Array(repeating: nil, count: size)
        
        for y in 0..<height {
            for x in 0..<width {
                let oldIdx = y * width + x
                let newIdx = x * height + y
                newData[newIdx] = data[oldIdx]
            }
        }
        
        return Grid(width: height, height: width, data: newData)
    }
    
    /// Extracts a rectangular subgrid.
    ///
    /// - Parameters:
    ///   - startX: Starting column (inclusive)
    ///   - startY: Starting row (inclusive)
    ///   - width: Width of the subgrid
    ///   - height: Height of the subgrid
    /// - Returns: A new Grid containing the specified region
    public func subgrid(startX: Int, startY: Int, width subWidth: Int, height subHeight: Int) -> Grid<T> {
        precondition(startX >= 0 && startY >= 0, "Start coordinates must be non-negative")
        precondition(subWidth > 0 && subHeight > 0, "Subgrid dimensions must be positive")
        precondition(startX + subWidth <= width, "Subgrid extends past right edge")
        precondition(startY + subHeight <= height, "Subgrid extends past bottom edge")
        
        var newData: [T?] = Array(repeating: nil, count: subWidth * subHeight)
        
        for y in 0..<subHeight {
            for x in 0..<subWidth {
                let srcIdx = (startY + y) * width + (startX + x)
                let dstIdx = y * subWidth + x
                newData[dstIdx] = data[srcIdx]
            }
        }
        
        return Grid(width: subWidth, height: subHeight, data: newData)
    }
    
    /// Creates a new grid by applying a transformation to each cell.
    ///
    /// - Parameter transform: The transformation function
    /// - Returns: A new Grid with transformed values
    public func map<R>(_ transform: (T?) -> R?) -> Grid<R> {
        let newData = data.map(transform)
        return Grid<R>(width: width, height: height, data: newData)
    }
    
    /// Creates a new grid by applying a transformation that includes coordinates.
    ///
    /// - Parameter transform: The transformation function receiving (x, y, value)
    /// - Returns: A new Grid with transformed values
    public func mapIndexed<R>(_ transform: (Int, Int, T?) -> R?) -> Grid<R> {
        var newData: [R?] = Array(repeating: nil, count: size)
        
        for y in 0..<height {
            for x in 0..<width {
                let idx = y * width + x
                newData[idx] = transform(x, y, data[idx])
            }
        }
        
        return Grid<R>(width: width, height: height, data: newData)
    }
    
    /// Iterates over all cells in the grid.
    ///
    /// - Parameter action: The action to perform for each cell value
    public func forEach(_ action: (T?) -> Void) {
        data.forEach(action)
    }
    
    /// Iterates over all cells with their coordinates.
    ///
    /// - Parameter action: The action to perform for each (x, y, value)
    public func forEachIndexed(_ action: (Int, Int, T?) -> Void) {
        for y in 0..<height {
            for x in 0..<width {
                action(x, y, data[y * width + x])
            }
        }
    }
    
    /// Finds the first cell matching the predicate.
    ///
    /// - Parameter predicate: The condition to match
    /// - Returns: A tuple of (Coordinate, value), or nil if not found
    public func find(_ predicate: (T?) -> Bool) -> (Coordinate, T?)? {
        for y in 0..<height {
            for x in 0..<width {
                let value = data[y * width + x]
                if predicate(value) {
                    return (Coordinate(validX: x, validY: y, validZ: nil), value)
                }
            }
        }
        return nil
    }
    
    /// Finds all cells matching the predicate.
    ///
    /// - Parameter predicate: The condition to match
    /// - Returns: Array of (Coordinate, value) tuples
    public func findAll(_ predicate: (T?) -> Bool) -> [(Coordinate, T?)] {
        var results: [(Coordinate, T?)] = []
        
        for y in 0..<height {
            for x in 0..<width {
                let value = data[y * width + x]
                if predicate(value) {
                    results.append((Coordinate(validX: x, validY: y, validZ: nil), value))
                }
            }
        }
        
        return results
    }
    
    /// Fills all cells with the specified value.
    public func fill(_ value: T?) {
        for i in 0..<data.count {
            data[i] = value
        }
        fireOnBulkChange(type: .fill, affectedRegion: nil, description: "Filled with value: \(String(describing: value))")
    }
    
    /// Fills a row with the specified value.
    ///
    /// - Parameters:
    ///   - y: The zero-based row index
    ///   - value: The value to fill
    public func fillRow(_ y: Int, value: T?) {
        precondition(y >= 0 && y < height, "Row index out of bounds: \(y)")
        
        let oldValues = getRowCopy(y)
        let start = y * width
        for x in 0..<width {
            data[start + x] = value
        }
        let newValues: [T?] = Array(repeating: value, count: width)
        fireOnRowChanged(rowIndex: y, type: .modified, oldValues: oldValues, newValues: newValues)
    }
    
    /// Fills a column with the specified value.
    ///
    /// - Parameters:
    ///   - x: The zero-based column index
    ///   - value: The value to fill
    public func fillColumn(_ x: Int, value: T?) {
        precondition(x >= 0 && x < width, "Column index out of bounds: \(x)")
        
        let oldValues = getColumnCopy(x)
        for y in 0..<height {
            data[y * width + x] = value
        }
        let newValues: [T?] = Array(repeating: value, count: height)
        fireOnColumnChanged(columnIndex: x, type: .modified, oldValues: oldValues, newValues: newValues)
    }
    
    /// Fills a column by letter with the specified value.
    ///
    /// - Parameters:
    ///   - column: The column letter(s) (A, B, ..., Z, AA, ...)
    ///   - value: The value to fill
    public func fillColumn(_ column: String, value: T?) {
        fillColumn(Coordinate.columnToIndex(column), value: value)
    }
    
    /// Clears all cells (sets them to nil).
    public func clear() {
        for i in 0..<data.count {
            data[i] = nil
        }
        fireOnBulkChange(type: .clear, affectedRegion: nil, description: "Grid cleared")
    }
    
    /// Counts cells matching the predicate.
    public func count(_ predicate: (T?) -> Bool) -> Int {
        data.filter(predicate).count
    }
    
    /// Returns true if any cell matches the predicate.
    public func any(_ predicate: (T?) -> Bool) -> Bool {
        data.contains(where: predicate)
    }
    
    /// Returns true if all cells match the predicate.
    public func all(_ predicate: (T?) -> Bool) -> Bool {
        data.allSatisfy(predicate)
    }
    
    /// Returns true if no cells match the predicate.
    public func none(_ predicate: (T?) -> Bool) -> Bool {
        !any(predicate)
    }
    
    /// Creates a deep copy of this grid.
    public func copy() -> Grid<T> {
        Grid(width: width, height: height, data: data)
    }
    
    /// Returns all values as a flat array (row-major order).
    public func toArray() -> [T?] {
        data
    }
    
    /// Returns values as an array of rows.
    public func toRowArray() -> [[T?]] {
        (0..<height).map { getRowCopy($0) }
    }
    
    // MARK: - Listener Management
    
    /// Adds a change listener to receive notifications about grid modifications.
    ///
    /// - Parameter listener: The listener to add
    public func addChangeListener(_ listener: GridChangeListener) {
        if listeners == nil {
            listeners = []
        }
        listeners?.append(listener)
    }
    
    /// Removes a previously added change listener.
    ///
    /// - Parameter listener: The listener to remove
    /// - Returns: true if the listener was found and removed
    @discardableResult
    public func removeChangeListener(_ listener: GridChangeListener) -> Bool {
        guard let index = listeners?.firstIndex(where: { $0 === listener }) else {
            return false
        }
        listeners?.remove(at: index)
        return true
    }
    
    /// Returns true if this grid has any change listeners.
    public var hasListeners: Bool {
        !(listeners?.isEmpty ?? true)
    }
    
    // MARK: - Private Helper Methods
    
    private func index(x: Int, y: Int) -> Int {
        y * width + x
    }
    
    private func checkBounds(x: Int, y: Int) {
        precondition(x >= 0 && x < width, "Column \(x) out of bounds (0..\(width - 1))")
        precondition(y >= 0 && y < height, "Row \(y) out of bounds (0..\(height - 1))")
    }
    
    private func fireOnCellChanged(coordinate: Coordinate, oldValue: T?, newValue: T?) {
        let event = CellChangeEvent(coordinate: coordinate, oldValue: oldValue, newValue: newValue)
        listeners?.forEach { $0.onCellChanged(event) }
    }
    
    private func fireOnRowChanged(rowIndex: Int, type: RowChangeType, oldValues: [T?]?, newValues: [T?]?) {
        let event = RowChangeEvent(rowIndex: rowIndex, type: type, oldValues: oldValues, newValues: newValues)
        listeners?.forEach { $0.onRowChanged(event) }
    }
    
    private func fireOnColumnChanged(columnIndex: Int, type: ColumnChangeType, oldValues: [T?]?, newValues: [T?]?) {
        let event = ColumnChangeEvent(columnIndex: columnIndex, type: type, oldValues: oldValues, newValues: newValues)
        listeners?.forEach { $0.onColumnChanged(event) }
    }
    
    private func fireOnBulkChange(type: BulkChangeType, affectedRegion: CoordinateRange?, description: String?) {
        let event = BulkChangeEvent<T>(type: type, affectedRegion: affectedRegion, description: description)
        listeners?.forEach { $0.onBulkChange(event) }
    }
}

// MARK: - Equatable

extension Grid: Equatable where T: Equatable {
    public static func == (lhs: Grid<T>, rhs: Grid<T>) -> Bool {
        lhs.width == rhs.width && lhs.height == rhs.height && lhs.data == rhs.data
    }
}

// MARK: - Hashable

extension Grid: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
        hasher.combine(data)
    }
}

// MARK: - Factory Methods

extension Grid {
    
    /// Creates a grid with the specified dimensions, initialized with the default value.
    ///
    /// - Parameters:
    ///   - width: Number of columns
    ///   - height: Number of rows
    ///   - defaultValue: Value to initialize all cells with
    public static func of(width: Int, height: Int, defaultValue: T?) -> Grid<T> {
        let data: [T?] = Array(repeating: defaultValue, count: width * height)
        return Grid(width: width, height: height, data: data)
    }
    
    /// Creates a grid with the specified dimensions, initialized with nils.
    ///
    /// - Parameters:
    ///   - width: Number of columns
    ///   - height: Number of rows
    public static func ofNulls(width: Int, height: Int) -> Grid<T> {
        of(width: width, height: height, defaultValue: nil)
    }
    
    /// Creates a grid from an array of rows.
    ///
    /// - Parameter rows: Array of rows, where each row is an array of values
    /// - Throws: `WrongRowLengthError` if rows have inconsistent lengths
    public static func fromRows(_ rows: [[T?]]) throws -> Grid<T> {
        guard !rows.isEmpty else {
            let msg: String = "Cannot create grid from empty row list"
            throw KiError.general(msg)
        }
        
        let height = rows.count
        let width = rows[0].count
        
        guard width > 0 else {
            let msg: String = "Row width must be positive"
            throw KiError.general(msg)
        }
        
        // Validate all rows have the same width
        for (index, row) in rows.enumerated() {
            if row.count != width {
                throw WrongRowLengthError(expectedLength: width, actualLength: row.count, rowIndex: index)
            }
        }
        
        var data: [T?] = Array(repeating: nil, count: width * height)
        for y in 0..<height {
            for x in 0..<width {
                data[y * width + x] = rows[y][x]
            }
        }
        
        return Grid(width: width, height: height, data: data)
    }
    
    /// Creates a single-row grid from an array of values.
    public static func fromSingleRow(_ values: [T?]) throws -> Grid<T> {
        try fromRows([values])
    }
    
    /// Creates a single-column grid from an array of values.
    public static func fromSingleColumn(_ values: [T?]) throws -> Grid<T> {
        let rows = values.map { [$0] }
        return try fromRows(rows)
    }
    
    /// Creates a grid using a builder function.
    ///
    /// - Parameters:
    ///   - width: Number of columns
    ///   - height: Number of rows
    ///   - init: Function called for each cell to compute its initial value
    public static func build(width: Int, height: Int, _ initializer: (Int, Int) -> T?) -> Grid<T> {
        var data: [T?] = Array(repeating: nil, count: width * height)
        
        for y in 0..<height {
            for x in 0..<width {
                data[y * width + x] = initializer(x, y)
            }
        }
        
        return Grid(width: width, height: height, data: data)
    }
    
    /// Checks if a string appears to be a Ki grid literal.
    public static func isLiteral(_ text: String) -> Bool {
        let trimmed: String = text.trimmingCharacters(in: .whitespaces)
        let prefixGrid: String = ".grid("
        let prefixGridTyped: String = ".grid<"
        let suffix: String = ")"
        return (trimmed.hasPrefix(prefixGrid) || trimmed.hasPrefix(prefixGridTyped)) && trimmed.hasSuffix(suffix)
    }
}

// MARK: - Row Accessor

/// Provides indexed access to rows as lightweight views.
public class RowAccessor<T> {
    private weak var grid: Grid<T>?
    
    init(grid: Grid<T>) {
        self.grid = grid
    }
    
    /// Gets a view of the specified row.
    /// The view is lightweight and reflects live grid data.
    public subscript(y: Int) -> RowView<T> {
        guard let grid = grid else { fatalError("Grid has been deallocated") }
        precondition(y >= 0 && y < grid.height, "Row index out of bounds: \(y)")
        return RowView(grid: grid, index: y)
    }
    
    /// The number of rows.
    public var count: Int {
        grid?.height ?? 0
    }
    
    /// Returns all rows as views.
    public func toArray() -> [RowView<T>] {
        guard let grid = grid else { return [] }
        return (0..<grid.height).map { RowView(grid: grid, index: $0) }
    }
}

/// A lightweight view of a single row.
/// Changes to the grid are reflected in the view, and vice versa.
public class RowView<T>: RandomAccessCollection {
    private weak var grid: Grid<T>?
    
    /// The row index.
    public let index: Int
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { grid?.width ?? 0 }
    
    init(grid: Grid<T>, index: Int) {
        self.grid = grid
        self.index = index
    }
    
    public subscript(position: Int) -> T? {
        get {
            guard let grid = grid else { return nil }
            precondition(position >= 0 && position < grid.width, "Column index out of bounds: \(position)")
            return grid[position, index]
        }
        set {
            guard let grid = grid else { return }
            grid[position, index] = newValue
        }
    }
    
    /// Returns a copy of this row's data.
    public func toCopy() -> [T?] {
        grid?.getRowCopy(index) ?? []
    }
    
    /// The row number (one-based, for sheet notation).
    public var rowNumber: Int { index + 1 }
}

// MARK: - Column Accessor

/// Provides indexed access to columns as lightweight views.
public class ColumnAccessor<T> {
    private weak var grid: Grid<T>?
    
    init(grid: Grid<T>) {
        self.grid = grid
    }
    
    /// Gets a view of the specified column by index.
    public subscript(x: Int) -> ColumnView<T> {
        guard let grid = grid else { fatalError("Grid has been deallocated") }
        precondition(x >= 0 && x < grid.width, "Column index out of bounds: \(x)")
        return ColumnView(grid: grid, index: x)
    }
    
    /// Gets a view of the specified column by letter.
    public subscript(column: String) -> ColumnView<T> {
        let x = Coordinate.columnToIndex(column)
        return self[x]
    }
    
    /// The number of columns.
    public var count: Int {
        grid?.width ?? 0
    }
    
    /// Returns all columns as views.
    public func toArray() -> [ColumnView<T>] {
        guard let grid = grid else { return [] }
        return (0..<grid.width).map { ColumnView(grid: grid, index: $0) }
    }
}

/// A lightweight view of a single column.
/// Changes to the grid are reflected in the view, and vice versa.
public class ColumnView<T>: RandomAccessCollection {
    private weak var grid: Grid<T>?
    
    /// The column index.
    public let index: Int
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { grid?.height ?? 0 }
    
    init(grid: Grid<T>, index: Int) {
        self.grid = grid
        self.index = index
    }
    
    public subscript(position: Int) -> T? {
        get {
            guard let grid = grid else { return nil }
            precondition(position >= 0 && position < grid.height, "Row index out of bounds: \(position)")
            return grid[index, position]
        }
        set {
            guard let grid = grid else { return }
            grid[index, position] = newValue
        }
    }
    
    /// Returns a copy of this column's data.
    public func toCopy() -> [T?] {
        grid?.getColumnCopy(index) ?? []
    }
    
    /// The column letter (for sheet notation).
    public var columnLetter: String {
        Coordinate.indexToColumn(index)
    }
}
