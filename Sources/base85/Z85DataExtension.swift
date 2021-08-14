//
//  Z85DataExtension.swift
//
//  Copyright (c) 2021 Paweł Sulik
//
import Foundation

let encodeZSetString = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.-:+=^!/*?&<>()[]{}@%$#"
let encodeZSet = encodeZSetString.data(using: .utf8)!._bytes

let decodeZSet: [UInt8] = [0x00, 0x44, 0x00, 0x54, 0x53, 0x52, 0x48, 0x00, //0-7
                           0x4B, 0x4C, 0x46, 0x41, 0x00, 0x3F, 0x3E, 0x45, //8-15
                           0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, //16-23
                           0x08, 0x09, 0x40, 0x00, 0x49, 0x42, 0x4A, 0x47, //24-31
                           0x51, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2A, //32-39
                           0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0x30, 0x31, 0x32, //40-47
                           0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x3A, //48-63
                           0x3B, 0x3C, 0x3D, 0x4D, 0x00, 0x4E, 0x43, 0x00, //64-71
                           0x00, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, //72-79
                           0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, //80-87
                           0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x20, //88-95
                           0x21, 0x22, 0x23, 0x4F, 0x00, 0x50, 0x00, 0x00] //96-103

extension Data {
    private func pow85(_ num: Int) -> UInt32 {
        return UInt32(pow(Double(85), Double(num)))
    }
    
    public var z85Encoded: String {
        
        let pow85_1 = pow85(1)
        let pow85_2 = pow85(2)
        let pow85_3 = pow85(3)
        let pow85_4 = pow85(4)
        
        let inputData = self

        var buffer = inputData

        var encodedData = Data()

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

            let C0 = encodeZSet[Int(N0)]
            let C1 = encodeZSet[Int(N1)]
            let C2 = encodeZSet[Int(N2)]
            let C3 = encodeZSet[Int(N3)]
            let C4 = encodeZSet[Int(N4)]

            switch bytesCountBeforeAppend {
            case 1:
                encodedData.append(Data([C0, C1]))
            case 2:
                encodedData.append(Data([C0, C1, C2]))
            case 3:
                encodedData.append(Data([C0, C1, C2, C3]))
            default:
                encodedData.append(Data([C0, C1, C2, C3, C4]))
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

    public init?(z85EncodedString: String) {
        
        self.init()
        let pow85_1 = UInt64(pow85(1))
        let pow85_2 = UInt64(pow85(2))
        let pow85_3 = UInt64(pow85(3))
        let pow85_4 = UInt64(pow85(4))

        var buffer = z85EncodedString.data(using: .utf8)!
        var decodedData = Data()
        
        while buffer.count > 0 {

            var bytes = Array(buffer.prefix(5)._bytes)
            let bytesUnpaddedSize = bytes.count
            buffer.removeFirst(bytesUnpaddedSize)
            
            //Padding
            while bytes.count < 5 {
//                bytes.append(UInt8(68 + (5 - bytes.count - 1)))
                bytes.append(32)
            }
            var int: UInt64 = 0
            
            int += UInt64(decodeZSet[Int(bytes[0] - 32)]) * pow85_4
            if bytes.count > 1 { int += UInt64(decodeZSet[Int(bytes[1] - 32)]) * pow85_3 }
            if bytes.count > 2 { int += UInt64(decodeZSet[Int(bytes[2] - 32)]) * pow85_2 }
            if bytes.count > 3 { int += UInt64(decodeZSet[Int(bytes[3] - 32)]) * pow85_1 }
            if bytes.count > 4 { int += UInt64(decodeZSet[Int(bytes[4] - 32)]) }

            let intBytes = Swift.withUnsafeBytes(of: int) { (pointer) in
                Array<UInt8>(Data(pointer).reversed())
            }
            
            let extractedIntBytes = intBytes.suffix(4)
            var selectedData: Data
            
            //Check overflow
            if !intBytes.prefix(4).allSatisfy({ $0 == 0}) {
                print("Overflow! \(intBytes._toHexString())")
            }

            if bytesUnpaddedSize == 1 {
                selectedData = Data(extractedIntBytes).prefix(0)
            } else if bytesUnpaddedSize == 2 {
                selectedData = Data(extractedIntBytes).prefix(1)
            } else if bytesUnpaddedSize == 3 {
                selectedData = Data(extractedIntBytes).prefix(2)
            } else if bytesUnpaddedSize == 4 {
                selectedData = Data(extractedIntBytes).prefix(3)
            } else {
                selectedData = Data(extractedIntBytes).prefix(4)
            }
            
            if bytesUnpaddedSize != 5 {
                //If the previous byte was larger than 170, increase the last byte of the selected data
                if Array(extractedIntBytes)[selectedData._bytes.count] > 170 {
                    selectedData.increaseLastByte()
                }
            }
            
            decodedData.append(selectedData)
        }
        self.append(decodedData)
    }
    
    private func charLookUp(charASCIIValue: UInt8) -> UInt8 {
        let charString = String(data: Data([charASCIIValue]), encoding: .utf8)!
        let char = Character(charString)
        if let index = encodeZSetString.firstIndex(of: char) {
            let distance = Int(encodeZSetString.distance(from: encodeZSetString.startIndex, to: index))
            return decodeZSet[distance]
        }
        return 0
    }
}

private extension Data {
    mutating func increaseLastByte() {
        if let lastByte = self.last {
            _ = self.popLast()
            if lastByte == 255 {
                increaseLastByte()
                self.append(0x00)
            } else {
                self.append(lastByte + 1)
            }
        }
    }
}
