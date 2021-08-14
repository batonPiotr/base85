# base85

This tool implements ASCII85 and Z85 decoding and encoding.

# Installation

This tool can be installed through Swift Package Manager by adding this to your `Package.swift`:
```
dependencies: [
    .package(url: "https://github.com/batonPiotr/base85", .upToNextMajor(from: "1.0.0")),
    ...
],
```
Or add it in Xcode:
1. File → Swift Packages → Add Package Dependency...
2. Package URL: https://github.com/batonPiotr/base85

# Usage

## ASCII 85

To encode data:
```
    let someData: Data
    let encodedString = someData.ascii85Encoded
```

To decode data:
```
    let someASCII85EncodedData = "<+ohcEHPu*CER),Dg-(AAoDo:C3=B4F!,CEATAo8BOr<&@=!2AA8c*5"
    let decodedData = Data(ascii85EncodedString: someASCII85EncodedData)
```

## Z85

To encode data:
```
    let someData: Data
    let encodedString = someData.z85Encoded
```

To decode data:
```
    let someZ85EncodedData = "ra]?=ADL#9yAN8bz*c7ww]z]pyisxjB0byAwPw]nxK@r5vs0hwwn=9k"
    guard let decodedData = Data(z85EncodedString: someZ85EncodedData) else {
        return
    }
```

# License

This package is released under The MIT License. See LICENSE for details.
