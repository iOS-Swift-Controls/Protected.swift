# Protected
![Swift](https://github.com/grsouza/Protected.swift/workflows/Swift/badge.svg?branch=master)

Micro library for Swift that makes possible to wrap any variable into a thread-safe environment.

## Installation

Protected is distributed using [Swift Package Manager](https://swift.org/package-manager/). To install it into a project, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/grsouza/Protected.swift.git", from: "1.0.0")
    ],
    ...
)
```

Then import Protected wherever you'd like to use it:

```swift
import Protected
```

## Usage

Protected is a property wrapper and can be used as follow.

```swift
class MyClass {
  
    @Protected
    var mutableState: Int = 0
    
    func someMethod() {
        DispatchQueue.concurrentPerform(iterations: 1_000) { i in
            $mutableState.write {
                $0 += i
            }
        }
        
        assert(mutableState == 499_500)
    }
}
```

`Protected` implements `dynamicMemberLookup` so you can access any field from the wrapped type without "dereferencing" the box.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License
[Apache License 2.0](https://github.com/grsouza/Protected.swift/blob/master/LICENSE)
