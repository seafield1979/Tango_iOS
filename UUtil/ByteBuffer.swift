//
//  ByteBuffer.swift
//  TangoBook
//
//  Created by Shusuke Unno on 2017/09/01.
//  Copyright © 2017年 Sun Sun Soft. All rights reserved.
//
import Foundation

public typealias Byte = UInt8

extension UInt {
    func toInt() -> Int {
        return Int(bitPattern: self)
    }
}

extension UInt16 {
    func toInt16() -> Int16 {
        return Int16(bitPattern: self)
    }
    
}
extension UInt8 {
    func toInt8() -> Int8 {
        return Int8(bitPattern: self)
    }
}

extension Int {
    func toUInt() -> UInt {
        return UInt(bitPattern: self)
    }
}

extension Int16 {
    func toUInt16() -> UInt16 {
        return UInt16(bitPattern: self)
    }
}

extension Int8 {
    func toUInt8() -> UInt8 {
        return UInt8(bitPattern: self)
    }
}


public class ByteBuffer {
    // MARK: Constants
    private let BUF_SIZE = 1024
    private let DATE_SIZE = 7
    
    // MARK: Properties
    private var data : [Byte] = []
    private var pos : Int = 0
    private var maxSize : Int = 0
    
    // MARK: Accessor
    public func position() -> Int {
        return pos
    }
    
    // get byte array
    public func array() -> [Byte] {
        return data
    }
    
    public func clear() {
        self.data = []
        self.pos = 0
    }
    
    // set current read/write position
    public func setPosition(_ pos : Int) {
        if pos >= data.count {
            self.pos = 0
        } else {
            self.pos = pos
        }
    }
    
    // MARK: Initializer
    public init() {
        data = []
    }
    
    public init(buf : [Byte]) {
        self.data = buf
        pos = 0
    }
    
    public init(data : Data) {
        self.data = [Byte](data)
        pos = 0
    }
    
    // MARK: Public Methods
    
    // MARK: put
    
    // put Byte (unsigned 8bit) data
    public func put(_ b : Byte) {
        data.append(b)
    }
    
    public func putByte(_ b: Byte) {
        data.append(b)
    }
    
    // put signed 8bit data
    public func put(_ b : Int8) {
        data.append(Byte(b))
    }
    
    // put Short(signed 16bit) data
    public func putShort(_ s: Int16) {
        putUInt16(UInt16(s))
    }
    
    // put signed 16bit data
    public func putInt16(_ s : Int16) {
        putUInt16(UInt16(s))
    }
    
    // put unsigned 16bit data
    public func putUInt16(_ s : UInt16) {
        // big endian
        data.append(Byte(s >> 8))
        data.append(Byte(s & 0xff))
    }
    
    // put Int (signed 32bit) data
    public func putInt(_ i : Int) {
        putUInt32( UInt32(i) )
    }
    
    // put UInt (unsigned 32bit) data
    public func putUInt(_ i : UInt) {
        putUInt32(UInt32(i))
    }
    
    // put signed 32bit data
    public func putInt32(_ i : Int32) {
        putUInt32( UInt32(i) )
    }
    
    // put unsigned 32bit data
    public func putUInt32(_ i : UInt32) {
        // big endian
        data.append(Byte(i >> 24))
        data.append(Byte((i >> 16) & 0xff))
        data.append(Byte((i >> 8) & 0xff))
        data.append(Byte(i & 0xff))
    }
    
    public func put<T>( _ data : T) {
        let data = toByteArray(data)
        write(data)
    }
    
    public func putFloat( _ f : Float) {
        put(f)
    }
    
    public func putDouble( _ d : Double) {
        put(d)
    }
    
    // write Byte array data
    public func write( _ array : [Byte]) {
        for b in array {
            data.append(b)
        }
    }
    
    // write Byte array data
    //   with offset and length
    public func write(array : [Byte], off : Int, len : Int) {
        for i in 0 ..< len {
            data.append(array[off + i])
        }
    }
    
    public func write(repeating b: Byte, count : Int) {
        for _ in 0 ..< count {
            data.append(b)
        }
    }
    
    public func putDate(_ date : Date?) {
        if let _date = date {
            let cal : Calendar = Calendar(identifier: .gregorian)
            putShort( Int16(cal.component(.year, from: _date)))
            putByte( Byte(cal.component(.month, from: _date)))
            putByte( Byte(cal.component(.day, from: _date)))
            putByte( Byte(cal.component(.hour, from: _date)))
            putByte( Byte(cal.component(.minute, from: _date)))
            putByte( Byte(cal.component(.second, from: _date)))
        } else {
            // 全て0で書き込み
            write(repeating: 0, count: DATE_SIZE)
        }
    }
    
    // write string
    public func putString(_ str : String?) {
        if str == nil {
        } else {
            let data = [UInt8](str!.utf8)
            write(data)
        }
        putByte(0)      // last nil(=0)
    }
    
    // write string count (4byte) and string
    public func putStringWithSize(_ str : String?) {
        if str == nil {
            putInt(0)
        } else {
            let data = [UInt8](str!.utf8)
            putInt(data.count)
            write(data)
        }
    }
    
    // MARK: get
    // get Byte (= UInt8)
    public func getByte() -> Byte {
        return getUInt8()
    }
    
    // get UInt8
    public func getUInt8() -> UInt8 {
        let ret : Byte = data[pos]
        pos += 1
        return ret
    }
    
    // get Int8
    public func getInt8() -> Int8 {
        let ret : UInt8 = data[pos]
        pos += 1
        return ret.toInt8()
    }
    
    // get Short( = Int16)
    public func getShort() -> Int16 {
        return getInt16()
    }
    
    // get Int16
    public func getInt16() -> Int16 {
        let ret = UInt16((Int(data[pos]) << 8) | Int(data[pos + 1]))
        pos += 2
        return ret.toInt16()
    }
    
    // get UInt16
    public func getUInt16() -> UInt16 {
        let ret = UInt16((Int(data[pos]) << 8) | Int(data[pos + 1]))
        pos += 2
        return ret
    }
    
    // get Int (signed 32bit)
    public func getInt() -> Int {
        return getUInt().toInt()
    }
    
    // get UInt (unsigned 32bit)
    public func getUInt() -> UInt {
        let ret = UInt( (UInt(data[pos]) << 24) |
            (UInt(data[pos + 1]) << 16) |
            (UInt(data[pos + 2]) << 8) |
            (UInt(data[pos + 3])))
        pos += 4
        return ret
    }
    
    // get Float
    public func getFloat() -> Float {
        let _data = Array(data[pos..<pos+4])
        let ret : Float = fromByteArray(_data,  Float.self)
        pos += 4
        return ret
    }
    
    // get String (end of String is nil)
    public func getStringWithNil() -> String {
        var buf : [Byte] = []
        
        while data[pos] != 0 {
            buf.append( data[pos] )
            pos += 1
        }
        pos += 1    // add last nil
        
        if let string = String(data: Data(buf), encoding: .utf8) {
            return string
        }
        return ""
    }
    
    // get String (top 4byte is string size)
    public func getStringWithSize() -> String {
        let size = getInt()
        
        let buf = data[pos ..< pos+size]
        pos += size
        
        if let string = String(data: Data(buf), encoding: .utf8) {
            return string
        }
        return ""
    }
    
    // get Date
    public func getDate() -> Date {
        let year = Int(getShort())
        let month = Int(getByte())
        let day = Int(getByte())
        let hour = Int(getByte())
        let min = Int(getByte())
        let sec = Int(getByte())
        
        let calendar : Calendar = Calendar(identifier: .gregorian)
        let date : Date = (calendar.date(from: DateComponents(
            year: year, month: month, day: day, hour: hour, minute: min, second: sec)))!
        
        return date
    }
    
    public var description : String {
        get {
            let _data = data.prefix(pos)
            
            // convert 1byte data to string
            let stringArray = _data.map{String(format: "%02X", $0)}
            
            // joind with "-"
            let binaryString = stringArray.joined(separator: "-")
            
            return binaryString
        }
    }
    
    // MARK: Private Methods
    
    private func toByteArray<T>(_ value: T) -> [UInt8] {
        var value = value
        return withUnsafePointer(to: &value) {
            $0.withMemoryRebound(to: UInt8.self, capacity: MemoryLayout<T>.size) {
                Array(UnsafeBufferPointer(start: $0, count: MemoryLayout<T>.size))
            }
        }
    }
    
    private func fromByteArray<T>(_ value: [UInt8], _: T.Type) -> T {
        return value.withUnsafeBufferPointer {
            $0.baseAddress!.withMemoryRebound(to: T.self, capacity: 1) {
                $0.pointee
            }
        }
    }
}
