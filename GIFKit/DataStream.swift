//
//  DataStream.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/5/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct DataStream {
    let data: NSData
    var position: Int = 0
    
    var bytesRemaining: Int {
        return data.length - position
    }
    
    var atEndOfStream: Bool {
        return position == data.length
    }
    
    init(data: NSData) {
        self.data = data
    }
    
    mutating func takeBool() -> Bool? {
        guard hasAvailableBytes(1) else {
            return nil
        }
        
        var value: Bool = false
        let length = sizeof(Bool)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    mutating func takeUInt8() -> UInt8? {
        guard hasAvailableBytes(1) else {
            return nil
        }
        
        var value: UInt8 = 0
        let length = sizeof(UInt8)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    mutating func takeUInt16() -> UInt16? {
        guard hasAvailableBytes(2) else {
            return nil
        }
        
        var value: UInt16 = 0
        let length = sizeof(UInt16)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    mutating func takeByte() -> Byte? {
        return takeUInt8()
    }

    mutating func takeBytes(length: Int) -> NSData? {
        guard let bytes = peekBytes(length) else {
            print("[gif decoder] invalid number of bytes!")
            return nil
        }
        
        position += length
        return bytes
    }
    
    mutating func takeBytes(length: Int) -> [Byte]? {
        guard hasAvailableBytes(length) else {
            print("[gif decoder] invalid number of bytes!")
            return nil
        }
        
        let bytes = nextBytes(length)
        position += length
        
        return bytes
    }
    
    // MARK: - Peek
    
    func peekBytes(length: Int) -> NSData? {
        return peekBytesWithRange(NSRange(location: position, length: length))
    }
    
    func peekBytesWithRange(range: NSRange) -> NSData? {
        guard range.location + range.length <= data.length else {
            print("[gif decoder] invalid range! \(range), bytes: \(data.length)")
            
            return nil
        }
        
        return data.subdataWithRange(range)
    }
    
    func nextBytes(count: Int) -> [Byte] {
        return nextBytes(NSRange(location: position, length: count))
    }
    
    func nextBytes(range: NSRange) -> [Byte] {
        var bytes = [Byte](count: range.length, repeatedValue: 0)
        data.getBytes(&bytes, range: range)
        return bytes
    }
    
    func hasAvailableBytes(count: Int) -> Bool {
        return bytesRemaining >= count
    }
}