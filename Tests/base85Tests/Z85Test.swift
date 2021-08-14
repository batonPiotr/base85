import XCTest
@testable import base85

class Z85Test: XCTestCase {
    
    func testEncode() {
        let input = "The quick brown fox jumps over the lazy dog."
        let expected = "ra]?=ADL#9yAN8bz*c7ww]z]pyisxjB0byAwPw]nxK@r5vs0hwwn=9k"
        XCTAssertEqual(input.data(using: .utf8)!.z85Encoded, expected)
    }
    
    func testDecode() throws {
        let input = "ra]?=ADL#9yAN8bz*c7ww]z]pyisxjB0byAwPw]nxK@r5vs0hwwn=9k"
        let expected = "The quick brown fox jumps over the lazy dog."
        guard let decodedData = Data(z85EncodedString: input) else {
            XCTFail("No data")
            return
        }
        XCTAssertEqual(String(data: decodedData, encoding: .utf8), expected)
    }
    
    func testBytes(bytes: Data) throws {
        let encoded = bytes.z85Encoded
        guard let decoded = Data(z85EncodedString: encoded) else {
            XCTFail("String is not valid")
            return
        }
        var message = "Input and decoded discrepancies"
        if bytes.count <= 10 {
            message = "\(bytes._toHexString()) and \(decoded._toHexString()) are not equal"
        }
        XCTAssertEqual(bytes, decoded, message)
    }
    
    func testRandomNBytes(count: Int) throws {
        guard let bytes = ASCII85Test.randomBytes(size: count) else {
            XCTFail("No random data")
            return
        }
        try testBytes(bytes: bytes)
    }
    
    func testTrickyData() throws {
        try testBytes(bytes: Data(_hex: "fd34"))// == @wj || @wl || @wm
        try testBytes(bytes: Data(_hex: "0c2e"))// == 3[: || 3[. || 3[+
        try testBytes(bytes: Data(_hex: "e6f8"))// == >j* || >j! || >j&
        try testBytes(bytes: Data(_hex: "642a"))// == wgx || wgv || wgy
        try testBytes(bytes: Data(_hex: "616263"))
        try testBytes(bytes: Data(_hex: "bc"))
        try testBytes(bytes: Data(_hex: "074a93"))
        try testBytes(bytes: Data(_hex: "960c"))
        try testBytes(bytes: Data(_hex: "43f6"))
        try testBytes(bytes: Data(_hex: "2cc0"))
        try testBytes(bytes: Data(_hex: "15a6"))
        try testBytes(bytes: Data(_hex: "a414"))
    }
    
    func testRandom1Byte() throws {
        try testRandomNBytes(count: 1)
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
    
    func testRandom2Bytes() throws {
        try testRandomNBytes(count: 2)
    }
    
    func testRandom3Bytes() throws {
        try testRandomNBytes(count: 3)
    }
    
    func testRandom4Bytes() throws {
        try testRandomNBytes(count: 4)
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
    
    func testSimpleString() throws {
        let string = "abc"
        try testBytes(bytes: string.data(using: .utf8)!)
    }
    
    func testComplexString() throws {
        let string = "Das ist ein komplexer String mit komischen Zeichen: \"\\\t\n\röüïäëß"
        try testBytes(bytes: string.data(using: .utf8)!)
    }
    
    func testDefinedData() throws {
        let dataHex = "02000080ab745f6746b0faf8f06b3cd01e3db53f19964dd244bad39a26e83f04c5017264109b8d577fc232c41273d7cead7e2a042da860030af99cbe1afd7fd740bff3f5395bc643a17a06aec4641c5feb338e1e6747caf6a8ca0e7c7dfa5833"

        let inputData = Data(_hex: dataHex)

        let definedEncodedData = "0SSjJT8}YYmZh::[m$ek9Zc[}8j11Bm7Q<ocG)U%-q$0&5sXUXF5i$V5{8WIT:R-5eVr4V3I*ja8Vtfqk!({-iA%G<P)u{C-af&{(OBLxxgHbrSlbP$EFN54"

        let encoded = inputData.z85Encoded
        print(encoded)

        guard let decoded = Data(z85EncodedString: definedEncodedData) else { throw NSError(domain: "No data", code: 0, userInfo: nil) }
        print(decoded)
        
        XCTAssertEqual(encoded, definedEncodedData)
        XCTAssertEqual(decoded._toHexString(), dataHex)

    }

}
