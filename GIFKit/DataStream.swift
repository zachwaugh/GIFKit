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
    var atEndOfStream: Bool {
        return position == data.length
    }
    
    init(data: NSData) {
        self.data = data
    }
    
    mutating func takeBool() -> Bool? {
        var value: Bool = false
        let length = sizeof(Bool)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    mutating func takeUInt8() -> UInt8? {
        var value: UInt8 = 0
        let length = sizeof(UInt8)
        data.getBytes(&value, range: NSRange(location: position, length: length))
        position += length
        
        return value
    }
    
    mutating func takeUInt16() -> UInt16? {
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
}