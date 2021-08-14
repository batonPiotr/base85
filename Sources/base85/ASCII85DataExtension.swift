//
//  ASCII85DataExtension.swift
//
//  Copyright (c) 2021 Paweł Sulik
//
import Foundation

extension Data {
    private func pow85(_ num: Int) -> UInt32 {
        return UInt32(pow(Double(85), Double(num)))
    }
    
    public var ascii85Encoded: String {
        
        let pow85_1 = pow85(1)
        let pow85_2 = pow85(2)
        let pow85_3 = pow85(3)
        let pow85_4 = pow85(4)
        
        let inputData = self

        var buffer = inputData

        var encodedData = Data()

        let nullPadder = "z".data(using: .utf8)!

        while(buffer.count > 0) {
            var bytes = Data(buffer.prefix(4))
            buffer.removeFirst(bytes.count)
            
            let bytesCountBeforeAppend = bytes.count
            
            while bytes.count < 4 {
                bytes.append(UInt8(0))
            }

            let x = bytesToInt32(bytes: bytes._bytes)

            let N0 = UInt8((x/pow85_4) % 85)
            let N1 = UInt8((x/pow85_3) % 85)
            let N2 = UInt8((x/pow85_2) % 85)
            let N3 = UInt8((x/pow85_1) % 85)
            let N4 = UInt8(x % 85)

            let C0 = N0 + 33
            let C1 = N1 + 33
            let C2 = N2 + 33
            let C3 = N3 + 33
            let C4 = N4 + 33

            switch bytesCountBeforeAppend {
            case 1:
                encodedData.append(Data([C0, C1]))
            case 2:
                encodedData.append(Data([C0, C1, C2]))
            case 3:
                encodedData.append(Data([C0, C1, C2, C3]))
            default:
                if x == 0 {
                    encodedData.append(nullPadder)
                } else {
                    encodedData.append(Data([C0, C1, C2, C3, C4]))
                }
            }
        }
        return String(data: encodedData, encoding: .utf8)!
    }
    
    private func bytesToInt32(bytes: [UInt8]) -> UInt32 {
        let bigEndianValue = bytes.withUnsafeBufferPointer {
                 ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
        }.pointee
        let value = UInt32(bigEndian: bigEndianValue)
        return value
    }

    public init(ascii85EncodedString: String) {
        self.init()
        
        let pow85_1 = pow85(1)
        let pow85_2 = pow85(2)
        let pow85_3 = pow85(3)
        let pow85_4 = pow85(4)
        
        var buffer = ascii85EncodedString.data(using: .utf8)!
        var decodedData = Data()
        let zeroPadder: UInt8 = "z".data(using: .utf8)!._bytes[0]
        let uPadder: UInt8 = "u".data(using: .utf8)!._bytes[0]
        while buffer.count > 0 {

            if buffer._bytes[0] == zeroPadder {
                buffer.removeFirst()
                decodedData.append(Data([0x00, 0x00, 0x00, 0x00]))
                continue
            }

            var bytes = Array(buffer.prefix(5)._bytes)
            let bytesUnpaddedSize = bytes.count
            buffer.removeFirst(bytesUnpaddedSize)
            //fill with u
            while bytes.count < 5 {
                bytes.append(uPadder)
            }
            var int: UInt64 = 0

            int += UInt64(bytes[0] - 33) * UInt64(pow85_4)
            int += UInt64(bytes[1] - 33) * UInt64(pow85_3)
            int += UInt64(bytes[2] - 33) * UInt64(pow85_2)
            int += UInt64(bytes[3] - 33) * UInt64(pow85_1)
            int += UInt64(bytes[4] - 33)

            let intBytes = Swift.withUnsafeBytes(of: int) { (pointer) in
                Array<UInt8>(Data(pointer).prefix(4).reversed())
            }

            if bytesUnpaddedSize == 2 {
                decodedData.append(Data(intBytes).prefix(1))
            } else if bytesUnpaddedSize == 3 {
                decodedData.append(Data(intBytes).prefix(2))
            } else if bytesUnpaddedSize == 4 {
                decodedData.append(Data(intBytes).prefix(3))
            } else {
                decodedData.append(Data(intBytes))
            }
        }
        self.append(decodedData)
    }
}
