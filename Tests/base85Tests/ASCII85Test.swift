import XCTest
@testable import base85

class ASCII85Test: XCTestCase {
    
    func testEncode() {
        let input = "The quick brown fox jumps over the lazy dog."
        let expected = "<+ohcEHPu*CER),Dg-(AAoDo:C3=B4F!,CEATAo8BOr<&@=!2AA8c*5"
        XCTAssertEqual(input.data(using: .utf8)!.ascii85Encoded, expected)
    }
    
    func testDecode() throws {
        let input = "<+ohcEHPu*CER),Dg-(AAoDo:C3=B4F!,CEATAo8BOr<&@=!2AA8c*5"
        let expected = "The quick brown fox jumps over the lazy dog."
        let decodedData = Data(ascii85EncodedString: input)
        XCTAssertEqual(String(data: decodedData, encoding: .utf8), expected)
    }
    
    func testBytes(bytes: Data) throws {
        let encoded = bytes.ascii85Encoded
        let decoded = Data(ascii85EncodedString: encoded)
        XCTAssertEqual(bytes, decoded)
    }
    
    func testRandomNBytes(count: Int) throws {
        guard let bytes = ASCII85Test.randomBytes(size: count) else {
            XCTFail("No random data")
            return
        }
        try testBytes(bytes: bytes)
    }
    
    func testRandom1Byte() throws {
        try testRandomNBytes(count: 1)
    }
    
    func testRandom2Bytes() throws {
        try testRandomNBytes(count: 2)
    }
    
    func testRandom3Bytes() throws {
        try testRandomNBytes(count: 3)
    }
    
    func testRandom4Bytes() throws {
        try testRandomNBytes(count: 4)
    }
    
    func testAll1BytesCombinations() throws {
        for i in 0..<255 {
            try testBytes(bytes: Data([UInt8(i)]))
        }
    }
    
    func testAll2BytesCombinations() throws {
        for i in 0..<255 {
            for j in 0..<255 {
                try testBytes(bytes: Data([UInt8(i), UInt8(j)]))
            }
        }
    }
    
    //It may take ~5 minutes
    func testAll3BytesCombinations() throws {
        for i in 0..<255 {
            for j in 0..<255 {
                for k in 0..<255 {
                    try testBytes(bytes: Data([UInt8(i), UInt8(j), UInt8(k)]))
                }
            }
            print("i: \(i)")
        }
    }
    
    func testRandomMultipleFullBlocks() throws {
        try testRandomNBytes(count: 4 * Int.random(in: 100..<1000))
    }
    
    func testRandomMultipleFullBlocksPlus1() throws {
        try testRandomNBytes(count: (4 * Int.random(in: 100..<1000)) + 1)
    }
    
    func testRandomMultipleFullBlocksPlus2() throws {
        try testRandomNBytes(count: (4 * Int.random(in: 100..<1000)) + 2)
    }
    
    func testRandomMultipleFullBlocksPlus3() throws {
        try testRandomNBytes(count: (4 * Int.random(in: 100..<1000)) + 3)
    }
    
    func testJSONString() throws {
        let string = """
        {
            "id": "0001",
            "type": "donut",
            "name": "Cake",
            "ppu": 0.55,
            "batters":
                {
                    "batter":
                        [
                            { "id": "1001", "type": "Regular" },
                            { "id": "1002", "type": "Chocolate" },
                            { "id": "1003", "type": "Blueberry" },
                            { "id": "1004", "type": "Devil's Food" }
                        ]
                },
            "topping":
                [
                    { "id": "5001", "type": "None" },
                    { "id": "5002", "type": "Glazed" },
                    { "id": "5005", "type": "Sugar" },
                    { "id": "5007", "type": "Powdered Sugar" },
                    { "id": "5006", "type": "Chocolate with Sprinkles" },
                    { "id": "5003", "type": "Chocolate" },
                    { "id": "5004", "type": "Maple" }
                ]
        }
        """
        try testBytes(bytes: string.data(using: .utf8)!)
    }
    
    func testComplexString() throws {
        let string = "Das ist ein komplexer String mit komischen Zeichen: \"\\\t\n\röüïäëß"
        try testBytes(bytes: string.data(using: .utf8)!)
    }
    
    static func randomBytes(size: Int) -> Data? {
        var bytes = [Int8](repeating: 0, count: size)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        if status == errSecSuccess {
            return Data(bytes: &bytes, count: size)
        }
        return nil
    }

}
