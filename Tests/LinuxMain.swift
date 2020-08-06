import XCTest

import ProtectedTests

var tests = [XCTestCaseEntry]()
tests += ProtectedTests.__allTests()

XCTMain(tests)
