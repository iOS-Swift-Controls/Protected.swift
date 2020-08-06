import Foundation

/// A thread-safe wrapper around a value.
@propertyWrapper
@dynamicMemberLookup
public final class Protected<Value> {

  #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
  private let lock = UnfairLock()
  #elseif os(Linux)
  private let lock = MutexLock()
  #endif

  private var value: Value

  public init(wrappedValue: Value) {
    value = wrappedValue
  }

  /// The contained value. Unsafe for anything more than direct read or write.
  public var wrappedValue: Value {
    get { lock.around { value } }
    set { lock.around { value = newValue } }
  }

  public var projectedValue: Protected<Value> { self }

  /// Synchronously read or transform the contained value.
  ///
  /// - Parameter closure: The closure to execute.
  ///
  /// - Returns:           The return value of the closure passed.
  public func read<U>(_ closure: (Value) -> U) -> U {
    lock.around { closure(value) }
  }

  /// Synchronously modify the protected value.
  ///
  /// - Parameter closure: The closure to execute.
  ///
  /// - Returns:           The modified value.
  @discardableResult
  public func write<U>(_ closure: (inout Value) -> U) -> U {
    lock.around { closure(&value) }
  }

  public subscript<Property>(dynamicMember keyPath: WritableKeyPath<Value, Property>) -> Property {
    get { lock.around { value[keyPath: keyPath] } }
    set { lock.around { value[keyPath: keyPath] = newValue } }
  }
}

extension Protected where Value: RangeReplaceableCollection {
  /// Adds a new element to the end of this protected collection.
  ///
  /// - Parameter newElement: The `Element` to append.
  public func append(_ newElement: Value.Element) {
    write { (ward: inout Value) in
      ward.append(newElement)
    }
  }

  /// Adds the elements of a sequence to the end of this protected collection.
  ///
  /// - Parameter newElements: The `Sequence` to append.
  public func append<S: Sequence>(contentsOf newElements: S) where S.Element == Value.Element {
    write { (ward: inout Value) in
      ward.append(contentsOf: newElements)
    }
  }

  /// Add the elements of a collection to the end of the protected collection.
  ///
  /// - Parameter newElements: The `Collection` to append.
  public func append<C: Collection>(contentsOf newElements: C) where C.Element == Value.Element {
    write { (ward: inout Value) in
      ward.append(contentsOf: newElements)
    }
  }
}

extension Protected: Equatable where Value: Equatable {
  public static func == (lhs: Protected<Value>, rhs: Protected<Value>) -> Bool {
    lhs.wrappedValue == rhs.wrappedValue
  }
}

extension Protected: Hashable where Value: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(wrappedValue)
  }
}

extension Protected: Comparable where Value: Comparable {
  public static func < (lhs: Protected<Value>, rhs: Protected<Value>) -> Bool {
    lhs.wrappedValue < rhs.wrappedValue
  }
}
