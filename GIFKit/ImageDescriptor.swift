//
//  ImageDescriptor.swift
//  GIFKit
//
//  Created by Zach Waugh on 11/14/15.
//  Copyright © 2015 Zach Waugh. All rights reserved.
//

import Foundation

struct ImageDescriptor: CustomStringConvertible {
    let leftPosition: UInt16
    let topPosition: UInt16
    let width: UInt16
    let height: UInt16
    let packedFields: Byte
    
    var localColorTableFlag: Bool {
        return (packedFields & 0b10000000) != 0
    }
    
    var interlaceFlag: Bool {
        return (packedFields & 0b01000000) != 0
    }
    
    var sortFlag: Bool {
        return (packedFields & 0b00100000) != 0
    }
    
    var localColorTableSize: UInt8 {
        return packedFields & 0b00000111
    }
    
    var description: String {
        return "<ImageDescriptor leftPosition: \(leftPosition), topPosition: \(topPosition), width: \(width), height: \(height), packedFields: \(packedFields)>"
    }
    
    init(data: NSData) {
        var dataStream = DataStream(data: data)
        
        leftPosition = dataStream.takeUInt16()!
        topPosition = dataStream.takeUInt16()!
        width = dataStream.takeUInt16()!
        height = dataStream.takeUInt16()!
        packedFields = dataStream.takeByte()!
    }
}