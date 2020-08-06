import Foundation

internal protocol Lock {
  func lock()
  func unlock()
}

extension Lock {
  /// Executes a closure returning a value while acquiring the lock.
  ///
  /// - Parameter closure: The closure to run.
  ///
  /// - Returns:           The value the closure generated.
  func around<T>(_ closure: () -> T) -> T {
    lock(); defer { unlock() }
    return closure()
  }

  /// Execute a closure while acquiring the lock.
  ///
  /// - Parameter closure: The closure to run.
  func around(_ closure: () -> Void) {
    lock(); defer { unlock() }
    closure()
  }
}

#if os(Linux)
/// A `pthread_mutex_t` wrapper.
final class MutexLock: Lock {
  private var mutex: UnsafeMutablePointer<pthread_mutex_t>

  init() {
    mutex = .allocate(capacity: 1)

    var attr = pthread_mutexattr_t()
    pthread_mutexattr_init(&attr)
    pthread_mutexattr_settype(&attr, .init(PTHREAD_MUTEX_ERRORCHECK))

    let error = pthread_mutex_init(mutex, &attr)
    precondition(error == 0, "Failed to create pthread_mutex")
  }

  deinit {
    let error = pthread_mutex_destroy(mutex)
    precondition(error == 0, "Failed to destroy pthread_mutex")
  }

  internal func lock() {
    let error = pthread_mutex_lock(mutex)
    precondition(error == 0, "Failed to lock pthread_mutex")
  }

  internal func unlock() {
    let error = pthread_mutex_unlock(mutex)
    precondition(error == 0, "Failed to unlock pthread_mutex")
  }
}
#endif

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
/// An `os_unfair_lock` wrapper.
final class UnfairLock: Lock {
  private let unfairLock: os_unfair_lock_t

  init() {
    unfairLock = .allocate(capacity: 1)
    unfairLock.initialize(to: os_unfair_lock())
  }

  deinit {
    unfairLock.deinitialize(count: 1)
    unfairLock.deallocate()
  }

  internal func lock() {
    os_unfair_lock_lock(unfairLock)
  }

  internal func unlock() {
    os_unfair_lock_unlock(unfairLock)
  }
}
#endif
